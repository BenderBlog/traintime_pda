// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import CryptoKit
import Foundation
import WatchConnectivity

/// 手机端支持的手表课表请求范围。
private enum PhoneScheduleScope: String {
    case today
    case fourteenDays
    case semester
}

/// 经过范围过滤或学期分页后的回复内容。
private struct PhoneScheduleResponse {
    let json: String
    let nextOffset: Int
    let hasMore: Bool
}

/// 已解析的 JSON 根对象和课程数组。
private struct PhoneScheduleDocument {
    var root: [String: Any]
    let courses: [[String: Any]]
}

/// 尚未成功写入 WCSession Application Context 的课表。
private struct PendingPhoneSchedule {
    let json: String
    let version: String
    let revision: Int
}

/// 更新手机本地完整课表后的判定结果。
private struct StoredPhoneScheduleResult {
    let version: String?
    let revision: Int
    let changed: Bool
}

/// iPhone 端的 WatchConnectivity 管理器。
///
/// Flutter 负责生成完整学期 JSON；该管理器负责持久化、维护最近上下文，
/// 并按手表请求生成“当天、近 14 天、整学期分页”三种响应。
final class PhoneWatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = PhoneWatchConnectivityManager()

    /// 双端通信协议键，必须与 watchOS 管理器保持一致。
    private enum Key {
        static let scheduleJSON = "scheduleJSON"
        static let requestSchedule = "requestSchedule"
        static let scope = "scheduleScope"
        static let offset = "scheduleOffset"
        static let nextOffset = "scheduleNextOffset"
        static let hasMore = "scheduleHasMore"
        static let preferredLanguage = "preferredLanguage"
        static let scheduleVersion = "scheduleVersion"
        static let scheduleUnchanged = "scheduleUnchanged"
    }

    private static let persistedScheduleKey =
        "TraintimeWatchSemesterSchedule"
    private static let persistedLanguageKey =
        "TraintimeWatchPreferredLanguage"
    private static let persistedScheduleVersionKey =
        "TraintimeWatchSemesterScheduleVersion"
    private static let scheduleVersionPrefix = "v1:"
    private static let semesterChunkSize = 50

    /// WCSession 回调和 Flutter Pigeon 调用可能来自不同线程。
    private let stateLock = NSLock()
    private var latestScheduleJSON: String?
    private var latestScheduleVersion: String?
    private var latestPreferredLanguage: String?
    private var latestRevision = 0
    private var pendingSchedule: PendingPhoneSchedule?

    /// 把无法实时送达的手表请求转换为系统后台队列回复。
    private let queuedScheduleTransport =
        PhoneWatchQueuedScheduleTransport()

    /// 启动时恢复上次完整学期缓存；坏缓存会被清理。
    private override init() {
        let storedJSON = UserDefaults.standard.string(
            forKey: Self.persistedScheduleKey
        )
        let storedLanguage = UserDefaults.standard.string(
            forKey: Self.persistedLanguageKey
        )
        latestScheduleJSON = storedJSON
        latestScheduleVersion = Self.scheduleVersion(for: storedJSON)
        latestPreferredLanguage = Self.normalizedLanguage(storedLanguage)
        super.init()

        if let storedJSON, !isValidScheduleJSON(storedJSON) {
            latestScheduleJSON = nil
            latestScheduleVersion = nil
            UserDefaults.standard.removeObject(
                forKey: Self.persistedScheduleKey
            )
            UserDefaults.standard.removeObject(
                forKey: Self.persistedScheduleVersionKey
            )
            log("Removed invalid persisted schedule")
        } else if let latestScheduleVersion {
            UserDefaults.standard.set(
                latestScheduleVersion,
                forKey: Self.persistedScheduleVersionKey
            )
        }
    }

    /// 激活与配对 Apple Watch 的系统会话。
    func activate() {
        guard WCSession.isSupported() else { return }
        configureAndActivate(WCSession.default)
    }

    /// 接收 Flutter 生成的新学期快照。
    ///
    /// 空字符串代表清空；非空字符串必须包含合法 JSON 根对象和课程数组。
    @discardableResult
    func syncSchedule(json: String) -> Bool {
        guard json.isEmpty || isValidScheduleJSON(json) else {
            log("Rejected invalid schedule JSON")
            return false
        }

        let result = storeLatestSchedule(json)
        guard result.changed else {
            log("Schedule content unchanged; skipped republishing")
            return true
        }
        persistSchedule(json, version: result.version)

        guard WCSession.isSupported() else { return false }
        let session = WCSession.default
        guard session.activationState == .activated else {
            if let version = result.version {
                setPendingSchedule(
                    json: json,
                    version: version,
                    revision: result.revision
                )
            }
            configureAndActivate(session)
            return true
        }

        return updateApplicationContext(
            json: json,
            version: result.version,
            revision: result.revision,
            session: session
        )
    }

    /// 清除手机持久化数据，并向手表发布空上下文。
    @discardableResult
    func clearSchedule() -> Bool {
        syncSchedule(json: "")
    }

    /// 保存手机当前实际生效的语言，并发布给配对 Apple Watch。
    ///
    /// Application Context 负责手表离线时的最终一致性；当手表 App 当前可达
    /// 时，再额外发送一次实时消息，使切换语言后无需重新打开手表应用。
    @discardableResult
    func syncPreferredLanguage(_ localeIdentifier: String) -> Bool {
        guard let language = Self.normalizedLanguage(localeIdentifier) else {
            log("Rejected unsupported language: \(localeIdentifier)")
            return false
        }

        withStateLock {
            latestPreferredLanguage = language
        }
        UserDefaults.standard.set(
            language,
            forKey: Self.persistedLanguageKey
        )

        guard WCSession.isSupported() else { return false }
        let session = WCSession.default
        guard session.activationState == .activated else {
            configureAndActivate(session)
            return true
        }
        return publishPreferredLanguage(using: session)
    }

    /// 配置代理并激活 WCSession。
    private func configureAndActivate(_ session: WCSession) {
        session.delegate = self
        session.activate()
    }

    /// 比较完整课表语义版本，仅在内容变化时更新内存状态。
    ///
    /// `generatedAtEpochMs` 不参与版本计算，因此 App 重启或响应式 effect
    /// 重建同一份课表时不会触发无意义的 WatchConnectivity 传输。
    private func storeLatestSchedule(
        _ json: String
    ) -> StoredPhoneScheduleResult {
        let version = Self.scheduleVersion(for: json)
        return withStateLock {
            guard version != latestScheduleVersion else {
                return StoredPhoneScheduleResult(
                    version: version,
                    revision: latestRevision,
                    changed: false
                )
            }

            latestRevision += 1
            latestScheduleJSON = json.isEmpty ? nil : json
            latestScheduleVersion = version
            return StoredPhoneScheduleResult(
                version: version,
                revision: latestRevision,
                changed: true
            )
        }
    }

    /// 把完整学期快照及其稳定版本号持久化到手机本地。
    private func persistSchedule(_ json: String, version: String?) {
        if json.isEmpty {
            UserDefaults.standard.removeObject(
                forKey: Self.persistedScheduleKey
            )
            UserDefaults.standard.removeObject(
                forKey: Self.persistedScheduleVersionKey
            )
        } else {
            UserDefaults.standard.set(
                json,
                forKey: Self.persistedScheduleKey
            )
            UserDefaults.standard.set(
                version,
                forKey: Self.persistedScheduleVersionKey
            )
        }
    }

    /// 只记录仍属于最新 revision 的待发送数据。
    private func setPendingSchedule(
        json: String,
        version: String,
        revision: Int
    ) {
        withStateLock {
            guard revision == latestRevision else { return }
            pendingSchedule = PendingPhoneSchedule(
                json: json,
                version: version,
                revision: revision
            )
        }
    }

    /// 成功发送后只清除同一 revision，避免误删更新的数据。
    private func clearPendingSchedule(revision: Int) {
        withStateLock {
            guard pendingSchedule?.revision == revision else { return }
            pendingSchedule = nil
        }
    }

    /// 读取当前待发送数据的线程安全副本。
    private func currentPendingSchedule() -> PendingPhoneSchedule? {
        withStateLock { pendingSchedule }
    }

    /// 读取最新完整学期 JSON 的线程安全副本。
    private func currentLatestScheduleJSON() -> String? {
        withStateLock { latestScheduleJSON }
    }

    /// 读取手机当前完整学期课表的稳定版本号。
    private func currentLatestScheduleVersion() -> String? {
        withStateLock { latestScheduleVersion }
    }

    /// 读取当前语言的线程安全副本。
    private func currentPreferredLanguage() -> String? {
        withStateLock { latestPreferredLanguage }
    }

    /// 使用 NSLock 保护闭包内的共享状态访问。
    private func withStateLock<T>(_ body: () -> T) -> T {
        stateLock.lock()
        defer { stateLock.unlock() }
        return body()
    }

    /// 发布一个轻量的近 14 天 Application Context。
    ///
    /// Application Context 是实时消息不可达时的离线回退，因此不发布整学期
    /// 大 JSON；手表主动打开后再通过 sendMessage 分页请求全部数据。
    private func updateApplicationContext(
        json: String,
        version: String?,
        revision: Int,
        session: WCSession
    ) -> Bool {
        let fallback = responsePayload(
            sourceJSON: json,
            scope: .fourteenDays,
            offset: 0,
            now: Date()
        )

        do {
            try session.updateApplicationContext(
                applicationContext(
                    for: fallback,
                    scheduleVersion: version
                )
            )
            clearPendingSchedule(revision: revision)
            return true
        } catch {
            if let version {
                setPendingSchedule(
                    json: json,
                    version: version,
                    revision: revision
                )
            }
            log("Failed to update application context: \(error)")
            return false
        }
    }

    /// 生成 Application Context 使用的协议字典。
    private func applicationContext(
        for response: PhoneScheduleResponse,
        scheduleVersion: String?
    ) -> [String: Any] {
        var context: [String: Any] = [
            Key.scheduleJSON: response.json,
            Key.scope: PhoneScheduleScope.fourteenDays.rawValue,
        ]
        if let scheduleVersion {
            context[Key.scheduleVersion] = scheduleVersion
        }
        if let language = currentPreferredLanguage() {
            context[Key.preferredLanguage] = language
        }
        return context
    }

    /// 在不覆盖已有课表上下文的前提下更新语言，并在可达时即时通知手表。
    private func publishPreferredLanguage(using session: WCSession) -> Bool {
        guard let language = currentPreferredLanguage() else {
            return false
        }

        var context = session.applicationContext
        if context[Key.scheduleJSON] == nil,
           let json = currentLatestScheduleJSON()
        {
            let fallback = responsePayload(
                sourceJSON: json,
                scope: .fourteenDays,
                offset: 0,
                now: Date()
            )
            context = applicationContext(
                for: fallback,
                scheduleVersion: currentLatestScheduleVersion()
            )
        }
        context[Key.preferredLanguage] = language

        do {
            try session.updateApplicationContext(context)
        } catch {
            log("Failed to update language context: \(error)")
            return false
        }

        if session.isReachable {
            session.sendMessage(
                [Key.preferredLanguage: language],
                replyHandler: nil
            ) { [weak self] error in
                self?.log(
                    "Failed to send immediate language update: \(error)"
                )
            }
        }
        return true
    }

    /// 按请求范围过滤或分页，并更新响应中的覆盖区间。
    private func responsePayload(
        sourceJSON: String,
        scope: PhoneScheduleScope,
        offset: Int,
        now: Date
    ) -> PhoneScheduleResponse {
        guard !sourceJSON.isEmpty,
              var document = parseScheduleDocument(sourceJSON)
        else {
            return PhoneScheduleResponse(
                json: sourceJSON,
                nextOffset: 0,
                hasMore: false
            )
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let selection = selectCourses(
            document: document,
            scope: scope,
            offset: offset,
            today: today,
            calendar: calendar
        )

        document.root["courses"] = selection.courses
        updateRangeMetadata(
            root: &document.root,
            rangeStart: selection.rangeStart,
            rangeEnd: selection.rangeEnd
        )

        guard let filteredJSON = serializeScheduleRoot(document.root) else {
            return PhoneScheduleResponse(
                json: sourceJSON,
                nextOffset: 0,
                hasMore: false
            )
        }
        return PhoneScheduleResponse(
            json: filteredJSON,
            nextOffset: selection.nextOffset,
            hasMore: selection.hasMore
        )
    }

    /// 课程筛选结果，包含同步范围和分页信息。
    private typealias CourseSelection = (
        courses: [[String: Any]],
        rangeStart: Date,
        rangeEnd: Date,
        nextOffset: Int,
        hasMore: Bool
    )

    /// 根据 scope 选择课程。
    private func selectCourses(
        document: PhoneScheduleDocument,
        scope: PhoneScheduleScope,
        offset: Int,
        today: Date,
        calendar: Calendar
    ) -> CourseSelection {
        switch scope {
        case .today:
            return dateRangeSelection(
                courses: document.courses,
                start: today,
                days: 1,
                calendar: calendar
            )
        case .fourteenDays:
            return dateRangeSelection(
                courses: document.courses,
                start: today,
                days: 14,
                calendar: calendar
            )
        case .semester:
            return semesterSelection(
                document: document,
                offset: offset,
                fallbackDate: today
            )
        }
    }

    /// 生成当天或近 14 天的左闭右开范围选择。
    private func dateRangeSelection(
        courses: [[String: Any]],
        start: Date,
        days: Int,
        calendar: Calendar
    ) -> CourseSelection {
        let end = calendar.date(
            byAdding: .day,
            value: days,
            to: start
        ) ?? start
        return (
            courses: coursesInRange(courses, from: start, through: end),
            rangeStart: start,
            rangeEnd: end,
            nextOffset: 0,
            hasMore: false
        )
    }

    /// 生成整学期的一个分页。
    private func semesterSelection(
        document: PhoneScheduleDocument,
        offset: Int,
        fallbackDate: Date
    ) -> CourseSelection {
        let safeOffset = max(0, min(offset, document.courses.count))
        let endOffset = min(
            safeOffset + Self.semesterChunkSize,
            document.courses.count
        )
        let rangeStart = date(
            fromEpochMilliseconds: document.root["rangeStartEpochMs"]
        ) ?? fallbackDate
        let rangeEnd = date(
            fromEpochMilliseconds: document.root["rangeEndEpochMs"]
        ) ?? fallbackDate

        return (
            courses: Array(document.courses[safeOffset..<endOffset]),
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            nextOffset: endOffset,
            hasMore: endOffset < document.courses.count
        )
    }

    /// 过滤开始时间落在 `[start, end)` 范围中的课程。
    private func coursesInRange(
        _ courses: [[String: Any]],
        from start: Date,
        through end: Date
    ) -> [[String: Any]] {
        let startMilliseconds = epochMilliseconds(for: start)
        let endMilliseconds = epochMilliseconds(for: end)

        return courses.filter { course in
            guard let value = epochValue(
                course["startAtEpochMs"]
            ) else {
                return false
            }
            return value >= startMilliseconds && value < endMilliseconds
        }
    }

    /// 将筛选后的范围写回 JSON 元数据。
    private func updateRangeMetadata(
        root: inout [String: Any],
        rangeStart: Date,
        rangeEnd: Date
    ) {
        root["rangeStartEpochMs"] = epochMilliseconds(for: rangeStart)
        root["rangeEndEpochMs"] = epochMilliseconds(for: rangeEnd)
        root["validThroughEpochMs"] = epochMilliseconds(for: rangeEnd)
    }

    /// 解析并验证课表根对象。
    private func parseScheduleDocument(
        _ json: String
    ) -> PhoneScheduleDocument? {
        guard let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let root = object as? [String: Any],
              let courses = root["courses"] as? [[String: Any]],
              root["schemaVersion"] is NSNumber
        else {
            return nil
        }
        return PhoneScheduleDocument(root: root, courses: courses)
    }

    /// 判断 Flutter 传入的 JSON 是否具备最低协议结构。
    private func isValidScheduleJSON(_ json: String) -> Bool {
        parseScheduleDocument(json) != nil
    }

    /// 把更新后的根对象重新编码为 JSON。
    private func serializeScheduleRoot(
        _ root: [String: Any]
    ) -> String? {
        guard JSONSerialization.isValidJSONObject(root),
              let data = try? JSONSerialization.data(
                  withJSONObject: root
              )
        else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// 为完整学期课表生成跨启动稳定的语义版本号。
    ///
    /// JSON 使用排序键重新编码后计算 SHA-256；唯一被剔除的字段是每次构建
    /// 都变化、但不影响展示内容的 `generatedAtEpochMs`。课程、考试、实验、
    /// 周次、提醒、颜色或时间等任何实际字段变化都会产生新版本。
    private static func scheduleVersion(for json: String?) -> String? {
        guard let json,
              !json.isEmpty,
              let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              var root = object as? [String: Any],
              root["courses"] is [[String: Any]]
        else {
            return nil
        }

        root.removeValue(forKey: "generatedAtEpochMs")
        guard JSONSerialization.isValidJSONObject(root),
              let canonicalData = try? JSONSerialization.data(
                  withJSONObject: root,
                  options: [.sortedKeys]
              )
        else {
            return nil
        }

        let digest = SHA256.hash(data: canonicalData)
        let hexadecimal = digest.map {
            String(format: "%02x", $0)
        }.joined()
        return scheduleVersionPrefix + hexadecimal
    }

    /// 从 JSON 的 NSNumber 字段读取毫秒时间戳。
    private func epochValue(_ value: Any?) -> Int64? {
        (value as? NSNumber)?.int64Value
    }

    /// 将毫秒时间戳转换为 Date。
    private func date(fromEpochMilliseconds value: Any?) -> Date? {
        guard let milliseconds = epochValue(value) else { return nil }
        return Date(
            timeIntervalSince1970: TimeInterval(milliseconds) / 1_000
        )
    }

    /// 将 Date 转换为跨语言使用的毫秒时间戳。
    private func epochMilliseconds(for date: Date) -> Int64 {
        Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    /// 把 Flutter、iOS 系统和历史版本可能产生的语言格式收敛为协议值。
    private static func normalizedLanguage(_ value: String?) -> String? {
        guard let value else { return nil }
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

    /// 从多个持久化来源选择当前完整学期 JSON。
    private func sourceScheduleJSON(
        session: WCSession
    ) -> String {
        currentLatestScheduleJSON()
            ?? UserDefaults.standard.string(
                forKey: Self.persistedScheduleKey
            )
            ?? session.applicationContext[Key.scheduleJSON] as? String
            ?? ""
    }

    /// WCSession 激活完成后重试最新待发送数据。
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            log("Activation failed: \(error)")
            return
        }
        guard activationState == .activated else { return }

        if let pending = currentPendingSchedule() {
            _ = updateApplicationContext(
                json: pending.json,
                version: pending.version,
                revision: pending.revision,
                session: session
            )
        }
        _ = publishPreferredLanguage(using: session)
    }

    /// iOS 会话切换阶段无需额外处理。
    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// 会话停用后按 Apple 建议重新激活。
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// 响应手表主动发起的分阶段课表请求。
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        replyHandler(makeScheduleReply(for: message, session: session) ?? [:])
    }

    /// 响应手表通过 `transferUserInfo` 排队发送的后台请求。
    ///
    /// 队列适配器只负责关联请求和回传；回复正文仍走与实时消息完全相同的
    /// 版本比较、范围筛选和学期分页逻辑，避免两条传输路径产生数据差异。
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        queuedScheduleTransport.handle(
            userInfo,
            through: session
        ) { [weak self] request in
            self?.makeScheduleReply(for: request, session: session)
        }
    }

    /// 为实时消息和后台队列生成同一格式的课表回复。
    private func makeScheduleReply(
        for message: [String: Any],
        session: WCSession
    ) -> [String: Any]? {
        guard isScheduleRequest(message) else { return nil }

        let scope = requestedScope(from: message)
        let sourceJSON = sourceScheduleJSON(session: session)
        let scheduleVersion =
            currentLatestScheduleVersion()
            ?? Self.scheduleVersion(for: sourceJSON)

        // 手表只上传它已经完整安装的版本号。相同则用一个轻量回复结束，
        // 不生成当天/14 天 JSON，更不会启动整学期分页传输。
        if let scheduleVersion,
           requestedScheduleVersion(from: message) == scheduleVersion
        {
            return unchangedReplyDictionary(
                scope: scope,
                scheduleVersion: scheduleVersion
            )
        }

        let response = responsePayload(
            sourceJSON: sourceJSON,
            scope: scope,
            offset: requestedOffset(from: message),
            now: Date()
        )
        return replyDictionary(
            response: response,
            scope: scope,
            scheduleVersion: scheduleVersion
        )
    }

    /// 判断消息是否为课表请求。
    private func isScheduleRequest(_ message: [String: Any]) -> Bool {
        message[Key.requestSchedule] as? Bool == true
    }

    /// 解析请求范围，无法识别时默认提供近 14 天数据。
    private func requestedScope(
        from message: [String: Any]
    ) -> PhoneScheduleScope {
        PhoneScheduleScope(
            rawValue: message[Key.scope] as? String ?? ""
        ) ?? .fourteenDays
    }

    /// 解析分页偏移，缺失时从第一页开始。
    private func requestedOffset(
        from message: [String: Any]
    ) -> Int {
        message[Key.offset] as? Int ?? 0
    }

    /// 读取手表已经完整安装的课表版本；请求本身不携带任何课表正文。
    private func requestedScheduleVersion(
        from message: [String: Any]
    ) -> String? {
        message[Key.scheduleVersion] as? String
    }

    /// 生成返回给手表的协议字典。
    private func replyDictionary(
        response: PhoneScheduleResponse,
        scope: PhoneScheduleScope,
        scheduleVersion: String?
    ) -> [String: Any] {
        var reply: [String: Any] = [
            Key.scheduleJSON: response.json,
            Key.scope: scope.rawValue,
            Key.nextOffset: response.nextOffset,
            Key.hasMore: response.hasMore,
        ]
        if let scheduleVersion {
            reply[Key.scheduleVersion] = scheduleVersion
        }
        if let language = currentPreferredLanguage() {
            reply[Key.preferredLanguage] = language
        }
        return reply
    }

    /// 版本一致时返回的轻量确认，不包含课表 JSON。
    private func unchangedReplyDictionary(
        scope: PhoneScheduleScope,
        scheduleVersion: String
    ) -> [String: Any] {
        var reply: [String: Any] = [
            Key.scope: scope.rawValue,
            Key.scheduleVersion: scheduleVersion,
            Key.scheduleUnchanged: true,
            Key.hasMore: false,
            Key.nextOffset: 0,
        ]
        if let language = currentPreferredLanguage() {
            reply[Key.preferredLanguage] = language
        }
        return reply
    }

    /// 统一输出 WatchConnectivity 日志。
    private func log(_ message: String) {
        NSLog("[WatchConnectivity] \(message)")
    }
}

/// Pigeon Host API 的薄适配层。
///
/// 这里只负责把异步完成回调桥接到管理器，业务逻辑全部留在可审计的管理器中。
final class WatchSyncApiImplementation: WatchSyncSwiftApi {
    /// 保存手机实际生效的语言并通知手表。
    func syncPreferredLanguage(
        localeIdentifier: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let accepted =
            PhoneWatchConnectivityManager.shared.syncPreferredLanguage(
                localeIdentifier
            )
        completion(.success(accepted))
    }

    /// 保存并发布新课表。
    func syncSchedule(
        payload: WatchSchedulePayload,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let accepted = PhoneWatchConnectivityManager.shared.syncSchedule(
            json: payload.json
        )
        completion(.success(accepted))
    }

    /// 清除手机和手表课表。
    func clearSchedule(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let accepted =
            PhoneWatchConnectivityManager.shared.clearSchedule()
        completion(.success(accepted))
    }
}
