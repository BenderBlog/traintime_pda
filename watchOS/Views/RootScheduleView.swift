// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI
import WatchKit

/// 手表端统一的轻量触觉反馈入口。
///
/// 只在用户完成明确操作或跨越一个导航刻度时播放，避免表冠连续转动期间
/// 高频触发导致触觉含义变得模糊。
@MainActor
enum WatchHaptics {
    static func selection() {
        WKInterfaceDevice.current().play(.click)
    }

    /// 到达边界时使用与课程列表表冠刻度一致的短点击触觉。
    static func boundary(_ amount: Int) {
        _ = amount
        WKInterfaceDevice.current().play(.click)
    }

    static func navigation(_ amount: Int) {
        // Core Haptics 不对普通 watchOS App target 开放；使用课程列表同款
        // 短点击组成双脉冲。边界为单击、翻页为双击，同时避开 `.start`
        // 等会附带明显系统提示音的反馈类型。
        _ = amount
        let device = WKInterfaceDevice.current()
        device.play(.click)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            device.play(.click)
        }
    }

    static func refreshStarted() {
        WKInterfaceDevice.current().play(.click)
    }

    static func success() {
        WKInterfaceDevice.current().play(.click)
    }
}

/// 一次表冠输入更新的语义结果。
///
/// 页面只需要关心方向、是否开始了新一轮旋转、以及是否发生反转；原始
/// 时间戳和累计小数刻度统一由 `WatchCrownTurnSession` 管理。
struct WatchCrownTurnUpdate {
    let direction: Int
    let startsNewSession: Bool
    let reversesDirection: Bool
}

/// 日视图、周视图和课程详情共用的表冠连续旋转状态机。
///
/// 该类型不决定“多少刻度翻页”，也不播放触觉；它只提供三项基础能力：
///
/// 1. 超过 0.35 秒没有输入时开始新一轮；
/// 2. 反向时丢弃旧方向尚未完成的残余刻度；
/// 3. 达到页面给定阈值后消费一次，并保留超出的余量。
///
/// 将机械输入归一化后，各视图可以分别实现半屏切日、精细翻周或详情皮筋，
/// 同时避免复制容易产生细微差异的时间和方向判断。
struct WatchCrownTurnSession {
    private static let inactivityTimeout: TimeInterval = 0.35

    private var accumulator = 0.0
    private var lastEventTime = 0.0
    private var direction = 0

    /// 接收一次非零表冠变化，并返回本次输入对应的会话语义。
    mutating func register(
        delta: Double,
        now: TimeInterval = Date.timeIntervalSinceReferenceDate
    ) -> WatchCrownTurnUpdate? {
        guard abs(delta) > .ulpOfOne else { return nil }

        let startsNewSession = lastEventTime == 0
            || now - lastEventTime > Self.inactivityTimeout
        let newDirection = delta > 0 ? 1 : -1
        let reversesDirection = !startsNewSession
            && direction != 0
            && newDirection != direction

        // 新一轮与方向反转都不能继承旧方向不足一个阈值的零碎输入。
        if startsNewSession || reversesDirection {
            accumulator = 0
        }

        lastEventTime = now
        direction = newDirection
        accumulator += abs(delta)

        return WatchCrownTurnUpdate(
            direction: newDirection,
            startsNewSession: startsNewSession,
            reversesDirection: reversesDirection
        )
    }

    /// 达到阈值时消费一次逻辑刻度；快速旋转产生的超额输入继续保留。
    mutating func consume(threshold: Double) -> Bool {
        guard threshold > 0, accumulator >= threshold else { return false }
        accumulator.formTruncatingRemainder(dividingBy: threshold)
        return true
    }
}

/// 手表课表支持的四种顶层展示方式。
private enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case nextCourse
    case courseList
    case day
    case week

    var id: String { rawValue }

    /// 视图选择列表中的本地化名称。
    var title: String {
        switch self {
        case .nextCourse:
            watchLocalizedString("概览")
        case .courseList:
            watchLocalizedString("课程列表")
        case .day:
            watchLocalizedString("日视图")
        case .week:
            watchLocalizedString("周视图")
        }
    }

    /// 视图选择列表中的 SF Symbol。
    var systemImage: String {
        switch self {
        case .nextCourse:
            "forward.end"
        case .courseList:
            "list.bullet"
        case .day:
            "calendar.day.timeline.left"
        case .week:
            "calendar"
        }
    }
}

