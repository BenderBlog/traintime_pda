// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 手表课表支持的五种顶层展示方式。
enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case overview
    case courseList
    case day
    case week
    case month

    var id: String { rawValue }

    /// 日、周、月页面共享同一个当前日期锚点。
    var usesSelectedDate: Bool {
        switch self {
        case .day, .week, .month:
            true
        case .overview, .courseList:
            false
        }
    }

    /// 首次进入时需要把悬浮按钮让给内容的页面。
    var hidesFloatingControlsOnEntry: Bool {
        self == .day || self == .month
    }

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
enum RootScheduleLayout {
    static let controlContentSize: CGFloat = 20
    /// `.controlSize(.small)` 在表盘上的近似外径；教学脉冲用它计算真实中心。
    static let controlVisualDiameter: CGFloat = 32
    static let completionBottomInset: CGFloat = 31
    static let cachedScheduleNoticeBottomInset: CGFloat = 42
    static let onboardingNoticeBottomInset: CGFloat = 42

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

    /// 刷新按钮与 `floatingControlsLayer` 完全相同的响应式中心点。
    static func refreshControlCenter(in size: CGSize) -> CGPoint {
        let radius = controlVisualDiameter * 0.5
        return CGPoint(
            x: size.width - edgeInset(for: size) - radius,
            y: refreshTopInset(for: size.height) + radius
        )
    }

    /// 视图切换按钮与 `floatingControlsLayer` 完全相同的响应式中心点。
    static func modeControlCenter(in size: CGSize) -> CGPoint {
        let radius = controlVisualDiameter * 0.5
        return CGPoint(
            x: size.width - edgeInset(for: size) - radius,
            y: size.height - modeBottomInset(for: size.height) - radius
        )
    }

}

private enum RootFloatingControlKind {
    case refresh
    case mode
}

