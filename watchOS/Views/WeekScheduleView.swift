// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 按自然日分组的完整课程列表。
///
/// 列表与日视图复用 `CourseRow`，从而保证课程、考试和实验的颜色、地点及
/// 教师/座位信息使用同一套展示规则。
struct CourseListView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var didPositionInitialDate = false
    let onCrownInteraction: () -> Void

    /// Store 在 App 启动或课表原子替换时已经完成分组，这里只读取结果。
    private var groups: [WatchCourseDayGroup] {
        store.courseListGroups
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            InteractionAwareScrollView(
                onScroll: onCrownInteraction,
                centersShortContent: true,
                protectsInitialTopEdge: true
            ) {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "暂无课程",
                        systemImage: "list.bullet"
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(groups) { group in
                            Text(
                                group.date,
                                format: .dateTime
                                    .month()
                                    .day()
                                    .weekday(.wide)
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.top, 2)
                            .padding(.trailing, 32)
                            .id(group.date)

                            ForEach(group.courses) { course in
                                CourseRow(
                                    course: course,
                                    showsInlineMetadata: true
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 1)
                }
            }
            .onAppear {
                positionInitialDate(using: scrollProxy)
            }
            .onChange(of: groups.map(\.date)) { _, _ in
                positionInitialDate(using: scrollProxy)
            }
        }
    }

    /// 首次进入课程列表时定位到今天；今天无课则定位到最近的日程日期。
    private func positionInitialDate(using scrollProxy: ScrollViewProxy) {
        guard !didPositionInitialDate,
              let targetDate = initialTargetDate
        else {
            return
        }
        didPositionInitialDate = true

        // 等待列表完成首轮布局后再定位；锚点放在中间，避免目标日期标题
        // 被顶部状态栏虚化遮住。
        DispatchQueue.main.async {
            scrollProxy.scrollTo(targetDate, anchor: .center)
        }
    }

    /// 今天优先；没有今天时按自然日距离选择最近日期，同距离时优先未来。
    private var initialTargetDate: Date? {
        store.courseListInitialDate
    }
}

/// 单日课程视图。
///
/// 日视图只负责日期切换和列表展示；按需求禁止从这里打开详情页。
/// 日视图收到表冠输入后要执行的唯一操作。
///
/// 先计算路由、再执行视觉更新，可以保证“课程滚动、边界拖动、横向翻日”
/// 三种状态互斥，也让主事件处理函数保持可审计。
private enum DayCrownRoute {
    case horizontalPage
    case course(direction: Int)
    case dayBoundary(direction: Int)
}

