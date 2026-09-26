// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import CryptoKit
import Foundation
import WatchConnectivity

/// 手机端支持的手表课表请求范围。
private typealias PhoneScheduleScope = WatchScheduleScope

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

    private typealias Key = WatchSyncProtocol.Key

    private static let persistedScheduleKey =
        "TraintimeWatchSemesterSchedule"
    private static let persistedLanguageKey =
        "TraintimeWatchPreferredLanguage"
    private static let persistedScheduleVersionKey =
        "TraintimeWatchSemesterScheduleVersion"
    private static let persistedRevisionKey = "TraintimeWatchStateRevision"
    private static let persistedGenerationKey = "TraintimeWatchAccountGeneration"
    private static let persistedSignedOutKey = "TraintimeWatchSignedOut"
    private static let scheduleVersionPrefix = "v1:"
    private static let semesterChunkSize = 50

    /// WCSession 回调和 Flutter Pigeon 调用可能来自不同线程。
    private let stateLock = NSLock()
    /// 生成回复、发布上下文和清理状态需要共享一次原子读取，防止新版本配上旧正文。
    /// 始终先获取此锁，再获取 stateLock；允许 clearSchedule 复用 syncSchedule。
    private let publicationLock = NSRecursiveLock()
    private var accountGeneration = UserDefaults.standard.string(forKey: persistedGenerationKey) ?? UUID().uuidString
    private var signedOut = UserDefaults.standard.bool(forKey: persistedSignedOutKey)
    private var latestScheduleJSON: String?
    /// 只在源 JSON 改变时解析；每个范围和分页复用这一份只读文档。
    private var latestScheduleDocument: PhoneScheduleDocument?
    private var latestScheduleVersion: String?
    private var latestPreferredLanguage: String?
    private var latestRevision = UserDefaults.standard.integer(forKey: persistedRevisionKey)
    /// 重试始终读取最新快照，只记录尚未成功发布的修订号，不另存一份正文。
    private var pendingScheduleRevision: Int?

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
        let document = storedJSON.flatMap(Self.parseScheduleDocument)
        latestScheduleJSON = storedJSON
        latestScheduleDocument = document
        latestScheduleVersion = document.flatMap(Self.scheduleVersion)
        latestPreferredLanguage = WatchLanguage(identifier: storedLanguage)?.rawValue
        super.init()
        latestRevision = max(latestRevision, Int(Date().timeIntervalSince1970 * 1_000))
        UserDefaults.standard.set(latestRevision, forKey: Self.persistedRevisionKey)
        UserDefaults.standard.set(accountGeneration, forKey: Self.persistedGenerationKey)

        if storedJSON != nil, document == nil {
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
        publicationLock.lock()
        defer { publicationLock.unlock() }
        let document = json.isEmpty ? nil : Self.parseScheduleDocument(json)
        guard json.isEmpty || document != nil else {
            log("Rejected invalid schedule JSON")
            return false
        }

        let result = storeLatestSchedule(json, document: document)
        guard result.changed || withStateLock({ pendingScheduleRevision != nil }) else {
            log("Schedule content unchanged; skipped republishing")
            return true
        }
        // 语义相同的重试继续发布已保存正文，保证分页与上下文的生成时间也一致。
        let publicationJSON = currentLatestScheduleJSON() ?? ""
        if result.changed { persistSchedule(publicationJSON, version: result.version) }

        guard WCSession.isSupported() else { return false }
        let session = WCSession.default
        guard session.activationState == .activated else {
            setPendingSchedule(revision: result.revision)
            configureAndActivate(session)
            return true
        }

        return updateApplicationContext(
            json: publicationJSON,
            version: result.version,
            revision: result.revision,
            session: session
        )
    }

    /// 清除手机持久化数据，并向手表发布空上下文。
    @discardableResult
    func clearSchedule(signedOut: Bool) -> Bool {
        publicationLock.lock()
        defer { publicationLock.unlock() }
        withStateLock {
            self.signedOut = signedOut
            accountGeneration = UUID().uuidString
            pendingScheduleRevision = nil
        }
        UserDefaults.standard.set(signedOut, forKey: Self.persistedSignedOutKey)
        UserDefaults.standard.set(accountGeneration, forKey: Self.persistedGenerationKey)
        if WCSession.isSupported() {
            for transfer in WCSession.default.outstandingUserInfoTransfers { transfer.cancel() }
        }
        return syncSchedule(json: "")
    }

    /// 保存手机当前实际生效的语言，并发布给配对 Apple Watch。
    ///
    /// Application Context 负责手表离线时的最终一致性；当手表 App 当前可达
    /// 时，再额外发送一次实时消息，使切换语言后无需重新打开手表应用。
    @discardableResult
    func syncPreferredLanguage(_ localeIdentifier: String) -> Bool {
        publicationLock.lock()
        defer { publicationLock.unlock() }
        guard let language = WatchLanguage(identifier: localeIdentifier)?.rawValue else {
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
        _ json: String,
        document: PhoneScheduleDocument?
    ) -> StoredPhoneScheduleResult {
        let version = document.flatMap(Self.scheduleVersion)
        return withStateLock {
            guard json.isEmpty || version != latestScheduleVersion else {
                return StoredPhoneScheduleResult(
                    version: version,
                    revision: latestRevision,
                    changed: false
                )
            }

            latestRevision = max(latestRevision + 1, Int(Date().timeIntervalSince1970 * 1_000))
            UserDefaults.standard.set(latestRevision, forKey: Self.persistedRevisionKey)
            if !json.isEmpty {
                signedOut = false
                UserDefaults.standard.set(false, forKey: Self.persistedSignedOutKey)
            }
            latestScheduleJSON = json.isEmpty ? nil : json
            latestScheduleDocument = document
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
    private func setPendingSchedule(revision: Int) {
        withStateLock {
            guard revision == latestRevision else { return }
            pendingScheduleRevision = revision
        }
    }

    /// 成功发送后只清除同一 revision，避免误删更新的数据。
    private func clearPendingSchedule(revision: Int) {
        withStateLock {
            guard pendingScheduleRevision == revision else { return }
            pendingScheduleRevision = nil
        }
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
        publicationLock.lock()
        defer { publicationLock.unlock() }
        guard withStateLock({ revision == latestRevision }) else { return true }
        let fallback = responsePayload(
            sourceJSON: json,
            scope: .fourteenDays,
            offset: 0,
            now: Date()
        )

        do {
            let context = applicationContext(for: fallback, scheduleVersion: version)
            try session.updateApplicationContext(context)
            if json.isEmpty, session.isReachable {
                session.sendMessage(context, replyHandler: nil, errorHandler: nil)
            }
            clearPendingSchedule(revision: revision)
            return true
        } catch {
            setPendingSchedule(revision: revision)
            log("Failed to update application context: \(error)")
            return false
        }
    }

    /// 生成 Application Context 使用的协议字典。
    private func applicationContext(
        for response: PhoneScheduleResponse,
        scheduleVersion: String?
    ) -> [String: Any] {
        responseDictionary([
            Key.scheduleJSON: response.json,
            Key.scope: PhoneScheduleScope.fourteenDays.rawValue,
        ], scheduleVersion: scheduleVersion)
    }

    /// 所有传输通道共用同一修订号和账户代次，语言更新也不能漏掉清空状态。
    private func stateMetadata() -> [String: Any] {
        withStateLock {
            [Key.stateRevision: latestRevision,
             Key.accountGeneration: accountGeneration,
             Key.scheduleCleared: latestScheduleJSON == nil,
             Key.signedOut: signedOut]
        }
    }

    /// 在不覆盖已有课表上下文的前提下更新语言，并在可达时即时通知手表。
    private func publishPreferredLanguage(using session: WCSession) -> Bool {
        publicationLock.lock()
        defer { publicationLock.unlock() }
        guard let language = currentPreferredLanguage() else {
            return false
        }

        let fallback = responsePayload(sourceJSON: currentLatestScheduleJSON() ?? "", scope: .fourteenDays, offset: 0, now: Date())
        var context = applicationContext(for: fallback, scheduleVersion: currentLatestScheduleVersion())
        context[Key.preferredLanguage] = language

        do {
            try session.updateApplicationContext(context)
        } catch {
            log("Failed to update language context: \(error)")
            return false
        }

        sendPreferredLanguage(language, through: session)
        return true
    }

    /// 课表上下文本身已包含语言；即时消息只用于缩短前台语言切换的等待。
    private func sendPreferredLanguage(_ language: String, through session: WCSession) {
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
    }

    /// 按请求范围过滤或分页，并更新响应中的覆盖区间。
    private func responsePayload(
        sourceJSON: String,
        scope: PhoneScheduleScope,
        offset: Int,
        now: Date
    ) -> PhoneScheduleResponse {
        // 值类型根字典在筛选时按需复制，已缓存的完整学期文档不会被修改。
        let cachedDocument = withStateLock {
            sourceJSON == latestScheduleJSON ? latestScheduleDocument : nil
        }
        guard !sourceJSON.isEmpty,
              var document = cachedDocument ?? Self.parseScheduleDocument(sourceJSON)
        else {
            return PhoneScheduleResponse(
                json: sourceJSON,
                nextOffset: 0,
                hasMore: false
            )
        }

        let calendar = WatchScheduleDate.calendar(
            offsetMinutes: document.root["timeZoneOffsetMinutes"] as? Int)
        document.root["sourceRevision"] = withStateLock { latestRevision }
        if document.root["semesterEndEpochMs"] == nil {
            document.root["semesterEndEpochMs"] = document.root["rangeEndEpochMs"]
        }
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
        let sourceStart = date(fromEpochMilliseconds: root["rangeStartEpochMs"]) ?? rangeStart
        let sourceEnd = date(fromEpochMilliseconds: root["rangeEndEpochMs"]) ?? rangeEnd
        let sourceExpiry = date(fromEpochMilliseconds: root["validThroughEpochMs"]) ?? sourceEnd
        let end = min(rangeEnd, sourceEnd)
        let start = min(max(rangeStart, sourceStart), end)
        root["rangeStartEpochMs"] = epochMilliseconds(for: start)
        root["rangeEndEpochMs"] = epochMilliseconds(for: end)
        root["validThroughEpochMs"] = epochMilliseconds(for: min(sourceExpiry, end))
    }

    /// 解析并验证课表根对象。
    private static func parseScheduleDocument(
        _ json: String
    ) -> PhoneScheduleDocument? {
        guard let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let root = object as? [String: Any],
              let courses = root["courses"] as? [[String: Any]],
              let schemaVersion = root["schemaVersion"] as? Int,
              WatchSyncProtocol.supportedSchemaVersions.contains(schemaVersion)
        else {
            return nil
        }
        return PhoneScheduleDocument(root: root, courses: courses)
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
    private static func scheduleVersion(for document: PhoneScheduleDocument) -> String? {
        var root = document.root
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
        return WatchScheduleDate.date(fromEpochMilliseconds: milliseconds)
    }

    /// 将 Date 转换为跨语言使用的毫秒时间戳。
    private func epochMilliseconds(for date: Date) -> Int64 {
        WatchScheduleDate.epochMilliseconds(for: date)
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

        publicationLock.lock()
        defer { publicationLock.unlock() }
        _ = updateApplicationContext(json: currentLatestScheduleJSON() ?? "",
                                     version: currentLatestScheduleVersion(),
                                     revision: withStateLock { latestRevision }, session: session)
        // 一次上下文已同时带上课表和语言，激活时无需再筛选、编码并发布同一范围。
        if let language = currentPreferredLanguage() {
            sendPreferredLanguage(language, through: session)
        }
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
        replyHandler(makeScheduleReply(for: message) ?? [:])
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
            self?.makeScheduleReply(for: request)
        }
    }

    /// 为实时消息和后台队列生成同一格式的课表回复。
    private func makeScheduleReply(
        for message: [String: Any]
    ) -> [String: Any]? {
        guard isScheduleRequest(message) else { return nil }
        publicationLock.lock()
        defer { publicationLock.unlock() }

        let scope = requestedScope(from: message)
        let sourceJSON = currentLatestScheduleJSON() ?? ""
        let scheduleVersion = currentLatestScheduleVersion()

        // 手表只上传它已经完整安装的版本号。相同则用一个轻量回复结束，
        // 不生成当天/14 天 JSON，更不会启动整学期分页传输。
        if let scheduleVersion,
           requestedScheduleVersion(from: message) == scheduleVersion,
           message[Key.accountGeneration] as? String == withStateLock({ accountGeneration })
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
        responseDictionary([
            Key.scheduleJSON: response.json,
            Key.scope: scope.rawValue,
            Key.nextOffset: response.nextOffset,
            Key.hasMore: response.hasMore,
        ], scheduleVersion: scheduleVersion)
    }

    /// 版本一致时返回的轻量确认，不包含课表 JSON。
    private func unchangedReplyDictionary(
        scope: PhoneScheduleScope,
        scheduleVersion: String
    ) -> [String: Any] {
        responseDictionary([
            Key.scope: scope.rawValue,
            Key.scheduleUnchanged: true,
            Key.hasMore: false,
            Key.nextOffset: 0,
        ], scheduleVersion: scheduleVersion)
    }

    /// 轻量确认、分页回复和 Application Context 共用版本、语言和账户状态封装。
    private func responseDictionary(
        _ body: [String: Any],
        scheduleVersion: String?
    ) -> [String: Any] {
        var reply = body
        if let scheduleVersion { reply[Key.scheduleVersion] = scheduleVersion }
        if let language = currentPreferredLanguage() {
            reply[Key.preferredLanguage] = language
        }
        reply.merge(stateMetadata()) { _, new in new }
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
        signedOut: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let accepted =
            PhoneWatchConnectivityManager.shared.clearSchedule(signedOut: signedOut)
        completion(.success(accepted))
    }
}
