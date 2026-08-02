// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 独立的日期选择页面。
///
/// 页面负责滚动月份、绘制轻量日程标记、命中日期以及提交或取消。它只从
/// Store 的自然日索引预计算标记，不修改课表或日视图滚动状态。月份横向
/// 分页复用日/周视图的三页容器；单月如有第六行仍可用手指纵向滚动，
/// 表冠始终用于横向翻月。
struct MonthScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    let initialDate: Date
    let submit: (Date) -> Void
    let cancel: () -> Void
    let onEmptyTap: () -> Void
    let onCrownInput: () -> Void
    let onTouchInputBegan: () -> Void
    let onSwipeInput: (CalendarPagingDragAxis) -> Void
    let onHeaderPreviousTap: () -> Void
    let onHeaderNextTap: () -> Void
    /// 启动预热实例只负责建立真实渲染树，不取得表冠焦点或监听课表变化。
    let prewarmingOnly: Bool

    @State private var visibleMonth: Date
    /// App 启动阶段已经准备好的当前月及相邻两月。
    @State private var loadedMonths: [Date: MonthCalendarPageModel]
    /// 与月份模型同窗口缓存的节次标记；表冠逐帧移动时只做字典读取。
    @State private var periodMarkersByMonth: [
        Date: [Int: MonthPeriodMarker]
    ]
    @State private var horizontalPageOffset: CGFloat = 0
    @State private var horizontalTouchStartOffset: CGFloat = 0
    @State private var horizontalPageWidth: CGFloat = 1
    @State private var interactionResetToken = 0
    @State private var crownValue = 0.0
    @State private var lastCrownEventOffset = 0.0
    @State private var crownSession = WatchCrownTurnSession()
    @State private var crownPageRamp = CalendarCrownPageRamp()
    @State private var horizontalCrownVelocity: CGFloat = 0
    @State private var crownIdleCoordinator = CalendarCrownIdleCoordinator()
    @State private var pageTransitionToken = 0
    @State private var pageTransitionInFlight = false
    @State private var pageTransitionTask: Task<Void, Never>?
    @FocusState private var crownFocused: Bool

    init(
        initialDate: Date,
        initialWindow: MonthCalendarWindow,
        submit: @escaping (Date) -> Void,
        cancel: @escaping () -> Void,
        onEmptyTap: @escaping () -> Void,
        onCrownInput: @escaping () -> Void,
        onTouchInputBegan: @escaping () -> Void,
        onSwipeInput: @escaping (CalendarPagingDragAxis) -> Void,
        onHeaderPreviousTap: @escaping () -> Void,
        onHeaderNextTap: @escaping () -> Void,
        prewarmingOnly: Bool = false
    ) {
        let normalizedDate = Calendar.current.startOfDay(for: initialDate)
        let month = monthCalendarStart(for: normalizedDate)
        self.initialDate = normalizedDate
        self.submit = submit
        self.cancel = cancel
        self.onEmptyTap = onEmptyTap
        self.onCrownInput = onCrownInput
        self.onTouchInputBegan = onTouchInputBegan
        self.onSwipeInput = onSwipeInput
        self.onHeaderPreviousTap = onHeaderPreviousTap
        self.onHeaderNextTap = onHeaderNextTap
        self.prewarmingOnly = prewarmingOnly
        _visibleMonth = State(initialValue: month)
        _loadedMonths = State(initialValue: initialWindow.models)
        _periodMarkersByMonth = State(
            initialValue: initialWindow.periodMarkers
        )
    }

    var body: some View {
        // 使用独立导航容器持有月份标题栏。系统会把 `.toolbar` 提升到
        // 最近的 NavigationStack；若继续复用根导航容器，标题栏会脱离
        // 日期选择页的 move 转场。现在标题、星期栏和网格属于同一棵
        // 可转场视图，进入与退出时会作为整页同步移动。
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                VStack(spacing: 2) {
                    // 星期栏位于系统顶部栏下方，不参与月份滚动。
                    MonthWeekdayHeader()

                    CalendarHorizontalPager(
                        pageOffset: horizontalPageOffset,
                        interactionResetToken: interactionResetToken,
                        pageIdentity: monthDate,
                        page: monthPage,
                        onViewportWidthChange: {
                            horizontalPageWidth = max(1, $0)
                        },
                        onViewportHeightChange: { _ in },
                        onHorizontalDragBegan: beginHorizontalMonthDrag,
                        onHorizontalDragChanged: updateHorizontalMonthDrag,
                        onHorizontalDragEnded: finishHorizontalMonthDrag,
                        // 六行月份内部的上下拖动继续交给系统 ScrollView；分页器
                        // 只负责识别并锁定横向手势，不实现第二套纵向物理。
                        onVerticalDragBegan: {},
                        onVerticalDragChanged: { _ in },
                        onVerticalDragEnded: { _ in
                            onSwipeInput(.vertical)
                        },
                        onDragAxisLocked: { _ in onTouchInputBegan() },
                        onDragFinished: {}
                    )
                }
                // 星期栏和网格作为一个整体靠近系统月份标题；只改变视觉位置，
                // 不改变 ScrollView 高度、日期命中坐标或分页手势的计算基准。
                .offset(y: -3)

                monthCrownObserver
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                guard !prewarmingOnly else { return }
                crownFocused = true
                lastCrownEventOffset = crownValue
            }
            // Store 安装新阶段或恢复持久化派生索引后递增修订号。月份页面只
            // 刷新当前三页颜色，不再直接观察整份快照并重新扫描全部课程。
            .onChange(of: store.renderCacheRevision) { _, _ in
                guard !prewarmingOnly else { return }
                replaceMonthWindow(
                    store.preparedMonthCalendarWindow(
                        centeredOn: visibleMonth
                    )
                )
            }
            .task {
                guard !prewarmingOnly else { return }
                await activateMonthCrownAfterEntrance()
            }
            .onDisappear {
                guard !prewarmingOnly else { return }
                crownIdleCoordinator.cancel()
                pageTransitionTask?.cancel()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DateNavigationHeader(
                        title: visibleMonth.formatted(
                            .dateTime
                                .month(.wide)
                                .locale(WatchWidgetShared.preferredLocale)
                        ),
                        previous: {
                            onHeaderPreviousTap()
                            requestMonthPage(-1)
                        },
                        next: {
                            onHeaderNextTap()
                            requestMonthPage(1)
                        },
                        titleAction: cancel
                    )
                    .frame(width: 116)
                    .offset(y: -10)
                }
            }
        }
    }

    /// 返回横向三页容器中相对页对应的自然月。
    private func monthDate(_ relativePage: Int) -> Date {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: relativePage,
            to: visibleMonth
        ) else {
            return visibleMonth
        }
        return monthCalendarStart(for: date)
    }

    /// 只绘制当前三页预热窗口中的月份；缺失页显示纯黑占位。
    @ViewBuilder
    private func monthPage(_ relativePage: Int) -> some View {
        let month = monthDate(relativePage)
        if let model = loadedMonths[month] {
            GeometryReader { viewport in
                // 同一时刻最多显示五行。六行月份可在当前页内使用系统
                // ScrollView 以手指查看最后一行；表冠留给横向月份分页。
                let rowHeight = max(18, viewport.size.height / 5)

                ScrollView(.vertical) {
                    MonthCalendarCanvas(
                        model: model,
                        selectedDate: initialDate,
                        periodMarkers: periodMarkersByMonth[month] ?? [:],
                        rowHeight: rowHeight,
                        select: submit,
                        onEmptyTap: onEmptyTap
                    )
                    .frame(
                        height: rowHeight * CGFloat(model.rowCount)
                    )
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(relativePage != 0)
                // 日期选择页的表冠始终用于横向翻月；这里关闭 ScrollView
                // 的焦点资格，但不影响手指纵向查看六行月份的最后一行。
                .focusable(false)
            }
        } else {
            Color.black
        }
    }

    private func beginHorizontalMonthDrag() {
        guard !pageTransitionInFlight else { return }
        crownIdleCoordinator.cancel()
        crownFocused = true
        horizontalTouchStartOffset = horizontalPageOffset
    }

    /// 手指锁定为横向后确认目标页已经安装；正常情况只是缓存命中。
    private func updateHorizontalMonthDrag(_ translation: CGFloat) {
        guard !pageTransitionInFlight else { return }
        if abs(translation) > 1 {
            installPreparedMonthIfNeeded(
                relativePage: translation < 0 ? 1 : -1
            )
        }
        performWithoutAnimation {
            horizontalPageOffset = min(
                horizontalPageWidth,
                max(
                    -horizontalPageWidth,
                    horizontalTouchStartOffset + translation
                )
            )
        }
    }

    private func finishHorizontalMonthDrag(_ value: DragGesture.Value) {
        guard !pageTransitionInFlight else { return }
        onSwipeInput(.horizontal)
        let motion = horizontalDragMotion(
            value,
            currentOffset: horizontalPageOffset,
            pageWidth: horizontalPageWidth
        )
        settleMonthPage(
            direction: motion.direction,
            velocity: motion.velocity
        )
    }

    /// 标题栏箭头和手指分页共用相同的加载、位移与吸附路径。
    private func requestMonthPage(_ amount: Int) {
        guard !pageTransitionInFlight else { return }
        crownIdleCoordinator.cancel()
        crownFocused = true
        installPreparedMonthIfNeeded(relativePage: amount)
        settleMonthPage(
            direction: amount,
            velocity: horizontalPageWidth * 2.2
        )
    }

    /// 处理跨页后窗口尚未换底或同步刚更新时的兜底安装。
    private func installPreparedMonthIfNeeded(relativePage: Int) {
        let normalizedPage = min(1, max(-1, relativePage))
        let month = monthDate(normalizedPage)
        guard loadedMonths[month] == nil else { return }
        let prepared = store.preparedMonthCalendarWindow(
            centeredOn: month
        )
        guard let model = prepared.models[month] else { return }
        performWithoutAnimation {
            loadedMonths[month] = model
            periodMarkersByMonth[month] = prepared.periodMarkers[month] ?? [:]
        }
    }

    /// 入场转场完成后重新取得表冠焦点。
    ///
    /// 日期选择器通过根视图的条件分支和底部转场出现。真机上在 `onAppear`
    /// 立即设置焦点时，焦点节点尚未完成挂载；随后底层日视图释放焦点以及
    /// 相邻月份缓存更新，都可能使首次请求失效。等待同转场一致的 300ms，
    /// 再先释放、后绑定一次，确保后续刻度进入本页的横向分页处理器。
    @MainActor
    private func activateMonthCrownAfterEntrance() async {
        try? await Task.sleep(nanoseconds: 320_000_000)
        guard !Task.isCancelled else { return }
        crownFocused = false
        await Task.yield()
        guard !Task.isCancelled else { return }
        crownSession.reset()
        lastCrownEventOffset = crownValue
        crownFocused = true
    }

    /// 透明焦点节点独占日期选择页的表冠输入，不参与布局或触摸命中。
    ///
    /// 参数与周视图保持一致，因此两个页面的机械刻度和连续翻页手感相同。
    private var monthCrownObserver: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .calendarPagingCrownInput(
                detent: $crownValue,
                focused: $crownFocused,
                onChange: handleMonthCrownChange,
                onIdle: handleMonthCrownIdle
            )
            .accessibilityHidden(true)
    }

    /// 从第一个有效表冠刻度起就直接横向移动月份，不经过纵向滚动或阈值路由。
    private func handleMonthCrownChange(_ event: DigitalCrownEvent) {
        onCrownInput()
        guard !pageTransitionInFlight else { return }
        crownIdleCoordinator.cancel()
        let delta = frameBoundCrownDelta(
            from: lastCrownEventOffset,
            to: event.offset
        )
        lastCrownEventOffset = event.offset
        guard let update = crownSession.register(delta: delta) else { return }
        crownPageRamp.register(update)

        applyMonthCrownDelta(delta, velocity: event.velocity)
        crownIdleCoordinator.scheduleFallback {
            settleMonthCrownAfterInput()
        }
    }

    /// 使用周视图相同的像素换算，把表冠刻度连续映射到三页横向容器。
    private func applyMonthCrownDelta(_ delta: Double, velocity: Double) {
        let motion = calendarCrownPageMotion(
            delta: delta,
            velocity: velocity,
            pageWidth: horizontalPageWidth,
            distanceScale: crownPageRamp.distanceScale
        )
        horizontalCrownVelocity = motion.velocity
        if updateContinuousMonthOffset(by: motion.offsetDelta) != 0 {
            crownPageRamp.recordCommittedPage()
        }
    }

    /// 越过整屏时立即提交月份并归一化位移，使一次持续旋转可以连续翻月。
    @discardableResult
    private func updateContinuousMonthOffset(by delta: CGFloat) -> Int {
        guard horizontalPageWidth > 0 else { return 0 }
        let update = normalizedContinuousPageOffset(
            horizontalPageOffset + delta,
            pageWidth: horizontalPageWidth
        )

        guard update.crossedPage != 0 else {
            performWithoutAnimation {
                horizontalPageOffset = update.offset
            }
            return 0
        }

        let landingMonth = monthDate(update.crossedPage)
        let nextWindow = preparedMonthWindow(centeredOn: landingMonth)
        commitMonthWindow(
            nextWindow,
            visibleMonth: landingMonth,
            pageOffset: update.offset
        )
        WatchHaptics.navigation(update.crossedPage)
        return update.crossedPage
    }

    /// 系统报告空闲后使用与周视图相同的短确认窗，再吸附到最近月份。
    private func handleMonthCrownIdle() {
        crownIdleCoordinator.scheduleIdleConfirmation {
            settleMonthCrownAfterInput()
        }
    }

    private func settleMonthCrownAfterInput() {
        guard !pageTransitionInFlight else { return }
        let direction = nearestPageDirection(
            for: horizontalPageOffset,
            width: horizontalPageWidth
        )
        settleMonthPage(
            direction: direction,
            velocity: horizontalCrownVelocity
        )
    }

    /// 从 Store 的预热缓存读取目标月三页窗口。
    private func preparedMonthWindow(
        centeredOn landingMonth: Date
    ) -> MonthCalendarWindow {
        store.preparedMonthCalendarWindow(
            centeredOn: landingMonth
        )
    }

    /// 仅替换三页缓存窗口，不改变当前月份和交互位移。
    private func replaceMonthWindow(_ window: MonthCalendarWindow) {
        loadedMonths = window.models
        periodMarkersByMonth = window.periodMarkers
    }

    /// 连续跨页或吸附完成后，用一次无动画事务提交月份和配套缓存。
    private func commitMonthWindow(
        _ window: MonthCalendarWindow,
        visibleMonth: Date,
        pageOffset: CGFloat
    ) {
        performWithoutAnimation {
            self.visibleMonth = visibleMonth
            horizontalPageOffset = pageOffset
            horizontalTouchStartOffset = pageOffset
            replaceMonthWindow(window)
        }
    }

    /// 完整翻页后原子切换月份，并回收为以新月份为中心的三页窗口。
    private func settleMonthPage(direction: Int, velocity: CGFloat) {
        crownIdleCoordinator.cancel()
        let normalizedDirection = min(1, max(-1, direction))
        if normalizedDirection != 0 {
            installPreparedMonthIfNeeded(relativePage: normalizedDirection)
        }

        let snap = horizontalPageSnap(
            direction: normalizedDirection,
            currentOffset: horizontalPageOffset,
            velocity: velocity,
            width: horizontalPageWidth
        )
        pageTransitionToken += 1
        let token = pageTransitionToken
        pageTransitionTask?.cancel()
        pageTransitionInFlight = true
        interactionResetToken += 1

        withAnimation(calendarPageSnapAnimation(duration: snap.duration)) {
            horizontalPageOffset = snap.target
        }

        pageTransitionTask = makeCalendarPageCompletionTask(
            after: snap.duration
        ) {
            guard token == pageTransitionToken else { return }
            let landingMonth = normalizedDirection == 0
                ? visibleMonth
                : monthDate(normalizedDirection)
            let nextWindow = preparedMonthWindow(centeredOn: landingMonth)
            commitMonthWindow(
                nextWindow,
                visibleMonth: landingMonth,
                pageOffset: 0
            )
            pageTransitionInFlight = false
            horizontalCrownVelocity = 0
            crownSession.reset()
            if normalizedDirection != 0 {
                WatchHaptics.navigation(normalizedDirection)
            }
        }
    }
}

