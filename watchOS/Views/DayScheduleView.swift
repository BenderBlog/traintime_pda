// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 单日课程视图。
///
/// 日视图只负责日期切换和列表展示；按需求禁止从这里打开详情页。
/// 日视图收到表冠输入后要执行的唯一操作。
///
/// 先计算路由、再执行视觉更新，可以保证“课程滚动、前一日直接分页、到达
/// 末项后连续横向翻日”三种状态互斥，也让主事件处理函数保持可审计。
private enum DayCrownRoute {
    case horizontalPage
    case course(direction: Int)
    case previousDayPage
}

/// 日视图完成横向吸附后重新绑定的表冠导航轴。
private enum DayCrownBinding: Equatable {
    case horizontalPages
    case verticalCourses
}

/// 日视图 ScrollView 的不可见顶部定位点；日期参与身份，避免三张预渲染
/// 页面之间误用同一个滚动目标。
private struct DayScrollTopTarget: Hashable {
    let date: Date
}

/// 当前日期的卡片布局采样。
///
/// 只记录不随滚动位置变化的高度，表冠每帧不需要重新传递 frame。
private struct DayCourseLayoutMetrics: Equatable {
    var cardHeights: [String: CGFloat] = [:]
}

/// 日视图卡片高度持久化格式。
private struct PersistedDayCourseLayoutCache: Codable {
    let schemaVersion: Int
    let signature: String
    let cardHeights: [String: Double]
}

private enum DayCourseLayoutCacheConfiguration {
    static let schemaVersion = 1
    static let persistenceDelayNanoseconds: UInt64 = 1_500_000_000
}

/// 保存日视图已经测量的卡片高度，但不发布变化，避免重绘父页面。
///
/// 相邻页在进入屏幕前就完成采样；横向跨页时只切换当前日期指针，不再临时
/// 挂载一组测量视图。缓存是普通引用状态，不会让表冠每个像素都触发父页面
/// 更新。高度以“课表版本 + 语言 + 表盘内容宽度”为签名持久化；这些条件任
/// 一变化都会自动舍弃旧值，避免跨设备或切换语言后复用错误高度。
@MainActor
private final class DayCourseLayoutTracker {
    private var metrics = DayCourseLayoutMetrics()
    private var activeSignature: String?
    private var persistenceTask: Task<Void, Never>?
    private var persistenceDirty = false

    func update(metrics: DayCourseLayoutMetrics) {
        var changed = false
        for (courseID, height) in metrics.cardHeights {
            let normalizedHeight = max(1, height)
            if let oldHeight = self.metrics.cardHeights[courseID],
               abs(oldHeight - normalizedHeight) <= 0.25
            {
                continue
            }
            self.metrics.cardHeights[courseID] = normalizedHeight
            changed = true
        }
        if changed {
            persistenceDirty = true
            schedulePersistence()
        }
    }

    /// 按当前课表和布局环境恢复磁盘缓存；签名相同的重复调用没有开销。
    func configure(signature: String) {
        guard activeSignature != signature else { return }
        persistenceTask?.cancel()
        persistenceTask = nil
        persistenceDirty = false
        activeSignature = signature
        metrics = DayCourseLayoutMetrics()

        guard let cache = try? WatchCacheCoding.load(
                  PersistedDayCourseLayoutCache.self,
                  key: WatchPersistentCacheKey.dayCourseLayout
              ),
              cache.schemaVersion
                  == DayCourseLayoutCacheConfiguration.schemaVersion,
              cache.signature == signature
        else {
            return
        }
        metrics.cardHeights = cache.cardHeights.mapValues { value in
            CGFloat(value)
        }
    }

    /// 手指或表冠正在逐帧更新页面时暂停 JSON 编码和 UserDefaults 写盘。
    func suspendPersistence() {
        persistenceTask?.cancel()
        persistenceTask = nil
    }

    /// 页面停止交互后再补写尚未落盘的测量值。
    func resumePersistence() {
        guard persistenceDirty else { return }
        schedulePersistence()
    }

