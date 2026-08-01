// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Combine
import Foundation

/// 课程列表预先生成的自然日分组。
///
/// 这份索引在课表安装时一次性构造，进入课程列表页面时只负责渲染和定位，
/// 避免第一次切换页面时才对整学期课程做分组、排序而产生明显卡顿。
struct WatchCourseDayGroup: Identifiable {
    let date: Date
    let courses: [WatchCourse]

    var id: Date { date }
}

/// 一份已解码缓存及其同步范围。
///
/// 使用命名类型代替散落的元组后，缓存恢复策略可以拆成多个职责单一的筛选
/// 函数，同时避免调用处混淆 `scope` 和 `snapshot` 的位置。
private struct CachedScheduleSelection {
    let scope: WatchScheduleScope
    let snapshot: WatchScheduleSnapshot
}

/// Watch 各课表视图共用的派生缓存格式。
///
/// 这里保存的是“课程 ID 如何排序、如何按自然日分组、月视图五段标记引用哪
/// 门课”，而不是 SwiftUI 视图或位图。课表语义版本仍只由 iPhone 计算；
/// Watch 端的来源字段只用于确认落盘索引与当前原始快照属于同一次安装，避免
/// App 在写盘中途退出后错误复用一份旧索引。
private enum WatchScheduleRenderCacheLayout {
    static let schemaVersion = 1
    static let periodRanges = [
        1...2,
        3...4,
        5...6,
        7...8,
        9...10,
    ]
}

/// 派生缓存对应的原始快照身份；不参与课表是否变化的业务判断。
private struct PersistedScheduleRenderSource: Codable, Equatable {
    let snapshotSchemaVersion: Int
    let generatedAtEpochMs: Int64
    let rangeStartEpochMs: Int64?
    let rangeEndEpochMs: Int64?
    let courseCount: Int
}

/// 单个自然日的持久化索引。
private struct PersistedScheduleRenderDay: Codable {
    let dayStartEpochMs: Int64
    let courseIDs: [String]
    /// 固定对应 1–2、3–4、5–6、7–8、9–10 节。
    let periodCourseIDs: [String?]
}

/// 日、周、月和课程列表共同复用的轻量派生缓存。
private struct PersistedScheduleRenderCache: Codable {
    let schemaVersion: Int
    let source: PersistedScheduleRenderSource
    let sortedCourseIDs: [String]
    let days: [PersistedScheduleRenderDay]
    let courseListReferenceDayEpochMs: Int64
    let courseListInitialDayEpochMs: Int64?
}

/// 通过完整性校验后，可直接安装到内存中的派生索引。
private struct RestoredScheduleRenderIndex {
    let coursesByID: [String: WatchCourse]
    let coursesByDay: [Date: [WatchCourse]]
    let periodCourseIDsByDay: [Date: [String?]]
}

/// 课程列表启动位置及其是否需要在稍后重新落盘。
private struct RestoredCourseListPosition {
    let date: Date?
    let needsPersistence: Bool
}

/// 手表界面的课表状态中心。
///
/// 该对象只在主线程修改可观察状态；同步过程收到的数据必须先完整解码，
/// 成功后才替换当前页面并写入缓存，因此半包或坏数据不会污染旧缓存。
@MainActor
final class WatchScheduleStore: ObservableObject {
    @Published private(set) var snapshot: WatchScheduleSnapshot?
    @Published private(set) var preferredLanguageIdentifier: String
    @Published private(set) var syncError: String?
    @Published private(set) var loadingScope: WatchScheduleScope?
    @Published private(set) var loadedScope: WatchScheduleScope?
    @Published private(set) var isRefreshing = false
    @Published private(set) var completedRefreshCount = 0
    @Published private(set) var isAwaitingLaunchSyncReply = false
    @Published private(set) var launchSyncTimedOut = false
    @Published private(set) var courseListGroups: [WatchCourseDayGroup] = []
    @Published private(set) var courseListInitialDate: Date?
    /// 派生索引安装后递增；月视图据此只刷新当前三页的颜色标记。
    @Published private(set) var renderCacheRevision = 0
    private(set) var installedScheduleVersion: String?

    /// 整学期缓存不存在时，短范围缓存的恢复优先级。
    private static let partialCacheScopes = Array(
        WatchWidgetShared.scheduleCacheScopesByPriority.dropFirst()
    )

    /// 手表 App 自身的标准缓存，用于不依赖 Widget 的离线恢复。
    private let defaults: UserDefaults