/// 固定在月份网格上方的周一至周日标题。
private struct MonthWeekdayHeader: View {
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(
                Array(mondayFirstWeekdaySymbols().enumerated()),
                id: \.offset
            ) { item in
                Text(item.element)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 15)
        // 与下方 Canvas 使用同一个完整宽度，确保七个星期标题严格对齐日期列。
        .accessibilityHidden(true)
    }
}

/// 日期 Canvas 的固定视觉参数。
///
/// 参数集中后，绘制函数和点击换算不再各自维护网格列数；这里保留的数值
/// 与现有布局完全一致，重构不会改变日期、红框或五段标记的位置。
private enum MonthCalendarCanvasLayout {
    static let columnCount = 7
    static let selectedFontSize: CGFloat = 12
    static let regularFontSize: CGFloat = 10
    static let selectedColor = Color(red: 0.25, green: 0.62, blue: 1)

    static let todayFrameWidth: CGFloat = 20
    static let todayFrameMaximumHeight: CGFloat = 20
    static let todayFrameMinimumHeight: CGFloat = 16
    static let todayFrameVerticalInset: CGFloat = 8
    static let todayFrameCornerRadius: CGFloat = 5
    static let todayFrameLineWidth: CGFloat = 2.2
    /// 今天有日程时，红框需要在五段标记四周保留的视觉间距。
    static let todayFrameMarkerHorizontalPadding: CGFloat = 2
    static let todayFrameMarkerVerticalPadding: CGFloat = 1.5