    /// 合并相邻三页测量结果后延迟写盘，连续翻页期间绝不执行磁盘编码。
    private func schedulePersistence() {
        persistenceTask?.cancel()
        persistenceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: DayCourseLayoutCacheConfiguration
                    .persistenceDelayNanoseconds
            )
            guard !Task.isCancelled else { return }
            self?.persist()
        }
    }

    private func persist() {
        guard let activeSignature, !metrics.cardHeights.isEmpty else { return }
        let cache = PersistedDayCourseLayoutCache(
            schemaVersion: DayCourseLayoutCacheConfiguration.schemaVersion,
            signature: activeSignature,
            cardHeights: metrics.cardHeights.mapValues { value in
                Double(value)
            }
        )
        do {
            try WatchCacheCoding.persist(
                cache,
                key: WatchPersistentCacheKey.dayCourseLayout
            )
        } catch {
            return
        }
        persistenceDirty = false
        persistenceTask = nil
    }

    /// 将连续的“课程索引”插值成内容纵向位移。
    ///
    /// 使用每张卡片的真实高度而不是猜测固定高度，课程名换行、
    /// 考试座位等内容导致卡片高度不同时也不会在提交下一项时跳动。
    func contentOffset(
        for position: Double,
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> CGFloat {
        guard courses.count > 1 else { return 0 }
        let boundedPosition = min(
            Double(courses.count - 1),
            max(0, position)
        )
        let lowerIndex = Int(floor(boundedPosition))
        let upperIndex = min(courses.count - 1, lowerIndex + 1)
        let fraction = CGFloat(boundedPosition - Double(lowerIndex))
        let fallbackHeight = averageMeasuredHeight ?? 72
        let offsets = courseTopOffsets(
            courses: courses,
            spacing: spacing,
            fallbackHeight: fallbackHeight
        )
        return offsets[lowerIndex]
            + (offsets[upperIndex] - offsets[lowerIndex]) * fraction
    }

    /// 把统一的内容纵向偏移反算成连续课程位置。
    ///
    /// 手指和表冠都通过这一坐标互相接续：手指拖动不再维护一套独立的
    /// ScrollView 锚点，放手后表冠会从屏幕当前所见位置继续移动。
    func position(
        forContentOffset contentOffset: CGFloat,
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> Double {
        guard courses.count > 1 else { return 0 }
        let offsets = courseTopOffsets(
            courses: courses,
            spacing: spacing,
            fallbackHeight: averageMeasuredHeight ?? 72
        )
        guard let first = offsets.first,
              let last = offsets.last
        else {
            return 0
        }
        if contentOffset >= first { return 0 }
        if contentOffset <= last { return Double(courses.count - 1) }

        for lowerIndex in 0..<(offsets.count - 1) {
            let upperOffset = offsets[lowerIndex]
            let lowerOffset = offsets[lowerIndex + 1]
            guard contentOffset <= upperOffset,
                  contentOffset >= lowerOffset
            else {
                continue
            }
            let distance = upperOffset - lowerOffset
            let fraction = distance > 0
                ? (upperOffset - contentOffset) / distance
                : 0
            return Double(lowerIndex) + Double(fraction)
        }
        return 0
    }

    /// 当前卡片栈的真实内容高度，用于触摸结束后的底边贴合。
    func contentHeight(
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> CGFloat {
        guard !courses.isEmpty else { return 0 }
        let fallbackHeight = averageMeasuredHeight ?? 72
        let cardHeight = courses.reduce(CGFloat.zero) { partial, course in
            partial + (metrics.cardHeights[course.id] ?? fallbackHeight)
        }
        return cardHeight + CGFloat(max(0, courses.count - 1)) * spacing
    }

    /// 以第一张卡片为原点，计算每张卡片顶边对应的内容偏移。
    private func courseTopOffsets(
        courses: [WatchCourse],
        spacing: CGFloat,
        fallbackHeight: CGFloat
    ) -> [CGFloat] {
        var result = [CGFloat]()
        result.reserveCapacity(courses.count)
        var accumulatedHeight: CGFloat = 0
        for course in courses {
            result.append(-accumulatedHeight)
            accumulatedHeight += (
                metrics.cardHeights[course.id] ?? fallbackHeight
            ) + spacing
        }
        return result
    }

    /// 首帧采样未完成时使用已有卡片的平均高度作为短暂回退。
    private var averageMeasuredHeight: CGFloat? {
        guard !metrics.cardHeights.isEmpty else { return nil }
        return metrics.cardHeights.values.reduce(0, +)
            / CGFloat(metrics.cardHeights.count)
    }
}

struct DayScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @Binding var selectedDate: Date
    @State private var crownValue = 0.0
    @State private var lastCrownEventOffset = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var crownPageRamp = CalendarCrownPageRamp()
    @State private var continuousDayNavigation = false
    /// 上一个已给出触觉反馈的卡片索引；日视图本身不选中卡片。
    @State private var feedbackCourseIndex = 0
    @State private var courseScrollPosition = 0.0
    @State private var courseContentOffset: CGFloat = 0
    @State private var verticalTouchStartOffset: CGFloat = 0
    @State private var dayViewportHeight: CGFloat = 1
    @State private var horizontalPageOffset: CGFloat = 0
    @State private var horizontalTouchStartOffset: CGFloat = 0
    @State private var horizontalPageWidth: CGFloat = 1
    @State private var horizontalCrownVelocity: CGFloat = 0
    @State private var inputRecognitionResetToken = 0
    @State private var pageTransitionToken = 0
    @State private var pageTransitionTask: Task<Void, Never>?
    @State private var crownIdleCoordinator = CalendarCrownIdleCoordinator()
    @State private var verticalMomentumTask: Task<Void, Never>?
    @State private var verticalMomentumToken = 0
    @State private var pageTransitionInFlight = false
    @State private var courseLayoutTracker = DayCourseLayoutTracker()
    @FocusState private var crownFocused: Bool
    let isDatePickerPresented: Bool
    let onDatePickerRequested: (Date) -> Void
    /// 日视图轻点内容时显式通知根视图显示两个悬浮按钮。
    let onContentTap: () -> Void
    let onCrownInteraction: () -> Void

    /// 日内纵向浏览使用的表冠位移倍率；横向翻页使用独立倍率。
    private let verticalCrownMotionScale = 0.175

    /// 一张完整课程卡片对应的表冠原始刻度基准。
    private let cardScrollThreshold = 0.75

    /// `DaySchedulePageContent` 内课程卡片之间的真实间距。
    private let courseCardSpacing: CGFloat = 5

    /// 当前选中日期内开始的全部日程。
    private var courses: [WatchCourse] {
        store.courses(on: selectedDate)
    }

    var body: some View {
        CalendarHorizontalPager(
            pageOffset: horizontalPageOffset,
            interactionResetToken: inputRecognitionResetToken,
            pageIdentity: dayDate,
            page: dayPage,
            onViewportWidthChange: updateDayViewportWidth,
            onViewportHeightChange: { dayViewportHeight = max(1, $0) },
            onHorizontalDragBegan: beginDayHorizontalDrag,
            onHorizontalDragChanged: updateDayHorizontalDrag,
            onHorizontalDragEnded: finishDayHorizontalDrag,
            onVerticalDragBegan: beginDayVerticalDrag,
            onVerticalDragChanged: updateDayVerticalDrag,
            onVerticalDragEnded: finishDayVerticalDrag,
            onDragAxisLocked: { _ in },
            onDragFinished: {}
        )
        .onAppear {
            crownFocused = true
            lastCrownEventOffset = crownValue
            feedbackCourseIndex = 0
            configureDayCourseLayoutCache()
        }
        .onDisappear {
            crownIdleCoordinator.cancel()
            pageTransitionTask?.cancel()
            cancelDayVerticalMomentum()
        }
        .onChange(of: isDatePickerPresented) { _, isPresented in
            if isPresented {
                cancelDayVerticalMomentum()
                crownIdleCoordinator.cancel()
                crownFocused = false
            } else {
                crownSession.reset()
                lastCrownEventOffset = crownValue
                crownFocused = true
            }
        }
        // 只在 Store 安装了新的课表索引时清理日内位置。此前监听当天课程 ID
        // 会在每次横向翻日时重复执行 moveDay 已做过的状态重置。
        .onChange(of: store.renderCacheRevision) { _, _ in
            recalculateCurrentDayCourseBounds()
        }
        .onChange(of: store.preferredLanguageIdentifier) { _, _ in
            configureDayCourseLayoutCache()
        }
        .toolbar {
            if !isDatePickerPresented {
                ToolbarItem(placement: .topBarLeading) {
                    DateNavigationHeader(
                        title: selectedDate.formatted(
                            .dateTime
                                .month()
                                .day()
                                .weekday(.short)
                                .locale(
                                    WatchWidgetShared.preferredLocale
                                )
                        ),
                        previous: { requestDayPage(-1) },
                        next: { requestDayPage(1) },
                        titleAction: requestDatePicker
                    )
                    .frame(width: 116)
                    .offset(y: -10)
                }
            }
        }
    }

    /// 视口宽度只在表盘尺寸变化时更新；同时用它选择对应的持久化高度缓存。
    private func updateDayViewportWidth(_ width: CGFloat) {
        let normalizedWidth = max(1, width)
        horizontalPageWidth = normalizedWidth
        configureDayCourseLayoutCache(for: normalizedWidth)
    }

    /// 卡片高度只在相同课表版本、语言和内容宽度下复用。
    private func configureDayCourseLayoutCache(
        for width: CGFloat? = nil
    ) {
        let contentWidth = Int(
            max(1, width ?? horizontalPageWidth).rounded()
        )
        let scheduleIdentity: String
        if let installedVersion = store.installedScheduleVersion {
            scheduleIdentity = installedVersion
        } else if let snapshot = store.snapshot {
            scheduleIdentity = [
                String(snapshot.schemaVersion),
                String(snapshot.generatedAtEpochMs),
                String(snapshot.courses.count),
            ].joined(separator: "-")
        } else {
            scheduleIdentity = "empty"
        }
        let signature = [
            "v\(DayCourseLayoutCacheConfiguration.schemaVersion)",
            scheduleIdentity,
            store.preferredLanguageIdentifier,
            String(contentWidth),
        ].joined(separator: "|")
        courseLayoutTracker.configure(signature: signature)
    }

    /// 入口只负责暂停日视图输入并请求根容器展示独立选择页面。
    private func requestDatePicker() {
        guard !isDatePickerPresented, !pageTransitionInFlight else { return }
        cancelDayVerticalMomentum()
        crownIdleCoordinator.cancel()
        crownFocused = false
        onCrownInteraction()
        onDatePickerRequested(selectedDate)
    }

    /// 预先渲染前一天、当天和后一天；三页共用同一个横向触摸检测层。
    ///
    /// 同一触摸层先锁定横向或纵向：横向修改三页容器的 `x` 偏移，纵向
    /// 修改课程栈与表冠共用的内容偏移，两条路径在一次触摸中保持互斥。
    @ViewBuilder
    private func dayPage(_ relativePage: Int) -> some View {
        let date = dayDate(relativePage)

        GeometryReader { viewport in
            ZStack(alignment: .bottomLeading) {
                DaySchedulePageContent(
                    date: date,
                    courses: store.courses(on: date),
                    viewportSize: viewport.size,
                    courseOffset: relativePage == 0
                        ? courseContentOffset
                        : 0,
                    languageIdentifier: store.preferredLanguageIdentifier,
                    onCourseLayoutMetricsChange: updateDayCourseLayout
                )
                .equatable()

                // 三页使用完全相同的内容层级，只给中间页添加表冠观察器。
                // 页面身份从右侧移动到中间时，课程 ScrollView 因而能原样
                // 保留，不会因条件分支结构改变而再次销毁重建。
                if relativePage == 0 {
                    dayCrownObserver()
                }
            }
            // 固定触摸层铺满状态栏以下的整个日视图，而不是只使用课程卡片
            // 的视觉边界。这样轻点任意黑色空白区域也能唤醒悬浮按钮。
            .frame(
                width: viewport.size.width,
                height: viewport.size.height
            )
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture().onEnded {
                    guard relativePage == 0 else { return }
                    onContentTap()
                    settleDayContentAfterTouch()
                }
            )
        }
        .allowsHitTesting(relativePage == 0)
    }

    /// 返回三页容器中某一相对位置对应的真实日期。
    ///
    /// 分页器使用该日期作为页面身份；跨日时，已经显示完整的相邻页会从
    /// “后一页”移动成“当前页”，而不是销毁后重新创建，从而消除有课页面
    /// 刚进入屏幕时的卡片补绘和明显卡顿。
    private func dayDate(_ relativePage: Int) -> Date {
        Calendar.current.date(
            byAdding: .day,
            value: relativePage,
            to: selectedDate
        ) ?? selectedDate
    }

    /// 透明节点独占日视图的表冠焦点，以便区分慢转滚动和快转切日。
    private func dayCrownObserver() -> some View {
        Color.clear
            .frame(width: 1, height: 1)
            .calendarPagingCrownInput(
                detent: $crownValue,
                focused: $crownFocused,
                onChange: { event in
                    handleDayCrownChange(event)
                },
                onIdle: {
                    handleDayCrownIdle()
                }
            )
            .accessibilityHidden(true)
    }

    /// 将表冠输入转换为“先滚课程、到达末项后直接切日”的两阶段操作。
    ///
    /// 数值增加先向后浏览课程，到达最后一项便进入下一日横向分页；数值
    /// 减少先向前浏览课程，到达第一项后直接进入前一日横向分页。
    private func handleDayCrownChange(_ event: DigitalCrownEvent) {
        // 新刻度是“仍在旋转”的唯一可靠信号；先取消可能由短暂 onIdle
        // 排队的吸附，保证连续翻页期间绝不会撞上收口动画。
        crownIdleCoordinator.cancel()
        courseLayoutTracker.suspendPersistence()
        // 表冠接管时立即停止手指松开后的惯性，避免两种输入同时修改
        // `courseContentOffset` 而造成位置跳动。
        cancelDayVerticalMomentum()
        let delta = frameBoundCrownDelta(
            from: lastCrownEventOffset,
            to: event.offset
        )
        lastCrownEventOffset = event.offset
        guard let update = crownSession.register(delta: delta) else { return }

        onCrownInteraction()
        crownFocused = true
        prepareDayCrownSession(update)

        switch dayCrownRoute(for: update.direction) {
        case .horizontalPage:
            activateHorizontalDayNavigation()
            applyHorizontalCrownDelta(delta, velocity: event.velocity)
        case .previousDayPage:
            beginPreviousDayHorizontalNavigation(
                delta: delta,
                velocity: event.velocity
            )
        case let .course(direction):
            updateCourseSelectionPreview(
                direction: direction,
                delta: delta,
                velocity: event.velocity
            )
        }
        crownIdleCoordinator.scheduleFallback {
            settleDayCrownAfterInput()
        }
    }

    /// 为新一轮旋转或方向反转准备日视图状态。
    ///
    /// 横向翻日一旦开始，同一轮旋转即使反向也仍由横向分页器接管。
    /// 日内浏览反向时仅清除越界拉动，连续的卡片位置不重置，因而不会
    /// 在三项以上课程中因 anchor 切换出现突变。
    private func prepareDayCrownSession(_ update: WatchCrownTurnUpdate) {
        crownPageRamp.register(update)
        if update.startsNewSession {
            if abs(horizontalPageOffset) < 0.5 {
                // 零或一项日程没有纵向卡片导航的必要，表冠直接用于翻日。
                if courses.count <= 1 {
                    activateHorizontalDayNavigation()
                } else {
                    continuousDayNavigation = false
                }
            }
        }

        guard update.reversesDirection,
              !continuousDayNavigation
        else {
            return
        }
    }

    /// 根据当前页面状态选择本次表冠事件的处理路径。
    private func dayCrownRoute(for direction: Int) -> DayCrownRoute {
        if continuousDayNavigation {
            return .horizontalPage
        }
        let lastPosition = Double(max(0, courses.count - 1))
        if direction > 0, courseScrollPosition < lastPosition {
            return .course(direction: direction)
        }
        if direction < 0, courseScrollPosition > 0 {
            return .course(direction: direction)
        }
        return direction < 0 ? .previousDayPage : .horizontalPage
    }

    /// 把表冠原始刻度连续映射到当日卡片轴。
    ///
    /// 该路径只更新一个连续的内容位移，不在滚动途中切换
    /// `ScrollView` 锚点，因此卡片高度不同时也能线性过渡。
    private func updateCourseSelectionPreview(
        direction: Int,
        delta: Double,
        velocity: Double
    ) {
        guard courses.count > 1 else { return }
        let previousPosition = courseScrollPosition
        let positionDelta = abs(delta) / cardScrollThreshold
            * verticalCrownMotionScale
            * Double(direction)
        let lastPosition = Double(courses.count - 1)
        let nextPosition = min(
            lastPosition,
            max(0, previousPosition + positionDelta)
        )
        courseScrollPosition = nextPosition

        let nextSelectedIndex = Int(nextPosition.rounded())
        if nextSelectedIndex != feedbackCourseIndex {
            feedbackCourseIndex = nextSelectedIndex
            WatchHaptics.selection()
        }

        let nextOffset = courseLayoutTracker.contentOffset(
            for: nextPosition,
            courses: courses,
            spacing: courseCardSpacing
        )
        // 用极短线性补间填充实体表相邻 detent 之间的显示帧；
        // 新输入会立即重定向目标，不会累积播放历史动画。
        withAnimation(.linear(duration: 0.045)) {
            courseContentOffset = nextOffset
        }

        guard direction > 0, nextPosition >= lastPosition else { return }

        // 到达末张卡片即切换导航轴，不再继续制造纵向越界位移。
        // 当前刻度如果越过末项，未被纵向消费的部分立即传给横向分页，
        // 因而持续旋转时不会在两种模式之间产生停顿。
        let consumedPosition = max(0, lastPosition - previousPosition)
        let consumedDelta = consumedPosition
            * cardScrollThreshold
            / verticalCrownMotionScale
        let horizontalRemainder = max(0, abs(delta) - consumedDelta)
        activateHorizontalDayNavigation()
        if horizontalRemainder > .ulpOfOne {
            applyHorizontalCrownDelta(
                horizontalRemainder,
                velocity: velocity
            )
        }
    }

    /// 已在第一项时反向转动表冠，立即切换到横向翻日前一日。
    private func beginPreviousDayHorizontalNavigation(
        delta: Double,
        velocity: Double
    ) {
        activateHorizontalDayNavigation()
        applyHorizontalCrownDelta(delta, velocity: velocity)
    }

    /// 统一进入日视图横向分页状态。
    ///
    /// 当前页保持纵向停留位置随页面一起移出屏幕；日期真正提交后，
    /// `moveDay` 才会无动画把新页面重置到首张卡片。
    private func activateHorizontalDayNavigation() {
        guard !continuousDayNavigation else { return }
        continuousDayNavigation = true
    }

    /// 以自然日为单位提交已完成的横向翻页。
    private func moveDay(
        _ amount: Int,
        preservesHorizontalNavigation: Bool = false
    ) {
        cancelDayVerticalMomentum()
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: amount,
            to: selectedDate
        ) ?? selectedDate
        guard nextDate != selectedDate else { return }
        // 当前页完整离屏或吸附到目标页后才提交日期；此刻无动画清除旧页
        // 的纵向位置，使新页面从首张卡片上沿开始。
        feedbackCourseIndex = 0
        courseScrollPosition = 0
        courseContentOffset = 0
        if !preservesHorizontalNavigation {
            continuousDayNavigation = false
        }
        // 手指、表冠和顶部按钮都在页面真正提交时反馈一次。
        WatchHaptics.navigation(amount)
        selectedDate = nextDate
    }

    /// 日期数据变化后清理旧卡片位置，从新列表顶部重新采样。
    private func recalculateCurrentDayCourseBounds() {
        cancelDayVerticalMomentum()
        feedbackCourseIndex = 0
        courseScrollPosition = 0
        courseContentOffset = 0
        configureDayCourseLayoutCache()
        // 连续横向翻页跨过整屏时，日期和课程 ID 会同时变化；保留表冠
        // 会话才能让未停下的旋转继续翻后续日期。普通同步替换则重置会话。
        if !continuousDayNavigation {
            crownSession.reset()
        }
    }

    /// 接收前、中、后三页的卡片高度，仅写入非观察型记录器。
    private func updateDayCourseLayout(
        _ metrics: DayCourseLayoutMetrics
    ) {
        courseLayoutTracker.update(metrics: metrics)
    }

    /// 顶部按钮与触摸、表冠共用相同的平移和吸附动画。
    private func requestDayPage(_ amount: Int) {
        guard !isDatePickerPresented, !pageTransitionInFlight else { return }
        cancelDayVerticalMomentum()
        crownIdleCoordinator.cancel()
        crownFocused = true
        onCrownInteraction()
        settleDayPage(direction: amount, velocity: horizontalPageWidth * 2.2)
    }

    private func beginDayHorizontalDrag() {
        guard !pageTransitionInFlight else { return }
        courseLayoutTracker.suspendPersistence()
        cancelDayVerticalMomentum()
        crownIdleCoordinator.cancel()
        continuousDayNavigation = false
        horizontalTouchStartOffset = horizontalPageOffset
        crownFocused = true
        onCrownInteraction()
    }

    /// 纵向触摸从表冠当前停留的内容偏移开始，不重新建立滚动锚点。
    ///
    /// 触摸与表冠由此共享 `courseContentOffset` 和连续课程位置；表冠已经把
    /// 卡片移动到中间时，手指可以直接从该位置向任意方向继续拖动。单项
    /// 日程也进入这条路径，从而获得与多项日程一致的跟手、惯性和回弹；
    /// 只有表冠继续保持单项日程直接横向翻日。
    private func beginDayVerticalDrag() {
        guard !pageTransitionInFlight, !courses.isEmpty else { return }
        courseLayoutTracker.suspendPersistence()
        cancelDayVerticalMomentum()
        crownIdleCoordinator.cancel()
        continuousDayNavigation = false
        verticalTouchStartOffset = courseContentOffset
        crownSession.reset()
        lastCrownEventOffset = crownValue
        onCrownInteraction()
    }

    /// 手指纵向移动直接修改表冠使用的同一内容合成位移。
    private func updateDayVerticalDrag(_ translation: CGFloat) {
        guard !pageTransitionInFlight, !courses.isEmpty else { return }
        let nextOffset = verticalTouchStartOffset + translation
        performWithoutAnimation {
            courseContentOffset = nextOffset
        }
        synchronizeCoursePosition(with: nextOffset)
        onCrownInteraction()
    }

    /// 触摸结束后按松手末速度继续滑动，并逐帧减速。
    ///
    /// 末速度由系统的预测终点反推，惯性阶段仍然写入触摸与表冠共用的
    /// `courseContentOffset`。速度较小则直接执行原来的边界收口。
    private func finishDayVerticalDrag(_ value: DragGesture.Value) {
        guard !pageTransitionInFlight, !courses.isEmpty else { return }
        let velocity = verticalDragReleaseVelocity(value)
        let restingRange = dayTouchRestingRange()
        let isOutsideRestingRange = !restingRange.contains(
            courseContentOffset
        )
        // 已经越界时即使末速度很低，也交给同一套边界物理过程，避免直接
        // 切换成 SwiftUI 弹簧而让速度在松手瞬间反号。
        guard abs(velocity) >= dayVerticalMomentumMinimumVelocity
                || isOutsideRestingRange
        else {
            settleDayContentAfterTouch()
            return
        }
        startDayVerticalMomentum(initialVelocity: velocity)
    }

    /// 启动日视图纵向惯性，并使用指数摩擦使速度连续衰减。
    ///
    /// 正常区间内只使用摩擦减速；越过首项顶边或末项贴底位置后，改用
    /// 弹力与阻尼共同减速。内容会先沿松手方向继续移动，速度降为零后再
    /// 自然反向；回程重新穿过边界时直接落位，不叠加第二段动画。
    private func startDayVerticalMomentum(initialVelocity: CGFloat) {
        cancelDayVerticalMomentum()
        verticalMomentumToken += 1
        let token = verticalMomentumToken
        let initialOffset = courseContentOffset
        let restingRange = dayTouchRestingRange()

        verticalMomentumTask = Task { @MainActor in
            var offset = initialOffset
            var velocity = initialVelocity
            var previousFrame = Date().timeIntervalSinceReferenceDate

            while !Task.isCancelled, token == verticalMomentumToken {
                try? await Task.sleep(nanoseconds: 16_000_000)
                guard !Task.isCancelled, token == verticalMomentumToken else {
                    return
                }

                let currentFrame = Date().timeIntervalSinceReferenceDate
                let elapsed = currentFrame - previousFrame
                previousFrame = currentFrame
                // 实体表掉帧时只消费一帧上限，避免恢复后追赶积压位移。
                let deltaTime = min(
                    dayVerticalMomentumMaximumFrameDuration,
                    max(0.001, elapsed)
                )
                let boundary = dayVerticalMomentumBoundary(
                    for: offset,
                    restingRange: restingRange
                )
                if let boundary {
                    let displacement = offset - boundary
                    let acceleration = -dayVerticalMomentumSpringStiffness
                        * displacement
                        - dayVerticalMomentumSpringDamping * velocity
                    let updatedVelocity = velocity
                        + acceleration * deltaTime
                    let isMovingOutward = displacement * velocity > 0
                    // 离散帧不能直接把向外速度改成向内速度；至少保留一帧
                    // 的零速转折点，视觉上才是“顺势减速—停住—反向”。
                    if isMovingOutward,
                       velocity * updatedVelocity < 0
                    {
                        velocity = 0
                    } else {
                        velocity = updatedVelocity
                    }
                } else {
                    velocity *= CGFloat(
                        exp(-dayVerticalMomentumFriction * deltaTime)
                    )
                }

                let nextOffset = offset + velocity * deltaTime
                // 越界内容已经反向并重新进入正常区间：在穿过边界的这一帧
                // 精确停到边界，避免继续冲入内容区后再出现一次方向突变。
                if let boundary,
                   (offset - boundary) * (nextOffset - boundary) <= 0
                {
                    performWithoutAnimation {
                        courseContentOffset = boundary
                    }
                    synchronizeCoursePosition(with: boundary)
                    verticalTouchStartOffset = boundary
                    verticalMomentumTask = nil
                    settleDayContentAfterTouch()
                    return
                }

                offset = nextOffset
                performWithoutAnimation {
                    courseContentOffset = offset
                }
                synchronizeCoursePosition(with: offset)

                let remainingBoundary = dayVerticalMomentumBoundary(
                    for: offset,
                    restingRange: restingRange
                )
                if abs(velocity) < dayVerticalMomentumStopVelocity,
                   remainingBoundary == nil
                {
                    verticalMomentumTask = nil
                    settleDayContentAfterTouch()
                    return
                } else if let remainingBoundary,
                          abs(offset - remainingBoundary) < 0.5,
                          abs(velocity) < dayVerticalMomentumStopVelocity
                {
                    performWithoutAnimation {
                        courseContentOffset = remainingBoundary
                    }
                    synchronizeCoursePosition(with: remainingBoundary)
                    verticalTouchStartOffset = remainingBoundary
                    verticalMomentumTask = nil
                    settleDayContentAfterTouch()
                    return
                }
            }
        }
    }

    /// 取消尚未结束的纵向惯性；Token 同时拒绝已经排队的旧帧。
    private func cancelDayVerticalMomentum() {
        verticalMomentumToken += 1
        verticalMomentumTask?.cancel()
        verticalMomentumTask = nil
    }

    /// 轻点或纵向拖动结束时，共用同一套触摸收口逻辑。
    private func settleDayContentAfterTouch() {
        guard !pageTransitionInFlight, !courses.isEmpty else { return }
        cancelDayVerticalMomentum()
        crownIdleCoordinator.cancel()
        let restingOffset = dayTouchRestingOffset(courseContentOffset)
        synchronizeCoursePosition(with: restingOffset)
        if abs(restingOffset - courseContentOffset) > 0.5 {
            withAnimation(
                .spring(
                    // 稍长的响应时间配合更高阻尼，让越界内容平顺回到
                    // 正常停留范围，避免松手后立即“弹紧”的突兀感。
                    response: 0.46,
                    dampingFraction: 0.84,
                    blendDuration: 0.08
                )
            ) {
                courseContentOffset = restingOffset
            }
        } else {
            courseContentOffset = restingOffset
        }
        verticalTouchStartOffset = restingOffset
        crownSession.reset()
        lastCrownEventOffset = crownValue
        crownFocused = true
        courseLayoutTracker.resumePersistence()
        // 这里只负责纵向内容收口，不再改变根页面按钮可见性。拖动路径在
        // begin/update 阶段已经调用过 onCrownInteraction；轻点路径则会先
        // 调用 onContentTap 显示按钮。若在这里再次上报“滚动交互”，两项及
        // 以上课程的页面就会出现“刚显示又立即隐藏”的假性点击失效。
    }

    /// 把手指修改后的像素偏移同步回表冠使用的连续课程索引。
    private func synchronizeCoursePosition(with contentOffset: CGFloat) {
        let position = courseLayoutTracker.position(
            forContentOffset: contentOffset,
            courses: courses,
            spacing: courseCardSpacing
        )
        courseScrollPosition = position
        feedbackCourseIndex = Int(position.rounded())
    }

    /// 返回触摸放手后允许停留的纵向偏移范围。
    private func dayTouchRestingOffset(_ proposedOffset: CGFloat) -> CGFloat {
        let range = dayTouchRestingRange()
        return min(range.upperBound, max(range.lowerBound, proposedOffset))
    }

    /// 返回首项顶边与末项贴底位置构成的正常触摸停留区间。
    private func dayTouchRestingRange() -> ClosedRange<CGFloat> {
        let protectedTopInset = max(26, dayViewportHeight * 0.25)
        // 末张卡片下方保留约一行正文高度，避免回弹后紧贴圆角屏幕边缘。
        // 比例约束兼顾不同表径，同时限制范围，防止大表盘留白过多。
        let bottomLineInset = min(
            20,
            max(16, dayViewportHeight * 0.08)
        )
        let contentHeight = courseLayoutTracker.contentHeight(
            courses: courses,
            spacing: courseCardSpacing
        )
        let bottomAlignedOffset = min(
            CGFloat.zero,
            dayViewportHeight
                - protectedTopInset
                - bottomLineInset
                - contentHeight
        )
        return bottomAlignedOffset...0
    }

    private func updateDayHorizontalDrag(_ translation: CGFloat) {
        guard !pageTransitionInFlight else { return }
        // 一次触摸内始终保持页面身份不变，并让容器位移与手指物理位移
        // 逐点相等；不缩放、不封顶，也不在手指按住时提前提交日期。
        horizontalPageOffset = horizontalTouchStartOffset + translation
    }

    private func finishDayHorizontalDrag(_ value: DragGesture.Value) {
        guard !pageTransitionInFlight else { return }
        let motion = horizontalDragMotion(
            value,
            currentOffset: horizontalPageOffset,
            pageWidth: horizontalPageWidth
        )
        settleDayPage(direction: motion.direction, velocity: motion.velocity)
    }

    /// 将表冠刻度转换成横向像素；快速旋转提高每刻度位移，慢转便于精确停页。
    private func applyHorizontalCrownDelta(
        _ delta: Double,
        velocity: Double
    ) {
        guard !pageTransitionInFlight else { return }
        let motion = calendarCrownPageMotion(
            delta: delta,
            velocity: velocity,
            pageWidth: horizontalPageWidth,
            distanceScale: crownPageRamp.distanceScale,
            velocityProfile: .precisionAccelerated
        )
        horizontalCrownVelocity = motion.velocity
        if updateContinuousDayOffset(by: motion.offsetDelta) != 0 {
            crownPageRamp.recordCommittedPage()
        }
    }

    /// 页面完整越过一屏时立即无动画换底，再把偏移归一化到中间页附近。
    ///
    /// 视觉上屏幕仍停留在同一张完整页面，但数据基准已经前进/后退一天，
    /// 三页容器马上获得新的相邻页；同一次表冠旋转或手指拖动因此可以持续
    /// 翻过任意多天，而不是等待停下后才能开始下一页。
    @discardableResult
    private func updateContinuousDayOffset(by delta: CGFloat) -> Int {
        let update = normalizedContinuousPageOffset(
            horizontalPageOffset + delta,
            pageWidth: horizontalPageWidth
        )

        if update.crossedPage == 0 {
            performWithoutAnimation {
                horizontalPageOffset = update.offset
            }
            return 0
        }

        performWithoutAnimation {
            moveDay(
                update.crossedPage,
                preservesHorizontalNavigation: true
            )
            horizontalPageOffset = update.offset
        }
        return update.crossedPage
    }

    /// 系统报告空闲后再确认一小段无新刻度时间，才允许启动吸附。
    ///
    /// `onIdle` 在慢速连续旋转的相邻刻度间也可能短暂触发；延后一小段时间
    /// 并允许下一个 `onChange` 取消任务，可确保动画入口只对应真正停止。
    private func handleDayCrownIdle() {
        crownIdleCoordinator.scheduleIdleConfirmation {
            settleDayCrownAfterInput()
        }
    }

    /// 把未完成的表冠位移吸附到前、当前或后一页；不依赖 Crown 焦点来源。
    private func settleDayCrownAfterInput() {
        guard !pageTransitionInFlight else { return }
        if continuousDayNavigation || abs(horizontalPageOffset) > 0.5 {
            let direction = nearestPageDirection(
                for: horizontalPageOffset,
                width: horizontalPageWidth
            )
            settleDayPage(
                direction: direction,
                velocity: horizontalCrownVelocity
            )
        } else {
            // 纯纵向浏览没有吸附和回弹；表冠停在哪里，卡片就保持在哪里。
            horizontalCrownVelocity = 0
            crownSession.reset()
            courseLayoutTracker.resumePersistence()
        }
    }

    /// 动画到目标页后才原子替换日期，再无动画复位三页容器的位置。
    private func settleDayPage(direction: Int, velocity: CGFloat) {
        crownIdleCoordinator.cancel()
        let snap = horizontalPageSnap(
            direction: direction,
            currentOffset: horizontalPageOffset,
            velocity: velocity,
            width: horizontalPageWidth
        )

        pageTransitionToken += 1
        let token = pageTransitionToken
        pageTransitionTask?.cancel()
        pageTransitionInFlight = true
        resetDayInputRecognitionForSnap()
        withAnimation(calendarPageSnapAnimation(duration: snap.duration)) {
            horizontalPageOffset = snap.target
        }

        pageTransitionTask = makeCalendarPageCompletionTask(
            after: snap.duration
        ) {
            guard token == pageTransitionToken else { return }
            let landingDate = snap.direction == 0
                ? selectedDate
                : dayDate(snap.direction)
            let binding = dayCrownBinding(
                for: store.courses(on: landingDate).count
            )
            if snap.direction != 0 {
                moveDay(snap.direction)
            }
            performWithoutAnimation {
                horizontalPageOffset = 0
            }
            pageTransitionInFlight = false
            horizontalCrownVelocity = 0
            courseLayoutTracker.resumePersistence()
            rebindDayCrown(binding, transitionToken: token)
        }
    }

    /// 吸附开始时统一结束当前表冠和触摸输入会话。
    ///
    /// 除了立即释放 Crown 焦点，还清除表冠基准、方向、触摸累计位移、
    /// 纵横轴锁定和分页模式。动画完成前不会接收新输入；完成后由目标页
    /// 的课程数量重新决定横向或纵向绑定。
    private func resetDayInputRecognitionForSnap() {
        cancelDayVerticalMomentum()
        crownFocused = false
        crownSession.reset()
        crownPageRamp.reset()
        lastCrownEventOffset = crownValue
        horizontalCrownVelocity = 0
        continuousDayNavigation = false
        verticalTouchStartOffset = courseContentOffset
        inputRecognitionResetToken += 1
    }

    /// 目标日期零或一项日程时继续横向翻页；两项及以上时恢复纵向浏览。
    private func dayCrownBinding(for courseCount: Int) -> DayCrownBinding {
        courseCount <= 1 ? .horizontalPages : .verticalCourses
    }

    /// 在吸附完成后更新导航轴，并于下一次主线程循环重新取得表冠焦点。
    ///
    /// 延后一帧可确保新日期的中间页和透明 Crown 观察器已经挂载。Token
    /// 校验会拒绝上一轮动画迟到的聚焦请求。
    private func rebindDayCrown(
        _ binding: DayCrownBinding,
        transitionToken: Int
    ) {
        continuousDayNavigation = binding == .horizontalPages
        crownSession.reset()
        lastCrownEventOffset = crownValue

        DispatchQueue.main.async {
            guard transitionToken == pageTransitionToken,
                  !pageTransitionInFlight
            else {
                return
            }
            crownFocused = true
        }
    }

}