struct DayScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var crownValue = 0.0
    @State private var lastCrownEventOffset = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var boundaryDragOffset: CGFloat = 0
    @State private var continuousDayNavigation = false
    @State private var boundaryHapticPlayed = false
    @State private var selectedCourseIndex = 0
    @State private var horizontalPageOffset: CGFloat = 0
    @State private var lastHorizontalTouchTranslation: CGFloat = 0
    @State private var horizontalPageWidth: CGFloat = 1
    @State private var horizontalCrownVelocity: CGFloat = 0
    @State private var pageTransitionToken = 0
    @State private var pageTransitionTask: Task<Void, Never>?
    @State private var pageTransitionInFlight = false
    @FocusState private var crownFocused: Bool
    let onCrownInteraction: () -> Void

    /// 累计四个表冠小刻度后平滑滚动到相邻课程卡片。
    ///
    /// 表冠每个原始 detent 为 0.25；阈值 1.0 只降低当天内容的纵向浏览
    /// 速度，不会改变进入翻日状态后的横向页面位移倍率。
    private let cardScrollThreshold = 1.0

    /// 到达列表边界后，每个逻辑刻度推动内容移动的屏幕高度比例。
    ///
    /// 日期切换阈值单独固定为二分之一屏，因此这里仅决定拖动的细腻程度，
    /// 不会让少量误触提前切换日期。
    private let boundaryDragStepRatio: CGFloat = 0.025

    /// 内容必须在表盘内实际越过二分之一可视高度，才允许切换日期。
    private let boundarySwitchDistanceRatio: CGFloat = 1.0 / 2.0

    /// 当前选中日期内开始的全部日程。
    private var courses: [WatchCourse] {
        store.courses(on: selectedDate)
    }

    var body: some View {
        CalendarHorizontalPager(
            pageOffset: horizontalPageOffset,
            page: dayPage,
            onViewportWidthChange: { horizontalPageWidth = max(1, $0) },
            onHorizontalDragBegan: beginDayHorizontalDrag,
            onHorizontalDragChanged: updateDayHorizontalDrag,
            onHorizontalDragEnded: finishDayHorizontalDrag
        )
        .onAppear {
            crownFocused = true
            lastCrownEventOffset = crownValue
            selectedCourseIndex = 0
            resetBoundaryDrag(animated: false)
        }
        .onDisappear {
            pageTransitionTask?.cancel()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DateNavigationHeader(
                    title: selectedDate.formatted(
                        .dateTime
                            .month()
                            .day()
                            .weekday(.short)
                            .locale(WatchWidgetShared.preferredLocale)
                    ),
                    previous: { requestDayPage(-1) },
                    next: { requestDayPage(1) }
                )
                .frame(width: 116)
                .offset(y: -10)
            }
        }
    }

    /// 预先渲染前一天、当天和后一天；三页共用同一个横向触摸检测层。
    ///
    /// 中间页保留原生纵向 `ScrollView`，分页层只在轴锁定为横向后改变
    /// `x` 偏移，因此上下滚动与左右翻页不会再由两个自定义手势竞争。
    @ViewBuilder
    private func dayPage(_ relativePage: Int) -> some View {
        let date = Calendar.current.date(
            byAdding: .day,
            value: relativePage,
            to: selectedDate
        ) ?? selectedDate

        GeometryReader { viewport in
            if relativePage == 0 {
                ScrollViewReader { scrollProxy in
                    ZStack(alignment: .bottomLeading) {
                        dayContent(
                            on: date,
                            in: viewport.size,
                            boundaryOffset: boundaryDragOffset,
                            isInteractive: true
                        )

                        dayCrownObserver(
                            scrollProxy: scrollProxy,
                            viewportHeight: viewport.size.height
                        )
                    }
                }
            } else {
                dayContent(
                    on: date,
                    in: viewport.size,
                    boundaryOffset: 0,
                    isInteractive: false
                )
            }
        }
        .allowsHitTesting(relativePage == 0)
    }

    /// 生成任意一天的原有内容布局，供横向分页器的三页复用。
    @ViewBuilder
    private func dayContent(
        on date: Date,
        in viewportSize: CGSize,
        boundaryOffset: CGFloat,
        isInteractive: Bool
    ) -> some View {
        let dayCourses = store.courses(on: date)
        if dayCourses.isEmpty {
            emptyDayState(
                in: viewportSize,
                boundaryOffset: boundaryOffset
            )
        } else {
            InteractionAwareScrollView(
                onScroll: isInteractive ? onCrownInteraction : {},
                protectsInitialTopEdge: true,
                alwaysProtectsInitialTopEdge: true,
                protectedTopInsetRatio: 0.25
            ) {
                LazyVStack(spacing: 5) {
                    ForEach(dayCourses) { course in
                        CourseRow(
                            course: course,
                            showsInlineMetadata: true
                        )
                        .id(course.id)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 1)
            }
            // 每个日期使用独立滚动标识，防止前后页复用旧的纵向偏移。
            .id(date)
            .scrollDisabled(!isInteractive)
            .offset(y: boundaryOffset)
        }
    }

    /// 无课程时的图标和提示保持垂直居中，并限制边界拖动后的可见范围。
    ///
    /// `boundaryDragOffset` 仍记录用户完整的二分之一屏拖动距离；这里只对
    /// 可见位置做钳制，确保提示最高不进入系统顶部栏，最低不越过屏幕底边。
    private func emptyDayState(
        in viewportSize: CGSize,
        boundaryOffset: CGFloat
    ) -> some View {
        let contentHeight: CGFloat = 60
        let topLimit = max(28, viewportSize.height * 0.16)
        let bottomLimit = max(
            topLimit + contentHeight,
            viewportSize.height - 4
        )
        let proposedCenterY = viewportSize.height / 2
            + boundaryOffset
        let centerY = min(
            max(
                proposedCenterY,
                topLimit + contentHeight / 2
            ),
            bottomLimit - contentHeight / 2
        )

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
            y: centerY
        )
    }

    /// 透明节点独占日视图的表冠焦点，以便区分慢转滚动和快转切日。
    private func dayCrownObserver(
        scrollProxy: ScrollViewProxy,
        viewportHeight: CGFloat
    ) -> some View {
        Color.clear
            .frame(width: 1, height: 1)
            .focusable()
            .focused($crownFocused)
            .digitalCrownRotation(
                detent: $crownValue,
                from: -1_000,
                through: 1_000,
                by: 0.25,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: false,
                onChange: { event in
                    handleDayCrownChange(
                        event,
                        scrollProxy: scrollProxy,
                        viewportHeight: viewportHeight
                    )
                },
                onIdle: {
                    handleDayCrownIdle(scrollProxy: scrollProxy)
                }
            )
            .accessibilityHidden(true)
    }

    /// 将表冠输入转换为“先滚课程、越过边界后再切日”的两阶段操作。
    ///
    /// 旋转方向始终保持一致：数值增加向下浏览，数值减少向上浏览。只有在
    /// 当前方向已无法继续滚动，并额外越过指定阈值时，才进入相邻日期。
    private func handleDayCrownChange(
        _ event: DigitalCrownEvent,
        scrollProxy: ScrollViewProxy,
        viewportHeight: CGFloat
    ) {
        let delta = frameBoundCrownDelta(
            from: lastCrownEventOffset,
            to: event.offset
        )
        lastCrownEventOffset = event.offset
        guard let update = crownSession.register(delta: delta) else { return }

        onCrownInteraction()
        crownFocused = true
        prepareDayCrownSession(update, scrollProxy: scrollProxy)

        switch dayCrownRoute(for: update.direction) {
        case .horizontalPage:
            applyHorizontalCrownDelta(delta, velocity: event.velocity)
        case let .dayBoundary(direction):
            smoothlyAdvanceDayBoundary(
                direction,
                delta: delta,
                viewportHeight: viewportHeight
            )
        case let .course(direction):
            updateCourseSelectionPreview(
                direction: direction,
                using: scrollProxy
            )
        }
    }

    /// 为新一轮旋转或方向反转准备日视图状态。
    ///
    /// 横向翻日一旦开始，同一轮旋转即使反向也仍由横向分页器接管；只有尚在
    /// 课程列表阶段的反向输入才会清理边界位移并把当前卡片拉回中心。
    private func prepareDayCrownSession(
        _ update: WatchCrownTurnUpdate,
        scrollProxy: ScrollViewProxy
    ) {
        if update.startsNewSession {
            resetBoundaryDrag()
            if abs(horizontalPageOffset) < 0.5 {
                continuousDayNavigation = courses.isEmpty
            }
            boundaryHapticPlayed = false
        }

        guard update.reversesDirection,
              !continuousDayNavigation
        else {
            return
        }
        resetBoundaryDrag()
        recenterCurrentCourse(using: scrollProxy)
        boundaryHapticPlayed = false
    }

    /// 根据当前页面状态选择本次表冠事件的处理路径。
    private func dayCrownRoute(for direction: Int) -> DayCrownRoute {
        if continuousDayNavigation {
            return .horizontalPage
        }
        let nextIndex = selectedCourseIndex + direction
        return courses.indices.contains(nextIndex)
            ? .course(direction: direction)
            : .dayBoundary(direction: direction)
    }

    /// 更新相邻课程的连续预览，并在累计阈值到达时提交选择。
    private func updateCourseSelectionPreview(
        direction: Int,
        using scrollProxy: ScrollViewProxy
    ) {
        previewAdjacentCourse(direction: direction, using: scrollProxy)
        guard crownSession.consume(threshold: cardScrollThreshold) else {
            return
        }
        commitAdjacentCourse(direction, using: scrollProxy)
    }

    /// 每个表冠事件都把当前卡片向相邻卡片连续插值，避免低帧率式跳动。
    private func previewAdjacentCourse(
        direction: Int,
        using scrollProxy: ScrollViewProxy
    ) {
        guard courses.indices.contains(selectedCourseIndex) else { return }
        let progress = crownSession.progress(toward: cardScrollThreshold)
        // 相邻课程卡片通常相距约三分之一屏高；只改变滚动锚点，不改布局。
        let anchorY = CGFloat(
            0.5 - Double(direction) * progress * 0.36
        )
        performWithoutAnimation {
            scrollProxy.scrollTo(
                courses[selectedCourseIndex].id,
                anchor: UnitPoint(x: 0.5, y: anchorY)
            )
        }
    }

    /// 累计到四个小刻度后提交相邻卡片；预览已把它移动到接近中心的位置。
    private func commitAdjacentCourse(
        _ amount: Int,
        using scrollProxy: ScrollViewProxy
    ) {
        let nextIndex = selectedCourseIndex + amount
        guard courses.indices.contains(nextIndex) else { return }
        resetBoundaryDrag()
        boundaryHapticPlayed = false
        selectedCourseIndex = nextIndex
        WatchHaptics.selection()
        performWithoutAnimation {
            scrollProxy.scrollTo(courses[nextIndex].id, anchor: .center)
        }
    }

    /// 到达列表边界后按每个原始 detent 更新位置，同时保持既定总速度。
    private func smoothlyAdvanceDayBoundary(
        _ amount: Int,
        delta: Double,
        viewportHeight: CGFloat
    ) {
        if !boundaryHapticPlayed {
            WatchHaptics.boundary(amount)
            boundaryHapticPlayed = true
        }

        let proposedOffset = proposedDayBoundaryOffset(
            direction: amount,
            delta: delta,
            viewportHeight: viewportHeight
        )
        performWithoutAnimation {
            boundaryDragOffset = proposedOffset
        }

        guard abs(proposedOffset) > dayBoundarySwitchDistance(
            viewportHeight: viewportHeight
        ) else {
            return
        }

        continuousDayNavigation = true
        performWithoutAnimation {
            boundaryDragOffset = 0
            horizontalPageOffset = -CGFloat(amount)
                * horizontalPageWidth * 0.52
        }
    }

    /// 把本次表冠增量换算成日内容在边界处的纵向位移。
    private func proposedDayBoundaryOffset(
        direction: Int,
        delta: Double,
        viewportHeight: CGFloat
    ) -> CGFloat {
        let fullThresholdStep = max(
            8,
            viewportHeight * boundaryDragStepRatio
        )
        let inputFraction = CGFloat(
            min(1, abs(delta) / cardScrollThreshold)
        )
        return boundaryDragOffset
            - CGFloat(direction) * fullThresholdStep * inputFraction
    }

    /// 返回从纵向边界切换到横向翻日所需的固定半屏距离。
    private func dayBoundarySwitchDistance(viewportHeight: CGFloat) -> CGFloat {
        max(1, viewportHeight * boundarySwitchDistanceRatio)
    }

    /// 未达到换卡阈值便停止时，把当前卡片立即吸回中心。
    private func recenterCurrentCourse(using scrollProxy: ScrollViewProxy) {
        guard courses.indices.contains(selectedCourseIndex) else { return }
        withAnimation(.easeOut(duration: 0.08)) {
            scrollProxy.scrollTo(
                courses[selectedCourseIndex].id,
                anchor: .center
            )
        }
    }

    /// 以自然日为单位提交已完成的横向翻页。
    private func moveDay(
        _ amount: Int,
        preservesHorizontalNavigation: Bool = false
    ) {
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: amount,
            to: selectedDate
        ) ?? selectedDate
        guard nextDate != selectedDate else { return }
        selectedCourseIndex = 0
        resetBoundaryDrag(animated: false)
        if !preservesHorizontalNavigation {
            continuousDayNavigation = false
        }
        boundaryHapticPlayed = false
        // 手指、表冠和顶部按钮都在页面真正提交时反馈一次。
        WatchHaptics.navigation(amount)
        selectedDate = nextDate
    }

    /// 顶部按钮与触摸、表冠共用相同的平移和吸附动画。
    private func requestDayPage(_ amount: Int) {
        guard !pageTransitionInFlight else { return }
        crownFocused = true
        onCrownInteraction()
        settleDayPage(direction: amount, velocity: horizontalPageWidth * 2.2)
    }

    private func beginDayHorizontalDrag() {
        guard !pageTransitionInFlight else { return }
        resetBoundaryDrag()
        continuousDayNavigation = false
        lastHorizontalTouchTranslation = 0
        crownFocused = true
        onCrownInteraction()
    }

    private func updateDayHorizontalDrag(_ translation: CGFloat) {
        guard !pageTransitionInFlight else { return }
        let incrementalDelta = translation - lastHorizontalTouchTranslation
        lastHorizontalTouchTranslation = translation
        updateContinuousDayOffset(by: incrementalDelta)
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
        let tickDistance = calendarPageCrownTickDistance(
            pageWidth: horizontalPageWidth,
            velocity: velocity
        )
        let pointDelta = CGFloat(delta / 0.25) * tickDistance
        horizontalCrownVelocity = CGFloat(abs(velocity) / 0.25)
            * tickDistance
        updateContinuousDayOffset(by: -pointDelta)
    }

    /// 页面完整越过一屏时立即无动画换底，再把偏移归一化到中间页附近。
    ///
    /// 视觉上屏幕仍停留在同一张完整页面，但数据基准已经前进/后退一天，
    /// 三页容器马上获得新的相邻页；同一次表冠旋转或手指拖动因此可以持续
    /// 翻过任意多天，而不是等待停下后才能开始下一页。
    private func updateContinuousDayOffset(by delta: CGFloat) {
        guard horizontalPageWidth > 0 else { return }
        var offset = horizontalPageOffset + delta
        var crossedPage = 0
        if offset <= -horizontalPageWidth {
            crossedPage = 1
            offset += horizontalPageWidth
        } else if offset >= horizontalPageWidth {
            crossedPage = -1
            offset -= horizontalPageWidth
        }

        if crossedPage == 0 {
            horizontalPageOffset = offset
            return
        }

        performWithoutAnimation {
            moveDay(
                crossedPage,
                preservesHorizontalNavigation: true
            )
            horizontalPageOffset = offset
        }
    }

    /// 系统确认表冠停止时立即吸附最近日期页。
    private func handleDayCrownIdle(scrollProxy: ScrollViewProxy) {
        guard !pageTransitionInFlight else { return }
        if continuousDayNavigation {
            let direction = nearestPageDirection(
                for: horizontalPageOffset,
                width: horizontalPageWidth
            )
            settleDayPage(
                direction: direction,
                velocity: horizontalCrownVelocity
            )
        } else {
            // 尚未越过半屏时，停止表冠便立即启动纵向边界回弹。
            resetBoundaryDrag()
            recenterCurrentCourse(using: scrollProxy)
            boundaryHapticPlayed = false
            crownSession.reset()
        }
    }

    /// 动画到目标页后才原子替换日期，再无动画复位三页容器的位置。
    private func settleDayPage(direction: Int, velocity: CGFloat) {
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
        withAnimation(
            .timingCurve(0.2, 0.82, 0.2, 1, duration: snap.duration)
        ) {
            horizontalPageOffset = snap.target
        }

        pageTransitionTask = Task { @MainActor in
            try? await Task.sleep(
                nanoseconds: UInt64(
                    (snap.duration + 0.015) * 1_000_000_000
                )
            )
            guard !Task.isCancelled, token == pageTransitionToken else { return }
            if snap.direction != 0 {
                moveDay(snap.direction)
            }
            performWithoutAnimation {
                horizontalPageOffset = 0
            }
            pageTransitionInFlight = false
            continuousDayNavigation = false
            horizontalCrownVelocity = 0
            crownSession.reset()
        }
    }

    /// 清除边界拖动状态；按需要使用弹簧动画恢复原位。
    private func resetBoundaryDrag(animated: Bool = true) {
        guard boundaryDragOffset != 0 else { return }

        if animated {
            withAnimation(.easeOut(duration: 0.06)) {
                boundaryDragOffset = 0
            }
        } else {
            boundaryDragOffset = 0
        }
    }
}

