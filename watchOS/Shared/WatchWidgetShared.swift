// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WidgetKit

/// 手表 App 与 Widget Extension 的共享存储入口。
///
/// 两个进程不能直接共享 `UserDefaults.standard`，因此课表需要同时写入
/// App Group。所有缓存键统一定义在此处，防止 App 与小组件使用不同键名。
enum WatchWidgetShared {
    /// 必须与两个 target 的 entitlements 中的 App Group 完全一致。
    static let appGroupIdentifier = "group.xyz.superbart.xdyou"

    /// WidgetKit 注册和刷新时间线时使用的唯一类型标识。
    static let widgetKind = "TraintimeScheduleWidget"

    /// 三阶段同步各自独立保存，只有阶段完整完成后才覆盖对应缓存。
    static let semesterCacheKey = "watchScheduleSnapshot"
    static let fourteenDayCacheKey = "watchScheduleSnapshot.fourteenDays"
    static let todayCacheKey = "watchScheduleSnapshot.today"

    /// 小组件交互按钮使用的轻量状态键。
    static let selectedCurrentCourseKey = "watchWidget.selectedCurrentCourse"

    /// 手机同步过来的实际语言。App 与 Widget 共用，避免两个界面语言不一致。
    static let preferredLanguageKey = "watchPreferredLanguage"

    /// 当前代码可以读取的数据结构版本。
    private static let supportedSchemaVersions = 1...4

    /// 缓存选择优先级：完整学期 > 近 14 天 > 当天。
    ///
    /// 完整学期通常覆盖范围最大；若它已经过期，则继续尝试较小但更新的缓存。
    private static let scopesByPriority: [WatchScheduleScope] = [
        .semester,
        .fourteenDays,
        .today,
    ]

    /// App Group 对应的共享 UserDefaults。
    ///
    /// 返回可选值是因为签名或 entitlement 配置错误时系统可能无法创建 suite。
    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    /// 当前手机指定的语言；首次同步前回退到手表系统语言。
    static var preferredLanguageIdentifier: String {
        if let stored = defaults?.string(forKey: preferredLanguageKey),
           let normalized = normalizedPreferredLanguage(stored)
        {
            return normalized
        }

        let systemLanguage =
            Locale.preferredLanguages.first ?? Locale.current.identifier
        return normalizedPreferredLanguage(systemLanguage) ?? "zh_CN"
    }

    /// SwiftUI 和 String Catalog 使用的标准 Locale。
    static var preferredLocale: Locale {
        locale(for: preferredLanguageIdentifier)
    }

    /// 将不同平台的语言代码收敛为与手机设置一致的三个协议值。
    static func normalizedPreferredLanguage(_ value: String) -> String? {
        let normalized = value
            .replacingOccurrences(of: "-", with: "_")
            .lowercased()

        if normalized.hasPrefix("zh_hant")
            || normalized.hasPrefix("zh_tw")
            || normalized.hasPrefix("zh_hk")
            || normalized.hasPrefix("zh_mo")
        {
            return "zh_TW"
        }
        if normalized.hasPrefix("zh") {
            return "zh_CN"
        }
        if normalized.hasPrefix("en") {
            return "en_US"
        }
        return nil
    }

    /// 将协议语言值映射为 String Catalog 能正确匹配的 Locale。
    static func locale(for languageIdentifier: String) -> Locale {
        switch normalizedPreferredLanguage(languageIdentifier) {
        case "zh_TW":
            Locale(identifier: "zh-Hant")
        case "en_US":
            Locale(identifier: "en")
        default:
            Locale(identifier: "zh-Hans")
        }
    }

    /// 保存新语言并刷新 Widget；返回值表示语言是否实际发生变化。
    @discardableResult
    static func updatePreferredLanguage(_ value: String) -> Bool {
        guard let normalized = normalizedPreferredLanguage(value),
              let defaults
        else {
            return false
        }

        let changed =
            defaults.string(forKey: preferredLanguageKey) != normalized
        defaults.set(normalized, forKey: preferredLanguageKey)
        if changed {
            reloadWidgetTimelines()
        }
        return changed
    }

    /// 将同步范围映射为稳定的缓存键。
    static func cacheKey(for scope: WatchScheduleScope) -> String {
        switch scope {
        case .today:
            todayCacheKey
        case .fourteenDays:
            fourteenDayCacheKey
        case .semester:
            semesterCacheKey
        }
    }