/// Apple Watch 课表的根容器。
///
/// 该视图负责模式切换、刷新入口、自动隐藏控件和同步完成提示；具体课程内容
/// 由五个独立页面分别承担，避免在根页面中混入日/周/月布局细节。
struct RootScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @StateObject private var onboardingInput = WatchOnboardingInputBridge()
    @State private var mode = WatchCalendarMode.overview
    @State private var showsModePicker = false
    @State private var showsSyncCompletion = false
    @State private var showsCachedScheduleNotice = false
    @State private var refreshRotation = 0.0
    @State private var controlsVisible = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var cachedScheduleNoticeTask: Task<Void, Never>?
    @State private var onboardingNoticeTask: Task<Void, Never>?
    @State private var onboardingStep: WatchOnboardingStep?
    @State private var onboardingViewportSize: CGSize = .zero
    @State private var onboardingViewportGlobalFrame: CGRect = .zero
    @State private var refreshControlGlobalFrame: CGRect = .zero
    @State private var modeControlGlobalFrame: CGRect = .zero
    /// 周视图教学随机选中的真实课程。步骤内保持不变，避免提示跳到
    /// 另一个色块；重新进入引导时重新选择。
    @State private var onboardingWeekTargetCourse: WatchCourse?
    /// 目标色块在整个屏幕全局坐标系中的几何中心。
    @State private var weekCourseGlobalCenter: CGPoint?
    @State private var detailCloseGlobalFrame: CGRect = .zero
    @State private var onboardingShowsCompletion = false
    /// 分段纯黑提示页等待用户轻点继续，不占用实操教学步骤。
    @State private var onboardingSectionIntro: WatchOnboardingSection?
    @State private var onboardingSectionIntroTask: Task<Void, Never>?
    /// App 启动后立即合作式预热课程列表、日索引与月历窗口。
    @State private var onboardingRenderPreparationTask: Task<Void, Never>?
    @State private var onboardingRenderDataReady = false
    /// 第一段黑场和首个实操提示已经在欢迎页背后完成首轮构造。
    @State private var onboardingInitialPresentationReady = false
    @State private var onboardingSectionPreparation =
        WatchOnboardingPreparationState.ready
    /// 自定义分页器按最后一个表冠刻度防抖，停止后才提交教学判断。
    @State private var onboardingCrownEvaluationTask: Task<Void, Never>?
    @State private var onboardingTeachingDate: Date?
    /// 错误操作后递增，用来重建当前教学页面并恢复到步骤开始状态。
    @State private var onboardingPageResetToken = 0
    /// 长按完成后 watchOS 可能补发一次普通 Button 点击；只抑制这一笔。
    @State private var suppressesModeTapAfterLongPress = false
    @State private var modeButtonPressIsActive = false
    @State private var modeButtonLongPressTask: Task<Void, Never>?
    @State private var showsOnboardingNotice = false
    /// 首次教学必须使用真实课程示范；无课表时停在教学外。
    @State private var onboardingWaitsForSchedule = false
    @State private var showsOnboardingScheduleAlert = false
    @State private var didCheckOnboarding = false
    @State private var selectedCourse: WatchCourse?
    @State private var daySelectedDate = Calendar.current.startOfDay(
        for: Date()
    )
    @State private var showsDayDatePicker = false
    @State private var dayDatePickerInitialDate = Calendar.current.startOfDay(
        for: Date()
    )
    /// 首帧后短暂预挂载真实月视图，提前建立 NavigationStack、分页器、
    /// Canvas 和工具栏的渲染管线；该实例不可见且不接收任何输入。
    @State private var prewarmsMonthPresentation = false
    @State private var didPrewarmMonthPresentation = false
    @State private var monthPresentationPrewarmTask: Task<Void, Never>?
    private let connectivity = WatchConnectivityManager.shared

    /// 手机同步期间两个入口必须保持可见，不受滚动和自动隐藏计时影响。
    private var controlsShouldBeVisible: Bool {
        controlsVisible
            || store.isRefreshing
            || store.isAwaitingLaunchSyncReply
            || onboardingForcesControlsVisible
            || showsOnboardingNotice
    }

    /// 引导通常保持操作入口可见；只有“点击空白隐藏/显示”两步需要展示
    /// 真实的切换结果，因此暂时服从 `controlsVisible`。
    private var onboardingForcesControlsVisible: Bool {
        guard let onboardingStep else { return false }
        return !onboardingStep.teachesControlVisibility
    }

    /// 日视图日期入口和模式目录共用同一个全屏月份承载层。
    ///
    /// 两种入口使用相同安全区与可用尺寸，月份网格不会因入口不同而缩放
    /// 或位移。
    private var presentsFullScreenMonthPage: Bool {
        if showsDayDatePicker {
            return true
        }
        guard mode == .month else { return false }
        // 新手引导需要展示真实月历，即使当前还没有任何课表缓存。
        // MonthScheduleView 的日期网格本身不依赖课程，空课表只是不绘制标记。
        if let onboardingStep,
           onboardingStep.requiredMode == .month
        {
            return true
        }
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
                    let viewportGlobalFrame = proxy.frame(in: .global)

                    ZStack {
                        // 课表主体铺满表盘。概览、课程列表和空状态没有独立
                        // 点击层，由这里统一切换悬浮按钮；日、周视图各自有
                        // 与分页/课程命中协调过的单一点击入口，避免一次点击
                        // 被父子两层重复处理。
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
                            // 概览和课程列表需要同时支持“轻点空白切换按钮”与
                            // 原生纵向滚动。这里不能使用 simultaneousGesture：
                            // 实体表上短内容的橡皮筋拖动可能与 TapGesture 同时
                            // 成功，轻点会先被教学判为错误，随后正确的纵向滚动
                            // 又因反馈状态而被忽略。普通点击手势会在 ScrollView
                            // 开始跟随手指后自动失败，因此两种输入保持互斥。
                            .onTapGesture {
                                guard mode == .overview
                                    || mode == .courseList
                                else { return }
                                toggleControlsFromContentTap()
                            }

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
                           store.hasCachedScheduleContent,
                           !showsOnboardingNotice
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

                        // 首次引导完成后的说明复用缓存提示的紧凑玻璃形态。
                        // 它可单击关闭，并在 15 秒后自动退出，不阻塞课表操作。
                        if showsOnboardingNotice {
                            onboardingCompletionNotice
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .bottom
                                )
                                .padding(.horizontal, edgeInset + 6)
                                .padding(
                                    .bottom,
                                    RootScheduleLayout.onboardingNoticeBottomInset
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.92))
                                )
                                .zIndex(95)
                        }

                        courseDetailOverlay
                    }
                    .onAppear {
                        onboardingViewportSize = proxy.size
                        onboardingViewportGlobalFrame = viewportGlobalFrame
                    }
                    .onChange(of: proxy.size) { _, size in
                        onboardingViewportSize = size
                    }
                    .onChange(of: viewportGlobalFrame) { _, frame in
                        onboardingViewportGlobalFrame = frame
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
                        cancel: dismissPresentedMonthPage,
                        onEmptyTap: toggleControlsFromContentTap,
                        onCrownInput: handleOnboardingCrownInput,
                        onTouchInputBegan: handleOnboardingTouchInputBegan,
                        onSwipeInput: handleOnboardingSwipeInput,
                        onHeaderPreviousTap: handleOnboardingHeaderPreviousTap,
                        onHeaderNextTap: handleOnboardingHeaderNextTap
                    )
                    // 教学的每个月视图步骤都从选定的有课日期出发；
                    // 正常使用时 identity 稳定，不会破坏用户当前浏览月。
                .id(
                    onboardingStep == nil
                        ? "month-page"
                        : "onboarding-month-\(onboardingPageResetToken)"
                )
                    .transition(.move(edge: .bottom))
                    .zIndex(200)
                }

                // 数据窗口已由 Store 初始化完成；这里利用首帧后的空闲窗口
                // 预构造一次真实月份页面。0.001 透明度会让渲染器实际建立
                // Canvas 管线，同时肉眼不可见，也不会抢占触摸、表冠或辅助
                // 功能焦点。首次真正打开月视图时只需显示已热身的组件类型。
                if prewarmsMonthPresentation,
                   !presentsFullScreenMonthPage
                {
                    MonthScheduleView(
                        initialDate: daySelectedDate,
                        initialWindow: store.preparedMonthCalendarWindow(
                            centeredOn: daySelectedDate
                        ),
                        submit: { _ in },
                        cancel: {},
                        onEmptyTap: {},
                        onCrownInput: {},
                        onTouchInputBegan: {},
                        onSwipeInput: { _ in },
                        onHeaderPreviousTap: {},
                        onHeaderNextTap: {},
                        prewarmingOnly: true
                    )
                    .opacity(0.001)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .zIndex(-100)
                }

                // 悬浮入口必须位于独立月视图之上，否则月视图虽然能够改变
                // 可见状态，按钮仍会被黑色全屏页面盖住。详情页继续独占最
                // 上层，因此打开课程详情时不显示这两个入口。
                if selectedCourse == nil, !showsModePicker {
                    GeometryReader { proxy in
                        floatingControlsLayer(size: proxy.size)
                    }
                    .ignoresSafeArea()
                    .zIndex(300)
                }

                // 最后加入根 ZStack，确保说明遮罩能覆盖所有真实页面。
                // 进入实操后遮罩完全隐去，输入仍由底层原生页面接收。
                if onboardingStep != nil {
                    onboardingOverlayLayer
                    .transition(.opacity)
                    // 教学层必须高于详情页、月视图和两个悬浮按钮；内部再由
                    // Overlay 自己区分说明面板、动作提示和结果反馈的层级。
                    .zIndex(10_000)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showsModePicker) {
            modePicker
                // 系统 Sheet 位于根视图的 zIndex 体系之外；在同一个展示层
                // 复用教学 Overlay，才能确保进度、提示与结果始终高于目录。
                .overlay {
                    if onboardingStep != nil {
                        onboardingOverlayLayer
                            .transition(.opacity)
                            .zIndex(10_000)
                    }
                }
        }
        .alert(
            Text(verbatim: watchLocalizedString("请先同步课表")),
            isPresented: $showsOnboardingScheduleAlert
        ) {
            Button(role: .cancel) {
                // 只关闭提示，保留等待状态；手机送达课表后
                // 会自动继续进入欢迎页。
            } label: {
                Text(verbatim: watchLocalizedString("好"))
            }
        } message: {
            Text(verbatim: watchLocalizedString(
                "请打开手机 XDYou 并单击刷新按钮"
            ))
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
        .onChange(of: store.allCourses.isEmpty) { _, isEmpty in
            handleOnboardingScheduleAvailability(isEmpty: isEmpty)
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
        scheduleMonthPresentationPrewarm()
        scheduleOnboardingIfNeeded()
    }

    /// 页面离开时取消只服务于界面的延迟任务。
    private func handleDisappear() {
        cancelFloatingControlTasks()
        cancelOnboardingTasks()
        resetOnboardingTargets()
        resetModeButtonPressState()
        onboardingInput.clear()
        cancelMonthPresentationPrewarm()
    }

    /// 取消悬浮控件与非阻塞提示使用的延迟任务。
    ///
    /// 每个引用都在取消后立即置空，后续 `onAppear` 可以准确判断是否需要
    /// 重新创建任务，也不会把已经完成的 Task 当成仍在运行。
    private func cancelFloatingControlTasks() {
        hideControlsTask?.cancel()
        hideControlsTask = nil
        cachedScheduleNoticeTask?.cancel()
        cachedScheduleNoticeTask = nil
        onboardingNoticeTask?.cancel()
        onboardingNoticeTask = nil
    }

    /// 取消新手引导的计时、章节过渡和表冠停止判定。
    ///
    /// 页面销毁、整轮引导重新开始或完成时调用，防止旧步骤的异步回调
    /// 修改新页面状态。
    private func cancelOnboardingTasks() {
        onboardingSectionIntroTask?.cancel()
        onboardingSectionIntroTask = nil
        onboardingSectionIntro = nil
        onboardingSectionPreparation = .ready
        onboardingCrownEvaluationTask?.cancel()
        onboardingCrownEvaluationTask = nil

        onboardingRenderPreparationTask?.cancel()
        onboardingRenderPreparationTask = nil
        onboardingRenderDataReady = false
        onboardingInitialPresentationReady = false
    }

    /// 清空仅对当前引导示例有效的课程与坐标。
    private func resetOnboardingTargets() {
        onboardingWeekTargetCourse = nil
        weekCourseGlobalCenter = nil
        detailCloseGlobalFrame = .zero
    }

    /// 恢复模式按钮的空闲状态，不触发单击或长按结果。
    private func resetModeButtonPressState() {
        modeButtonLongPressTask?.cancel()
        modeButtonLongPressTask = nil
        modeButtonPressIsActive = false
        suppressesModeTapAfterLongPress = false
    }

    /// 结束不可见月视图的渲染预热。
    private func cancelMonthPresentationPrewarm() {
        monthPresentationPrewarmTask?.cancel()
        monthPresentationPrewarmTask = nil
        prewarmsMonthPresentation = false
    }

    /// 首个可见帧提交后预热一次月份页面的真实 SwiftUI 渲染树。
    ///
    /// Store 初始化负责数据和三页窗口，这里只处理必须依赖显示环境的首次
    /// View/Canvas/Toolbar 构造。预热实例保留约 0.8 秒，足够异步 Canvas
    /// 完成首轮绘制；之后立即移除，不持续占用后续交互帧。
    private func scheduleMonthPresentationPrewarm() {
        guard !didPrewarmMonthPresentation,
              monthPresentationPrewarmTask == nil
        else { return }
        monthPresentationPrewarmTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            prewarmsMonthPresentation = true
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            prewarmsMonthPresentation = false
            didPrewarmMonthPresentation = true
            monthPresentationPrewarmTask = nil
        }
    }

    /// 从日视图进入独立日期选择页；页面从表盘底部向上弹入。
    private func presentDayDatePicker(_ date: Date) {
        guard mode == .day, !showsDayDatePicker else { return }
        reportOnboardingOperation(
            .tap(.headerTitle),
            target: .headerTitle
        )
        dayDatePickerInitialDate = Calendar.current.startOfDay(for: date)
        hideControls()
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
        hideControls()
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
        reportOnboardingOperation(
            .tap(.calendarDate),
            target: .calendarDate
        )
        if showsDayDatePicker {
            submitDayDatePicker(date)
        } else {
            submitMonthViewDate(date)
        }
    }

    /// 日期入口关闭后留在日视图；顶层月视图关闭后切回日视图。
    private func dismissPresentedMonthPage() {
        reportOnboardingOperation(
            .tap(.monthTitle),
            target: .monthTitle
        )
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
        if onboardingWaitsForSchedule
            || (store.launchSyncTimedOut
                && !store.hasCachedScheduleContent
            )
        {
            openPhoneSyncState
        } else if store.snapshot == nil {
            emptyState
        } else {
            switch mode {
            case .overview:
                OverviewScheduleView(
                    onCrownInteraction: handlePassiveScrollInteraction,
                    onCrownInput: handleOnboardingCrownInput,
                    onTouchInput: handleOnboardingVerticalSwipeInput,
                    alwaysAllowsTeachingBounce:
                        onboardingStep == .overviewSwipe
                            || onboardingStep == .overviewCrown
                )
                .id(
                    onboardingStep == nil
                        ? "overview-page"
                        : "onboarding-overview-\(onboardingPageResetToken)"
                )
            case .courseList:
                CourseListView(
                    onCrownInteraction: handlePassiveScrollInteraction,
                    onCrownInput: handleOnboardingCrownInput,
                    onTouchInput: handleOnboardingVerticalSwipeInput,
                    alwaysAllowsTeachingBounce:
                        onboardingStep == .courseListSwipe
                            || onboardingStep == .courseListCrown,
                    positionsInitialDate: onboardingStep == nil
                )
                .id(
                    onboardingStep == nil
                        ? "course-list-page"
                        : "onboarding-list-\(onboardingPageResetToken)"
                )
            case .day:
                DayScheduleView(
                    selectedDate: $daySelectedDate,
                    isDatePickerPresented: showsDayDatePicker,
                    onDatePickerRequested: presentDayDatePicker,
                    onContentTap: toggleControlsFromContentTap,
                    onCrownInteraction: hideControls,
                    onCrownInput: handleOnboardingCrownInput,
                    onCrownPageInput: handleOnboardingDayCrownPageInput,
                    onTouchInputBegan: handleOnboardingTouchInputBegan,
                    onSwipeInput: handleOnboardingSwipeInput,
                    onHeaderPreviousTap: handleOnboardingHeaderPreviousTap,
                    onHeaderNextTap: handleOnboardingHeaderNextTap
                )
                .id(
                    onboardingStep == nil
                        ? "day-page"
                        : "onboarding-day-\(onboardingPageResetToken)"
                )
            case .month:
                // 月视图实际内容由根层的全屏页面承载。这里仅提供不会参与
                // 布局的背景，避免再次把月份页嵌进主体缩进容器。
                Color.black
            case .week:
                WeekScheduleView(
                    selectedCourse: $selectedCourse,
                    // 正常进入仍从本周开始；只有教学期间才改用
                    // 预先选定的真实有课日期。
                    initialDate: onboardingTeachingDate ?? Date(),
                    onEmptyTap: toggleControlsFromContentTap,
                    onCrownInteraction: hideControls,
                    onCrownInput: handleOnboardingCrownInput,
                    onTouchInputBegan: handleOnboardingTouchInputBegan,
                    onSwipeInput: handleOnboardingSwipeInput,
                    onHeaderPreviousTap: handleOnboardingHeaderPreviousTap,
                    onHeaderNextTap: handleOnboardingHeaderNextTap,
                    onboardingTargetCourse: onboardingWeekTargetCourse,
                    onCourseFrameChange: recordOnboardingWeekCourseFrame,
                    onCourseSelected: { course in
                        reportOnboardingWeekCourseSelection(course)
                    }
                )
                .id(
                    onboardingStep == nil
                        ? "week-page"
                        : "onboarding-week-\(onboardingPageResetToken)"
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
        hideControls()
    }

    /// 点击月视图的月份标题时返回日视图，不改变当前日期。
    private func dismissMonthView() {
        withAnimation(monthScheduleTransitionAnimation) {
            mode = .day
        }
        hideControls()
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
                onScroll: handlePassiveScrollInteraction,
                onCrownInput: handleOnboardingCrownInput,
                onTouchInput: handleOnboardingVerticalSwipeInput,
                onCloseButtonFrameChange: {
                    recordOnboardingTargetFrame(.detailClose, frame: $0)
                },
                dismiss: dismissCourseDetail
            )
            // 教学从手指滑动进入表冠步骤时重建原生 ScrollView，
            // 阻止上一步惯性滚动被误判成新的表冠操作。
            .id(
                onboardingStep == nil
                    ? "course-detail"
                    : "onboarding-detail-\(onboardingPageResetToken)"
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
        reportOnboardingOperation(
            .tap(.detailClose),
            target: .detailClose
        )
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
                "请打开手机 XDYou 并单击刷新按钮",
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
            reportOnboardingOperation(.tap(.refresh), target: .refresh)
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
        // Button 本身只保留系统玻璃和按压外观；单击/三秒长按由同一个
        // 零距离手势在松手或计时到点时唯一提交，避免实体表上两套识别竞争。
        Button(action: {}) {
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
        .simultaneousGesture(modeButtonPressGesture)
        .accessibilityAction {
            performModeButtonTap()
        }
        .accessibilityLabel(watchLocalizedString("切换课表视图"))
        .accessibilityHint(watchLocalizedString("长按重新进入新手引导"))
    }

    /// 所有不足三秒的按压及辅助功能默认动作都走这里，确保目录必定打开。
    private func performModeButtonTap() {
        guard !suppressesModeTapAfterLongPress else { return }
        reportOnboardingOperation(.tap(.mode), target: .mode)
        WatchHaptics.selection()
        revealControls()
        showsModePicker = true
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

    /// 根页面与系统模式 Sheet 共用唯一的教学显示状态。
    ///
    /// Sheet 会创建独立展示层，单纯提高根视图的 `zIndex` 无法盖住它；将
    /// 同一 Overlay 挂入两个宿主可保持画面层级一致，又不会复制步骤状态机。
    @ViewBuilder
    private var onboardingOverlayLayer: some View {
        if let onboardingStep {
            WatchOnboardingOverlay(
                step: onboardingStep,
                sectionIntro: onboardingSectionIntro,
                sectionPreparation: onboardingSectionPreparation,
                controlCenters: onboardingControlCenters,
                feedback: onboardingInput.feedback,
                showsPrompt: onboardingInput.showsPrompt,
                showsCompletion: onboardingShowsCompletion,
                isInitialPreparationReady:
                    onboardingRenderDataReady
                        && onboardingInitialPresentationReady,
                initialPresentationPrepared: {
                    onboardingInitialPresentationReady = true
                },
                start: handleOnboardingWelcomeTap,
                continueSectionIntro: handleOnboardingSectionIntroTap,
                finish: finishOnboarding
            )
        }
    }

    /// 提交模式选择并关闭目录。
    ///
    /// 模式选择的触觉、状态提交和目录关闭必须属于同一次操作；集中在这里后，
    /// 新增视图不会遗漏其中一步，也不会触碰各视图已经保存的浏览位置。
    private func selectMode(_ candidate: WatchCalendarMode) {
        WatchHaptics.selection()
        if candidate.hidesFloatingControlsOnEntry {
            hideControls()
        }
        if candidate == .month {
            withAnimation(monthScheduleTransitionAnimation) {
                mode = candidate
            }
        } else {
            mode = candidate
        }
        showsModePicker = false
    }

    // MARK: - 新手引导

    /// 首次启动仅检查一次持久化标记。
    ///
    /// 欢迎页必须在首个可见帧立即出现，不能为根页面预留人为
    /// 等待时间。后续的日期定位、列表索引和月历缓存全部在欢迎
    /// 页背后准备，并由欢迎页自己展示加载状态。
    private func scheduleOnboardingIfNeeded() {
        guard !didCheckOnboarding else { return }
        didCheckOnboarding = true
        guard !UserDefaults.standard.bool(
            forKey: WatchPersistentCacheKey.completedOnboarding
        ) else { return }

        requestOnboardingStart()
    }

    /// 长按右下角按钮重新开始时使用同一入口，不重建课表 Store。
    /// 教学进行中只把三秒按压作为教学操作上报，绝不会递归重启引导。
    private func restartOnboarding() {
        if onboardingStep != nil {
            reportOnboardingOperation(.longPress(.mode), target: .mode)
            return
        }
        WatchHaptics.selection()
        requestOnboardingStart()
    }

    /// 教学需要用真实课程展示列表、日视图卡片和周视图色块。
    /// 无任何日程时不创建欢迎页，保留在手机同步页面并给出一次
    /// 明确提示。课表到达后由 `handleOnboardingScheduleAvailability`
    /// 自动续上，用户不需要再次长按。
    private func requestOnboardingStart() {
        guard store.recommendedOnboardingDate != nil else {
            onboardingWaitsForSchedule = true
            showsModePicker = false
            mode = .overview
            withAnimation(.easeInOut(duration: 0.18)) {
                showsOnboardingScheduleAlert = true
            }
            return
        }

        onboardingWaitsForSchedule = false
        showsOnboardingScheduleAlert = false
        startOnboarding()
    }

    /// 无课表阻断期间，手机每完成一个同步阶段都可能安装新快照。
    /// 第一条可用日程一出现就撤下弹窗，再进入正常的欢迎与预热流程。
    private func handleOnboardingScheduleAvailability(isEmpty: Bool) {
        guard onboardingWaitsForSchedule, !isEmpty else { return }
        onboardingWaitsForSchedule = false
        showsOnboardingScheduleAlert = false
        startOnboarding()
    }

    /// 零距离拖动负责精确记录按下和松开；按住满三秒的任务会立即触发，
    /// 不需要等待手指抬起。三秒内松手则统一走普通单击逻辑。
    private var modeButtonPressGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onChanged { value in
            guard hypot(value.translation.width, value.translation.height) <= 36
            else {
                cancelModeButtonPress()
                return
            }
            beginModeButtonPressIfNeeded()
        }
        .onEnded { _ in
            finishModeButtonPress()
        }
    }

    /// 首个触摸刻度立即暂停按钮自动隐藏，并启动独立三秒计时。
    private func beginModeButtonPressIfNeeded() {
        guard !modeButtonPressIsActive else { return }
        modeButtonPressIsActive = true
        suppressesModeTapAfterLongPress = false
        handleModeButtonPressing(true)
        modeButtonLongPressTask?.cancel()
        modeButtonLongPressTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            } catch {
                return
            }
            guard modeButtonPressIsActive else { return }
            suppressesModeTapAfterLongPress = true
            modeButtonLongPressTask = nil
            restartOnboarding()
        }
    }

    /// 松手时根据三秒任务是否已经触发，二选一执行单击或长按结果。
    private func finishModeButtonPress() {
        let didTriggerLongPress = suppressesModeTapAfterLongPress
        modeButtonPressIsActive = false
        modeButtonLongPressTask?.cancel()
        modeButtonLongPressTask = nil
        handleModeButtonPressing(false)
        if !didTriggerLongPress {
            performModeButtonTap()
        }
        // 让系统 Button 可能补发的空动作先结束，再释放抑制标记。
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            suppressesModeTapAfterLongPress = false
        }
    }

    private func cancelModeButtonPress() {
        guard modeButtonPressIsActive else { return }
        resetModeButtonPressState()
        handleModeButtonPressing(false)
    }

    /// 按住三点按钮期间暂停自动隐藏，避免长按计时与 2.6 秒隐藏任务竞争。
    private func handleModeButtonPressing(_ isPressing: Bool) {
        if isPressing {
            hideControlsTask?.cancel()
            hideControlsTask = nil
            if !controlsVisible {
                withAnimation(.easeOut(duration: 0.12)) {
                    controlsVisible = true
                }
            }
        } else if onboardingStep == nil {
            revealControls()
        }
    }

    /// 清理可能盖住课表的临时页面，再从第一步进入引导。
    private func startOnboarding() {
        onboardingNoticeTask?.cancel()
        onboardingNoticeTask = nil
        cancelOnboardingTasks()
        onboardingInput.clear()
        showsModePicker = false
        showsOnboardingNotice = false
        onboardingShowsCompletion = false
        showsDayDatePicker = false
        selectedCourse = nil
        showsCachedScheduleNotice = false
        onboardingWaitsForSchedule = false
        showsOnboardingScheduleAlert = false
        onboardingTeachingDate = nil
        resetOnboardingTargets()
        mode = .overview
        keepControlsVisibleDuringRefresh()
        withAnimation(WatchOnboardingMotion.pageTransition) {
            onboardingStep = .welcome
        }
        configureOnboardingInput(for: .welcome)
        // 先把轻量欢迎页提交给渲染循环，再计算教学日期和五个页面的派生
        // 数据。真机不会在点击“重新引导”后卡在尚未出现的首帧。
        startOnboardingRenderPreparation()
    }

    /// 欢迎页出现后立即预热后续五个页面共用的派生数据。
    ///
    /// 已命中持久化缓存时直接标记完成；缓存缺失时把工作拆到多个可让出
    /// 执行权的阶段。课程列表章节页会在必要时等待这个任务，但欢迎、概览
    /// 动画和用户操作不会被同步阻塞。
    private func startOnboardingRenderPreparation() {
        onboardingRenderPreparationTask?.cancel()
        onboardingRenderDataReady = false
        onboardingInitialPresentationReady = false
        onboardingRenderPreparationTask = Task { @MainActor in
            // 必须先让欢迎页完成一次提交；下面的日期选择和持久化缓存恢复
            // 即使命中缓存，也不占用欢迎页出现前的关键帧。
            await Task.yield()
            guard !Task.isCancelled else { return }

            let resolvedDate = store.recommendedOnboardingDate
            let date = resolvedDate ?? Date()
            installOnboardingTeachingDate(resolvedDate)

            if store.hasPreparedOnboardingRenderData(around: date) {
                onboardingRenderDataReady = true
                return
            }

            await store.prepareOnboardingRenderData(around: date)
            guard !Task.isCancelled else { return }
            // `prepareOnboardingRenderData` 返回即代表本轮必需的索引与
            // 月历窗口已完成。不再用二次推导检查锁住欢迎页：
            // 即使当前是空课表，用户也应能正常进入教学。
            onboardingRenderDataReady = true
        }
    }

    /// 前进到下一项；最后一项的“完成”会提交持久化状态。
    private func showNextOnboardingStep() {
        guard let onboardingStep else { return }
        guard let next = WatchOnboardingStep(
            rawValue: onboardingStep.rawValue + 1
        ) else {
            showOnboardingFinale()
            return
        }
        presentOnboardingStep(next)
    }

    /// 原子切换步骤及其对应的真实背景页面。
    private func presentOnboardingStep(_ step: WatchOnboardingStep) {
        resetOnboardingTargetFrame(for: step)
        if let section = WatchOnboardingSection.starting(at: step) {
            presentOnboardingSectionIntro(section, for: step)
        } else {
            applyOnboardingBackground(for: step)
            withAnimation(WatchOnboardingMotion.pageTransition) {
                onboardingStep = step
            }
            configureOnboardingInput(for: step)
        }
    }

    /// 在黑色章节页下方切换真实页面；普通步骤也复用同一原子入口。
    ///
    /// 这里不启动任何视觉转场。章节页先完整覆盖表盘，下一次主线程更新才
    /// 安装底层页面，因此不会再出现“先漏一帧页面变化、随后才变黑”。
    private func applyOnboardingBackground(for step: WatchOnboardingStep) {
        performWithoutAnimation {
            installOnboardingRoute(for: step)
        }
    }

    /// 把教学示例日期原子写入日视图和月份选择器入口。
    ///
    /// Store 可能尚未给出推荐日期，因此 `nil` 只清空教学引用，不改动用户
    /// 正在浏览的日期；一旦日期可用，两个入口始终保持一致。
    private func installOnboardingTeachingDate(_ date: Date?) {
        onboardingTeachingDate = date
        guard let date else { return }
        let day = Calendar.current.startOfDay(for: date)
        onboardingTeachingDate = day
        daySelectedDate = day
        dayDatePickerInitialDate = day
    }

    /// 安装某一步需要的真实底层页面和详情路由。
    ///
    /// 正常推进与错误恢复共用该入口，避免两条路径对日期选择器、详情课程或
    /// 悬浮控件的处理逐渐产生差异。调用方负责决定是否禁用动画。
    private func installOnboardingRoute(for step: WatchOnboardingStep) {
        if step.requiredMode.usesSelectedDate {
            installOnboardingTeachingDate(
                onboardingTeachingDate ?? store.recommendedOnboardingDate
            )
        }
        selectedCourse = step == .courseDetailClose
            ? onboardingDetailTeachingCourse
            : nil
        showsDayDatePicker = step.presentsDayDatePicker
        mode = step.requiredMode
        prepareControlVisibility(for: step)
    }

    /// 为需要重新选择示例内容的步骤清理动态目标。
    ///
    /// 详情页在“点开课程”成功后已经显示并上报关闭按钮坐标，进入下一步时
    /// 必须保留该坐标；若清零但不重建详情页，GeometryReader 不会再次回调，
    /// 关闭提示就会一直隐藏到错误恢复重建页面之后。
    private func resetOnboardingTargetFrame(for step: WatchOnboardingStep) {
        switch step.operation {
        case .tap(.weekCourse):
            weekCourseGlobalCenter = nil
            onboardingWeekTargetCourse = randomOnboardingWeekCourse()
            // 前面的箭头、滑动和表冠教学可能已把周页带离示范课程。
            // 只在进入色块教学时重建一次并回到教学周；其他相邻步骤保持
            // 相同 identity，不再为每个提示销毁整棵周视图。
            onboardingPageResetToken &+= 1
        default:
            break
        }
    }

    /// 在每个顶层视图的第一项实操前显示纯黑分段页。
    ///
    /// 分段页不再自动计时消失；输入桥保持清空，直到用户主动轻点屏幕。
    /// 这样阅读速度不会影响教学节奏，轻点后的淡出也不会误算成下一项操作。
    private func presentOnboardingSectionIntro(
        _ section: WatchOnboardingSection,
        for step: WatchOnboardingStep
    ) {
        onboardingSectionIntroTask?.cancel()
        onboardingInput.clear()
        onboardingSectionPreparation = .ready
        // 黑色覆盖层先同步插入；底层模式在下一次 run-loop 才更新。
        // `WatchOnboardingOverlay` 的非对称 transition 保证插入没有淡入漏帧。
        performWithoutAnimation {
            onboardingStep = step
            onboardingSectionIntro = section
        }

        onboardingSectionIntroTask = Task { @MainActor in
            await Task.yield()
            guard onboardingStep == step,
                  onboardingSectionIntro == section
            else { return }

            let waitsForInitialRender = section == .courseList
                && !onboardingRenderDataReady
            if waitsForInitialRender {
                onboardingSectionPreparation = .loading
                await onboardingRenderPreparationTask?.value
                guard !Task.isCancelled,
                      onboardingStep == step,
                      onboardingSectionIntro == section
                else { return }
            }

            // 页面在纯黑覆盖下完成首次构造；用户阅读章节说明的时间也会
            // 成为 SwiftUI 建立列表/分页树的预热窗口。
            applyOnboardingBackground(for: step)

            if waitsForInitialRender {
                onboardingSectionPreparation = .completed
                WatchHaptics.onboardingSuccess()
                do {
                    try await Task.sleep(nanoseconds: 820_000_000)
                } catch {
                    return
                }
                guard onboardingStep == step,
                      onboardingSectionIntro == section
                else { return }
                onboardingSectionPreparation = .ready
            }
            onboardingSectionIntroTask = nil
        }
    }

    /// 用户轻点纯黑分段页后淡出，再启用当前页面的第一项真实操作检测。
    private func handleOnboardingSectionIntroTap() {
        guard let step = onboardingStep,
              onboardingSectionIntro != nil,
              onboardingSectionIntroTask == nil
        else { return }
        onboardingSectionIntroTask = Task { @MainActor in
            withAnimation(WatchOnboardingMotion.sectionIntro) {
                onboardingSectionIntro = nil
            }

            do {
                try await Task.sleep(
                    nanoseconds: WatchOnboardingMotion
                        .sectionIntroFadeNanoseconds
                )
            } catch {
                return
            }
            guard onboardingStep == step,
                  onboardingSectionIntro == nil
            else { return }
            WatchHaptics.selection()
            configureOnboardingInput(for: step)
        }
    }

    /// 真实操作被验证后只做必要的教学页面收尾。
    ///
    /// 引导不再模拟点击、刷新或分页：这些效果均由底层真实控件完成，
    /// 因此用户能直接看到原本的滚动、动画和反馈。
    private func handleOnboardingOperation(
        step: WatchOnboardingStep,
        operation: WatchOnboardingOperation
    ) {
        if step == .overviewSwitcherTap,
           operation == .tap(.mode)
        {
            // 用户已经真实看到目录；成功反馈期间只收起 Sheet。不要在这里
            // 提前挂载课程列表：列表的首次 scrollTo 会让实体表同步计算
            // 跨整学期布局，反而阻塞黑场和下一条教学提示。
            DispatchQueue.main.async {
                showsModePicker = false
            }
        }
    }

    /// 为当前步骤重置旁路输入桥。黑色半透明说明只在这里
    /// 短暂出现；它消失后所有真实页面手势都保持原来的命中和动画。
    private func configureOnboardingInput(for step: WatchOnboardingStep) {
        onboardingCrownEvaluationTask?.cancel()
        onboardingCrownEvaluationTask = nil
        onboardingInput.configure(
            step: step,
            operationAccepted: handleOnboardingOperation,
            operationRejected: handleRejectedOnboardingOperation,
            advance: showNextOnboardingStep
        )
    }

    /// 错误输入可能已经真实打开目录、切换日期或关闭顶层页面；播放错号前，
    /// 统一恢复到当前步骤开始时的页面。内部分页状态通过 identity 重建，
    /// 根层路由则直接回到该步骤要求的模式、日期选择器或详情页。
    private func handleRejectedOnboardingOperation(
        step: WatchOnboardingStep,
        operation: WatchOnboardingOperation
    ) {
        _ = operation
        onboardingCrownEvaluationTask?.cancel()
        onboardingCrownEvaluationTask = nil

        performWithoutAnimation {
            showsModePicker = false
            installOnboardingRoute(for: step)
            onboardingPageResetToken &+= 1
        }
    }

    /// 最后一项完成后保留纯黑完成页，等待用户轻点确认后再退出引导。
    private func showOnboardingFinale() {
        onboardingSectionIntroTask?.cancel()
        onboardingSectionIntro = nil
        onboardingInput.clear()
        withAnimation(WatchOnboardingMotion.pageTransition) {
            onboardingShowsCompletion = true
        }
        WatchHaptics.onboardingSuccess()
    }

    /// 将按钮、分页器或顶层手势中的真实操作报告给引导。
    private func reportOnboardingOperation(
        _ operation: WatchOnboardingOperation,
        location: CGPoint? = nil
    ) {
        guard onboardingStep != nil,
              onboardingViewportSize.width > 0,
              onboardingViewportSize.height > 0
        else { return }
        onboardingInput.observe(
            operation,
            at: location,
            controlCenters: onboardingControlCenters,
            in: onboardingViewportSize
        )
    }

    /// 固定布局入口直接使用语义目标中心，避免小屏幕圆角对坐标造成误差。
    private func reportOnboardingOperation(
        _ operation: WatchOnboardingOperation,
        target: WatchOnboardingTapTarget
    ) {
        guard onboardingStep != nil,
              onboardingViewportSize.width > 0,
              onboardingViewportSize.height > 0
        else { return }
        let point = target.point(
            in: onboardingViewportSize,
            controlCenters: onboardingControlCenters
        )
        onboardingInput.observe(
            operation,
            at: point,
            controlCenters: onboardingControlCenters,
            in: onboardingViewportSize
        )
    }

    /// 周视图教学只接受当前随机目标课程；其他色块走错误恢复流程。
    private func reportOnboardingWeekCourseSelection(_ course: WatchCourse) {
        guard onboardingStep != nil else { return }
        if onboardingStep == .weekCourse,
           course == onboardingWeekTargetCourse
        {
            reportOnboardingOperation(
                .tap(.weekCourse),
                target: .weekCourse
            )
        } else {
            reportOnboardingOperation(
                .tap(.content),
                target: .content
            )
        }
    }

    /// 日历自身的单一触摸层锁定轴向时，只隐去说明，不创建第二个手势。
    private func handleOnboardingTouchInputBegan() {
        guard onboardingStep != nil else { return }
        onboardingInput.beginOperation()
    }

    /// 分页器完成自己的真实拖动后，再把已经执行的轴向旁路交给教学验证。
    private func handleOnboardingSwipeInput(_ axis: CalendarPagingDragAxis) {
        switch axis {
        case .horizontal:
            reportOnboardingOperation(.horizontalSwipe)
        case .vertical:
            reportOnboardingOperation(.verticalSwipe)
        }
    }

    /// 原生纵向 ScrollView 确认内容已被手指带动时报告。
    private func handleOnboardingVerticalSwipeInput() {
        // 原生 ScrollView 会在滚动完全进入 idle 后调用这里；自定义页面
        // 则由 DragGesture.onEnded 上报，二者都不会在手指仍按住时判断。
        reportOnboardingOperation(.verticalSwipe)
    }

    /// 日、周、月标题栏左箭头共用同一个语义报告入口。
    private func handleOnboardingHeaderPreviousTap() {
        reportOnboardingOperation(
            .tap(.headerPrevious),
            target: .headerPrevious
        )
    }

    /// 日、周、月标题栏右箭头共用同一个语义报告入口。
    private func handleOnboardingHeaderNextTap() {
        reportOnboardingOperation(
            .tap(.headerNext),
            target: .headerNext
        )
    }

    /// 欢迎页不是测试题：轻点后立即进入第一项，不播放对错动画或成功反馈。
    private func handleOnboardingWelcomeTap() {
        guard onboardingStep == .welcome,
              onboardingRenderDataReady
        else { return }
        onboardingInput.clear()
        WatchHaptics.selection()
        showNextOnboardingStep()
    }

    /// 原生 ScrollView 的偏移回调只用来管理悬浮按钮。
    ///
    /// 表冠教学不再用偏移和超时猜测，而是由 ScrollView 的系统
    /// 滚动阶段通过 `handleOnboardingCrownInput` 明确报告。
    private func handlePassiveScrollInteraction() {
        hideControls()
        // 滚动内容一发生真实位移就隐去教学说明；对错仍等待系统 idle。
        onboardingInput.beginOperation()
    }

    /// 自定义分页器每个表冠刻度都会调用；持续旋转时反复取消任务，只有
    /// 最后一个刻度后的短暂空闲才真正提交判断。
    private func handleOnboardingCrownInput() {
        guard onboardingStep != nil else { return }
        onboardingInput.beginOperation()
        // 日视图的连续翻页步骤必须真正跨过一个日期页面才完成；普通刻度
        // 只负责隐去说明。停止后若仍未跨页，恢复说明而不判定成功或错误。
        if onboardingStep == .dayPagingCrown {
            onboardingCrownEvaluationTask?.cancel()
            onboardingCrownEvaluationTask = makeWatchAutoDismissTask(
                after: 0.24
            ) {
                guard onboardingStep == .dayPagingCrown else { return }
                onboardingInput.restorePromptAfterIncompleteOperation()
            }
            return
        }
        onboardingCrownEvaluationTask?.cancel()
        onboardingCrownEvaluationTask = makeWatchAutoDismissTask(after: 0.20) {
            reportOnboardingOperation(.crown)
        }
    }

    /// 日视图确认表冠已经越过一整页后才提交“连续旋转翻日”教学。
    private func handleOnboardingDayCrownPageInput() {
        guard onboardingStep == .dayPagingCrown else { return }
        onboardingCrownEvaluationTask?.cancel()
        onboardingCrownEvaluationTask = nil
        reportOnboardingOperation(.crownPage)
    }

    /// 详情教学使用与日/周/月教学相同日期中的第一项真实日程。
    private var onboardingTeachingCourse: WatchCourse? {
        guard let date = onboardingTeachingDate else {
            return store.snapshot?.courses.first { $0.startPeriod <= 10 }
                ?? store.snapshot?.courses.first
        }
        let dayCourses = store.courses(on: date)
        if let visibleCourse = dayCourses.first(where: { $0.startPeriod <= 10 }) {
            return visibleCourse
        }

        // 若教学日只有第 11 节后的事项，改从同一周寻找实际绘制在 1–10
        // 节网格中的色块；教学脉冲才能稳定落在一个真实可点课程上。
        let weekCourses = store.courses(
            startingAt: onboardingWeekStart(containing: date),
            dayCount: 7
        )
        return weekCourses.first { $0.startPeriod <= 10 }
            ?? dayCourses.first
            ?? store.snapshot?.courses.first
    }

    /// 周视图教学从当前展示周的可见色块中随机选择一个目标。
    ///
    /// 这里只选择课程数据；`WeekScheduleGridGeometry` 随后使用星期列和
    /// 开始/结束节次反算色块矩形，不再读取色块渲染后的视图边界。
    private func randomOnboardingWeekCourse() -> WatchCourse? {
        guard let date = onboardingTeachingDate
                ?? store.recommendedOnboardingDate
        else { return nil }
        return store.courses(
            startingAt: onboardingWeekStart(containing: date),
            dayCount: 7
        )
        .filter { $0.startPeriod <= 10 }
        .randomElement()
    }

    /// 详情页沿用刚刚在周视图中实际点中的随机课程；若教学尚未进入周视图，
    /// 再回退到原有教学日期中的课程。
    private var onboardingDetailTeachingCourse: WatchCourse? {
        onboardingWeekTargetCourse ?? onboardingTeachingCourse
    }

    /// 仅供教学课程定位使用的周一起点，避免依赖周视图的私有布局工具。
    private func onboardingWeekStart(containing date: Date) -> Date {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: day)
        let daysSinceMonday = (weekday + 5) % 7
        return calendar.date(
            byAdding: .day,
            value: -daysSinceMonday,
            to: day
        ) ?? day
    }

    /// 完成后只写入一个布尔标记，并展示可复用的 15 秒提示。
    private func finishOnboarding() {
        guard onboardingStep != nil else { return }
        cancelOnboardingTasks()
        onboardingInput.clear()
        onboardingShowsCompletion = false
        selectedCourse = nil
        resetOnboardingTargets()
        UserDefaults.standard.set(
            true,
            forKey: WatchPersistentCacheKey.completedOnboarding
        )
        withAnimation(WatchOnboardingMotion.pageTransition) {
            onboardingStep = nil
        }
        showOnboardingCompletionNotice()
    }

    /// 完成提示可在不影响课表操作的情况下自动消失。
    private func showOnboardingCompletionNotice() {
        onboardingNoticeTask?.cancel()
        keepControlsVisibleDuringRefresh()
        withAnimation(.easeInOut(duration: 0.2)) {
            showsOnboardingNotice = true
        }
        onboardingNoticeTask = makeWatchAutoDismissTask(after: 15) {
            dismissOnboardingCompletionNotice(playsHaptic: false)
        }
    }

    /// 单击和计时共用关闭函数，只有显式单击才播放反馈。
    private func dismissOnboardingCompletionNotice(
        playsHaptic: Bool = true
    ) {
        onboardingNoticeTask?.cancel()
        guard showsOnboardingNotice else { return }
        if playsHaptic {
            WatchHaptics.selection()
        }
        withAnimation(.easeInOut(duration: 0.22)) {
            showsOnboardingNotice = false
        }
        revealControls()
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

    /// 引导完成提示沿用紧凑提示的材质与关闭行为。
    @ViewBuilder
    private var onboardingCompletionNotice: some View {
        Group {
            if #available(watchOS 26.0, *) {
                onboardingCompletionNoticeLabel
                    .glassEffect(.regular, in: Capsule())
                    .glassEffectTransition(.materialize)
            } else {
                onboardingCompletionNoticeLabel
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .contentShape(Capsule())
        .onTapGesture {
            dismissOnboardingCompletionNotice()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(
            watchLocalizedString("关闭新手引导提示")
        )
    }

    private var onboardingCompletionNoticeLabel: some View {
        Label(
            watchLocalizedString("长按右下角切换按钮重新进入新手引导"),
            systemImage: "hand.tap.fill"
        )
        .font(.system(size: 9, weight: .semibold))
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.78)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
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
        cachedScheduleNoticeTask = makeWatchAutoDismissTask(after: 15) {
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
            guard !Task.isCancelled,
                  !store.isRefreshing,
                  onboardingStep == nil,
                  !showsOnboardingNotice
            else { return }
            withAnimation(.easeIn(duration: 0.2)) {
                controlsVisible = false
            }
        }
    }

    /// 空白区域轻点使用同一个显隐入口。同步、启动等待和完成提示期间按钮
    /// 按既有规则强制可见；普通浏览和对应引导步骤才允许点击隐藏。
    private func toggleControlsFromContentTap() {
        if onboardingStep?.operation == .verticalSwipe {
            // 纵向滑动教学由 ScrollView 的原生滚动阶段和拖动结束兜底
            // 独占判定。短内容橡皮筋在个别系统版本上可能补发父层轻点，
            // 无论说明淡出是否已提交，都不能把这次补发当成错误操作。
            return
        }
        reportOnboardingOperation(.tap(.content), target: .content)
        if store.isRefreshing
            || store.isAwaitingLaunchSyncReply
            || showsOnboardingNotice
        {
            keepControlsVisibleDuringRefresh()
            return
        }
        if controlsVisible {
            hideControls()
        } else {
            revealControls()
        }
    }

    /// 在两个教学步骤开始前设置确定的初始状态：先展示按钮教用户隐藏，
    /// 再保持隐藏教用户重新显示。其他步骤继续由引导强制展示入口。
    private func prepareControlVisibility(for step: WatchOnboardingStep) {
        guard step.teachesControlVisibility else { return }
        hideControlsTask?.cancel()
        hideControlsTask = nil
        performWithoutAnimation {
            controlsVisible = step == .overviewControlsHide
        }
    }

    /// 同步开始时取消隐藏任务，并立即恢复两个悬浮入口。
    private func keepControlsVisibleDuringRefresh() {
        hideControlsTask?.cancel()
        guard !controlsVisible else { return }
        withAnimation(.easeOut(duration: 0.18)) {
            controlsVisible = true
        }
    }

    /// 表冠或滚动发生时立即隐藏按钮，释放课程内容区域。
    private func hideControls() {
        guard !store.isRefreshing,
              !store.isAwaitingLaunchSyncReply,
              onboardingStep == nil
                || onboardingStep?.teachesControlVisibility == true,
              !showsOnboardingNotice
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

    /// 两个按钮脱离具体课表页面后复用同一套响应式定位；这不会改变原有
    /// 尺寸和边距，只保证独立月视图也能显示它们。
    private func floatingControlsLayer(size: CGSize) -> some View {
        let edgeInset = RootScheduleLayout.edgeInset(for: size)
        return ZStack {
            refreshControl
                .background {
                    floatingControlFrameReader(.refresh)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topTrailing
                )
                .padding(
                    .top,
                    RootScheduleLayout.refreshTopInset(for: size.height)
                )
                .padding(.trailing, edgeInset)

            modeControl
                .background {
                    floatingControlFrameReader(.mode)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .padding(.trailing, edgeInset)
                .padding(
                    .bottom,
                    RootScheduleLayout.modeBottomInset(for: size.height)
                )
        }
    }

    /// 透明 GeometryReader 只记录系统玻璃按钮渲染后的真实边界，不参与布局。
    private func floatingControlFrameReader(
        _ kind: RootFloatingControlKind
    ) -> some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            Color.clear
                .onAppear {
                    recordFloatingControlFrame(frame, kind: kind)
                }
                .onChange(of: frame) { _, newFrame in
                    recordFloatingControlFrame(newFrame, kind: kind)
                }
        }
        .allowsHitTesting(false)
    }

    private func recordFloatingControlFrame(
        _ frame: CGRect,
        kind: RootFloatingControlKind
    ) {
        switch kind {
        case .refresh:
            refreshControlGlobalFrame = frame
        case .mode:
            modeControlGlobalFrame = frame
        }
    }

    /// 记录标题栏、课程色块和详情按钮的真实全局边界。
    private func recordOnboardingTargetFrame(
        _ target: WatchOnboardingTapTarget,
        frame: CGRect
    ) {
        guard !frame.isEmpty else { return }
        switch target {
        case .detailClose:
            detailCloseGlobalFrame = frame
        default:
            break
        }
    }

    /// 接收周网格公式算出的目标矩形，并转换为教学层使用的中心点。
    private func recordOnboardingWeekCourseFrame(
        _ course: WatchCourse,
        frame: CGRect
    ) {
        guard course == onboardingWeekTargetCourse,
              onboardingStep == .weekCourse,
              !frame.isEmpty,
              !onboardingViewportGlobalFrame.isEmpty,
              isMostlyVisibleOnboardingTarget(frame)
        else { return }
        // 矩形的宽高和本地坐标来自绘制公式，GeometryReader 只提供整个
        // 网格的全局原点。首次稳定进入视口后冻结，过渡帧不会拖动提示圆。
        guard weekCourseGlobalCenter == nil else { return }
        weekCourseGlobalCenter = CGPoint(x: frame.midX, y: frame.midY)
    }

    /// 模式切换或分页过渡期间，当前页也可能暂时位于视口边缘。教学只
    /// 接收至少 80% 面积已经进入表盘的目标，避免冻结过渡中的坐标。
    private func isMostlyVisibleOnboardingTarget(_ frame: CGRect) -> Bool {
        guard frame.width > 0, frame.height > 0 else { return false }
        let visibleFrame = onboardingViewportGlobalFrame.intersection(frame)
        guard !visibleFrame.isNull, !visibleFrame.isEmpty else { return false }
        let targetArea = frame.width * frame.height
        let visibleArea = visibleFrame.width * visibleFrame.height
        return visibleArea / targetArea >= 0.80
    }

    /// 将全局按钮中心转换为教学 Overlay 使用的表盘本地坐标。
    private var onboardingControlCenters: WatchOnboardingControlCenters {
        WatchOnboardingControlCenters(
            refresh: localControlCenter(for: refreshControlGlobalFrame),
            mode: localControlCenter(for: modeControlGlobalFrame),
            weekCourse: localControlCenter(
                forGlobalPoint: weekCourseGlobalCenter
            ),
            detailClose: localControlCenter(for: detailCloseGlobalFrame)
        )
    }

    private func localControlCenter(for frame: CGRect) -> CGPoint? {
        guard !frame.isEmpty, !onboardingViewportGlobalFrame.isEmpty
        else { return nil }
        return CGPoint(
            x: frame.midX - onboardingViewportGlobalFrame.minX,
            y: frame.midY - onboardingViewportGlobalFrame.minY
        )
    }

    /// 把整个屏幕坐标系中的绝对中心转换为全屏教学 Overlay 的本地坐标。
    private func localControlCenter(forGlobalPoint point: CGPoint?) -> CGPoint? {
        guard let point, !onboardingViewportGlobalFrame.isEmpty else {
            return nil
        }
        return CGPoint(
            x: point.x - onboardingViewportGlobalFrame.minX,
            y: point.y - onboardingViewportGlobalFrame.minY
        )
    }
}