/// 一周七列、最多十节的紧凑课表。
///
/// 色块点击在网格容器中统一做坐标命中测试，空白点击才会唤回浮动按钮；
/// 因而不会再次出现“点中色块却被识别为空白”的手势竞争。
struct WeekScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var anchorDate = Date()
    @Binding var selectedCourse: WatchCourse?
    @State private var crownValue = 0.0
    @State private var lastCrownEventOffset = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var horizontalPageOffset: CGFloat = 0
    @State private var lastHorizontalTouchTranslation: CGFloat = 0
    @State private var horizontalPageWidth: CGFloat = 1
    @State private var horizontalCrownVelocity: CGFloat = 0
    @State private var pageTransitionToken = 0
    @State private var pageTransitionTask: Task<Void, Never>?
    @State private var pageTransitionInFlight = false
    @State private var weekBoundaryHapticPlayed = false
    @State private var restoreCrownFocusTask: Task<Void, Never>?
    @FocusState private var crownFocused: Bool
    let onEmptyTap: () -> Void
    let onCrownInteraction: () -> Void

    /// 当前周的周一零点。
    private var weekStart: Date {
        startOfWeek(containing: anchorDate)
    }

    /// 只保留当前周 `[周一, 下周一)` 内的日程。
    private func courses(in start: Date) -> [WatchCourse] {
        store.courses(startingAt: start, dayCount: 7)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CalendarHorizontalPager(
                pageOffset: horizontalPageOffset,
                page: weekPage,
                onViewportWidthChange: {
                    horizontalPageWidth = max(1, $0)
                },
                onHorizontalDragBegan: beginWeekHorizontalDrag,
                onHorizontalDragChanged: updateWeekHorizontalDrag,
                onHorizontalDragEnded: finishWeekHorizontalDrag
            )

            crownObserver
        }
        .toolbar {
            if selectedCourse == nil {
                ToolbarItem(placement: .topBarLeading) {
                    DateNavigationHeader(
                        title: weekTitle,
                        previous: { requestWeekPage(-1) },
                        next: { requestWeekPage(1) }
                    )
                    .frame(width: 116)
                    .offset(y: -10)
                }
            }
        }
        .onAppear {
            crownFocused = true
            lastCrownEventOffset = crownValue
            clampAnchorToSemester()
        }
        .onChange(of: store.semesterRangeStart) { _, _ in
            clampAnchorToSemester()
        }
        .onChange(of: store.semesterRangeEnd) { _, _ in
            clampAnchorToSemester()
        }
        .onChange(of: selectedCourse?.id) { _, courseID in
            scheduleCrownFocusRestore(afterClosing: courseID == nil)
        }
        .onDisappear {
            restoreCrownFocusTask?.cancel()
            pageTransitionTask?.cancel()
        }
    }

    /// 生成前一周、当前周和后一周；课程网格本身的尺寸与布局保持不变。
    private func weekPage(_ relativePage: Int) -> some View {
        let pageStart = Calendar.current.date(
            byAdding: .day,
            value: relativePage * 7,
            to: weekStart
        ) ?? weekStart

        return GeometryReader { proxy in
            let topBarContentInset = max(26, proxy.size.height * 0.13)
            let weekdayHeight = max(15, proxy.size.height * 0.075)

            VStack(spacing: max(1, proxy.size.height * 0.008)) {
                WeekdayHeader(weekStart: pageStart)
                    .frame(height: weekdayHeight)
                    .offset(y: 2)

                WeekPeriodGrid(
                    weekStart: pageStart,
                    courses: courses(in: pageStart),
                    select: selectCourse,
                    onEmptyTap: handleEmptyTap
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)
            }
            .padding(.top, topBarContentInset)
        }
        .allowsHitTesting(relativePage == 0)
    }

    private func beginWeekHorizontalDrag() {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        lastHorizontalTouchTranslation = 0
        crownFocused = true
        onCrownInteraction()
    }

    private func updateWeekHorizontalDrag(_ translation: CGFloat) {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        let incrementalDelta = translation - lastHorizontalTouchTranslation
        lastHorizontalTouchTranslation = translation
        updateContinuousWeekOffset(by: incrementalDelta)
    }

    private func finishWeekHorizontalDrag(_ value: DragGesture.Value) {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        let motion = horizontalDragMotion(
            value,
            currentOffset: horizontalPageOffset,
            pageWidth: horizontalPageWidth
        )
        settleWeekPage(direction: motion.direction, velocity: motion.velocity)
    }

    /// 顶部按钮与触摸、表冠共用相同的横向动画。
    private func requestWeekPage(_ amount: Int) {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        crownFocused = true
        onCrownInteraction()
        settleWeekPage(direction: amount, velocity: horizontalPageWidth * 2.2)
    }

    /// 详情完全退出后再把表冠焦点交还周视图。
    ///
    /// 立即聚焦底层周视图会与详情的移除转场争夺实体表上的 Crown/Scroll
    /// 响应器。延迟略长于 0.38 秒弹簧主响应时间，可避免真机保留详情命中
    /// 层；模拟器与真机随后都恢复相同的周视图表冠行为。
    private func scheduleCrownFocusRestore(afterClosing: Bool) {
        restoreCrownFocusTask?.cancel()
        guard afterClosing else {
            crownFocused = false
            return
        }

        restoreCrownFocusTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 420_000_000)
            guard !Task.isCancelled, selectedCourse == nil else { return }
            crownFocused = true
        }
    }

    /// 优先采用手机同步的周次参考；缺少参考时按学期开始日期推算。
    private var weekTitle: String {
        if let reference = store.synchronizedWeekReference {
            let referenceWeek = startOfWeek(containing: reference.date)
            let elapsedDays = Calendar.current.dateComponents(
                [.day],
                from: referenceWeek,
                to: weekStart
            ).day ?? 0
            let zeroBasedIndex = reference.zeroBasedIndex + elapsedDays / 7
            return localizedWeekNumber(max(1, zeroBasedIndex + 1))
        }

        let termStart = startOfWeek(
            containing: store.semesterStart ?? weekStart
        )
        let elapsedDays = Calendar.current.dateComponents(
            [.day],
            from: termStart,
            to: weekStart
        ).day ?? 0
        return localizedWeekNumber(max(1, elapsedDays / 7 + 1))
    }

    /// 左右按钮按整周移动，并限制在手机端相同的整学期周次范围内。
    @discardableResult
    private func moveWeek(
        _ amount: Int,
        playsBoundaryFeedback: Bool = true
    ) -> Bool {
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: amount * 7,
            to: anchorDate
        ) ?? anchorDate
        guard nextDate != anchorDate else { return false }

        guard isWeekInsideSemester(nextDate) else {
            if playsBoundaryFeedback {
                WatchHaptics.boundary(amount)
            }
            return false
        }

        WatchHaptics.navigation(amount)
        anchorDate = nextDate
        return true
    }

    /// 将表冠的连续刻度直接映射成页面像素，速度越快每刻度推进越多。
    private func applyWeekCrownDelta(
        _ delta: Double,
        velocity: Double
    ) {
        guard !pageTransitionInFlight else { return }
        let tickDistance = calendarPageCrownTickDistance(
            pageWidth: horizontalPageWidth,
            velocity: velocity
        )
        let pointDelta = CGFloat(delta / 0.25) * tickDistance
        horizontalCrownVelocity = CGFloat(abs(velocity) / 0.25)
            * tickDistance
        updateContinuousWeekOffset(by: -pointDelta)
    }

    /// 完整跨过一屏后立即换底，使同一次表冠旋转可以无缝连续翻周。
    private func updateContinuousWeekOffset(by delta: CGFloat) {
        guard horizontalPageWidth > 0 else { return }
        var offset = horizontalPageOffset + delta

        // 学期首尾只显示带阻尼的边缘位移，不允许无效相邻周占满屏幕。
        let attemptedDirection = offset < 0 ? 1 : -1
        let candidate = Calendar.current.date(
            byAdding: .day,
            value: attemptedDirection * 7,
            to: anchorDate
        ) ?? anchorDate
        if offset != 0, !isWeekInsideSemester(candidate) {
            if !weekBoundaryHapticPlayed {
                WatchHaptics.boundary(attemptedDirection)
                weekBoundaryHapticPlayed = true
            }
            let resisted = min(
                horizontalPageWidth * 0.2,
                abs(offset) * 0.18
            )
            horizontalPageOffset = (offset < 0 ? -1 : 1) * resisted
            return
        }
        weekBoundaryHapticPlayed = false

        var crossedPage = 0
        if offset <= -horizontalPageWidth {
            crossedPage = 1
            offset += horizontalPageWidth
        } else if offset >= horizontalPageWidth {
            crossedPage = -1
            offset -= horizontalPageWidth
        }

        guard crossedPage != 0 else {
            horizontalPageOffset = offset
            return
        }

        performWithoutAnimation {
            _ = moveWeek(crossedPage, playsBoundaryFeedback: false)
            horizontalPageOffset = offset
        }
    }

    /// 系统报告表冠空闲时立刻吸附最近周。
    private func handleWeekCrownIdle() {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        let direction = nearestPageDirection(
            for: horizontalPageOffset,
            width: horizontalPageWidth
        )
        settleWeekPage(
            direction: direction,
            velocity: horizontalCrownVelocity
        )
    }

    /// 动画结束后提交周次；越过学期边界时回弹并使用既有边界反馈。
    private func settleWeekPage(direction: Int, velocity: CGFloat) {
        var direction = min(1, max(-1, direction))
        if direction != 0 {
            let candidate = Calendar.current.date(
                byAdding: .day,
                value: direction * 7,
                to: anchorDate
            ) ?? anchorDate
            if !isWeekInsideSemester(candidate) {
                WatchHaptics.boundary(direction)
                direction = 0
            }
        }

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
        withAnimation(
            .timingCurve(0.2, 0.82, 0.2, 1, duration: snap.duration)
        ) {
            horizontalPageOffset = snap.target
        }

        pageTransitionTask = Task { @MainActor in
            try? await Task.sleep(
                nanoseconds: UInt64(
                    (snap.duration + 0.015) * 1_000_000_000
                )
            )
            guard !Task.isCancelled, token == pageTransitionToken else { return }
            if snap.direction != 0 {
                _ = moveWeek(
                    snap.direction,
                    playsBoundaryFeedback: false
                )
            }
            performWithoutAnimation {
                horizontalPageOffset = 0
            }
            pageTransitionInFlight = false
            horizontalCrownVelocity = 0
            weekBoundaryHapticPlayed = false
            crownSession.reset()
        }
    }

    /// 判断目标周是否落在手机可浏览的 `semesterLength` 个周页面内。
    private func isWeekInsideSemester(_ date: Date) -> Bool {
        guard let bounds = semesterWeekBounds else {
            // 缓存缺少完整学期元数据时暂不限制范围；学期快照安装后
            // `onChange` 会立即校正当前周。
            return true
        }
        let target = startOfWeek(containing: date)
        return target >= bounds.first && target <= bounds.last
    }

    /// 把当前周钳制到手机端的第一周或最后一周。
    private func clampAnchorToSemester() {
        guard let bounds = semesterWeekBounds else { return }
        let current = startOfWeek(containing: anchorDate)
        let clamped = min(max(current, bounds.first), bounds.last)
        guard clamped != current else { return }
        anchorDate = clamped
    }

    /// 把同步快照的左闭右开日期范围换算成首、末周的周一。
    private var semesterWeekBounds: (first: Date, last: Date)? {
        guard let rangeStart = store.semesterRangeStart,
              let rangeEnd = store.semesterRangeEnd,
              rangeEnd > rangeStart
        else {
            return nil
        }

        let first = startOfWeek(containing: rangeStart)
        // `rangeEnd` 是右开边界，减去一秒后才属于手机最后一个周页面。
        let lastIncludedDate = rangeEnd.addingTimeInterval(-1)
        let last = startOfWeek(containing: lastIncludedDate)
        return (first, max(first, last))
    }

    /// 打开课程详情前取消表冠焦点并隐藏根页面悬浮按钮。
    private func selectCourse(_ course: WatchCourse) {
        crownFocused = false
        onCrownInteraction()
        WatchHaptics.selection()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
            selectedCourse = course
        }
    }

    /// 空白区域轻点只恢复控件，不改变课程选择。
    private func handleEmptyTap() {
        crownFocused = true
        onEmptyTap()
    }

    /// 透明焦点节点只观察表冠旋转，不参与可见布局和点击命中。
    private var crownObserver: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .focusable()
            .focused($crownFocused)
            .digitalCrownRotation(
                detent: $crownValue,
                from: -1_000,
                through: 1_000,
                by: 0.25,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: false,
                onChange: { event in
                    handleWeekCrownChange(event)
                },
                onIdle: {
                    handleWeekCrownIdle()
                }
            )
            .accessibilityHidden(true)
    }

    /// 周视图一开始转动表冠就进入横向拖页，停止后自动吸附最近页。
    private func handleWeekCrownChange(
        _ event: DigitalCrownEvent
    ) {
        guard selectedCourse == nil else { return }
        let delta = frameBoundCrownDelta(
            from: lastCrownEventOffset,
            to: event.offset
        )
        lastCrownEventOffset = event.offset
        guard crownSession.register(delta: delta) != nil else { return }

        onCrownInteraction()
        applyWeekCrownDelta(delta, velocity: event.velocity)
    }
}