    static let periodMarkerWidth: CGFloat = 17
    static let periodMarkerGap: CGFloat = 0.55
    static let periodMarkerHeight: CGFloat = 3
    static let periodMarkerBottomInset: CGFloat = 4
    static let emptyPeriodColor = Color.white.opacity(0.3)

    static let gridLineWidth: CGFloat = 0.5
    static let gridColor = Color.white.opacity(0.065)
}

/// 使用一张 Canvas 绘制整个月份，并通过触点坐标命中日期。
///
/// 相比 35/42 个 `Button`，这里只创建一个绘制节点和一个点击手势；垂直
/// 拖动仍由外层系统 ScrollView 处理，因此不会引入自定义滚动物理。
private struct MonthCalendarCanvas: View {
    let model: MonthCalendarPageModel
    let selectedDate: Date
    let periodMarkers: [Int: MonthPeriodMarker]
    let rowHeight: CGFloat
    let select: (Date) -> Void
    let onEmptyTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Canvas(rendersAsynchronously: true) { context, size in
                let columnWidth = size.width
                    / CGFloat(MonthCalendarCanvasLayout.columnCount)
                drawGrid(
                    size: size,
                    columnWidth: columnWidth,
                    context: &context
                )
                for (index, cell) in model.cells.enumerated() {
                    guard let cell else { continue }
                    let column = index % MonthCalendarCanvasLayout.columnCount
                    let row = index / MonthCalendarCanvasLayout.columnCount
                    let center = cellCenter(
                        column: column,
                        row: row,
                        columnWidth: columnWidth
                    )
                    let isSelected = Calendar.current.isDate(
                        cell.date,
                        inSameDayAs: selectedDate
                    )
                    let isToday = Calendar.current.isDateInToday(cell.date)
                    let periodMarker = periodMarkers[index]

                    if isToday {
                        // 红框以日期数字和五段节次标记的联合区域为准；这样有
                        // 日程时五段颜色不会落在框外，无日程时则保持原来尺寸。
                        drawTodayFrame(
                            at: center,
                            row: row,
                            includesPeriodMarker: periodMarker != nil,
                            context: &context
                        )
                    }

                    if let marker = periodMarker {
                        drawPeriodMarker(
                            marker,
                            row: row,
                            centerX: center.x,
                            context: &context
                        )
                    }

                    let label = dateLabel(
                        cell.text,
                        isSelected: isSelected
                    )
                    context.draw(
                        label,
                        at: center,
                        anchor: .center
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(coordinateSpace: .local) { location in
                guard let date = date(
                    at: location,
                    canvasWidth: geometry.size.width
                ) else {
                    onEmptyTap()
                    return
                }
                select(date)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            model.monthStart.formatted(
                .dateTime
                    .year()
                    .month(.wide)
                    .locale(WatchWidgetShared.preferredLocale)
            )
        )
    }

    /// 绘制与星期栏共用列宽的极淡网格，帮助快速确认日期所在行列。
    ///
    /// 网格先于日期、今天红框和课程标记绘制，不参与点击命中，也不会改变
    /// Canvas 的尺寸。横线数量直接取月份模型行数，五行与六行月份都能对齐。
    private func drawGrid(
        size: CGSize,
        columnWidth: CGFloat,
        context: inout GraphicsContext
    ) {
        let gridHeight = min(
            size.height,
            rowHeight * CGFloat(model.rowCount)
        )
        var path = Path()

        for column in 0...MonthCalendarCanvasLayout.columnCount {
            let x = CGFloat(column) * columnWidth
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: gridHeight))
        }
        for row in 0...model.rowCount {
            let y = CGFloat(row) * rowHeight
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }

        context.stroke(
            path,
            with: .color(MonthCalendarCanvasLayout.gridColor),
            lineWidth: MonthCalendarCanvasLayout.gridLineWidth
        )
    }