    /// 保存一个已经完整完成的同步阶段，并通知所有同类组件刷新。
    ///
    /// 调用方必须确保 JSON 已经完成解码校验；该函数只负责跨进程持久化。
    static func persist(json: String, scope: WatchScheduleScope) {
        guard let defaults else { return }
        persist(
            json: json,
            key: cacheKey(for: scope),
            defaults: defaults
        )
        reloadWidgetTimelines()
    }

    /// 读取当前最适合展示的课表快照。
    ///
    /// 先按覆盖范围寻找尚未过期的缓存；若全部过期，则退回到生成时间最新的
    /// 快照，使手机离线时手表仍能展示最后一次同步的数据。
    static func loadPreferredSnapshot(
        now: Date = Date()
    ) -> WatchScheduleSnapshot? {
        guard let defaults else { return nil }

        let cachedSnapshots = loadCachedSnapshots(from: defaults)
        return firstUnexpiredSnapshot(
            in: cachedSnapshots,
            now: now
        ) ?? newestSnapshot(in: cachedSnapshots)
    }

    /// 写入一个键值。单独封装后便于未来替换为文件级原子存储。
    private static func persist(
        json: String,
        key: String,
        defaults: UserDefaults
    ) {
        defaults.set(json, forKey: key)
    }

    /// 逐个读取三种缓存，坏数据只影响自身，不会阻断其他阶段的回退。
    private static func loadCachedSnapshots(
        from defaults: UserDefaults
    ) -> [WatchScheduleScope: WatchScheduleSnapshot] {
        var snapshots = [WatchScheduleScope: WatchScheduleSnapshot]()

        for scope in scopesByPriority {
            guard let json = defaults.string(forKey: cacheKey(for: scope)),
                  let snapshot = decodeSnapshot(from: json)
            else {
                continue
            }
            snapshots[scope] = snapshot
        }
        return snapshots
    }

    /// 解码并校验 schema，避免扩展因未来不兼容数据而崩溃。
    private static func decodeSnapshot(
        from json: String
    ) -> WatchScheduleSnapshot? {
        guard let snapshot = try? JSONDecoder().decode(
            WatchScheduleSnapshot.self,
            from: Data(json.utf8)
        ),
            supportedSchemaVersions.contains(snapshot.schemaVersion)
        else {
            return nil
        }
        return snapshot
    }

    /// 按范围优先级返回第一份仍有效的缓存。
    private static func firstUnexpiredSnapshot(
        in snapshots: [WatchScheduleScope: WatchScheduleSnapshot],
        now: Date
    ) -> WatchScheduleSnapshot? {
        for scope in scopesByPriority {
            if let snapshot = snapshots[scope],
               snapshot.validThrough >= now
            {
                return snapshot
            }
        }
        return nil
    }

    /// 所有缓存均过期时，选择最后生成的一份作为离线回退。
    private static func newestSnapshot(
        in snapshots: [WatchScheduleScope: WatchScheduleSnapshot]
    ) -> WatchScheduleSnapshot? {
        snapshots.values.max {
            $0.generatedAt < $1.generatedAt
        }
    }

    /// 只刷新本项目的课程组件，避免影响其他 Widget。
    private static func reloadWidgetTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}

/// 使用手机同步语言从指定 `.lproj` 中读取显式字符串。
///
/// `String(localized:locale:)` 的 `locale` 主要参与插值格式化，Bundle 仍可能
/// 按手表系统首选语言选择资源。因此手机设置为英语、而手表系统是中文时，
/// 目录标题仍会返回中文。这里显式选择 `en.lproj` 或 `zh-Hant.lproj`；
/// 简体中文是 String Catalog 的源语言，直接返回中文键即可。
func watchLocalizedString(_ key: String) -> String {
    let resourceName: String
    switch WatchWidgetShared.preferredLanguageIdentifier {
    case "en_US":
        resourceName = "en"
    case "zh_TW":
        resourceName = "zh-Hant"
    default:
        return key
    }

    guard let path = Bundle.main.path(
        forResource: resourceName,
        ofType: "lproj"
    ),
        let localizationBundle = Bundle(path: path)
    else {
        return key
    }
    return localizationBundle.localizedString(
        forKey: key,
        value: key,
        table: nil
    )
}