/// 单个触摸层判定横向翻页或纵向滚动的轴向。
private enum CalendarPagingDragAxis {
    case horizontal
    case vertical
}

/// 仿系统日历的三页横向容器。
///
/// 前一页、当前页、后一页始终并排预渲染，外部只需要提供一个连续像素偏移。
/// 手指横拖和表冠旋转因此能看到同一套跟手动画；日期数据只在吸附动画结束
/// 后替换，避免中途出现空白或旧页闪烁。
private struct CalendarHorizontalPager<Page: View>: View {
    let pageOffset: CGFloat
    let page: (Int) -> Page
    let onViewportWidthChange: (CGFloat) -> Void
    let onHorizontalDragBegan: () -> Void
    let onHorizontalDragChanged: (CGFloat) -> Void
    let onHorizontalDragEnded: (DragGesture.Value) -> Void

    @State private var dragAxis: CalendarPagingDragAxis?
    @State private var horizontalDragStarted = false

    init(
        pageOffset: CGFloat,
        @ViewBuilder page: @escaping (Int) -> Page,
        onViewportWidthChange: @escaping (CGFloat) -> Void,
        onHorizontalDragBegan: @escaping () -> Void,
        onHorizontalDragChanged: @escaping (CGFloat) -> Void,
        onHorizontalDragEnded: @escaping (DragGesture.Value) -> Void
    ) {
        self.pageOffset = pageOffset
        self.page = page
        self.onViewportWidthChange = onViewportWidthChange
        self.onHorizontalDragBegan = onHorizontalDragBegan
        self.onHorizontalDragChanged = onHorizontalDragChanged
        self.onHorizontalDragEnded = onHorizontalDragEnded
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(-1...1, id: \.self) { relativePage in
                    page(relativePage)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                }
            }
            .frame(
                width: proxy.size.width * 3,
                height: proxy.size.height,
                alignment: .leading
            )
            .offset(x: -proxy.size.width + pageOffset)
            .contentShape(Rectangle())
            // 日视图只挂这一层自定义 DragGesture。锁定横向时由分页器处理，
            // 锁定纵向时完全不改偏移，让中间页的原生 ScrollView 跟手。
            .simultaneousGesture(pagingGesture)
            .onAppear {
                onViewportWidthChange(proxy.size.width)
            }
            .onChange(of: proxy.size.width) { _, width in
                onViewportWidthChange(width)
            }
        }
        .clipped()
    }

    private var pagingGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .local)
            .onChanged { value in
                if dragAxis == nil {
                    let horizontal = abs(value.translation.width)
                    let vertical = abs(value.translation.height)
                    guard max(horizontal, vertical) >= 5 else { return }
                    dragAxis = horizontal > vertical
                        ? .horizontal
                        : .vertical
                }

                guard dragAxis == .horizontal else { return }
                if !horizontalDragStarted {
                    horizontalDragStarted = true
                    onHorizontalDragBegan()
                }
                onHorizontalDragChanged(value.translation.width)
            }
            .onEnded { value in
                if dragAxis == .horizontal, horizontalDragStarted {
                    onHorizontalDragEnded(value)
                }
                dragAxis = nil
                horizontalDragStarted = false
            }
    }
}

