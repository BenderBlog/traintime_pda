// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 手表课表支持的五种顶层展示方式。
private enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case overview
    case courseList
    case day
    case week
    case month

    var id: String { rawValue }

    /// 视图选择列表中的本地化名称。
    var title: String {
        switch self {
        case .overview:
            watchLocalizedString("概览")
        case .courseList:
            watchLocalizedString("课程列表")
        case .day:
            watchLocalizedString("日视图")
        case .month:
            watchLocalizedString("月视图")
        case .week:
            watchLocalizedString("周视图")
        }
    }

    /// 视图选择列表中的 SF Symbol。
    var systemImage: String {
        switch self {
        case .overview:
            "forward.end"
        case .courseList:
            "list.bullet"
        case .day:
            "calendar.day.timeline.left"
        case .month:
            "calendar.circle"
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
    static let cachedScheduleNoticeBottomInset: CGFloat = 42

    /// 顶部安全距离由各滚动内容内部负责；根容器保持全屏。
    static let contentTopInset: CGFloat = 0

    static func edgeInset(for size: CGSize) -> CGFloat {
        max(2, min(size.width, size.height) * 0.02)
    }

    static func refreshTopInset(for height: CGFloat) -> CGFloat {
        max(20, height * 0.21)
    }

    static func modeBottomInset(for height: CGFloat) -> CGFloat {
        max(10, height * 0.08)
    }

}

/// Apple Watch 课表的根容器。
///
/// 该视图负责模式切换、刷新入口、自动隐藏控件和同步完成提示；具体课程内容
/// 由五个独立页面分别承担，避免在根页面中混入日/周/月布局细节。
struct RootScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var mode = WatchCalendarMode.overview
    @State private var showsModePicker = false
    @State private var showsSyncCompletion = false
    @State private var showsCachedScheduleNotice = false
    @State private var refreshRotation = 0.0
    @State private var controlsVisible = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var cachedScheduleNoticeTask: Task<Void, Never>?
    @State private var selectedCourse: WatchCourse?
    @State private var daySelectedDate = Calendar.current.startOfDay(
        for: Date()
    )
    @State private var showsDayDatePicker = false
    @State private var dayDatePickerInitialDate = Calendar.current.startOfDay(
        for: Date()
    )
    private let connectivity = WatchConnectivityManager.shared

    /// 手机同步期间两个入口必须保持可见，不受滚动和自动隐藏计时影响。
    private var controlsShouldBeVisible: Bool {
        controlsVisible
            || store.isRefreshing
            || store.isAwaitingLaunchSyncReply
    }

    /// 日视图日期入口与模式目录中的“月视图”必须复用同一个全屏承载层。
    ///
    /// 过去从模式目录进入时，`MonthScheduleView` 会被放进课表主体的缩进
    /// 容器，再额外创建一层导航栈；从日视图日期入口进入时却位于根层，
    /// 两条路径因此获得不同的安全区和可用尺寸。这里统一路由条件，避免
    /// 月历在直接切换模式时发生缩放、位移或星期栏错位。
    private var presentsFullScreenMonthPage: Bool {
        if showsDayDatePicker {
            return true
        }
        guard mode == .month else { return false }
        guard store.snapshot != nil else { return false }
        return !store.launchSyncTimedOut || store.hasCachedScheduleContent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { proxy in
                    let edgeInset = RootScheduleLayout.edgeInset(
                        for: proxy.size
                    )
                    let topInset = RootScheduleLayout.contentTopInset

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

                        // 启动请求超时但本机仍有缓存时，只显示紧凑提示。
                        if showsCachedScheduleNotice,
                           store.hasCachedScheduleContent
                        {
                            cachedScheduleNotice
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .bottom
                                )
                                .padding(.horizontal, edgeInset + 6)
                                .padding(
                                    .bottom,
                                    RootScheduleLayout
                                        .cachedScheduleNoticeBottomInset
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.92))
                                )
                                .zIndex(90)
                        }

                        courseDetailOverlay
                    }
                    .animation(
                        .easeInOut(duration: 0.22),
                        value: store.launchSyncTimedOut
                    )
                }
                .ignoresSafeArea()
                .allowsHitTesting(!presentsFullScreenMonthPage)
                // `allowsHitTesting` 只阻止触摸，底层日视图仍可能留在
                // watchOS 焦点树中并继续接收表冠。选择器展示期间同时禁用
                // 整个底层页面，确保 Digital Crown 只路由到顶层选择器。
                .disabled(presentsFullScreenMonthPage)
                .accessibilityHidden(presentsFullScreenMonthPage)

                // 日期选择器和顶层月视图共用根容器中的独立全屏页面，保证
                // 两种入口具有完全相同的尺寸、安全区、星期栏和分页行为。
                if presentsFullScreenMonthPage {
                    MonthScheduleView(
                        initialDate: presentedMonthInitialDate,
                        initialWindow: store.preparedMonthCalendarWindow(
                            centeredOn: presentedMonthInitialDate
                        ),
                        submit: submitPresentedMonthDate,
                        cancel: dismissPresentedMonthPage
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(200)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showsModePicker) {
            modePicker
        }
        .onAppear(perform: handleAppear)
        .onDisappear(perform: handleDisappear)
        .onChange(of: store.isRefreshing) { _, isRefreshing in
            handleRefreshStateChange(isRefreshing)
        }
        .onChange(of: store.isAwaitingLaunchSyncReply) { _, isAwaiting in
            handleLaunchReplyWaitChange(isAwaiting)
        }
        .onChange(of: store.launchSyncTimedOut) { _, didTimeOut in
            updateCachedScheduleNotice(didTimeOut: didTimeOut)
        }
        .onChange(of: store.completedRefreshCount) { _, count in
            guard count > 0 else { return }
            showCompletion(for: count)
        }
        .onChange(of: daySelectedDate) { _, date in
            // 用户浏览日视图时同步准备对应月份；以后从标题进入月视图不会
            // 把月份模型计算推迟到点击发生的那一帧。
            store.prewarmMonthCalendar(around: date)
        }
        .onChange(of: mode) { _, _ in
            dismissCourseDetailImmediately()
            dismissDayDatePickerImmediately()
        }
    }

    /// 初始化只与根页面生命周期相关的视觉状态。
    ///
    /// 数据请求由 `TraintimeWatchApp` 和 `WatchConnectivityManager` 负责；根
    /// 页面只读取 Store 状态，避免视图重建时重复创建同步任务。
    private func handleAppear() {
        updateRefreshAnimation(isRefreshing: store.isRefreshing)
        revealControls()
        updateCachedScheduleNotice(didTimeOut: store.launchSyncTimedOut)
    }

    /// 页面离开时取消只服务于界面的延迟任务。
    private func handleDisappear() {
        hideControlsTask?.cancel()
        cachedScheduleNoticeTask?.cancel()
    }

    /// 从日视图进入独立日期选择页；页面从表盘底部向上弹入。
    private func presentDayDatePicker(_ date: Date) {
        guard mode == .day, !showsDayDatePicker else { return }
        dayDatePickerInitialDate = Calendar.current.startOfDay(for: date)
        hideControlsTask?.cancel()
        withAnimation(monthScheduleTransitionAnimation) {
            showsDayDatePicker = true
        }
    }

    /// 日期格被点中时才提交选择；随后沿进入路径退回底部。
    private func submitDayDatePicker(_ date: Date) {
        daySelectedDate = Calendar.current.startOfDay(for: date)
        WatchHaptics.selection()
        dismissDayDatePicker()
    }

    /// 点击月份标题退出，不修改 `daySelectedDate`。
    private func dismissDayDatePicker() {
        guard showsDayDatePicker else { return }
        withAnimation(monthScheduleTransitionAnimation) {
            showsDayDatePicker = false
        }
        revealControls()
    }

    /// 模式变化不播放迟到的选择器动画，直接清理独立页面路由。
    private func dismissDayDatePickerImmediately() {
        showsDayDatePicker = false
    }

    /// 根据入口提供初始日期，但不让月视图承担日视图的任何业务状态。
    private var presentedMonthInitialDate: Date {
        showsDayDatePicker ? dayDatePickerInitialDate : daySelectedDate
    }

    /// 全屏月份页只负责选择日期；最终提交路径由打开它的入口决定。
    private func submitPresentedMonthDate(_ date: Date) {
        if showsDayDatePicker {
            submitDayDatePicker(date)
        } else {
            submitMonthViewDate(date)
        }
    }

    /// 日期入口关闭后留在日视图；顶层月视图关闭后切回日视图。
    private func dismissPresentedMonthPage() {
        if showsDayDatePicker {
            dismissDayDatePicker()
        } else {
            dismissMonthView()
        }
    }

    /// 将刷新状态映射为旋转动画和悬浮控件可见性。
    private func handleRefreshStateChange(_ isRefreshing: Bool) {
        updateRefreshAnimation(isRefreshing: isRefreshing)
        if isRefreshing {
            keepControlsVisibleDuringRefresh()
        } else {
            revealControls()
        }
    }

    /// 启动同步等待期间保持操作入口可见；收到回复后恢复自动隐藏计时。
    private func handleLaunchReplyWaitChange(_ isAwaiting: Bool) {
        if isAwaiting {
            keepControlsVisibleDuringRefresh()
        } else if !store.isRefreshing {
            revealControls()
        }
    }

    /// 根据当前模式选择内容，并统一传入表冠交互回调。
    @ViewBuilder
    private var content: some View {
        if store.launchSyncTimedOut,
           !store.hasCachedScheduleContent
        {
            openPhoneSyncState
        } else if store.snapshot == nil {
            emptyState
        } else {
            switch mode {
            case .overview:
                OverviewScheduleView(onCrownInteraction: hideControls)
            case .courseList:
                CourseListView(onCrownInteraction: hideControls)
            case .day:
                DayScheduleView(
                    selectedDate: $daySelectedDate,
                    isDatePickerPresented: showsDayDatePicker,
                    onDatePickerRequested: presentDayDatePicker,
                    onContentTap: revealControls,
                    onCrownInteraction: hideControls
                )
            case .month:
                // 月视图实际内容由根层的全屏页面承载。这里仅提供不会参与
                // 布局的背景，避免再次把月份页嵌进主体缩进容器。
                Color.black
            case .week:
                WeekScheduleView(
                    selectedCourse: $selectedCourse,
                    onEmptyTap: revealControls,
                    onCrownInteraction: hideControls
                )
            }
        }
    }

    /// 月视图选择日期后提交给日视图，并保持既有选中反馈。
    private func submitMonthViewDate(_ date: Date) {
        daySelectedDate = Calendar.current.startOfDay(for: date)
        WatchHaptics.selection()
        withAnimation(monthScheduleTransitionAnimation) {
            mode = .day
        }
        revealControls()
    }

    /// 点击月视图的月份标题时返回日视图，不改变当前日期。
    private func dismissMonthView() {
        withAnimation(monthScheduleTransitionAnimation) {
            mode = .day
        }
        revealControls()
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

    /// 模式切换不需要退出动画，直接清理不再属于当前页面的详情状态。
    private func dismissCourseDetailImmediately() {
        selectedCourse = nil
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
                    store.isAwaitingLaunchSyncReply
                        ? watchLocalizedString("正在从手机同步课表")
                        : store.syncError
                            ?? watchLocalizedString(
                                "请在配对的 iPhone 上打开应用并刷新课表"
                            )
                )
            }
            .padding(.horizontal, 4)
        }
    }

    /// 本机完全没有可展示缓存且启动请求超时时显示的整页引导。
    private var openPhoneSyncState: some View {
        InteractionAwareScrollView(
            onScroll: hideControls,
            centersShortContent: true,
            protectsInitialTopEdge: true
        ) {
            ContentUnavailableView(
                "请打开手机 XDYou 以同步课表",
                systemImage: "iphone.and.arrow.forward"
            )
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
            connectivity.beginLaunchRefresh()
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
                            selectMode(candidate)
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

    /// 提交模式选择并关闭目录。
    ///
    /// 模式选择的触觉、状态提交和目录关闭必须属于同一次操作；集中在这里后，
    /// 新增视图不会遗漏其中一步，也不会触碰各视图已经保存的浏览位置。
    private func selectMode(_ candidate: WatchCalendarMode) {
        WatchHaptics.selection()
        if candidate == .month {
            withAnimation(monthScheduleTransitionAnimation) {
                mode = candidate
            }
        } else {
            mode = candidate
        }
        showsModePicker = false
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

    /// 有缓存时的超时提示，压缩成两行以尽量少遮挡课表内容。
    @ViewBuilder
    private var cachedScheduleNotice: some View {
        Group {
            if #available(watchOS 26.0, *) {
                cachedScheduleNoticeLabel
                    .glassEffect(.regular, in: Capsule())
                    .glassEffectTransition(.materialize)
            } else {
                cachedScheduleNoticeLabel
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .contentShape(Capsule())
        .onTapGesture(perform: dismissCachedScheduleNotice)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("关闭缓存提示")
    }

    private var cachedScheduleNoticeLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "iphone.slash")
                .font(.caption2.weight(.semibold))
            VStack(alignment: .leading, spacing: 0) {
                Text("已加载缓存课表")
                    .font(.caption2.weight(.semibold))
                Text("更新请打开手机 XDYou 以同步")
                    .font(.system(size: 8.5))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    /// 缓存提示最多展示 15 秒；手机提前回复时由超时状态变化立即撤下。
    private func updateCachedScheduleNotice(didTimeOut: Bool) {
        cachedScheduleNoticeTask?.cancel()
        guard didTimeOut,
              store.hasCachedScheduleContent
        else {
            withAnimation(.easeInOut(duration: 0.18)) {
                showsCachedScheduleNotice = false
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            showsCachedScheduleNotice = true
        }
        cachedScheduleNoticeTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.28)) {
                showsCachedScheduleNotice = false
            }
        }
    }

    /// 用户轻点提示时立即撤下，并取消尚未结束的自动隐藏任务。
    private func dismissCachedScheduleNotice() {
        cachedScheduleNoticeTask?.cancel()
        WatchHaptics.selection()
        withAnimation(.easeInOut(duration: 0.18)) {
            showsCachedScheduleNotice = false
        }
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
        guard !store.isRefreshing,
              !store.isAwaitingLaunchSyncReply
        else {
            keepControlsVisibleDuringRefresh()
            return
        }
        hideControlsTask?.cancel()
        hideControlsTask = nil
        // 表冠连续旋转会高频调用该入口。按钮第一次隐藏后不再创建无意义的
        // 动画事务，避免每个 detent 都让根 ZStack 与三页课表重新参与更新。
        guard controlsVisible else { return }
        withAnimation(.easeIn(duration: 0.16)) {
            controlsVisible = false
        }
    }
}