/// 根页面的响应式布局参数。
///
/// 集中维护尺寸计算可以防止不同表径下的按钮与内容各自使用一套比例。
/// 这些函数保留已确认的视觉数值，只把散落的公式收拢到一个位置。
private enum RootScheduleLayout {
    static let controlContentSize: CGFloat = 20
    static let completionBottomInset: CGFloat = 31

    static func edgeInset(for size: CGSize) -> CGFloat {
        max(2, min(size.width, size.height) * 0.02)
    }

    static func refreshTopInset(for height: CGFloat) -> CGFloat {
        max(20, height * 0.21)
    }

    static func modeBottomInset(for height: CGFloat) -> CGFloat {
        max(10, height * 0.08)
    }

    static func contentTopInset(
        for mode: WatchCalendarMode,
        height: CGFloat
    ) -> CGFloat {
        // 顶部安全距离必须属于 ScrollView 的内容，用户继续向上滚动时它才会
        // 随内容离开屏幕并允许内容进入系统时钟下方的虚化区域。根视图不再
        // 施加固定顶部边距，否则无论怎样滚动都会永久浪费这块空间。
        0
    }
}

/// Apple Watch 课表的根容器。
///
/// 该视图负责模式切换、刷新入口、自动隐藏控件和同步完成提示；具体课程内容
/// 由四个子视图分别承担，避免在根页面中混入日/周布局细节。
struct RootScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var mode = WatchCalendarMode.nextCourse
    @State private var showsModePicker = false
    @State private var showsSyncCompletion = false
    @State private var refreshRotation = 0.0
    @State private var controlsVisible = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var selectedCourse: WatchCourse?
    private let connectivity = WatchConnectivityManager.shared

    /// 手机同步期间两个入口必须保持可见，不受滚动和自动隐藏计时影响。
    private var controlsShouldBeVisible: Bool {
        controlsVisible || store.isRefreshing
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let edgeInset = RootScheduleLayout.edgeInset(
                    for: proxy.size
                )
                let topInset = RootScheduleLayout.contentTopInset(
                    for: mode,
                    height: proxy.size.height
                )

                ZStack {
                    // 课表主体铺满表盘；非周视图轻点内容可唤回按钮。
                    content
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .padding(.horizontal, edgeInset)
                        .padding(.top, topInset)
                        .padding(.bottom, edgeInset)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                guard mode != .week else { return }
                                revealControls()
                            }
                        )

                    // 按比例下移刷新按钮，避免遮住系统时钟。
                    refreshControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topTrailing
                        )
                        .padding(
                            .top,
                            RootScheduleLayout.refreshTopInset(
                                for: proxy.size.height
                            )
                        )
                        .padding(.trailing, edgeInset)

                    // 模式按钮悬浮在右下角，不挤压课表主体。
                    modeControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                        .padding(.trailing, edgeInset)
                        .padding(
                            .bottom,
                            RootScheduleLayout.modeBottomInset(
                                for: proxy.size.height
                            )
                        )

                    // 提示不截获手势，显示期间仍可滚动或点击课程。
                    if showsSyncCompletion {
                        syncCompletionToast
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottom
                            )
                            .padding(
                                .bottom,
                                RootScheduleLayout.completionBottomInset
                            )
                            .allowsHitTesting(false)
                            .transition(
                                .opacity.combined(with: .scale(scale: 0.84))
                            )
                    }

                    courseDetailOverlay
                }
            }
            .ignoresSafeArea()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showsModePicker) {
            modePicker
        }
        .onAppear {
            updateRefreshAnimation(isRefreshing: store.isRefreshing)
            revealControls()
        }
        .onDisappear {
            hideControlsTask?.cancel()
        }
        .onChange(of: store.isRefreshing) { _, isRefreshing in
            updateRefreshAnimation(isRefreshing: isRefreshing)
            if isRefreshing {
                keepControlsVisibleDuringRefresh()
            } else {
                // 同步完成后重新开始常规自动隐藏倒计时。
                revealControls()
            }
        }
        .onChange(of: store.completedRefreshCount) { _, count in
            guard count > 0 else { return }
            showCompletion(for: count)
        }
        .onChange(of: mode) { _, _ in
            selectedCourse = nil
        }
    }

    /// 根据当前模式选择内容，并统一传入表冠交互回调。
    @ViewBuilder
    private var content: some View {
        if store.snapshot == nil {
            emptyState
        } else {
            switch mode {
            case .nextCourse:
                NextCourseView(onCrownInteraction: hideControls)
            case .courseList:
                CourseListView(onCrownInteraction: hideControls)
            case .day:
                DayScheduleView(onCrownInteraction: hideControls)
            case .week:
                WeekScheduleView(
                    selectedCourse: $selectedCourse,
                    onEmptyTap: revealControls,
                    onCrownInteraction: hideControls
                )
            }
        }
    }

    /// 详情页从底部出现、关闭时回到底部的统一动画。
    private var detailAnimation: Animation {
        .spring(response: 0.38, dampingFraction: 0.84)
    }

    /// 根容器最上层的课程详情。
    ///
    /// 不使用系统 Sheet 是刻意设计：watchOS 会为 Sheet 强制增加左上角
    /// 关闭按钮，且该按钮无法与详情中固定在右侧的关闭入口合并。把详情
    /// 放在根 ZStack 最后一层，既能保证它覆盖其他控件，也能在清空
    /// `selectedCourse` 时同步、确定地解除整个详情视图。
    @ViewBuilder
    private var courseDetailOverlay: some View {
        if let selectedCourse {
            CourseDetailView(
                course: selectedCourse,
                showsTopCloseButton: true,
                dismiss: dismissCourseDetail
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.move(edge: .bottom))
            .zIndex(100)
        }
    }

    /// 使用与出现时相同的弹簧动画原子移除详情。
    private func dismissCourseDetail() {
        // 关闭按钮已经做了单次触发保护，这里再次校验可让辅助功能、模式
        // 切换或迟到的主线程任务安全地重复调用，而不会启动第二段转场。
        guard selectedCourse != nil else { return }
        withAnimation(detailAnimation) {
            selectedCourse = nil
        }
    }

    /// 完全没有缓存时显示；离线但有缓存时仍会展示课表。
    private var emptyState: some View {
        InteractionAwareScrollView(
            onScroll: hideControls,
            centersShortContent: true,
            protectsInitialTopEdge: true
        ) {
            ContentUnavailableView {
                Label("暂无课表", systemImage: "iphone.and.arrow.forward")
            } description: {
                Text(
                    store.syncError
                        ?? watchLocalizedString(
                            "请在配对的 iPhone 上打开应用并刷新课表"
                        )
                )
            }
            .padding(.horizontal, 4)
        }
    }

    /// watchOS 26 使用液态玻璃，旧系统回退到标准描边样式。
    @ViewBuilder
    private var refreshControl: some View {
        if #available(watchOS 26.0, *) {
            refreshButton
                .buttonStyle(.glass)
        } else {
            refreshButton
                .buttonStyle(.bordered)
        }
    }

    /// 触发强制渐进刷新；图标转动由 Store 的刷新状态驱动。
    private var refreshButton: some View {
        Button {
            WatchHaptics.refreshStarted()
            revealControls()
            connectivity.beginProgressiveRefresh(force: true)
        } label: {
            // 先把对称图标放进固定正方形，再旋转整个正方形。若先旋转
            // SF Symbol 本身，其不对称的字形边界会造成箭头绕偏心点打转。
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption.weight(.semibold))
                .frame(
                    width: RootScheduleLayout.controlContentSize,
                    height: RootScheduleLayout.controlContentSize
                )
                .rotationEffect(
                    .degrees(refreshRotation),
                    anchor: .center
                )
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .opacity(controlsShouldBeVisible ? 1 : 0)
        .scaleEffect(controlsShouldBeVisible ? 1 : 0.82)
        .allowsHitTesting(controlsShouldBeVisible)
        .animation(
            .easeOut(duration: 0.2),
            value: controlsShouldBeVisible
        )
        .accessibilityLabel(
            store.isRefreshing
                ? watchLocalizedString("正在刷新")
                : watchLocalizedString("从手机刷新")
        )
    }

    /// 视图切换按钮的系统版本适配。
    @ViewBuilder
    private var modeControl: some View {
        if #available(watchOS 26.0, *) {
            modeButton
                .buttonStyle(.glass)
        } else {
            modeButton
                .buttonStyle(.bordered)
        }
    }

    /// 打开模式选择 Sheet，不在主页面堆叠菜单内容。
    private var modeButton: some View {
        Button {
            WatchHaptics.selection()
            revealControls()
            showsModePicker = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.bold))
                .frame(
                    width: RootScheduleLayout.controlContentSize,
                    height: RootScheduleLayout.controlContentSize
                )
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .opacity(controlsShouldBeVisible ? 1 : 0)
        .scaleEffect(controlsShouldBeVisible ? 1 : 0.82)
        .allowsHitTesting(controlsShouldBeVisible)
        .animation(
            .easeOut(duration: 0.2),
            value: controlsShouldBeVisible
        )
        .accessibilityLabel("切换课表视图")
    }

    /// 选中模式后立即关闭列表；课表数据和缓存不会被重置。
    private var modePicker: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(WatchCalendarMode.allCases) { candidate in
                        Button {
                            WatchHaptics.selection()
                            mode = candidate
                            showsModePicker = false
                        } label: {
                            HStack {
                                Label(
                                    candidate.title,
                                    systemImage: candidate.systemImage
                                )
                                Spacer()
                                if candidate == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(verbatim: watchLocalizedString("切换视图"))
                }
            }
        }
    }

    /// 同步提示的系统版本适配。
    @ViewBuilder
    private var syncCompletionToast: some View {
        if #available(watchOS 26.0, *) {
            syncCompletionLabel
                .glassEffect(.regular, in: Capsule())
                .glassEffectTransition(.materialize)
        } else {
            syncCompletionLabel
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    /// 提示本体保持紧凑，避免遮挡底部的模式按钮。
    private var syncCompletionLabel: some View {
        Label("同步完成", systemImage: "checkmark.circle.fill")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
    }

    /// 开始或停止刷新图标的连续旋转。
    private func updateRefreshAnimation(isRefreshing: Bool) {
        if isRefreshing {
            refreshRotation = 0
            withAnimation(
                .linear(duration: 0.8).repeatForever(autoreverses: false)
            ) {
                refreshRotation = 360
            }
        } else {
            withAnimation(.easeOut(duration: 0.18)) {
                refreshRotation = 0
            }
        }
    }

    /// 用刷新完成计数区分多轮异步提示，旧任务不会隐藏新提示。
    private func showCompletion(for count: Int) {
        WatchHaptics.success()
        withAnimation(
            .spring(
                response: 0.36,
                dampingFraction: 0.62,
                blendDuration: 0.08
            )
        ) {
            showsSyncCompletion = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard count == store.completedRefreshCount else { return }
            withAnimation(.easeInOut(duration: 0.28)) {
                showsSyncCompletion = false
            }
        }
    }

    /// 显示两个悬浮按钮，并重新开始自动隐藏倒计时。
    private func revealControls() {
        hideControlsTask?.cancel()
        withAnimation(.easeOut(duration: 0.18)) {
            controlsVisible = true
        }
        hideControlsTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled, !store.isRefreshing else { return }
            withAnimation(.easeIn(duration: 0.2)) {
                controlsVisible = false
            }
        }
    }

    /// 同步开始时取消隐藏任务，并立即恢复两个悬浮入口。
    private func keepControlsVisibleDuringRefresh() {
        hideControlsTask?.cancel()
        withAnimation(.easeOut(duration: 0.18)) {
            controlsVisible = true
        }
    }

    /// 表冠或滚动发生时立即隐藏按钮，释放课程内容区域。
    private func hideControls() {
        guard !store.isRefreshing else {
            keepControlsVisibleDuringRefresh()
            return
        }
        hideControlsTask?.cancel()
        withAnimation(.easeIn(duration: 0.16)) {
            controlsVisible = false
        }
    }
}

/// “下一节课”页面：正在进行的课程优先，否则显示未来最近一节。
private struct NextCourseView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    let onCrownInteraction: () -> Void

    var body: some View {
        InteractionAwareScrollView(
            onScroll: onCrownInteraction,
            centersShortContent: true,
            protectsInitialTopEdge: true
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if store.isStale {
                    Label(
                        "课表可能已过期",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .padding(.trailing, 34)
                }

                if let course = store.nextCourse {
                    timeline(for: course)
                        .padding(.trailing, 34)
                    CourseRow(
                        course: course,
                        showsDate: true,
                        isProminent: true
                    )
                } else {
                    ContentUnavailableView(
                        "没有下一节课",
                        systemImage: "checkmark.circle"
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
            .padding(.top, 2)
        }
    }

    /// 显示当前状态或距下一节课的相对时间。
    private func timeline(for course: WatchCourse) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            if course.startAt <= Date(), course.endAt > Date() {
                Text("正在上课")
                    .foregroundStyle(course.color)
            } else {
                Text("距离上课")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(course.startAt, style: .relative)
                    .foregroundStyle(course.color)
            }
        }
        .font(.headline)
    }
}