/// 一次触摸结束时推算出的目标页和横向速度。
private struct HorizontalPageMotion {
    let direction: Int
    let velocity: CGFloat
}

/// 一次吸附动画已经归一化的方向、终点和时长。
private struct HorizontalPageSnap {
    let direction: Int
    let target: CGFloat
    let duration: Double
}

/// 在不触发隐式动画的事务中原子更新分页或滚动状态。
///
/// 三页容器跨过整页后需要同时切换数据基准并归一化偏移；统一使用该函数可
/// 避免某个调用点遗漏 `transaction.animation = nil` 而产生闪动。
private func performWithoutAnimation(_ updates: () -> Void) {
    var transaction = Transaction()
    transaction.animation = nil
    withTransaction(transaction) {
        updates()
    }
}

/// 丢弃掉帧期间积压的旧表冠位移，只消费当前绘制周期内合理的输入量。
///
/// `DigitalCrownEvent.offset` 可能在主线程繁忙后一次跳过很多 detent。如果把
/// 差值全量应用，页面会在动画恢复时突然追赶。限制为两个 0.25 小刻度后，
/// 当前速度仍参与位移倍率，但历史积压不会污染下一帧。
private func frameBoundCrownDelta(
    from previousOffset: Double,
    to currentOffset: Double
) -> Double {
    min(0.5, max(-0.5, currentOffset - previousOffset))
}

