// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

/// iPhone、Watch App 和 Widget 共用的协议定义，不依赖任何界面框架。
enum WatchSyncProtocol {
    static let supportedSchemaVersions = 1...4

    /// 分页必须向前推进；当天与近 14 天回复必须一次完整交付。
    static func acceptsPagination(
        scope: WatchScheduleScope, offset: Int, nextOffset: Int, hasMore: Bool
    ) -> Bool {
        guard offset >= 0, nextOffset >= 0 else { return false }
        return !hasMore || (scope == .semester && nextOffset > offset)
    }

    enum Key {
        static let scheduleJSON = "scheduleJSON"
        static let requestSchedule = "requestSchedule"
        static let scope = "scheduleScope"
        static let offset = "scheduleOffset"
        static let nextOffset = "scheduleNextOffset"
        static let hasMore = "scheduleHasMore"
        static let preferredLanguage = "preferredLanguage"
        static let scheduleVersion = "scheduleVersion"
        static let scheduleUnchanged = "scheduleUnchanged"
        static let scheduleCleared = "scheduleCleared"
        static let signedOut = "signedOut"
        static let stateRevision = "stateRevision"
        static let accountGeneration = "accountGeneration"
        static let messageType = "messageType"
        static let refreshID = "refreshID"
        static let requestID = "requestID"
    }

    enum MessageType {
        static let request = "scheduleRequest"
        static let response = "scheduleResponse"
    }
}

/// 三阶段同步顺序与日期范围；本地化阶段标题由 Watch 模型提供。
enum WatchScheduleScope: String, CaseIterable {
    case today
    case fourteenDays
    case semester

    var next: Self? {
        switch self {
        case .today: .fourteenDays
        case .fourteenDays: .semester
        case .semester: nil
        }
    }
}

/// 协议值、BCP-47 标识与资源目录的唯一映射。显式文字脚本优先于地区。
enum WatchLanguage: String, CaseIterable {
    case simplifiedChinese = "zh_CN"
    case traditionalChinese = "zh_TW"
    case english = "en_US"

    init?(identifier: String?) {
        guard let identifier else { return nil }
        let parts = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_").lowercased().split(separator: "_")
        switch parts.first {
        case "en":
            self = .english
        case "zh":
            if parts.contains("hant") {
                self = .traditionalChinese
            } else if parts.contains("hans") {
                self = .simplifiedChinese
            } else {
                self = parts.contains(where: { $0 == "tw" || $0 == "hk" || $0 == "mo" })
                    ? .traditionalChinese : .simplifiedChinese
            }
        default:
            return nil
        }
    }

    var resourceName: String {
        switch self {
        case .simplifiedChinese: "zh-Hans"
        case .traditionalChinese: "zh-Hant"
        case .english: "en"
        }
    }

    var locale: Locale { Locale(identifier: resourceName) }
}

/// 时间戳和固定 24 小时显示共用一组纯函数，时区始终由调用者指定。
enum WatchScheduleDate {
    static func date(fromEpochMilliseconds value: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(value) / 1_000)
    }

    static func epochMilliseconds(for date: Date) -> Int64 {
        Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    static func calendar(offsetMinutes: Int?) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        // 先限制分钟数，避免协议中的异常整数在乘以 60 时溢出。
        if let offsetMinutes, (-1_080...1_080).contains(offsetMinutes),
           let timeZone = TimeZone(secondsFromGMT: offsetMinutes * 60) {
            calendar.timeZone = timeZone
        }
        return calendar
    }

    @available(iOS 15.0, watchOS 8.0, macOS 12.0, *)
    static func clockText(_ date: Date, timeZone: TimeZone = .current) -> String {
        date.formatted(
            Date.VerbatimFormatStyle(
                format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
                timeZone: timeZone,
                calendar: Calendar(identifier: .gregorian)
            )
        )
    }
}

enum WatchScheduleText {
    static func nonempty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }
        return value
    }

    static func singleLine(_ value: String?) -> String? {
        nonempty(value)?.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func compactLocation(_ value: String) -> String {
        value.replacingOccurrences(of: "信远", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