    /// 计算日期格中心点；绘制、今天边框和节次标记共享同一坐标基准。
    private func cellCenter(
        column: Int,
        row: Int,
        columnWidth: CGFloat
    ) -> CGPoint {
        CGPoint(
            x: (CGFloat(column) + 0.5) * columnWidth,
            y: (CGFloat(row) + 0.5) * rowHeight
        )
    }

    /// 绘制今天的透明红框，不改变选中日期文字的蓝色语义。
    private func drawTodayFrame(
        at center: CGPoint,
        row: Int,
        includesPeriodMarker: Bool,
        context: inout GraphicsContext
    ) {
        let frameHeight = min(
            MonthCalendarCanvasLayout.todayFrameMaximumHeight,
            max(
                MonthCalendarCanvasLayout.todayFrameMinimumHeight,
                rowHeight - MonthCalendarCanvasLayout.todayFrameVerticalInset
            )
        )
        let dateFrame = CGRect(
            x: center.x - MonthCalendarCanvasLayout.todayFrameWidth / 2,
            y: center.y - frameHeight / 2,
            width: MonthCalendarCanvasLayout.todayFrameWidth,
            height: frameHeight
        )
        let frame: CGRect
        if includesPeriodMarker {
            // 五段标记靠近日期格底部，不能再用仅围绕数字的固定高度。
            // 对实际标记区域加少量留白后与数字框取并集，不移动日期、网格
            // 或标记本身，因此只改变今天红框的可视范围。
            let markerFrame = CGRect(
                x: center.x - MonthCalendarCanvasLayout.periodMarkerWidth / 2,
                y: CGFloat(row + 1) * rowHeight
                    - MonthCalendarCanvasLayout.periodMarkerBottomInset,
                width: MonthCalendarCanvasLayout.periodMarkerWidth,
                height: MonthCalendarCanvasLayout.periodMarkerHeight
            )
            .insetBy(
                dx: -MonthCalendarCanvasLayout.todayFrameMarkerHorizontalPadding,
                dy: -MonthCalendarCanvasLayout.todayFrameMarkerVerticalPadding
            )
            frame = dateFrame.union(markerFrame)
        } else {
            frame = dateFrame
        }
        context.stroke(
            Path(
                roundedRect: frame,
                cornerRadius: MonthCalendarCanvasLayout.todayFrameCornerRadius
            ),
            with: .color(.red),
            lineWidth: MonthCalendarCanvasLayout.todayFrameLineWidth
        )
    }