/// 日、周视图统一的表冠速度倍率，确保两个页面具有相同的机械手感。
private func calendarPageCrownSpeedScale(_ velocity: Double) -> Double {
    min(2.0, max(0.85, 0.8 + abs(velocity) * 0.09))
}

/// 把一个表冠小刻度换算成日、周分页共用的横向像素行程。
private func calendarPageCrownTickDistance(
    pageWidth: CGFloat,
    velocity: Double
) -> CGFloat {
    pageWidth * 0.044 * calendarPageCrownSpeedScale(velocity)
}

/// 结合实际位移和系统预测位移，选择最接近的前/当前/后页。
private func horizontalDragMotion(
    _ value: DragGesture.Value,
    currentOffset: CGFloat,
    pageWidth: CGFloat
) -> HorizontalPageMotion {
    let projectedRemainder = value.predictedEndTranslation.width
        - value.translation.width
    let projectedOffset = currentOffset + projectedRemainder * 0.28
    let direction = nearestPageDirection(
        for: projectedOffset,
        width: pageWidth
    )
    // `predictedEndTranslation` 通常覆盖约 0.2 秒减速过程，用它估算速度
    // 可以让快甩吸附更利落、慢拖吸附更柔和。
    let velocity = abs(projectedRemainder) / 0.2
    return HorizontalPageMotion(direction: direction, velocity: velocity)
}

/// 偏移超过半页时选择相邻页，否则回到当前页。
private func nearestPageDirection(
    for offset: CGFloat,
    width: CGFloat
) -> Int {
    guard width > 0 else { return 0 }
    if offset <= -width / 2 { return 1 }
    if offset >= width / 2 { return -1 }
    return 0
}

/// 统一生成日、周页面的吸附参数。
///
/// 调用方可以在生成前按业务范围调整方向，例如周视图在学期边界把方向改为
/// `0`。这里仅处理视觉参数，不修改日期、周次或触觉状态。
private func horizontalPageSnap(
    direction: Int,
    currentOffset: CGFloat,
    velocity: CGFloat,
    width: CGFloat
) -> HorizontalPageSnap {
    let normalizedDirection = min(1, max(-1, direction))
    let target = -CGFloat(normalizedDirection) * width
    return HorizontalPageSnap(
        direction: normalizedDirection,
        target: target,
        duration: pageSnapDuration(
            from: currentOffset,
            to: target,
            velocity: velocity,
            width: width
        )
    )
}