    /// 每个同步阶段保留一份独立快照，方便按有效期回退。
    private var cachedSnapshots: [
        WatchScheduleScope: WatchScheduleSnapshot
    ] = [:]

    /// 整学期数据可能分多个消息传输，先按课程 ID 合并到临时缓冲区。
    private var semesterBuffer: [String: WatchCourse] = [:]

    /// 当前页面使用的稳定排序结果，随快照安装同步更新。
    private var sortedVisibleCourses: [WatchCourse] = []

    /// 日视图三页预加载使用的自然日索引。
    ///
    /// 连续翻页期间会同时读取前一天、当天和后一天。提前建立索引后无需在
    /// 每一帧对整学期课表执行三次过滤，真机上的页面换底会更稳定。
    private var coursesByDay: [Date: [WatchCourse]] = [:]

    /// 课程 ID 到当前快照模型的映射；恢复持久化索引时无需复制完整课程。
    private var coursesByID: [String: WatchCourse] = [:]

    /// 月视图每个自然日的五段课程 ID，绘制时再读取课程颜色。
    private var periodCourseIDsByDay: [Date: [String?]] = [:]

    /// 月视图的日期模型和课程标记由独立缓存管理，Store 不持有其组装细节。
    private var monthCalendarCache = MonthCalendarCache()

    /// 启动时若派生缓存缺失，先在内存中建立以保证页面可用；待手机回复或
    /// 三秒启动等待结束后再落盘，避免与即将到达的新课表重复写入。
    private var renderCacheNeedsPersistence = false

