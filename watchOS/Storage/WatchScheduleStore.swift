// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Combine
import Foundation

/// 手表界面的课表状态中心。
///
/// 该对象只在主线程修改可观察状态；同步过程收到的数据必须先完整解码，
/// 成功后才替换当前页面并写入缓存，因此半包或坏数据不会污染旧缓存。
@MainActor
final class WatchScheduleStore: ObservableObject {
    @Published private(set) var snapshot: WatchScheduleSnapshot?
    @Published private(set) var syncError: String?
    @Published private(set) var loadingScope: WatchScheduleScope?
    @Published private(set) var loadedScope: WatchScheduleScope?
    @Published private(set) var isRefreshing = false
    @Published private(set) var completedRefreshCount = 0

    /// 当前代码可读取的缓存结构版本。
    private static let supportedSchemaVersions = 1...4

    /// 缓存加载优先级与共享键集中定义，避免循环内重复拼装。
    private static let cacheDescriptors: [
        (scope: WatchScheduleScope, key: String)
    ] = [
        (.semester, WatchWidgetShared.semesterCacheKey),
        (.fourteenDays, WatchWidgetShared.fourteenDayCacheKey),
        (.today, WatchWidgetShared.todayCacheKey),
    ]

    /// 手表 App 自身的标准缓存，用于不依赖 Widget 的离线恢复。
    private let defaults: UserDefaults

    /// 每个同步阶段保留一份独立快照，方便按有效期回退。
    private var cachedSnapshots: [
        WatchScheduleScope: WatchScheduleSnapshot
    ] = [:]

    /// 整学期数据可能分多个消息传输，先按课程 ID 合并到临时缓冲区。
    private var semesterBuffer: [String: WatchCourse] = [:]