/// 根据剩余距离与输入速度选择短促吸附时长。
///
/// 系统 `onIdle` 会立即触发；这里把动画限制在 35–65ms，只保留两到四帧
/// 完成视觉收口，避免表冠已经松开后页面仍长时间移动。
private func pageSnapDuration(
    from current: CGFloat,
    to target: CGFloat,
    velocity: CGFloat,
    width: CGFloat
) -> Double {
    let remainingRatio = min(1, abs(target - current) / max(1, width))
    let normalizedVelocity = abs(velocity) / max(1, width)
    let distanceDuration = 0.035 + Double(remainingRatio) * 0.03
    return min(
        0.065,
        max(
            0.035,
            distanceDuration / (1 + Double(normalizedVelocity) * 0.08)
        )
    )
}

/// 日/周视图左上角共用的日期导航条。
private struct DateNavigationHeader: View {
    let title: String
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        HStack(spacing: 1) {
            Image(systemName: "chevron.left")
                .frame(width: 18, height: 20)
                .accessibilityHidden(true)

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .monospacedDigit()
                .frame(maxWidth: .infinity)

            Image(systemName: "chevron.right")
                .frame(width: 18, height: 20)
                .accessibilityHidden(true)
        }
        .frame(height: 22)
        // 两个透明按钮通过 overlay 扩大热区，不参与 HStack 宽度计算，
        // 日期文字的可用宽度和缩放比例保持稳定。
        .overlay(alignment: .leading) {
            Button(action: previous) {
                Color.clear
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("上一项")
        }
        .overlay(alignment: .trailing) {
            Button(action: next) {
                Color.clear
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("下一项")
        }
    }
}

/// 周网格顶部的月份、星期和日期行。
private struct WeekdayHeader: View {
    let weekStart: Date

    var body: some View {
        GeometryReader { proxy in
            let fontSize = max(6, min(8, proxy.size.width * 0.035))
            let labelWidth = max(11, min(15, proxy.size.width * 0.075))
            let symbols = mondayFirstWeekdaySymbols()
            HStack(spacing: 0) {
                Text(weekStart, format: .dateTime.month(.abbreviated))
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .frame(width: labelWidth)

                ForEach(0..<7, id: \.self) { index in
                    let date = Calendar.current.date(
                        byAdding: .day,
                        value: index,
                        to: weekStart
                    ) ?? weekStart
                    VStack(spacing: -1) {
                        Text(symbols[index])
                        Text(date, format: .dateTime.day())
                    }
                    .font(.system(size: fontSize, weight: .medium))
                    .frame(maxWidth: .infinity)
                    // 今天的表头使用不参与布局的淡色背景，避免改变原有列宽。
                    // 它会与网格中的同列高亮带连成一条完整的“今天”标记。
                    .background {
                        if Calendar.current.isDateInToday(date) {
                            RoundedRectangle(
                                cornerRadius: 2,
                                style: .continuous
                            )
                            .fill(Color.accentColor.opacity(0.18))
                        }
                    }
                    .foregroundStyle(
                        Calendar.current.isDateInToday(date)
                            ? Color.accentColor
                            : Color.secondary
                    )
                }
            }
        }
    }
}

/// 周课表的节次网格、课程色块和点击命中区域。
private struct WeekPeriodGrid: View {
    let weekStart: Date
    let courses: [WatchCourse]
    let select: (WatchCourse) -> Void
    let onEmptyTap: () -> Void

    private let maximumPeriod = 10
    private let totalUnits: CGFloat = 56

    /// 第 11 节及之后开始的课程不进入当前 1–10 节网格。
    private var visibleCourses: [WatchCourse] {
        courses.filter { $0.startPeriod <= maximumPeriod }
    }