/// 日分页器中一张按真实日期复用的页面。
///
/// 页面显式实现 `Equatable`，横向偏移的每帧变化不会重新计算未变化的卡片、
/// 时间格式和滚动高度。一天通常只有少量日程，因此这里使用完整 `VStack`
/// 预渲染三页；相比 `LazyVStack`，它能避免相邻页刚进入屏幕时才补画卡片。
private struct DaySchedulePageContent: View, Equatable {
    let date: Date
    let courses: [WatchCourse]
    let viewportSize: CGSize
    let courseOffset: CGFloat
    let languageIdentifier: String
    let onCourseLayoutMetricsChange: (DayCourseLayoutMetrics) -> Void

    static func == (
        lhs: DaySchedulePageContent,
        rhs: DaySchedulePageContent
    ) -> Bool {
        lhs.date == rhs.date
            && lhs.courses == rhs.courses
            && lhs.viewportSize == rhs.viewportSize
            && lhs.courseOffset == rhs.courseOffset
            && lhs.languageIdentifier == rhs.languageIdentifier
    }

    @ViewBuilder
    var body: some View {
        if courses.isEmpty {
            emptyDayState
        } else {
            InteractionAwareScrollView(
                onScroll: {},
                protectsInitialTopEdge: true,
                alwaysProtectsInitialTopEdge: true,
                protectedTopInsetRatio: 0.25,
                topScrollTarget: AnyHashable(
                    DayScrollTopTarget(date: date)
                )
            ) {
                VStack(spacing: 5) {
                    ForEach(courses) { course in
                        CourseRow(
                            course: course,
                            showsInlineMetadata: true
                        )
                        .id(course.id)
                        .background {
                            GeometryReader { cardProxy in
                                Color.clear.preference(
                                    key: DayCourseLayoutPreferenceKey.self,
                                    value: DayCourseLayoutMetrics(
                                        cardHeights: [
                                            course.id: cardProxy.size.height,
                                        ]
                                    )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 1)
                // 表冠浏览只改变一个合成位移，不再每帧调用
                // ScrollViewProxy.scrollTo；这是三项以上卡片仍能连续跟手的关键。
                .offset(y: courseOffset)
            }
            // 纵向触摸与表冠统一由外层分页手势修改 `courseOffset`。
            // ScrollView 只保留既有的安全区、测量和裁剪布局，不再维护第二套
            // 独立滚动锚点。
            .scrollDisabled(true)
            .onPreferenceChange(DayCourseLayoutPreferenceKey.self) { metrics in
                onCourseLayoutMetricsChange(metrics)
            }
        }
    }

    /// 无课程时保持既有居中布局。
    private var emptyDayState: some View {
        let contentHeight: CGFloat = 60

        return VStack(spacing: 8) {
            Image(systemName: "cup.and.saucer")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("当天没有课程")
                .font(.headline)
        }
        .frame(width: viewportSize.width, height: contentHeight)
        .position(
            x: viewportSize.width / 2,
            y: viewportSize.height / 2
        )
    }
}

/// 汇总当前日所有卡片的固定高度。
///
/// 数值不随表冠位移改变，因此布局完成后不会持续触发偏好链。
private struct DayCourseLayoutPreferenceKey: PreferenceKey {
    static var defaultValue = DayCourseLayoutMetrics()

    static func reduce(
        value: inout DayCourseLayoutMetrics,
        nextValue: () -> DayCourseLayoutMetrics
    ) {
        let next = nextValue()
        value.cardHeights.merge(next.cardHeights) { _, new in new }
    }
}

/// 日视图纵向触摸的惯性参数。
///
/// 速度单位统一为 point/second。指数摩擦不依赖具体刷新率，因此实体表在
/// 30Hz 或 60Hz 下具有接近的滑行距离；单帧时间上限负责丢弃卡顿期间积压
/// 的位移，避免恢复绘制后卡片突然跳动。
private let dayVerticalMomentumMinimumVelocity: CGFloat = 55
private let dayVerticalMomentumStopVelocity: CGFloat = 22
private let dayVerticalMomentumMaximumVelocity: CGFloat = 1_600
private let dayVerticalMomentumFriction = 7.2
private let dayVerticalMomentumMaximumFrameDuration = 1.0 / 30.0
private let dayVerticalMomentumSpringStiffness: CGFloat = 210
private let dayVerticalMomentumSpringDamping: CGFloat = 23

/// 返回当前越界位置需要吸附的边界；正常区间内返回 `nil`。
private func dayVerticalMomentumBoundary(
    for offset: CGFloat,
    restingRange: ClosedRange<CGFloat>
) -> CGFloat? {
    if offset > restingRange.upperBound {
        return restingRange.upperBound
    }
    if offset < restingRange.lowerBound {
        return restingRange.lowerBound
    }
    return nil
}

/// 根据系统预测终点估算纵向松手末速度。
///
/// `predictedEndTranslation` 表示系统按当前手势趋势预计的减速终点。减去
/// 实际位移后再除以约 0.2 秒预测窗口，可得到带方向的释放速度；最后限制
/// 极端甩动，防止很短的一次触摸跨过整张表盘。
private func verticalDragReleaseVelocity(
    _ value: DragGesture.Value
) -> CGFloat {
    let projectedRemainder = value.predictedEndTranslation.height
        - value.translation.height
    let estimatedVelocity = projectedRemainder / 0.2
    return min(
        dayVerticalMomentumMaximumVelocity,
        max(-dayVerticalMomentumMaximumVelocity, estimatedVelocity)
    )
}