    /// 创建日期文字；普通日期统一亮白，选中日期使用蓝色粗体并放大。
    private func dateLabel(_ text: String, isSelected: Bool) -> Text {
        Text(text)
            .font(
                .system(
                    size: isSelected
                        ? MonthCalendarCanvasLayout.selectedFontSize
                        : MonthCalendarCanvasLayout.regularFontSize,
                    weight: isSelected ? .bold : .medium
                )
            )
            .foregroundColor(
                isSelected
                    ? MonthCalendarCanvasLayout.selectedColor
                    : .white
            )
    }

    /// 在日期底部画总宽 17pt 的五段节次条。
    ///
    /// 17pt 沿用原“今天”红色线条的标准长度；五段依次代表两节课，已有
    /// 日程使用课程色，其余段使用暗白色。整天没有日程时调用方不会绘制。
    private func drawPeriodMarker(
        _ marker: MonthPeriodMarker,
        row: Int,
        centerX: CGFloat,
        context: inout GraphicsContext
    ) {
        guard !marker.segmentCourses.isEmpty else { return }
        let totalWidth = MonthCalendarCanvasLayout.periodMarkerWidth
        let gap = MonthCalendarCanvasLayout.periodMarkerGap
        let segmentCount = marker.segmentCourses.count
        let segmentWidth = (
            totalWidth - gap * CGFloat(segmentCount - 1)
        ) / CGFloat(segmentCount)
        let startX = centerX - totalWidth / 2
        let markerY = CGFloat(row + 1) * rowHeight
            - MonthCalendarCanvasLayout.periodMarkerBottomInset

        for index in marker.segmentCourses.indices {
            let color = marker.segmentCourses[index]?.color
                ?? MonthCalendarCanvasLayout.emptyPeriodColor
            let rect = CGRect(
                x: startX + CGFloat(index) * (segmentWidth + gap),
                y: markerY,
                width: segmentWidth,
                height: MonthCalendarCanvasLayout.periodMarkerHeight
            )
            context.fill(
                Path(roundedRect: rect, cornerRadius: 1),
                with: .color(color)
            )
        }
    }

    /// 将 Canvas 内的单次点击换算为 7 列网格索引。
    private func date(at location: CGPoint, canvasWidth: CGFloat) -> Date? {
        guard location.x >= 0,
              location.y >= 0,
              rowHeight > 0,
              canvasWidth > 0
        else {
            return nil
        }
        let columnWidth = max(
            1,
            canvasWidth / CGFloat(MonthCalendarCanvasLayout.columnCount)
        )
        let column = min(
            MonthCalendarCanvasLayout.columnCount - 1,
            max(0, Int(location.x / columnWidth))
        )
        let row = min(
            model.rowCount - 1,
            max(0, Int(location.y / rowHeight))
        )
        let index = row * MonthCalendarCanvasLayout.columnCount + column
        guard model.cells.indices.contains(index) else { return nil }
        return model.cells[index]?.date
    }
}
