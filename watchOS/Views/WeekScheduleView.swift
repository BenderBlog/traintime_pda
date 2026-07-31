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
struct DayScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var crownValue = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var boundaryDragOffset: CGFloat = 0
    @State private var boundaryInteractionToken = 0
    @State private var boundarySwitchPending = false
    @State private var continuousDayNavigation = false
    @State private var continuousDayPageCount = 0
    @State private var boundaryHapticPlayed = false
    @State private var selectedCourseIndex = 0
    @FocusState private var crownFocused: Bool
    let onCrownInteraction: () -> Void

    /// 累计两个表冠小刻度后平滑滚动到相邻课程卡片。
    private let cardScrollThreshold = 0.5

    /// 进入连续切日状态后需要三个表冠小刻度，避免日期跳动过快。
    private let continuousDaySwitchThreshold = 0.75

    /// 到达列表边界后，每个逻辑刻度推动内容移动的屏幕高度比例。
    ///
    /// 日期切换阈值单独固定为二分之一屏，因此这里仅决定拖动的细腻程度，
    /// 不会让少量误触提前切换日期。
    private let boundaryDragStepRatio: CGFloat = 0.05

    /// 内容必须在表盘内实际越过二分之一可视高度，才允许切换日期。
    private let boundarySwitchDistanceRatio: CGFloat = 1.0 / 2.0

    /// 当前选中日期内开始的全部日程。
    private var courses: [WatchCourse] {
        store.courses(on: selectedDate)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { viewport in
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if courses.isEmpty {
                            emptyDayState(in: viewport.size)
                        } else {
                            InteractionAwareScrollView(
                                onScroll: onCrownInteraction,
                                protectsInitialTopEdge: true,
                                alwaysProtectsInitialTopEdge: true,
                                protectedTopInsetRatio: 0.25
                            ) {
                                LazyVStack(spacing: 5) {
                                    ForEach(courses) { course in
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
                            // 每个日期使用独立滚动标识，避免重新进入日视图时恢复
                            // 到上一次位于顶部虚化区内的旧偏移。
                            .id(selectedDate)
                            // 有课程时整页卡片直接跟随边界拖动。
                            .offset(y: boundaryDragOffset)
                        }
                    }

                    dayCrownObserver(
                        scrollProxy: scrollProxy,
                        viewportHeight: viewport.size.height
                    )
                }
            }
            .onAppear {
                crownFocused = true
                selectedCourseIndex = 0
                resetBoundaryDrag(animated: false)
            }
        }
        .horizontalPageSwipe(
            previous: { handleDaySwipe(-1) },
            next: { handleDaySwipe(1) }
        )
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
                    previous: { moveDay(-1) },
                    next: { moveDay(1) }
                )
                .frame(width: 116)
                .offset(y: -10)
            }
        }
    }

    /// 横滑按自然日翻页，并恢复日视图的表冠焦点。
    ///
    /// 实际日期修改仍统一进入 `moveDay`，所以课程索引、连续表冠状态和
    /// 翻页触觉与顶部左右按钮完全一致。
    private func handleDaySwipe(_ amount: Int) {
        crownFocused = true
        onCrownInteraction()
        moveDay(amount)
    }

    /// 无课程时的图标和提示保持垂直居中，并限制边界拖动后的可见范围。
    ///
    /// `boundaryDragOffset` 仍记录用户完整的二分之一屏拖动距离；这里只对
    /// 可见位置做钳制，确保提示最高不进入系统顶部栏，最低不越过屏幕底边。
    private func emptyDayState(in viewportSize: CGSize) -> some View {
        let contentHeight: CGFloat = 60
        let topLimit = max(28, viewportSize.height * 0.16)
        let bottomLimit = max(
            topLimit + contentHeight,
            viewportSize.height - 4
        )
        let proposedCenterY = viewportSize.height / 2
            + boundaryDragOffset
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
                $crownValue,
                from: -1_000,
                through: 1_000,
                by: 0.25,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: false
            )
            .onChange(of: crownValue) { oldValue, newValue in
                handleDayCrownChange(
                    from: oldValue,
                    to: newValue,
                    scrollProxy: scrollProxy,
                    viewportHeight: viewportHeight
                )
            }
            .accessibilityHidden(true)
    }

    /// 将表冠输入转换为“先滚课程、越过边界后再切日”的两阶段操作。
    ///
    /// 旋转方向始终保持一致：数值增加向下浏览，数值减少向上浏览。只有在
    /// 当前方向已无法继续滚动，并额外越过指定阈值时，才进入相邻日期。
    private func handleDayCrownChange(
        from oldValue: Double,
        to newValue: Double,
        scrollProxy: ScrollViewProxy,
        viewportHeight: CGFloat
    ) {
        let delta = newValue - oldValue
        guard let update = crownSession.register(delta: delta) else { return }

        onCrownInteraction()
        // 新一轮旋转不继承上一轮未完成的慢转刻度。
        if update.startsNewSession {
            resetBoundaryDrag()
            continuousDayNavigation = false
            continuousDayPageCount = 0
            boundaryHapticPlayed = false
        }

        if update.reversesDirection {
            // 已经进入连续翻日后，反向只改变翻页方向，不退出翻页模式；
            // 用户无需再次把课程卡片拉过半屏，但新方向的前两页重新使用
            // 双倍行程，方便精确停在紧邻日期。尚未进入翻页时仍正常复位
            // 边界拖动，防止两个方向的位移错误相加。
            if continuousDayNavigation {
                continuousDayPageCount = 0
            } else {
                resetBoundaryDrag()
            }
            boundaryHapticPlayed = false
        }

        let activeThreshold: Double
        if continuousDayNavigation {
            activeThreshold = continuousDayPageCount < 2
                ? continuousDaySwitchThreshold * 2
                : continuousDaySwitchThreshold
        } else {
            activeThreshold = cardScrollThreshold
        }
        guard crownSession.consume(threshold: activeThreshold) else { return }
        advanceDayContent(
            update.direction,
            using: scrollProxy,
            viewportHeight: viewportHeight
        )
    }

    /// 优先滚动当天课程；已经位于边界时把整页内容继续向外拉动。
    ///
    /// 这里使用可视高度而非固定刻度作为日期切换条件。只有橡皮筋偏移严格
    /// 超过二分之一屏幕，才执行相邻日期切换。
    private func advanceDayContent(
        _ amount: Int,
        using scrollProxy: ScrollViewProxy,
        viewportHeight: CGFloat
    ) {
        guard !boundarySwitchPending else { return }

        // 第一次越过二分之一屏后，同一次没有停顿、没有反向的连续旋转
        // 已经明确表达了切日意图，后续刻度直接切日，不再重复拉动阈值。
        if continuousDayNavigation {
            moveDay(
                amount,
                preservesContinuousCrownNavigation: true
            )
            return
        }

        let nextIndex = selectedCourseIndex + amount
        if courses.indices.contains(nextIndex) {
            resetBoundaryDrag()
            boundaryHapticPlayed = false
            selectedCourseIndex = nextIndex
            WatchHaptics.selection()
            withAnimation(.easeOut(duration: 0.2)) {
                scrollProxy.scrollTo(courses[nextIndex].id, anchor: .center)
            }
            return
        }

        if !boundaryHapticPlayed {
            WatchHaptics.boundary(amount)
            boundaryHapticPlayed = true
        }

        let dragStep = max(8, viewportHeight * boundaryDragStepRatio)
        let proposedOffset = boundaryDragOffset
            - CGFloat(amount) * dragStep
        let switchDistance = max(
            1,
            viewportHeight * boundarySwitchDistanceRatio
        )

        invalidateBoundaryReset()
        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.82)) {
            boundaryDragOffset = proposedOffset
        }

        guard abs(proposedOffset) > switchDistance else {
            scheduleBoundaryReset()
            return
        }

        // 先让超过阈值的最后一段拉动显示出来，再切换日期并复位。短暂延迟
        // 仅服务于视觉反馈，不会阻塞界面或表冠事件。
        boundarySwitchPending = true
        continuousDayNavigation = true
        let token = boundaryInteractionToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard boundarySwitchPending,
                  token == boundaryInteractionToken
            else {
                return
            }
            moveDay(
                amount,
                preservesContinuousCrownNavigation: true
            )
        }
    }

    /// 以自然日为单位移动，避免手工增减时间戳造成夏令时边界错误。
    private func moveDay(
        _ amount: Int,
        preservesContinuousCrownNavigation: Bool = false
    ) {
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: amount,
            to: selectedDate
        ) ?? selectedDate
        guard nextDate != selectedDate else { return }
        selectedCourseIndex = 0
        resetBoundaryDrag(animated: false)
        if !preservesContinuousCrownNavigation {
            continuousDayNavigation = false
            continuousDayPageCount = 0
            boundaryHapticPlayed = false
        } else {
            continuousDayPageCount += 1
        }
        // 每成功切换一个自然日只播放一次最短促的点击触觉。
        WatchHaptics.navigation(amount)
        selectedDate = nextDate
    }

    /// 使所有尚未执行的边界回弹任务失效。
    private func invalidateBoundaryReset() {
        boundaryInteractionToken += 1
    }

    /// 表冠停止后让未达到阈值的内容自动回弹，不把半次拖动留到下一轮。
    private func scheduleBoundaryReset() {
        invalidateBoundaryReset()
        let token = boundaryInteractionToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard token == boundaryInteractionToken,
                  !boundarySwitchPending
            else {
                return
            }
            resetBoundaryDrag()
        }
    }

    /// 清除边界拖动状态；按需要使用弹簧动画恢复原位。
    private func resetBoundaryDrag(animated: Bool = true) {
        invalidateBoundaryReset()
        boundarySwitchPending = false
        guard boundaryDragOffset != 0 else { return }

        if animated {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
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
    @State private var crownSession = WatchCrownTurnSession()
    @State private var boundaryHapticPlayed = false
    @State private var continuousWeekPageCount = 0
    @State private var restoreCrownFocusTask: Task<Void, Never>?
    @FocusState private var crownFocused: Bool
    let onEmptyTap: () -> Void
    let onCrownInteraction: () -> Void

    /// 七个表冠小刻度切换一周，进一步提高低速旋转时的定位精度。
    ///
    /// 每轮转动及反转后的前两周还会在输入处理中乘以 2，因此对应约
    /// 十四个小刻度；第三周起恢复这里定义的常规行程。
    private let weekSwitchCrownThreshold = 1.75

    /// 当前周的周一零点。
    private var weekStart: Date {
        startOfWeek(containing: anchorDate)
    }

    /// 只保留当前周 `[周一, 下周一)` 内的日程。
    private var courses: [WatchCourse] {
        let end = Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: weekStart
        ) ?? weekStart
        return store.allCourses.filter {
            $0.startAt >= weekStart && $0.startAt < end
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                let topBarContentInset = max(26, proxy.size.height * 0.13)
                let weekdayHeight = max(15, proxy.size.height * 0.075)

                VStack(spacing: max(1, proxy.size.height * 0.008)) {
                    WeekdayHeader(weekStart: weekStart)
                        .frame(height: weekdayHeight)
                        .offset(y: 2)

                    WeekPeriodGrid(
                        weekStart: weekStart,
                        courses: courses,
                        select: selectCourse,
                        onEmptyTap: handleEmptyTap
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
                }
                .padding(.top, topBarContentInset)
            }

            crownObserver
        }
        .horizontalPageSwipe(
            previous: { handleWeekSwipe(-1) },
            next: { handleWeekSwipe(1) }
        )
        .toolbar {
            if selectedCourse == nil {
                ToolbarItem(placement: .topBarLeading) {
                    DateNavigationHeader(
                        title: weekTitle,
                        previous: { moveWeek(-1) },
                        next: { moveWeek(1) }
                    )
                    .frame(width: 116)
                    .offset(y: -10)
                }
            }
        }
        .onAppear {
            crownFocused = true
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
        }
    }

    /// 横滑按整周翻页，继续复用手机同步的学期边界和既有触觉。
    private func handleWeekSwipe(_ amount: Int) {
        crownFocused = true
        onCrownInteraction()
        _ = moveWeek(amount)
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

    /// 优先采用手机同步的周次参考；旧缓存再回退到学期开始日期推算。
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

    /// 判断目标周是否落在手机可浏览的 `semesterLength` 个周页面内。
    private func isWeekInsideSemester(_ date: Date) -> Bool {
        guard let bounds = semesterWeekBounds else {
            // 旧缓存尚未包含完整学期元数据时维持原行为，收到整学期快照后
            // `onChange` 会立即校正，避免把用户永久锁在某个临时范围。
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
                $crownValue,
                from: -1_000,
                through: 1_000,
                by: 0.25,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: false
            )
            .onChange(of: crownValue) { oldValue, newValue in
                handleWeekCrownChange(from: oldValue, to: newValue)
            }
            .accessibilityHidden(true)
    }

    /// 表冠累计一个完整逻辑刻度后切换一周；停顿后不会继承残余刻度。
    private func handleWeekCrownChange(
        from oldValue: Double,
        to newValue: Double
    ) {
        guard selectedCourse == nil else { return }
        let delta = newValue - oldValue
        guard let update = crownSession.register(delta: delta) else { return }

        onCrownInteraction()
        if update.startsNewSession {
            continuousWeekPageCount = 0
            boundaryHapticPlayed = false
        }

        if update.reversesDirection {
            // 反转仍属于同一轮连续翻周，不退出翻页状态；仅把新方向的
            // 精细计数归零，使反转后的前两周也重新使用双倍行程。
            continuousWeekPageCount = 0
            boundaryHapticPlayed = false
        }

        if !boundaryHapticPlayed {
            WatchHaptics.boundary(update.direction)
            boundaryHapticPlayed = true
        }

        let activeThreshold = continuousWeekPageCount < 2
            ? weekSwitchCrownThreshold * 2
            : weekSwitchCrownThreshold
        guard crownSession.consume(threshold: activeThreshold) else { return }
        boundaryHapticPlayed = false
        // 表冠开始转动时已经播放过边界短点击，碰到学期边界不再重复。
        if moveWeek(update.direction, playsBoundaryFeedback: false) {
            continuousWeekPageCount += 1
        }
    }
}

/// 日视图与周视图共用的横向翻页手势。
///
/// 手势使用 `simultaneousGesture`，不会夺走日视图纵向 ScrollView 或周网格
/// `SpatialTapGesture` 的识别权。结束时必须同时满足：
///
/// 1. 实际位移以横向为主；
/// 2. 实际或预测位移越过最小阈值。
///
/// 因此轻点课程色块、上下浏览课程和斜向小幅抖动都不会误翻页。
private struct HorizontalPageSwipeModifier: ViewModifier {
    let previous: () -> Void
    let next: () -> Void

    private let minimumHorizontalDistance: CGFloat = 36
    private let horizontalDominanceRatio: CGFloat = 1.25

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded(handleDragEnded)
        )
    }

    /// 将一次明确的横滑转换成前一页或后一页。
    private func handleDragEnded(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal)
                > abs(vertical) * horizontalDominanceRatio
        else {
            return
        }

        let projectedHorizontal = value.predictedEndTranslation.width
        let effectiveDistance = max(
            abs(horizontal),
            abs(projectedHorizontal)
        )
        guard effectiveDistance >= minimumHorizontalDistance else { return }

        if horizontal > 0 {
            previous()
        } else {
            next()
        }
    }
}

private extension View {
    /// 添加不影响原有布局和纵向交互的左右翻页能力。
    func horizontalPageSwipe(
        previous: @escaping () -> Void,
        next: @escaping () -> Void
    ) -> some View {
        modifier(
            HorizontalPageSwipeModifier(
                previous: previous,
                next: next
            )
        )
    }
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
        // 两个透明按钮通过 overlay 扩大热区，不参与 HStack 宽度计算；
        // 日期文字因此保持修改前的位置、宽度和缩放比例。
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