    /// 初始化时立即恢复缓存，让界面在连接手机之前就可以显示。
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        installedScheduleVersion = defaults.string(
            forKey: WatchPersistentCacheKey.installedSemesterVersion
        )
        preferredLanguageIdentifier =
            WatchWidgetShared.preferredLanguageIdentifier
        loadCachedSchedule()
        discardOrphanedScheduleVersionIfNeeded()
        // 有缓存时，索引安装流程已经完成预热；空课表仍在根视图出现前准备
        // 日期网格。条件判断避免启动时对同一个三页窗口重复组装。
        if snapshot == nil {
            prewarmMonthCalendar(around: Date())
        }
    }

    /// SwiftUI 根视图使用的语言环境；修改后整棵视图树会立即重新本地化。
    var preferredLocale: Locale {
        WatchWidgetShared.locale(for: preferredLanguageIdentifier)
    }

    /// 安装手机同步过来的语言，并写入 App Group 供 Widget 使用。
    @discardableResult
    func setPreferredLanguage(_ value: String) -> Bool {
        guard let normalized =
            WatchWidgetShared.normalizedPreferredLanguage(value)
        else {
            return false
        }

        let changed = preferredLanguageIdentifier != normalized
        _ = WatchWidgetShared.updatePreferredLanguage(normalized)
        preferredLanguageIdentifier = normalized
        if changed {
            // 错误文本是在产生时本地化的；语言切换后清除旧文本，空状态会用
            // 新 Locale 重新生成默认提示，避免页面同时出现两种语言。
            syncError = nil
        }
        return changed
    }

    /// 当前展示快照是否超过手机给出的有效期。
    var isStale: Bool {
        guard let snapshot else { return true }
        return isExpired(snapshot, comparedWith: Date())
    }

    /// 所有日程按开始时间稳定排序。
    var allCourses: [WatchCourse] {
        sortedVisibleCourses
    }

    /// 本地持久化缓存中是否至少包含一条本学期日程。
    ///
    /// “已成功解码一个快照”不等于“已有课表”：手机可能同步过覆盖范围与
    /// 周次等元数据、但 `courses` 为空的快照。启动超时提示必须检查实际
    /// 课程、考试或实验记录，避免空快照被误报为“已加载缓存课表”。历史
    /// 日程仍属于本学期课表，因此不按结束时间或有效期排除。整学期缓存一旦
    /// 存在便是权威结果：若它为空，不得再被旧的当天/14 天缓存误判为有课。
    var hasCachedScheduleContent: Bool {
        if let semester = cachedSnapshots[.semester] {
            return containsScheduleContent(semester)
        }
        return cachedSnapshots.values.contains(where: containsScheduleContent)
    }

    /// 空快照仍可携带周次与范围元数据，但不能代表存在可展示课表。
    private func containsScheduleContent(
        _ snapshot: WatchScheduleSnapshot
    ) -> Bool {
        !snapshot.courses.isEmpty
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

    /// 与手机课表 `0 ..< semesterLength` 完全一致的第一周开始日期。
    ///
    /// 渐进同步的当天/14 天阶段范围较短，不能拿来限制周视图；这里只读取
    /// 已完整落盘的整学期快照，避免同步过程中错误缩小可浏览范围。
    var semesterRangeStart: Date? {
        semesterNavigationSnapshot?.rangeStart
    }

    /// 整学期范围的右开边界，即手机最后一周结束后的日期。
    var semesterRangeEnd: Date? {
        semesterNavigationSnapshot?.rangeEnd
    }

    /// 周视图日期限制所使用的完整学期快照。
    private var semesterNavigationSnapshot: WatchScheduleSnapshot? {
        if let semester = cachedSnapshots[.semester] {
            return semester
        }
        guard loadedScope == .semester else { return nil }
        return snapshot
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
        coursesByDay[Calendar.current.startOfDay(for: date)] ?? []
    }

    /// 返回从指定日期开始若干自然日内的课程，供周视图预加载相邻页面。
    ///
    /// 只访问至多 `dayCount` 个字典槽位，不随整学期课程数量增长；表冠每次
    /// 改变横向偏移时，前、中、后三个周页面都可以稳定地复用这份索引。
    func courses(startingAt date: Date, dayCount: Int) -> [WatchCourse] {
        guard dayCount > 0 else { return [] }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return (0..<dayCount).flatMap { dayOffset in
            let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: start
            ) ?? start
            return coursesByDay[day] ?? []
        }
    }

    /// 提前生成目标月及前后两月的网格和五段日程标记。
    ///
    /// App 初始化、课表索引替换以及日视图日期变化都会调用该入口。月份页
    /// 因此不需要在第一次显示时遍历日期或解析课程颜色。
    func prewarmMonthCalendar(around date: Date) {
        monthCalendarCache.prewarm(
            around: date,
            periodCourseIDsByDay: periodCourseIDsByDay,
            coursesByID: coursesByID
        )
    }

    /// 返回月份页面可以直接安装的三页原子窗口。
    func preparedMonthCalendarWindow(
        centeredOn date: Date
    ) -> MonthCalendarWindow {
        monthCalendarCache.window(
            centeredOn: date,
            periodCourseIDsByDay: periodCourseIDsByDay,
            coursesByID: coursesByID
        )
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

    /// 每次 App 打开或重新回到前台时开始等待手机的实时回复。
    ///
    /// 该状态与普通课表刷新分离：同步失败或超时都不能清空现有快照。这样
    /// 有缓存时页面会继续可用，只显示一条紧凑提醒；完全没有缓存时才由
    /// 根视图切换到“打开手机”的整页引导。
    func beginLaunchSyncAttempt() {
        isAwaitingLaunchSyncReply = true
        launchSyncTimedOut = false
    }

    /// 收到本轮手机实时通信后清除离线提示。
    ///
    /// 这里只表示手机已经响应；当天、14 天、学期三个阶段仍由各自的
    /// 安装流程决定何时替换页面以及何时结束刷新动画。
    func receiveLaunchSyncReply() {
        isAwaitingLaunchSyncReply = false
        launchSyncTimedOut = false
    }

    /// 启动请求在限定时间内没有收到手机实时回复。
    ///
    /// 不调用 `failRefresh`，也不修改 `snapshot`，以保证已有缓存原样保留。
    func markLaunchSyncTimedOut() {
        isAwaitingLaunchSyncReply = false
        launchSyncTimedOut = true
        persistRenderCacheIfNeeded()
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

    /// 手机确认版本未变化时恢复已安装整学期缓存并结束刷新。
    ///
    /// 通常页面本来就是该缓存；额外恢复用于处理一个极端竞态：同步过程中
    /// 手机课表先变化、随后又恢复为手表已安装版本，避免保留先前局部阶段
    /// 已经合入页面的临时内容。
    func finishRefreshWithoutScheduleChanges() {
        if let semester = cachedSnapshots[.semester] {
            snapshot = semester
            loadedScope = .semester
            syncError = nil
            prepareVisibleScheduleIndex(
                preferringPersistentCache: true,
                persistIfRebuilt: true
            )
        }
        persistRenderCacheIfNeeded()
        finishRefresh(showCompletion: true)
    }

    /// 刷新失败时保留最后一份完整缓存，并向界面报告原因。
    func failRefresh(_ message: String) {
        clearSemesterBuffer(keepingCapacity: false)
        restoreCacheIfNeeded()
        persistRenderCacheIfNeeded()
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
            installProgressiveSnapshot(
                decoded,
                json: json,
                scope: scope
            )
            return true
        } catch {
            syncError = watchLocalizedString("课表数据无法读取")
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
    func appendSemesterChunk(
        json: String,
        isFinal: Bool,
        scheduleVersion: String?
    ) -> Bool {
        guard hasPayload(json) else {
            failRefresh(watchLocalizedString("手机端没有可用的学期课表"))
            return false
        }

        do {
            let chunk = try decode(json)
            mergeSemesterCourses(from: chunk)

            guard isFinal else { return true }
            try completeSemesterTransfer(
                using: chunk,
                scheduleVersion: scheduleVersion
            )
            return true
        } catch {
            clearSemesterBuffer(keepingCapacity: false)
            failRefresh(watchLocalizedString("全学期课表无法合并"))
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
        syncError = watchLocalizedString(
            "手机端暂无课表，请先在 iPhone 打开并刷新课表"
        )
    }

    /// 解码课表并验证数据结构版本。
    private func decode(_ json: String) throws -> WatchScheduleSnapshot {
        let decoded = try WatchCacheCoding.decode(
            WatchScheduleSnapshot.self,
            fromJSON: json
        )
        guard WatchWidgetShared.supportedScheduleSchemaVersions.contains(
            decoded.schemaVersion
        ) else {
            throw ScheduleError.unsupportedSchema(decoded.schemaVersion)
        }
        return decoded
    }

    /// 将完整快照编码回共享缓存格式。
    private func encode(_ snapshot: WatchScheduleSnapshot) throws -> String {
        try WatchCacheCoding.encodeJSON(snapshot)
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
        rebuildVisibleScheduleIndex(persisting: true)
        persistCompletedStage(
            snapshot: completedSnapshot,
            json: json,
            scope: scope
        )
    }

    /// 安装渐进同步阶段，同时保留该阶段日期范围外的现有课程。
    ///
    /// 当天和 14 天阶段完成后会立刻反映到页面，但只替换新快照明确覆盖的
    /// `[rangeStart, rangeEnd)` 日期范围。整学期阶段是一份完整数据，直接
    /// 整体替换。这样既能逐步显示新内容，又不会让其他日期突然消失。
    private func installProgressiveSnapshot(
        _ completedSnapshot: WatchScheduleSnapshot,
        json: String,
        scope: WatchScheduleScope
    ) {
        guard scope != .semester, snapshot != nil else {
            installCompletedSnapshot(
                completedSnapshot,
                json: json,
                scope: scope
            )
            return
        }

        snapshot = mergeVisibleSnapshot(
            replacing: completedSnapshot
        )
        syncError = nil
        rebuildVisibleScheduleIndex(persisting: true)

        // 阶段缓存保存手机发来的原始范围，而不是混合后的页面快照，便于
        // Widget 与离线回退准确识别该缓存实际覆盖的日期。
        persistCompletedStage(
            snapshot: completedSnapshot,
            json: json,
            scope: scope
        )
        if loadedScope == nil {
            loadedScope = scope
        }
    }

    /// 将局部快照合入当前页面，范围内以新数据为准，范围外完整保留。
    private func mergeVisibleSnapshot(
        replacing incoming: WatchScheduleSnapshot
    ) -> WatchScheduleSnapshot {
        guard let current = snapshot else { return incoming }

        let lowerBound = incoming.rangeStart
        let upperBound = incoming.rangeEnd
        var mergedByID: [String: WatchCourse] = [:]

        for course in current.courses
        where course.startAt < lowerBound || course.startAt >= upperBound {
            mergedByID[course.id] = course
        }
        for course in incoming.courses {
            mergedByID[course.id] = course
        }

        return WatchScheduleSnapshot(
            schemaVersion: max(
                current.schemaVersion,
                incoming.schemaVersion
            ),
            generatedAtEpochMs: incoming.generatedAtEpochMs,
            semesterStartEpochMs:
                incoming.semesterStartEpochMs
                ?? current.semesterStartEpochMs,
            currentWeekIndex:
                incoming.currentWeekIndex
                ?? current.currentWeekIndex,
            validThroughEpochMs: max(
                current.validThroughEpochMs,
                incoming.validThroughEpochMs
            ),
            rangeStartEpochMs: minimumEpoch(
                current.rangeStartEpochMs,
                incoming.rangeStartEpochMs
            ),
            rangeEndEpochMs: maximumEpoch(
                current.rangeEndEpochMs,
                incoming.rangeEndEpochMs
            ),
            timeZoneOffsetMinutes: incoming.timeZoneOffsetMinutes,
            reminderMinutes: incoming.reminderMinutes,
            courses: sortedCourses(Array(mergedByID.values))
        )
    }

    /// 返回两个可选毫秒时间戳中的较小值。
    private func minimumEpoch(_ lhs: Int64?, _ rhs: Int64?) -> Int64? {
        switch (lhs, rhs) {
        case let (lhs?, rhs?): min(lhs, rhs)
        case let (lhs?, nil): lhs
        case let (nil, rhs?): rhs
        case (nil, nil): nil
        }
    }

    /// 返回两个可选毫秒时间戳中的较大值。
    private func maximumEpoch(_ lhs: Int64?, _ rhs: Int64?) -> Int64? {
        switch (lhs, rhs) {
        case let (lhs?, rhs?): max(lhs, rhs)
        case let (lhs?, nil): lhs
        case let (nil, rhs?): rhs
        case (nil, nil): nil
        }
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
        using metadata: WatchScheduleSnapshot,
        scheduleVersion: String?
    ) throws {
        let complete = makeCompletedSemesterSnapshot(metadata: metadata)
        let json = try encode(complete)

        installProgressiveSnapshot(
            complete,
            json: json,
            scope: .semester
        )
        installCompletedScheduleVersion(scheduleVersion)
        clearSemesterBuffer(keepingCapacity: false)
        finishRefresh(showCompletion: true)
    }

    /// 只有整学期全部分页安装成功后才确认版本。
    ///
    /// 当天或 14 天阶段不能写入版本，否则手表可能只有局部缓存，却在下一次
    /// 请求中误报“已完整安装”。缺少版本号代表旧协议，主动清除旧版本以便
    /// 下次仍执行正常三阶段同步。
    private func installCompletedScheduleVersion(_ value: String?) {
        guard let value, !value.isEmpty else {
            installedScheduleVersion = nil
            defaults.removeObject(
                forKey: WatchPersistentCacheKey.installedSemesterVersion
            )
            return
        }

        installedScheduleVersion = value
        defaults.set(
            value,
            forKey: WatchPersistentCacheKey.installedSemesterVersion
        )
    }

    /// 完整学期缓存损坏或被清除时同步清除孤立版本号。
    ///
    /// 否则手表可能只有一个版本号却没有对应课表，向手机误报“无需更新”后
    /// 永远停留在空页面。
    private func discardOrphanedScheduleVersionIfNeeded() {
        guard installedScheduleVersion != nil,
              cachedSnapshots[.semester] == nil
        else {
            return
        }
        installedScheduleVersion = nil
        defaults.removeObject(
            forKey: WatchPersistentCacheKey.installedSemesterVersion
        )
    }

    /// 清空学期分块缓冲区。
    private func clearSemesterBuffer(keepingCapacity: Bool) {
        semesterBuffer.removeAll(keepingCapacity: keepingCapacity)
    }

    /// 从标准缓存和 App Group 中恢复每个阶段。
    ///
    /// 两个来源会分别尝试解码；任一来源损坏时仍会继续检查另一份缓存。
    private func loadCachedSchedule() {
        for scope in WatchWidgetShared.scheduleCacheScopesByPriority {
            let key = WatchWidgetShared.cacheKey(for: scope)
            guard let cached = loadFirstValidCache(
                for: scope,
                key: key
            ) else {
                continue
            }

            cachedSnapshots[scope] = cached.snapshot
            migrateToSharedCacheIfNeeded(
                json: cached.json,
                key: key
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
        prepareVisibleScheduleIndex(
            preferringPersistentCache: true,
            persistIfRebuilt: false
        )
    }

    /// 优先恢复权威的整学期缓存，历史课程也必须保持可浏览。
    ///
    /// 只有尚未完成过整学期同步时，才在当天/14 天缓存中选择。此时优先
    /// 非空快照，防止一个较新的空当天快照把实际有内容的缓存遮住。
    private func preferredCachedSnapshot() -> CachedScheduleSelection? {
        if let semester = cachedSelection(for: .semester) {
            return semester
        }

        let now = Date()
        if let fresh = firstFreshPartialCache(comparedWith: now) {
            return fresh
        }
        if let nonempty = newestPartialCache(requiringContent: true) {
            return nonempty
        }
        return newestPartialCache(requiringContent: false)
    }

    /// 返回指定阶段的命名缓存对象。
    private func cachedSelection(
        for scope: WatchScheduleScope
    ) -> CachedScheduleSelection? {
        cachedSnapshots[scope].map {
            CachedScheduleSelection(scope: scope, snapshot: $0)
        }
    }

    /// 按 14 天、当天的既定优先级寻找仍有效且包含日程的缓存。
    private func firstFreshPartialCache(
        comparedWith date: Date
    ) -> CachedScheduleSelection? {
        for scope in Self.partialCacheScopes {
            guard let selection = cachedSelection(for: scope),
                  containsScheduleContent(selection.snapshot),
                  !isExpired(selection.snapshot, comparedWith: date)
            else {
                continue
            }
            return selection
        }
        return nil
    }

    /// 从短范围缓存中选择生成时间最新的一份。
    private func newestPartialCache(
        requiringContent: Bool
    ) -> CachedScheduleSelection? {
        Self.partialCacheScopes
            .compactMap { cachedSelection(for: $0) }
            .filter {
                !requiringContent || containsScheduleContent($0.snapshot)
            }
            .max {
                $0.snapshot.generatedAt < $1.snapshot.generatedAt
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

    /// 优先恢复持久化派生缓存；缺失或校验失败时才遍历原始课表重建。
    private func prepareVisibleScheduleIndex(
        preferringPersistentCache: Bool,
        persistIfRebuilt: Bool
    ) {
        if preferringPersistentCache, restorePersistedRenderCache() {
            return
        }

        rebuildVisibleScheduleIndex(persisting: persistIfRebuilt)
        if !persistIfRebuilt {
            renderCacheNeedsPersistence = true
        }
    }

    /// 预生成全部视图共用的派生数据。
    ///
    /// 只有手机实际发来某个新同步阶段，或本地派生缓存不可用时才执行。排序、
    /// 按日分组、课程列表定位及月视图五段课程 ID 在一次遍历内完成，进入任一
    /// 页面时都只做字典读取。
    private func rebuildVisibleScheduleIndex(persisting: Bool) {
        let sorted = sortedCourses(snapshot?.courses ?? [])
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sorted) {
            calendar.startOfDay(for: $0.startAt)
        }
        let groups = makeCourseDayGroups(from: grouped)

        installVisibleScheduleIndex(
            sorted: sorted,
            grouped: grouped,
            groups: groups,
            initialDate: preferredCourseListDate(
                in: groups,
                calendar: calendar
            )
        )

        if persisting {
            persistRenderCache()
        } else {
            renderCacheNeedsPersistence = true
        }
    }

    /// 把已计算或已恢复的索引一次性安装到所有视图读取的内存状态。
    private func installVisibleScheduleIndex(
        sorted: [WatchCourse],
        grouped: [Date: [WatchCourse]],
        groups: [WatchCourseDayGroup],
        initialDate: Date?,
        restoredCourseMap: [String: WatchCourse]? = nil,
        restoredPeriodCourseIDs: [Date: [String?]]? = nil
    ) {
        sortedVisibleCourses = sorted
        coursesByDay = grouped
        courseListGroups = groups
        courseListInitialDate = initialDate

        if let restoredCourseMap {
            coursesByID = restoredCourseMap
        } else {
            var byID: [String: WatchCourse] = [:]
            byID.reserveCapacity(sorted.count)
            for course in sorted {
                byID[course.id] = course
            }
            coursesByID = byID
        }
        periodCourseIDsByDay = restoredPeriodCourseIDs
            ?? makePeriodCourseIDsByDay(from: grouped)
        // 日期格模型可以继续复用，但颜色标记必须与新课表索引一起失效。
        monthCalendarCache.invalidateScheduleMarkers()
        prewarmMonthCalendar(around: Date())
        renderCacheRevision &+= 1
    }

    /// 按自然日生成课程列表分组，统一新建和恢复两条路径的顺序。
    private func makeCourseDayGroups(
        from grouped: [Date: [WatchCourse]]
    ) -> [WatchCourseDayGroup] {
        grouped.keys.sorted().map { date in
            WatchCourseDayGroup(
                date: date,
                courses: grouped[date] ?? []
            )
        }
    }

    /// 为每个有日程的自然日选出五个两节区间中的第一项日程。
    private func makePeriodCourseIDsByDay(
        from grouped: [Date: [WatchCourse]]
    ) -> [Date: [String?]] {
        var result: [Date: [String?]] = [:]
        result.reserveCapacity(grouped.count)
        for (day, courses) in grouped {
            result[day] = WatchScheduleRenderCacheLayout.periodRanges.map {
                periodRange in
                courses.first {
                    $0.startPeriod <= periodRange.upperBound
                        && $0.endPeriod >= periodRange.lowerBound
                }?.id
            }
        }
        return result
    }

    /// 将内存索引编码到手表 App 自己的 UserDefaults。
    private func persistRenderCache() {
        guard let snapshot else {
            defaults.removeObject(
                forKey: WatchPersistentCacheKey.scheduleRenderIndex
            )
            renderCacheNeedsPersistence = false
            return
        }

        let calendar = Calendar.current
        let days = coursesByDay.keys.sorted().map { day in
            PersistedScheduleRenderDay(
                dayStartEpochMs: epochMilliseconds(day),
                courseIDs: (coursesByDay[day] ?? []).map(\.id),
                periodCourseIDs: periodCourseIDsByDay[day]
                    ?? Array(
                        repeating: nil,
                        count: WatchScheduleRenderCacheLayout
                            .periodRanges.count
                    )
            )
        }
        let today = calendar.startOfDay(for: Date())
        let cache = PersistedScheduleRenderCache(
            schemaVersion: WatchScheduleRenderCacheLayout.schemaVersion,
            source: renderCacheSource(for: snapshot),
            sortedCourseIDs: sortedVisibleCourses.map(\.id),
            days: days,
            courseListReferenceDayEpochMs: epochMilliseconds(today),
            courseListInitialDayEpochMs: courseListInitialDate.map(
                epochMilliseconds
            )
        )

        do {
            try WatchCacheCoding.persist(
                cache,
                key: WatchPersistentCacheKey.scheduleRenderIndex,
                defaults: defaults
            )
            renderCacheNeedsPersistence = false
        } catch {
            renderCacheNeedsPersistence = true
            NSLog("[WatchScheduleStore] Render cache encode failed: \(error)")
        }
    }

    /// 启动等待结束且手机未下发新课表时，补写缺失的派生缓存。
    private func persistRenderCacheIfNeeded() {
        guard renderCacheNeedsPersistence else { return }
        persistRenderCache()
    }

    /// 从磁盘恢复派生索引，并用原始快照做结构完整性校验。
    ///
    /// 这里只验证缓存是否属于当前快照，不在 Watch 端计算或比较课表语义
    /// 版本；“是否有新课表”仍完全以 iPhone 的版本回复为准。
    private func restorePersistedRenderCache() -> Bool {
        guard let snapshot,
              let cache = try? WatchCacheCoding.load(
                  PersistedScheduleRenderCache.self,
                  key: WatchPersistentCacheKey.scheduleRenderIndex,
                  defaults: defaults
              ),
              cache.schemaVersion
                  == WatchScheduleRenderCacheLayout.schemaVersion,
              cache.source == renderCacheSource(for: snapshot)
        else {
            return false
        }

        guard let restored = restoreScheduleRenderIndex(
            cache,
            snapshot: snapshot
        )
        else {
            return false
        }

        let sorted = cache.sortedCourseIDs.compactMap {
            restored.coursesByID[$0]
        }
        let groups = makeCourseDayGroups(from: restored.coursesByDay)
        let position = restoreCourseListPosition(
            from: cache,
            groups: groups,
            calendar: .current
        )
        renderCacheNeedsPersistence = position.needsPersistence

        // 新建和恢复两条路径最终都经过同一安装入口，确保以后新增派生字段时
        // 不会只更新其中一条路径。恢复值已经完成完整性校验，因此直接复用，
        // 不再次扫描课程或重算五段索引。
        installVisibleScheduleIndex(
            sorted: sorted,
            grouped: restored.coursesByDay,
            groups: groups,
            initialDate: position.date,
            restoredCourseMap: restored.coursesByID,
            restoredPeriodCourseIDs: restored.periodCourseIDsByDay
        )
        return true
    }

    /// 校验持久化课程顺序、自然日归属和五段课程引用，并恢复字典索引。
    private func restoreScheduleRenderIndex(
        _ cache: PersistedScheduleRenderCache,
        snapshot: WatchScheduleSnapshot
    ) -> RestoredScheduleRenderIndex? {
        var courseMap: [String: WatchCourse] = [:]
        courseMap.reserveCapacity(snapshot.courses.count)
        for course in snapshot.courses {
            courseMap[course.id] = course
        }
        guard courseMap.count == snapshot.courses.count,
              cache.sortedCourseIDs.count == snapshot.courses.count,
              Set(cache.sortedCourseIDs) == Set(courseMap.keys)
        else {
            return nil
        }

        let calendar = Calendar.current
        var grouped: [Date: [WatchCourse]] = [:]
        var periodIDsByDay: [Date: [String?]] = [:]
        var groupedCourseIDs: [String] = []
        groupedCourseIDs.reserveCapacity(snapshot.courses.count)

        for day in cache.days {
            guard day.periodCourseIDs.count
                    == WatchScheduleRenderCacheLayout.periodRanges.count
            else {
                return nil
            }
            let date = date(fromEpochMilliseconds: day.dayStartEpochMs)
            let courses = day.courseIDs.compactMap { courseMap[$0] }
            guard courses.count == day.courseIDs.count,
                  courses.allSatisfy({
                      calendar.startOfDay(for: $0.startAt) == date
                  }),
                  day.periodCourseIDs.allSatisfy({ courseID in
                      guard let courseID else { return true }
                      return courseMap[courseID] != nil
                  })
            else {
                return nil
            }
            grouped[date] = courses
            periodIDsByDay[date] = day.periodCourseIDs
            groupedCourseIDs.append(contentsOf: day.courseIDs)
        }
        guard groupedCourseIDs.count == snapshot.courses.count,
              Set(groupedCourseIDs) == Set(courseMap.keys)
        else {
            return nil
        }
        return RestoredScheduleRenderIndex(
            coursesByID: courseMap,
            coursesByDay: grouped,
            periodCourseIDsByDay: periodIDsByDay
        )
    }

    /// 恢复课程列表入口；缓存跨自然日后只重算入口，不重建其他索引。
    private func restoreCourseListPosition(
        from cache: PersistedScheduleRenderCache,
        groups: [WatchCourseDayGroup],
        calendar: Calendar
    ) -> RestoredCourseListPosition {
        let today = calendar.startOfDay(for: Date())
        let referenceDay = date(
            fromEpochMilliseconds: cache.courseListReferenceDayEpochMs
        )
        let cachedDate = cache.courseListInitialDayEpochMs.map {
            date(fromEpochMilliseconds: $0)
        }
        let cachedDateIsValid = cachedDate.map { initial in
            groups.contains(where: { $0.date == initial })
        } ?? groups.isEmpty

        if referenceDay == today, cachedDateIsValid {
            return RestoredCourseListPosition(
                date: cachedDate,
                needsPersistence: false
            )
        }
        return RestoredCourseListPosition(
            date: preferredCourseListDate(in: groups, calendar: calendar),
            needsPersistence: true
        )
    }

    /// 创建轻量来源标识，只用于防止原始快照与派生缓存错配。
    private func renderCacheSource(
        for snapshot: WatchScheduleSnapshot
    ) -> PersistedScheduleRenderSource {
        PersistedScheduleRenderSource(
            snapshotSchemaVersion: snapshot.schemaVersion,
            generatedAtEpochMs: snapshot.generatedAtEpochMs,
            rangeStartEpochMs: snapshot.rangeStartEpochMs,
            rangeEndEpochMs: snapshot.rangeEndEpochMs,
            courseCount: snapshot.courses.count
        )
    }

    /// 将 Date 转换为缓存统一使用的 Unix 毫秒。
    private func epochMilliseconds(_ date: Date) -> Int64 {
        Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    /// 将缓存毫秒时间戳转换回 Date。
    private func date(fromEpochMilliseconds value: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(value) / 1_000)
    }

    /// 首次打开列表优先定位今天；今天无课则选择距离最近的有课日期。
    ///
    /// 前后距离相同时优先未来日期，便于用户直接查看接下来要上的课。
    private func preferredCourseListDate(
        in groups: [WatchCourseDayGroup],
        calendar: Calendar
    ) -> Date? {
        let today = calendar.startOfDay(for: Date())
        if groups.contains(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            return today
        }

        return groups.min { lhs, rhs in
            let lhsDistance = abs(lhs.date.timeIntervalSince(today))
            let rhsDistance = abs(rhs.date.timeIntervalSince(today))
            if lhsDistance == rhsDistance {
                return lhs.date > rhs.date
            }
            return lhsDistance < rhsDistance
        }?.date
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