    var body: some View {
        GeometryReader { proxy in
            let labelWidth = max(11, min(15, proxy.size.width * 0.075))
            let labelFontSize = max(5.5, min(7, proxy.size.width * 0.032))
            let columnWidth = max(1, (proxy.size.width - labelWidth) / 7)
            let unitHeight = max(0.5, proxy.size.height / totalUnits)

            ZStack(alignment: .topLeading) {
                Color.clear

                todayColumnHighlight(
                    size: proxy.size,
                    labelWidth: labelWidth,
                    columnWidth: columnWidth
                )

                gridLines(
                    size: proxy.size,
                    labelWidth: labelWidth,
                    columnWidth: columnWidth,
                    unitHeight: unitHeight
                )

                ForEach(1...maximumPeriod, id: \.self) { period in
                    Text("\(period)")
                        .font(.system(size: labelFontSize, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: labelWidth, height: 8)
                        .offset(
                            x: 0,
                            y: periodStartUnit(period) * unitHeight
                                + 2.5 * unitHeight - 4
                        )
                }

                ForEach(visibleCourses) { course in
                    let start = periodStartUnit(course.startPeriod)
                    let end = periodEndUnit(course.endPeriod)
                    let weekday = weekdayIndex(for: course.startAt)

                    RoundedRectangle(
                        cornerRadius: 2.5,
                        style: .continuous
                    )
                    .fill(course.color)
                    .frame(
                        width: max(3, columnWidth - 1.5),
                        height: max(3, (end - start) * unitHeight - 1)
                    )
                    .offset(
                        x: labelWidth + CGFloat(weekday) * columnWidth + 0.75,
                        y: start * unitHeight + 0.5
                    )
                    .contentShape(Rectangle())
                    .accessibilityLabel(
                        localizedCoursePeriodRange(course)
                    )
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction {
                        select(course)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        if let course = course(
                            at: value.location,
                            labelWidth: labelWidth,
                            columnWidth: columnWidth,
                            unitHeight: unitHeight
                        ) {
                            select(course)
                        } else {
                            onEmptyTap()
                        }
                    }
            )
        }
    }

    /// 当前展示周包含今天时，在今天所在列的底层绘制一条淡色高亮带。
    ///
    /// 高亮位于网格线和课程色块下方，不会覆盖课程颜色，也不会参与手势命中；
    /// 原有色块坐标命中算法因此保持不变。
    @ViewBuilder
    private func todayColumnHighlight(
        size: CGSize,
        labelWidth: CGFloat,
        columnWidth: CGFloat
    ) -> some View {
        if let column = todayColumnIndex {
            Rectangle()
                .fill(Color.accentColor.opacity(0.09))
                .frame(width: columnWidth, height: size.height)
                .offset(
                    x: labelWidth + CGFloat(column) * columnWidth,
                    y: 0
                )
                .accessibilityHidden(true)
        }
    }

    /// 仅当今天位于当前展示的七天范围内时，返回“周一为 0”的列序号。
    private var todayColumnIndex: Int? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let displayedStart = calendar.startOfDay(for: weekStart)
        let displayedEnd = calendar.date(
            byAdding: .day,
            value: 7,
            to: displayedStart
        ) ?? displayedStart

        guard today >= displayedStart, today < displayedEnd else {
            return nil
        }
        return weekdayIndex(for: today)
    }

    /// 在与绘制完全相同的几何参数下执行命中测试。
    ///
    /// `last` 与 ZStack 最后绘制者优先的规则一致；即使未来出现重叠课程，
    /// 用户点到的也会是视觉上位于最上层的色块。
    private func course(
        at location: CGPoint,
        labelWidth: CGFloat,
        columnWidth: CGFloat,
        unitHeight: CGFloat
    ) -> WatchCourse? {
        visibleCourses.last { course in
            let start = periodStartUnit(course.startPeriod)
            let end = periodEndUnit(course.endPeriod)
            let weekday = weekdayIndex(for: course.startAt)
            let frame = CGRect(
                x: labelWidth + CGFloat(weekday) * columnWidth + 0.75,
                y: start * unitHeight + 0.5,
                width: max(3, columnWidth - 1.5),
                height: max(3, (end - start) * unitHeight - 1)
            )
            return frame.contains(location)
        }
    }

    /// 绘制七列和十节课的辅助线。
    private func gridLines(
        size: CGSize,
        labelWidth: CGFloat,
        columnWidth: CGFloat,
        unitHeight: CGFloat
    ) -> some View {
        Path { path in
            for column in 0...7 {
                let x = labelWidth + CGFloat(column) * columnWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            for period in 1...maximumPeriod {
                let y = periodStartUnit(period) * unitHeight
                path.move(to: CGPoint(x: labelWidth, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            path.move(to: CGPoint(x: labelWidth, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
        }
        .stroke(.secondary.opacity(0.18), lineWidth: 0.5)
    }

    /// 把节次映射到纵向布局单位；第 4、8 节后各留出午休/晚休间隔。
    private func periodStartUnit(_ period: Int) -> CGFloat {
        let period = min(maximumPeriod, max(1, period))
        if period <= 4 {
            return CGFloat(period - 1) * 5
        }
        if period <= 8 {
            return CGFloat(period - 1) * 5 + 3
        }
        return CGFloat(period - 1) * 5 + 6
    }

    /// 每节课固定占五个纵向单位。
    private func periodEndUnit(_ period: Int) -> CGFloat {
        periodStartUnit(period) + 5
    }

    /// 将 Foundation 的周日为 1 转换为周一为 0。
    private func weekdayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return max(0, min(6, (weekday + 5) % 7))
    }
}

/// 按手机端相同的系统区域规则，生成“第 N 周”标题。
private func localizedWeekNumber(_ number: Int) -> String {
    String.localizedStringWithFormat(
        watchLocalizedString("第%lld周"),
        Int64(number)
    )
}

/// 获取系统本地化的极短星期符号，并转换为周一到周日顺序。
///
/// 简体/繁体中文分别得到“一…日”，英语得到“M…S”，既能适配窄表盘，
/// 也避免手工维护三套星期缩写。
private func mondayFirstWeekdaySymbols() -> [String] {
    var calendar = Calendar.current
    calendar.locale = WatchWidgetShared.preferredLocale
    let symbols = calendar.veryShortStandaloneWeekdaySymbols
    guard symbols.count == 7 else {
        return ["M", "T", "W", "T", "F", "S", "S"]
    }
    return Array(symbols[1...6]) + [symbols[0]]
}

/// 生成 VoiceOver 使用的本地化节次范围。
private func localizedCoursePeriodRange(_ course: WatchCourse) -> String {
    String.localizedStringWithFormat(
        watchLocalizedString("%1$@，第%2$lld到第%3$lld节"),
        course.name,
        Int64(course.startPeriod),
        Int64(course.endPeriod)
    )
}

/// 返回给定日期所在周的周一零点。
private func startOfWeek(containing date: Date) -> Date {
    let calendar = Calendar.current
    let day = calendar.startOfDay(for: date)
    let weekday = calendar.component(.weekday, from: day)
    return calendar.date(
        byAdding: .day,
        value: -(weekday + 5) % 7,
        to: day
    ) ?? day
}

/// 能检测触摸/表冠导致的滚动，并通知根页面隐藏悬浮按钮。
struct InteractionAwareScrollView<Content: View>: View {
    let onScroll: () -> Void
    var centersShortContent = false
    var protectsInitialTopEdge = false
    var alwaysProtectsInitialTopEdge = false
    var protectedTopInsetRatio: CGFloat = 0.13
    @ViewBuilder let content: () -> Content
    @State private var previousOffset: CGFloat?
    @State private var intrinsicContentHeight: CGFloat = 0

    var body: some View {
        GeometryReader { viewport in
            let protectedTopInset = max(
                26,
                viewport.size.height * protectedTopInsetRatio
            )
            let contentOverflows = intrinsicContentHeight
                + (protectsInitialTopEdge ? protectedTopInset : 0)
                > viewport.size.height
            let shouldProtectTopEdge = protectsInitialTopEdge
                && (alwaysProtectsInitialTopEdge || contentOverflows)
            let initialTopInset = shouldProtectTopEdge
                ? protectedTopInset
                : 0

            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(
                            in: .named("watchScheduleScroll")
                        ).minY
                    )
                }
                .frame(height: 0)

                content()
                    // 先测量内容的自然高度，再决定使用居中还是顶部布局。
                    // 测量器放在最小高度 frame 之前，避免把视口高度误认为
                    // 内容自身高度。
                    .fixedSize(horizontal: false, vertical: true)
                    .background {
                        GeometryReader { contentProxy in
                            Color.clear.preference(
                                key: ScrollContentHeightPreferenceKey.self,
                                value: contentProxy.size.height
                            )
                        }
                    }
                    .frame(
                        minHeight: max(
                            0,
                            viewport.size.height - initialTopInset
                        ),
                        alignment: centersShortContent && !contentOverflows
                            ? .center
                            : .top
                    )
                    // 长内容首次打开时从状态栏下方开始；这段 padding 位于
                    // ScrollView 内，用户转动表冠或上滑后仍可进入顶部虚化区。
                    .padding(.top, initialTopInset)
            }
            .coordinateSpace(name: "watchScheduleScroll")
            .scrollIndicators(.hidden)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                guard let previousOffset else {
                    self.previousOffset = offset
                    return
                }
                self.previousOffset = offset
                guard abs(offset - previousOffset) > 0.25 else { return }
                onScroll()
            }
            .onPreferenceChange(
                ScrollContentHeightPreferenceKey.self
            ) { height in
                guard abs(height - intrinsicContentHeight) > 0.5 else {
                    return
                }
                intrinsicContentHeight = height
            }
        }
    }
}

/// 在滚动内容与外层视图之间传递当前纵向偏移。
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 记录滚动内容未施加视口最小高度前的自然高度。
///
/// 根页面据此判断内容能否在一页内完整展示：短内容垂直居中，长内容则保留
/// 一段可滚走的状态栏安全距离。
private struct ScrollContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