    /// 初始化时立即恢复缓存，让界面在连接手机之前就可以显示。
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadCachedSchedule()
    }

    /// 当前展示快照是否超过手机给出的有效期。
    var isStale: Bool {
        guard let snapshot else { return true }
        return isExpired(snapshot, comparedWith: Date())
    }

    /// 所有日程按开始时间稳定排序。
    var allCourses: [WatchCourse] {
        sortedCourses(snapshot?.courses ?? [])
    }

    /// 计算周次时使用的学期起点。
    ///
    /// 优先采用当前页面数据；若当前仅展示当天数据，则回退到完整学期缓存。
    var semesterStart: Date? {
        if let currentStart = snapshot?.semesterStart {
            return currentStart
        }
        if let semester = cachedSnapshots[.semester] {
            return semester.semesterStart ?? semester.rangeStart
        }
        guard loadedScope == .semester else { return nil }
        return snapshot?.rangeStart
    }

    /// 手机端同步过来的“当前周次”参考点。
    ///
    /// 周视图用生成日期和零基周次计算其他周，避免手表自行猜测开学日期。
    var synchronizedWeekReference: (
        date: Date,
        zeroBasedIndex: Int
    )? {
        if let snapshot,
           let index = snapshot.currentWeekIndex
        {
            return (snapshot.generatedAt, index)
        }
        if let semester = cachedSnapshots[.semester],
           let index = semester.currentWeekIndex
        {
            return (semester.generatedAt, index)
        }
        return nil
    }

    /// 返回“仍未结束的第一条日程”。
    ///
    /// 若当前正在上课，该课程也会被返回；这是“下一节课”页面同时承担
    /// “当前课程”展示的既有行为。
    var nextCourse: WatchCourse? {
        firstUnfinishedCourse(at: Date())
    }

    /// 返回指定自然日内开始的全部日程。
    func courses(on date: Date) -> [WatchCourse] {
        allCourses.filter {
            Calendar.current.isDate($0.startAt, inSameDayAs: date)
        }
    }

    /// 开始三阶段刷新，并保留当前可用页面内容。
    func beginRefresh() {
        clearSemesterBuffer(keepingCapacity: true)
        restoreCacheIfNeeded()
        updateRefreshState(
            isRefreshing: true,
            loadingScope: .today,
            error: nil
        )
    }

    /// 进入指定同步阶段。
    func setLoadingScope(_ scope: WatchScheduleScope) {
        updateRefreshState(
            isRefreshing: true,
            loadingScope: scope,
            error: nil
        )
    }

    /// 结束刷新；仅整个渐进流程完成时递增提示计数。
    func finishRefresh(showCompletion: Bool = false) {
        updateRefreshState(
            isRefreshing: false,
            loadingScope: nil,
            error: nil
        )
        if showCompletion {
            completedRefreshCount += 1
        }
    }

    /// 刷新失败时保留最后一份完整缓存，并向界面报告原因。
    func failRefresh(_ message: String) {
        restoreCacheIfNeeded()
        updateRefreshState(
            isRefreshing: false,
            loadingScope: nil,
            error: message
        )
    }

    /// 接收当天或近 14 天的一次完整 JSON 快照。
    ///
    /// 只有解码和 schema 校验都成功后，才会替换页面与对应缓存。
    @discardableResult
    func replaceSchedule(
        json: String,
        scope: WatchScheduleScope
    ) -> Bool {
        guard hasPayload(json) else {
            setMissingScheduleErrorIfNeeded()
            return false
        }

        do {
            let decoded = try decode(json)
            installCompletedSnapshot(
                decoded,
                json: json,
                scope: scope
            )
            return true
        } catch {
            syncError = String(localized: "课表数据无法读取")
            logDecodeFailure(error)
            return false
        }
    }

    /// 准备接收分块的整学期课表。
    func beginSemesterTransfer() {
        clearSemesterBuffer(keepingCapacity: true)
        setLoadingScope(.semester)
    }

    /// 合并一个学期分块，并在最后一块到达时一次性生成完整快照。
    ///
    /// 非最后一块只进入内存缓冲区，不会覆盖原有缓存；因此中途断线时，
    /// 手表仍然可以继续展示同步前的完整数据。
    @discardableResult
    func appendSemesterChunk(json: String, isFinal: Bool) -> Bool {
        guard hasPayload(json) else {
            failRefresh(String(localized: "手机端没有可用的学期课表"))
            return false
        }

        do {
            let chunk = try decode(json)
            mergeSemesterCourses(from: chunk)

            guard isFinal else { return true }
            try completeSemesterTransfer(using: chunk)
            return true
        } catch {
            clearSemesterBuffer(keepingCapacity: false)
            failRefresh(String(localized: "全学期课表无法合并"))
            logSemesterMergeFailure(error)
            return false
        }
    }

    /// 统一更新刷新状态，防止多个入口漏改某个属性。
    private func updateRefreshState(
        isRefreshing: Bool,
        loadingScope: WatchScheduleScope?,
        error: String?
    ) {
        self.isRefreshing = isRefreshing
        self.loadingScope = loadingScope
        syncError = error
    }

    /// 判断字符串是否包含可尝试解码的数据。
    private func hasPayload(_ json: String) -> Bool {
        !json.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 只有当前完全没有页面内容时才显示“手机暂无课表”。
    private func setMissingScheduleErrorIfNeeded() {
        guard snapshot == nil else { return }
        syncError = String(
            localized: "手机端暂无课表，请先在 iPhone 打开并刷新课表"
        )
    }

    /// 解码课表并验证数据结构版本。
    private func decode(_ json: String) throws -> WatchScheduleSnapshot {
        let decoded = try JSONDecoder().decode(
            WatchScheduleSnapshot.self,
            from: Data(json.utf8)
        )
        guard Self.supportedSchemaVersions.contains(
            decoded.schemaVersion
        ) else {
            throw ScheduleError.unsupportedSchema(decoded.schemaVersion)
        }
        return decoded
    }

    /// 将完整快照编码回共享缓存格式。
    private func encode(_ snapshot: WatchScheduleSnapshot) throws -> String {
        let data = try JSONEncoder().encode(snapshot)
        return String(decoding: data, as: UTF8.self)
    }

    /// 将新快照安装到页面、内存缓存、标准缓存和 App Group。
    private func installCompletedSnapshot(
        _ completedSnapshot: WatchScheduleSnapshot,
        json: String,
        scope: WatchScheduleScope
    ) {
        snapshot = completedSnapshot
        loadedScope = scope
        syncError = nil
        persistCompletedStage(
            snapshot: completedSnapshot,
            json: json,
            scope: scope
        )
    }

    /// 把分块中的日程按 ID 合并；后到的记录覆盖先到的同 ID 记录。
    private func mergeSemesterCourses(
        from chunk: WatchScheduleSnapshot
    ) {
        for course in chunk.courses {
            semesterBuffer[course.id] = course
        }
    }

    /// 使用最后一块的元数据与全部缓冲课程生成完整学期快照。
    private func makeCompletedSemesterSnapshot(
        metadata: WatchScheduleSnapshot
    ) -> WatchScheduleSnapshot {
        WatchScheduleSnapshot(
            schemaVersion: metadata.schemaVersion,
            generatedAtEpochMs: metadata.generatedAtEpochMs,
            semesterStartEpochMs: metadata.semesterStartEpochMs,
            currentWeekIndex: metadata.currentWeekIndex,
            validThroughEpochMs: metadata.validThroughEpochMs,
            rangeStartEpochMs: metadata.rangeStartEpochMs,
            rangeEndEpochMs: metadata.rangeEndEpochMs,
            timeZoneOffsetMinutes: metadata.timeZoneOffsetMinutes,
            reminderMinutes: metadata.reminderMinutes,
            courses: sortedCourses(Array(semesterBuffer.values))
        )
    }

    /// 原子完成学期传输：构造、编码、持久化成功后才替换当前页面。
    private func completeSemesterTransfer(
        using metadata: WatchScheduleSnapshot
    ) throws {
        let complete = makeCompletedSemesterSnapshot(metadata: metadata)
        let json = try encode(complete)

        installCompletedSnapshot(
            complete,
            json: json,
            scope: .semester
        )
        clearSemesterBuffer(keepingCapacity: false)
        finishRefresh(showCompletion: true)
    }

    /// 清空学期分块缓冲区。
    private func clearSemesterBuffer(keepingCapacity: Bool) {
        semesterBuffer.removeAll(keepingCapacity: keepingCapacity)
    }

    /// 从标准缓存和 App Group 中恢复每个阶段。
    ///
    /// 两个来源会分别尝试解码：标准缓存损坏时仍会继续读取共享缓存，
    /// 不再因为 `nil` 合并顺序而错误丢弃一份有效数据。
    private func loadCachedSchedule() {
        for descriptor in Self.cacheDescriptors {
            guard let cached = loadFirstValidCache(
                for: descriptor.scope,
                key: descriptor.key
            ) else {
                continue
            }

            cachedSnapshots[descriptor.scope] = cached.snapshot
            migrateToSharedCacheIfNeeded(
                json: cached.json,
                key: descriptor.key
            )
        }
        restoreCacheIfNeeded()
    }

    /// 依次尝试标准缓存与共享缓存，返回第一份能完整解码的数据。
    private func loadFirstValidCache(
        for scope: WatchScheduleScope,
        key: String
    ) -> (snapshot: WatchScheduleSnapshot, json: String)? {
        let candidates = [
            defaults.string(forKey: key),
            WatchWidgetShared.defaults?.string(forKey: key),
        ].compactMap { $0 }

        for json in candidates {
            do {
                return (try decode(json), json)
            } catch {
                logInvalidCache(scope: scope, error: error)
            }
        }
        return nil
    }

    /// 旧版本只有标准缓存时，将有效数据迁移到 Widget 可读的 App Group。
    private func migrateToSharedCacheIfNeeded(
        json: String,
        key: String
    ) {
        guard WatchWidgetShared.defaults?.string(forKey: key) == nil else {
            return
        }
        WatchWidgetShared.defaults?.set(json, forKey: key)
    }

    /// 写入一个已经完整完成的同步阶段。
    private func persistCompletedStage(
        snapshot: WatchScheduleSnapshot,
        json: String,
        scope: WatchScheduleScope
    ) {
        cachedSnapshots[scope] = snapshot
        defaults.set(json, forKey: WatchWidgetShared.cacheKey(for: scope))
        WatchWidgetShared.persist(json: json, scope: scope)
    }

    /// 当前没有页面数据时，恢复优先级最高的缓存。
    private func restoreCacheIfNeeded() {
        guard snapshot == nil,
              let cached = preferredCachedSnapshot()
        else {
            return
        }
        snapshot = cached.snapshot
        loadedScope = cached.scope
    }

    /// 优先选择尚未过期且覆盖范围最大的缓存。
    ///
    /// 全部过期时选择生成时间最新的一份，确保离线情况下仍有内容可看。
    private func preferredCachedSnapshot()
        -> (
            scope: WatchScheduleScope,
            snapshot: WatchScheduleSnapshot
        )?
    {
        let now = Date()
        for descriptor in Self.cacheDescriptors {
            if let cached = cachedSnapshots[descriptor.scope],
               !isExpired(cached, comparedWith: now)
            {
                return (descriptor.scope, cached)
            }
        }

        return cachedSnapshots.max {
            $0.value.generatedAt < $1.value.generatedAt
        }.map {
            (scope: $0.key, snapshot: $0.value)
        }
    }

    /// 判断快照是否已经过期。
    private func isExpired(
        _ snapshot: WatchScheduleSnapshot,
        comparedWith date: Date
    ) -> Bool {
        snapshot.validThrough < date
    }

    /// 对任意课程集合进行稳定排序。
    private func sortedCourses(
        _ courses: [WatchCourse]
    ) -> [WatchCourse] {
        courses.sorted {
            if $0.startAt == $1.startAt {
                return $0.endAt < $1.endAt
            }
            return $0.startAt < $1.startAt
        }
    }

    /// 从已排序日程中查找指定时刻后仍未结束的第一条。
    private func firstUnfinishedCourse(at date: Date) -> WatchCourse? {
        allCourses.first { $0.endAt > date }
    }

    /// 记录单阶段 JSON 解码失败。
    private func logDecodeFailure(_ error: Error) {
        NSLog("[WatchScheduleStore] Decode failed: \(error)")
    }

    /// 记录学期分块合并失败。
    private func logSemesterMergeFailure(_ error: Error) {
        NSLog("[WatchScheduleStore] Semester merge failed: \(error)")
    }

    /// 记录某个缓存来源无效；加载流程仍会继续尝试下一个来源。
    private func logInvalidCache(
        scope: WatchScheduleScope,
        error: Error
    ) {
        NSLog(
            "[WatchScheduleStore] Ignoring invalid \(scope.rawValue) cache: \(error)"
        )
    }
}

/// 本地数据校验错误。
private enum ScheduleError: LocalizedError {
    case unsupportedSchema(Int)

    /// 日志使用的可读错误说明。
    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version):
            "Unsupported schedule schema: \(version)"
        }
    }
}
