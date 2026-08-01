// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 一周七列、最多十节的紧凑课表。
///
/// 色块点击在网格容器中统一做坐标命中测试，空白点击才会唤回浮动按钮；
/// 因而色块与空白区域始终使用互斥的命中路径。
struct WeekScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var anchorDate = Date()
    @Binding var selectedCourse: WatchCourse?
    @State private var crownValue = 0.0
    @State private var lastCrownEventOffset = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var crownPageRamp = CalendarCrownPageRamp()
    @State private var horizontalPageOffset: CGFloat = 0
    @State private var horizontalTouchStartOffset: CGFloat = 0
    @State private var horizontalPageWidth: CGFloat = 1
    @State private var horizontalCrownVelocity: CGFloat = 0
    @State private var pageTransitionToken = 0
    @State private var pageTransitionTask: Task<Void, Never>?
    @State private var crownIdleCoordinator = CalendarCrownIdleCoordinator()
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
                pageIdentity: weekDate,
                page: weekPage,
                onViewportWidthChange: {
                    horizontalPageWidth = max(1, $0)
                },
                onViewportHeightChange: { _ in },
                onHorizontalDragBegan: beginWeekHorizontalDrag,
                onHorizontalDragChanged: updateWeekHorizontalDrag,
                onHorizontalDragEnded: finishWeekHorizontalDrag,
                onVerticalDragBegan: {},
                onVerticalDragChanged: { _ in },
                onVerticalDragEnded: { _ in },
                onDragAxisLocked: { _ in },
                onDragFinished: {}
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
            crownIdleCoordinator.cancel()
            pageTransitionTask?.cancel()
        }
    }

    /// 生成前一周、当前周和后一周；课程网格本身的尺寸与布局保持不变。
    private func weekPage(_ relativePage: Int) -> some View {
        let pageStart = weekDate(relativePage)

        return WeekSchedulePageContent(
            weekStart: pageStart,
            courses: courses(in: pageStart),
            languageIdentifier: store.preferredLanguageIdentifier,
            select: selectCourse,
            onEmptyTap: handleEmptyTap
        )
        .equatable()
        .allowsHitTesting(relativePage == 0)
    }

    /// 返回三页周分页器中某一位置对应的周一。
    private func weekDate(_ relativePage: Int) -> Date {
        Calendar.current.date(
            byAdding: .day,
            value: relativePage * 7,
            to: weekStart
        ) ?? weekStart
    }

    private func beginWeekHorizontalDrag() {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        crownIdleCoordinator.cancel()
        horizontalTouchStartOffset = horizontalPageOffset
        crownFocused = true
        onCrownInteraction()
    }

    private func updateWeekHorizontalDrag(_ translation: CGFloat) {
        guard selectedCourse == nil, !pageTransitionInFlight else { return }
        let offset = horizontalTouchStartOffset + translation

        // 触摸期间保持当前三页的身份稳定，松手吸附后才提交周次。否则拖过
        // 一屏时中途换底会重建手势宿主，表现为页面短暂反向跳动或抽动。
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
            let resisted = min(horizontalPageWidth * 0.2, abs(offset) * 0.18)
            horizontalPageOffset = (offset < 0 ? -1 : 1) * resisted
            return
        }

        weekBoundaryHapticPlayed = false
        horizontalPageOffset = offset
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
        crownIdleCoordinator.cancel()
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
        let motion = calendarCrownPageMotion(
            delta: delta,
            velocity: velocity,
            pageWidth: horizontalPageWidth,
            distanceScale: crownPageRamp.distanceScale
        )
        horizontalCrownVelocity = motion.velocity
        if updateContinuousWeekOffset(by: motion.offsetDelta) != 0 {
            crownPageRamp.recordCommittedPage()
        }
    }

    /// 完整跨过一屏后立即换底，使同一次表冠旋转可以无缝连续翻周。
    @discardableResult
    private func updateContinuousWeekOffset(by delta: CGFloat) -> Int {
        guard horizontalPageWidth > 0 else { return 0 }
        let offset = horizontalPageOffset + delta

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
            performWithoutAnimation {
                horizontalPageOffset = (offset < 0 ? -1 : 1) * resisted
            }
            return 0
        }
        weekBoundaryHapticPlayed = false

        let update = normalizedContinuousPageOffset(
            offset,
            pageWidth: horizontalPageWidth
        )

        guard update.crossedPage != 0 else {
            performWithoutAnimation {
                horizontalPageOffset = update.offset
            }
            return 0
        }

        performWithoutAnimation {
            _ = moveWeek(
                update.crossedPage,
                playsBoundaryFeedback: false
            )
            horizontalPageOffset = update.offset
        }
        return update.crossedPage
    }

    /// 系统报告空闲后确认没有新刻度，才启动周页面吸附。
    private func handleWeekCrownIdle() {
        crownIdleCoordinator.scheduleIdleConfirmation {
            settleWeekCrownAfterInput()
        }
    }

    /// 将当前周偏移吸附到最近一页；供系统回调与实体表兜底共同调用。
    private func settleWeekCrownAfterInput() {
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
        crownIdleCoordinator.cancel()
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
        withAnimation(calendarPageSnapAnimation(duration: snap.duration)) {
            horizontalPageOffset = snap.target
        }

        pageTransitionTask = makeCalendarPageCompletionTask(
            after: snap.duration
        ) {
            guard token == pageTransitionToken else { return }
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
            .calendarPagingCrownInput(
                detent: $crownValue,
                focused: $crownFocused,
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
        // 连续旋转的新刻度立即撤销尚未开始的吸附确认任务。
        crownIdleCoordinator.cancel()
        let delta = frameBoundCrownDelta(
            from: lastCrownEventOffset,
            to: event.offset
        )
        lastCrownEventOffset = event.offset
        guard let update = crownSession.register(delta: delta) else { return }
        crownPageRamp.register(update)

        onCrownInteraction()
        applyWeekCrownDelta(delta, velocity: event.velocity)
        crownIdleCoordinator.scheduleFallback {
            settleWeekCrownAfterInput()
        }
    }
}

/// 周分页器中一张按真实周一复用的页面。
///
/// 横向拖动或表冠滚动只改变父容器偏移；周起点、课程与语言未变时，这张
/// 页面跳过网格路径、节次推断和色块坐标的重复计算。跨周后已经预渲染的
/// 相邻页会直接成为当前页，只在屏幕外创建新的边缘周。
private struct WeekSchedulePageContent: View, Equatable {
    let weekStart: Date
    let courses: [WatchCourse]
    let languageIdentifier: String
    let select: (WatchCourse) -> Void
    let onEmptyTap: () -> Void

    static func == (
        lhs: WeekSchedulePageContent,
        rhs: WeekSchedulePageContent
    ) -> Bool {
        lhs.weekStart == rhs.weekStart
            && lhs.courses == rhs.courses
            && lhs.languageIdentifier == rhs.languageIdentifier
    }

    var body: some View {
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
                    select: select,
                    onEmptyTap: onEmptyTap
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)
            }
            .padding(.top, topBarContentInset)
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
            // 课程/空白点击优先于父层分页拖动。真正产生横向位移时
            // SpatialTapGesture 会自然失败，再由分页手势接管。
            .highPriorityGesture(
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
