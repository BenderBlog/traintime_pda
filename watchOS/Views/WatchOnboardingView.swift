// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

private struct WatchOnboardingAnimationsPausedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var watchOnboardingAnimationsPaused: Bool {
        get { self[WatchOnboardingAnimationsPausedKey.self] }
        set { self[WatchOnboardingAnimationsPausedKey.self] = newValue }
    }
}

/// 新手引导统一采用接近 watchOS 系统控件的短促响应节奏。
///
/// 动画参数集中在这里；任务内直接更新提示，任务结束只短暂显示小图标。
enum WatchOnboardingMotion {
    static let prompt = Animation.easeOut(duration: 0.24)
    // 用户开始真实操作后以淡出结束说明，避免低功耗显示下的单帧跳变。
    static let promptDismiss = Animation.easeOut(duration: 0.32)
    static let feedback = Animation.spring(
        response: 0.30,
        dampingFraction: 0.86
    )
    static let feedbackDismiss = Animation.easeInOut(duration: 0.18)
    static let pageTransition = Animation.spring(
        response: 0.34,
        dampingFraction: 0.90
    )
    static let progress = Animation.spring(
        response: 0.42,
        dampingFraction: 0.88
    )
    static let welcome = Animation.spring(
        response: 0.52,
        dampingFraction: 0.90
    )
    static let welcomePrompt = Animation.easeOut(duration: 0.32)
    static let operationHint = Animation.easeInOut(duration: 0.88)
    static let successVisibleDuration: TimeInterval = 0.36
    static let errorVisibleDuration: TimeInterval = 0.65

}

/// 新手引导遮罩的公共几何参数。
///
/// 标题与底部说明必须使用完全相同的左右边界，否则在小表盘上会显得偏心；
/// 表冠高度则依据 Apple Watch 正面参考图测得的物理中心比例统一计算。
private enum WatchOnboardingOverlayLayout {
    static let horizontalInset: CGFloat = 4
    static let titleTopInset: CGFloat = 39
    static let titleHeight: CGFloat = 28
    static let panelCornerRadius: CGFloat = 13
    static let instructionBottomInset: CGFloat = 17

    /// 表冠提示的垂直中心，按教学视口高度等比定位。
    static let crownCenterHeightRatio: CGFloat = 0.27

    /// 左翻页提示按表盘宽度缩放；198pt 参考表盘上的横坐标约为 21pt。
    static let previousPageCueXRatio: CGFloat = 0.106

    /// 右翻页提示按表盘宽度缩放；198pt 参考表盘上的横坐标约为 124pt。
    static let nextPageCueXRatio: CGFloat = 0.626
}

/// 引导点击位置的语义名称。
///
/// 位置以真实页面的稳定布局为基准计算，而不是把说明文字本身做成按钮。
/// 用户因此会在刷新、模式、日期标题、箭头或详情关闭按钮的实际位置完成操作。
extension WatchOnboardingTapTarget {
    /// 目标中心点。所有值只服务于旁路位置验证，不改变底层页面布局。
    func point(
        in size: CGSize,
        controlCenters: WatchOnboardingControlCenters? = nil
    ) -> CGPoint {
        switch self {
        case .anywhere, .content:
            CGPoint(x: size.width * 0.5, y: size.height * 0.52)
        case .refresh:
            controlCenters?.refresh
                ?? RootScheduleLayout.refreshControlCenter(in: size)
        case .mode:
            controlCenters?.mode
                ?? RootScheduleLayout.modeControlCenter(in: size)
        case .headerPrevious:
            fixedHeaderArrowPoint(in: size, isNext: false)
        case .headerNext:
            fixedHeaderArrowPoint(in: size, isNext: true)
        case .headerTitle, .monthTitle:
            CGPoint(x: size.width * 0.47, y: max(28, size.height * 0.17))
        case .calendarDate:
            CGPoint(x: size.width * 0.5, y: size.height * 0.53)
        case .weekCourse:
            validPoint(controlCenters?.weekCourse, in: size)
                ?? CGPoint(x: size.width * 0.48, y: size.height * 0.52)
        case .detailClose:
            validPoint(controlCenters?.detailClose, in: size)
                ?? CGPoint(x: size.width - 25, y: max(48, size.height * 0.29))
        }
    }

    /// 这些目标由系统 Toolbar、滚动详情或周网格决定位置，估算坐标只能
    /// 用于命中兜底，不能用于绘制教学动画，否则首帧会从估算位置滑过去。
    var requiresMeasuredCuePoint: Bool {
        switch self {
        case .refresh, .mode, .weekCourse, .detailClose:
            true
        default:
            false
        }
    }

    /// 返回已经由真实页面测得的目标中心；没有首帧布局时返回 nil。
    func measuredPoint(
        controlCenters: WatchOnboardingControlCenters
    ) -> CGPoint? {
        switch self {
        case .refresh:
            controlCenters.refresh
        case .mode:
            controlCenters.mode
        case .weekCourse:
            controlCenters.weekCourse
        case .detailClose:
            controlCenters.detailClose
        default:
            nil
        }
    }

    /// 绘制位置与命中位置分开：需要实测的控件在坐标到达前宁可暂不显示，
    /// 也不先画在估算位置；普通固定布局目标仍可立即使用响应式坐标。
    func cuePoint(
        in size: CGSize,
        controlCenters: WatchOnboardingControlCenters
    ) -> CGPoint? {
        if requiresMeasuredCuePoint {
            return validPoint(
                measuredPoint(controlCenters: controlCenters),
                in: size
            )
        }
        let basePoint = point(in: size, controlCenters: controlCenters)
        // 左右箭头只调整教学动画的绘制位置；实际按钮命中和操作判定
        // 仍使用上面的固定中心，不扩大或移动响应区。
        if self == .headerPrevious {
            return CGPoint(
                x: size.width
                    * WatchOnboardingOverlayLayout.previousPageCueXRatio,
                y: basePoint.y
            )
        } else if self == .headerNext {
            return CGPoint(
                x: size.width * WatchOnboardingOverlayLayout.nextPageCueXRatio,
                y: basePoint.y
            )
        }
        return basePoint
    }

    /// ScrollView 重建期间可能短暂上报上一帧的屏外坐标；只有仍位于表盘
    /// 内部的实测中心才参与教学动画，否则立即使用响应式回退位置。
    private func validPoint(_ point: CGPoint?, in size: CGSize) -> CGPoint? {
        guard let point,
              point.x.isFinite,
              point.y.isFinite,
              point.x >= 0,
              point.x <= size.width,
              point.y >= 0,
              point.y <= size.height
        else { return nil }
        return point
    }

    /// 日、周、月共用一个 116pt 宽的系统标题栏，因此两枚箭头的视觉中心
    /// 是稳定的。直接按表盘宽度缩放坐标，避免分页重建时等待
    /// GeometryReader 采样而造成提示先漂移、后归位或短暂消失。
    private func fixedHeaderArrowPoint(
        in size: CGSize,
        isNext: Bool
    ) -> CGPoint {
        let scale = min(1, max(0.82, size.width / 198))
        let leading = max(14, 16 * scale)
        return CGPoint(
            x: isNext ? leading + 98 * scale : leading,
            y: max(25, size.height * 0.12)
        )
    }

    var hitRadius: CGFloat {
        switch self {
        case .anywhere, .content:
            92
        case .calendarDate, .weekCourse:
            38
        default:
            30
        }
    }
}

/// 根页面实测得到的教学目标中心点。
///
/// 教学动画优先使用真实几何位置；按钮尚未完成首帧布局时才回退到响应式公式。
struct WatchOnboardingControlCenters: Equatable {
    var refresh: CGPoint?
    var mode: CGPoint?
    var weekCourse: CGPoint?
    var detailClose: CGPoint?
}

/// 读取无法由确定性布局公式推算的真实控件边界，不绘制内容也不参与命中。
///
/// 当前用于滚动详情中的关闭按钮。周课程色块已有统一网格几何模型，直接
/// 按星期和节次反算，无需使用渲染后采样器。
struct WatchOnboardingFrameReader: View {
    let report: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            Color.clear
                .onAppear { report(frame) }
                .onChange(of: frame) { _, newFrame in
                    report(newFrame)
                }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// 文案与视觉保留在 SwiftUI 层；顺序和完成规则由纯状态模型共享。
extension WatchOnboardingStep {
    var title: String {
        let action: String
        switch self {
        case .welcome: return watchLocalizedString("欢迎使用 XDYou")
        case .overviewSwipe: action = watchLocalizedString("滑动浏览")
        case .overviewCrown: action = watchLocalizedString("表冠浏览")
        case .courseListBrowse: action = watchLocalizedString("浏览课程")
        case .overviewControlsHide, .overviewControlsShow:
            action = watchLocalizedString("悬浮按钮")
        case .overviewRefresh: action = watchLocalizedString("刷新课表")
        case .courseListOpen, .courseListSelect, .dayOpen, .daySelect,
             .weekOpen, .weekSelect, .monthOpen, .monthChoose:
            return watchLocalizedFormat("切换到%@", destinationMode!.title)
        case .dayPaging, .weekPaging, .monthPaging: action = watchLocalizedString("翻页")
        case .dayPagingCrown: action = watchLocalizedString("表冠跨日")
        case .weekCourse, .courseDetailClose: action = watchLocalizedString("查看课程")
        case .monthSelect: action = watchLocalizedString("选择日期")
        case .dayDatePickerOpen: action = watchLocalizedString("打开日期选择器")
        case .dayDatePickerSelect:
            return watchLocalizedFormat("切换到%@", WatchCalendarMode.day.title)
        case .restartHold: action = watchLocalizedString("重新打开引导")
        }
        return "\(requiredMode.title)·\(action)"
    }

    var message: String {
        switch self {
        case .welcome: watchLocalizedString("轻点屏幕以开始")
        case .overviewSwipe: watchLocalizedString("上下滑动，浏览当前和下一节课程。")
        case .overviewCrown: watchLocalizedString("旋转数码表冠，也能浏览课程。")
        case .overviewControlsHide: watchLocalizedString("轻点空白处，隐藏右侧按钮。")
        case .overviewControlsShow: watchLocalizedString("再点一次空白处，显示按钮。")
        case .overviewRefresh: watchLocalizedString("轻点刷新，从 iPhone 更新课表。")
        case .courseListOpen: watchLocalizedString("点右下角，切换到课程列表。")
        case .courseListBrowse: watchLocalizedString("上下滑动或转动表冠，浏览整学期课程。")
        case .dayOpen: watchLocalizedString("点右下角，切换到日视图。")
        case .weekOpen: watchLocalizedString("点右下角，切换到周视图。")
        case .monthOpen: watchLocalizedString("点右下角，切换到月视图。")
        case .courseListSelect, .daySelect, .weekSelect, .monthChoose:
            watchLocalizedFormat("在目录中选择“%@”。", destinationMode!.title)
        case .dayPaging: watchLocalizedString("左右滑动或点箭头，切换日期。")
        case .dayPagingCrown: watchLocalizedString("继续转动表冠，滚过课程边界，进入另一天。")
        case .weekPaging: watchLocalizedString("滑动、箭头或表冠，任选一种翻周。")
        case .weekCourse: watchLocalizedString("轻点课程色块，查看详情。")
        case .courseDetailClose: watchLocalizedString("可滚动查看详情，读完后点关闭。")
        case .monthPaging: watchLocalizedString("滑动、箭头或表冠，任选一种翻月。")
        case .monthSelect, .dayDatePickerSelect: watchLocalizedString("轻点一个日期，返回日视图查看当天课程。")
        case .dayDatePickerOpen: watchLocalizedString("在日视图轻点顶部日期，打开月历。")
        case .restartHold: watchLocalizedString("长按右下角按钮 3 秒，可再次进入教程。现在试一试。")
        }
    }
}

/// 任务结果以紧凑图标显示，不遮挡真实页面。
enum WatchOnboardingFeedback: Equatable {
    case success
    case error
}

/// 旁路接收真实页面产生的输入并判定当前教学步骤。
///
/// 这个对象不持有任何触摸层或表冠焦点，因此不会吞掉底层按钮、滚动和分页
/// 动画。根视图把真实输入抄送进来；这里仅做类型/位置校验、触觉反馈和切步。
@MainActor
final class WatchOnboardingInputBridge: ObservableObject {
    @Published private(set) var feedback: WatchOnboardingFeedback?
    @Published private(set) var showsPrompt = false

    private var step: WatchOnboardingStep?
    private var isEvaluating = false
    private var feedbackTask: Task<Void, Never>?
    private var operationRejected: ((
        WatchOnboardingStep,
        WatchOnboardingOperation
    ) -> Void)?
    private var advance: (() -> Void)?

    var acceptsOperations: Bool {
        step != nil && !isEvaluating
    }

    /// 切换步骤前取消上一轮反馈；回调始终绑定当前这次教学配置。
    func configure(
        step: WatchOnboardingStep,
        operationRejected: @escaping (
            WatchOnboardingStep,
            WatchOnboardingOperation
        ) -> Void,
        advance: @escaping () -> Void
    ) {
        cancelFeedbackTask()
        self.step = step
        self.operationRejected = operationRejected
        self.advance = advance
        isEvaluating = false
        feedback = nil
        presentPrompt()
    }

    /// 退出引导时同时释放任务与页面回调，避免继续持有根视图状态。
    func clear() {
        cancelFeedbackTask()
        step = nil
        operationRejected = nil
        advance = nil
        isEvaluating = false
        feedback = nil
        showsPrompt = false
    }

    /// 用户真正开始触摸或旋转表冠时才隐去说明遮罩。
    ///
    /// 说明没有固定超时：用户可以任意停留阅读；而遮罩消失只是
    /// 视觉状态变更，不会改写底层真实页面的手势或表冠焦点。
    func beginOperation() {
        guard step != nil, !isEvaluating, showsPrompt else { return }
        withAnimation(WatchOnboardingMotion.promptDismiss) {
            showsPrompt = false
        }
    }

    /// 输入已经停止、但尚未完成当前要求时重新展示说明。
    ///
    /// 典型场景是日视图“连续旋转表冠翻页”：用户只转动了几个刻度，没有
    /// 真正跨过日期页。此时不判错，也不能让说明永久透明；表冠空闲后恢复
    /// 提示，用户可以从当前真实页面状态继续尝试。
    func restorePromptAfterIncompleteOperation() {
        guard step != nil,
              !isEvaluating,
              feedback == nil,
              !showsPrompt
        else { return }
        presentPrompt()
    }

    /// 验证完整任务的结果；任务内连续动作直接推进提示。
    func observe(
        _ operation: WatchOnboardingOperation,
        at location: CGPoint? = nil,
        controlCenters: WatchOnboardingControlCenters? = nil,
        in size: CGSize
    ) {
        guard let step, !isEvaluating
        else { return }
        beginOperation()
        guard step.accepts(operation) else {
            if step.ignores(operation) {
                // 等真实翻页动画或滚动结束后再恢复提示，避免输入刚开始就闪回。
                cancelFeedbackTask()
                feedbackTask = makeWatchAutoDismissTask(after: 0.65) { [weak self] in
                    guard let self, self.step == step else { return }
                    self.restorePromptAfterIncompleteOperation()
                }
            } else {
                operationRejected?(step, operation)
                showError()
            }
            return
        }
        guard tapLocationMatches(
            expected: operation, location: location,
            controlCenters: controlCenters, size: size
        ) else {
            showError()
            return
        }

        isEvaluating = true
        showsPrompt = false
        guard step.completesTask else {
            advance?()
            return
        }
        withAnimation(WatchOnboardingMotion.feedback) {
            feedback = .success
        }
        WatchHaptics.onboardingSuccess()
        cancelFeedbackTask()
        feedbackTask = makeWatchAutoDismissTask(
            after: WatchOnboardingMotion.successVisibleDuration
        ) { [weak self] in
            guard let self, self.step == step else { return }
            withAnimation(WatchOnboardingMotion.feedbackDismiss) {
                self.feedback = nil
            }
            self.advance?()
        }
    }

    private func showError() {
        isEvaluating = true
        // 保留提示与真实页面，用户可在短反馈后直接继续。
        withAnimation(WatchOnboardingMotion.feedback) {
            showsPrompt = true
            feedback = .error
        }
        WatchHaptics.onboardingError()
        cancelFeedbackTask()
        feedbackTask = makeWatchAutoDismissTask(
            after: WatchOnboardingMotion.errorVisibleDuration
        ) { [weak self] in
            guard let self else { return }
            withAnimation(WatchOnboardingMotion.feedbackDismiss) {
                self.feedback = nil
            }
            self.isEvaluating = false
        }
    }

    /// 每一项的说明持续显示，直到收到该项的第一个真实输入。
    private func presentPrompt() {
        withAnimation(WatchOnboardingMotion.prompt) {
            showsPrompt = true
        }
    }

    private func cancelFeedbackTask() {
        feedbackTask?.cancel()
        feedbackTask = nil
    }

    deinit {
        feedbackTask?.cancel()
    }

    private func tapLocationMatches(
        expected: WatchOnboardingOperation,
        location: CGPoint?,
        controlCenters: WatchOnboardingControlCenters?,
        size: CGSize
    ) -> Bool {
        let target: WatchOnboardingTapTarget
        switch expected {
        case let .tap(value), let .longPress(value):
            target = value
        default:
            return true
        }
        guard let location else { return false }
        if target == .anywhere || target == .content {
            return true
        }
        let point = target.point(
            in: size,
            controlCenters: controlCenters
        )
        return hypot(location.x - point.x, location.y - point.y)
            <= target.hitRadius
    }
}

/// 真实页面上的提示层；除欢迎页外不拦截触摸。
struct WatchOnboardingOverlay: View {
    let step: WatchOnboardingStep
    let controlCenters: WatchOnboardingControlCenters
    let feedback: WatchOnboardingFeedback?
    let showsPrompt: Bool
    let isInitialPreparationReady: Bool
    /// 首个实操提示已在欢迎页背后完成首轮渲染。
    let initialPresentationPrepared: () -> Void
    let start: () -> Void
    let openWidgetTutorial: () -> Void
    let hasWeekCourseTarget: Bool
    @State private var animatedCompletedSteps: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if step == .welcome, showsPrompt, feedback == nil {
                    ZStack {
                        // 首个实操提示在欢迎页背后准备，后续不再插入章节页。
                        initialOnboardingPresentationWarmup(in: proxy.size)

                        // 欢迎页接收继续轻点和指南长按；实操遮罩不参与命中，
                        // 让输入直接抵达真实课表。
                        WatchOnboardingWelcomeView(
                            isReady: isInitialPreparationReady,
                            start: start,
                            openWidgetTutorial: openWidgetTutorial
                        )
                    }
                    .transition(.opacity)
                } else {
                    ZStack {
                        if showsPrompt {
                            // 教学出现时稍微压低真实页面亮度，把注意力集中在
                            // 操作目标；整层连续透明，不制造横向分界线。
                            Color.black.opacity(0.12)
                                .ignoresSafeArea()
                                .transition(.opacity)
                                .zIndex(0)

                            stepTitleBanner
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .top
                                )
                                // 位于系统状态栏下方，不侵占底部说明区。
                                .padding(.horizontal, WatchOnboardingOverlayLayout.horizontalInset)
                                .padding(.top, WatchOnboardingOverlayLayout.titleTopInset)
                                .zIndex(10)

                            WatchOnboardingOperationCue(
                                operations: step.operations,
                                viewportSize: proxy.size,
                                controlCenters: controlCenters
                            )
                            .id(step.rawValue)
                            // 点击、滑动和表冠示范始终覆盖标题及底部液态玻璃，
                            // 避免目标靠近说明区时被材质截断或遮暗。
                            .zIndex(100)

                            instruction
                                // 提示按自己的自然高度贴底；下三分之一只是
                                // 最大可用区域，并不会被空白框强制占满。
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .bottom
                                )
                                .padding(.horizontal, WatchOnboardingOverlayLayout.horizontalInset)
                                .padding(.bottom, WatchOnboardingOverlayLayout.instructionBottomInset)
                                .zIndex(10)
                        }

                        if let feedback {
                            Image(systemName: feedback == .success ? "checkmark.circle.fill" : "arrow.clockwise.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(feedback == .success ? .green : .white)
                                .padding(6)
                                .background(.ultraThinMaterial, in: Capsule())
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .padding(.top, WatchOnboardingOverlayLayout.titleTopInset)
                                .transition(.opacity)
                                .zIndex(200)
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        // 根导航容器会把普通内容放到状态栏下方；教学层跨越安全区后，
        // 标题与底部说明才能按整个表盘的固定参考位置摆放。
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
        .onAppear {
            animateProgress(to: step.taskNumber)
        }
        .onChange(of: step.taskNumber) { _, number in
            animateProgress(to: number)
        }
    }

    /// 欢迎页期间预热首个操作提示的材质与字形。
    private func onboardingPromptPrewarm(
        for warmupStep: WatchOnboardingStep,
        in viewportSize: CGSize
    ) -> some View {
        ZStack {
            stepTitleBanner(for: warmupStep)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.horizontal, WatchOnboardingOverlayLayout.horizontalInset)
                .padding(.top, WatchOnboardingOverlayLayout.titleTopInset)

            WatchOnboardingOperationCue(
                operations: warmupStep.operations,
                viewportSize: viewportSize,
                controlCenters: controlCenters
            )

            instruction(for: warmupStep)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
                .padding(.horizontal, WatchOnboardingOverlayLayout.horizontalInset)
                .padding(.bottom, WatchOnboardingOverlayLayout.instructionBottomInset)
        }
        // 预热只提交首帧材质与字形，不持续运行动画。
        .environment(\.watchOnboardingAnimationsPaused, true)
    }

    /// 欢迎页背后的真实首屏预热内容。
    ///
    /// 两次让出主线程后再等待一个短帧窗口，确保 SwiftUI 不仅建立了 View
    /// 值，还至少提交过一轮材质与 Canvas。完成回调和数据准备共同控制欢迎
    /// 页是否允许轻点，用户进入后不再承担首次渲染开销。
    private func initialOnboardingPresentationWarmup(
        in viewportSize: CGSize
    ) -> some View {
        ZStack {
            onboardingPromptPrewarm(
                for: .overviewSwipe,
                in: viewportSize
            )

        }
        .opacity(0.001)
        .allowsHitTesting(false)
        .environment(\.watchOnboardingAnimationsPaused, true)
        .task {
            await Task.yield()
            await Task.yield()
            do {
                try await Task.sleep(nanoseconds: 120_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            initialPresentationPrepared()
        }
    }

    /// 文字按实际内容高度贴近屏幕底部；不会强占整个下三分之一。
    private var instruction: some View {
        instruction(for: step)
    }

    /// 图标固定在左侧垂直居中，正文最多两行并适度放大。整个提示只占用
    /// 自然高度，避免遮住本来要操作的页面内容。
    @ViewBuilder
    private func instruction(
        for instructionStep: WatchOnboardingStep
    ) -> some View {
        let content = HStack(alignment: .center, spacing: 7) {
            Image(systemName: instructionSystemImage(
                for: instructionStep.operations.first
            ))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.96))
                .frame(width: 20, alignment: .center)

            Text(verbatim: instructionStep == .weekCourse && !hasWeekCourseTarget
                 ? watchLocalizedString("本周暂无课程，翻周找到课程后轻点查看。")
                 : instructionStep.message)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)

        if #available(watchOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(
                    cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                    style: .continuous
                ))
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                        style: .continuous
                    )
                )
        }
    }

    /// 底部说明图标只表达输入方式，不重复页面图标。
    private func instructionSystemImage(
        for operation: WatchOnboardingOperation?
    ) -> String {
        switch operation {
        case .tap:
            "hand.tap.fill"
        case .longPress:
            "hand.point.up.left.fill"
        case .verticalSwipe, .horizontalSwipe:
            "hand.draw.fill"
        case .crown, .crownPage:
            "digitalcrown.horizontal.arrow.counterclockwise"
        case .selectMode:
            "list.bullet"
        case .pageChanged, nil:
            "info.circle"
        }
    }

    /// 所有步骤使用相同宽度的标题；连续进度融入标题材质，不占额外布局高度。
    private var stepTitleBanner: some View {
        stepTitleBanner(for: step)
    }

    @ViewBuilder
    private func stepTitleBanner(
        for bannerStep: WatchOnboardingStep
    ) -> some View {
        let content = ZStack {
            stepTitleMaterial

            Text(verbatim: bannerTitle(for: bannerStep))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .padding(.horizontal, 9)
        }
        .frame(maxWidth: .infinity)
        .frame(height: WatchOnboardingOverlayLayout.titleHeight)

        if #available(watchOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(
                    cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                    style: .continuous
                ))
                .glassEffectTransition(.materialize)
        } else {
            content.background(
                .ultraThinMaterial,
                in: RoundedRectangle(
                    cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                    style: .continuous
                )
            )
        }
    }

    /// 标题材质只保留暗色底和单条连续蓝色进度。
    ///
    /// 去掉持续刷新的斑驳 Canvas 后，实体表在展示操作动画时无需额外进行
    /// 15 fps 的异步绘制，标题轮廓也能始终和底部说明严格对齐。
    private var stepTitleMaterial: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                    style: .continuous
                )
                    .fill(Color.white.opacity(0.08))

                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.34),
                        Color.cyan.opacity(0.22),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                // 渐变始终保持和外层玻璃相同的完整尺寸，再用矩形遮罩
                // 表示完成比例。不能先缩窄再裁成 Capsule，否则进度较少
                // 时会得到一个独立“小胶囊”，轮廓无法与标题玻璃重合。
                .frame(width: proxy.size.width, height: proxy.size.height)
                .mask(alignment: .leading) {
                    Rectangle()
                        .frame(
                            width: proxy.size.width * overallProgress,
                            height: proxy.size.height
                        )
                }
                .clipShape(RoundedRectangle(
                    cornerRadius: WatchOnboardingOverlayLayout.panelCornerRadius,
                    style: .continuous
                ))
            }
        }
    }

    /// 欢迎页不显示普通教学标题；其余步骤使用从 1 开始的教学序号。
    private func bannerTitle(for bannerStep: WatchOnboardingStep) -> String {
        "\(bannerStep.taskNumber)/\(WatchOnboardingStep.taskCount) \(bannerStep.title)"
    }

    /// 所有教学步骤共用一条 0...1 连续进度。
    private var overallProgress: CGFloat {
        min(
            1,
            max(
                0,
                animatedCompletedSteps
                    / CGFloat(WatchOnboardingStep.taskCount)
            )
        )
    }

    private func animateProgress(to completedSteps: Int) {
        withAnimation(WatchOnboardingMotion.progress) {
            animatedCompletedSteps = CGFloat(completedSteps)
        }
    }

}

/// 直接画在真实操作位置上的视觉示范。
///
/// 滑动提示位于屏幕中央，点击/长按使用语义目标的真实坐标，表冠提示根据
/// 系统表冠方向贴近左侧或右侧实体表冠。它只负责绘制且由父层禁用命中，
/// 不会抢走底层输入。
private struct WatchOnboardingOperationCue: View {
    @Environment(\.watchOnboardingAnimationsPaused) private var animationsPaused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let operations: [WatchOnboardingOperation]
    let viewportSize: CGSize
    let controlCenters: WatchOnboardingControlCenters

    var body: some View {
        PhaseAnimator(animationsPaused || reduceMotion ? [false] : [false, true]) { phase in
            ZStack {
                ForEach(operations.indices, id: \.self) { index in
                    cue(for: operations[index], phase: phase)
                }
            }
        } animation: { _ in
            WatchOnboardingMotion.operationHint
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func cue(for operation: WatchOnboardingOperation, phase: Bool) -> some View {
        switch operation {
        case let .tap(target), let .longPress(target):
            if let point = target.cuePoint(in: viewportSize, controlCenters: controlCenters) {
                tapCue(holds: operation == .longPress(target), phase: phase)
                    .position(point)
            }
        case .verticalSwipe:
            swipeCue(axis: .vertical, phase: phase)
        case .horizontalSwipe:
            swipeCue(axis: .horizontal, phase: phase)
        case .crown, .crownPage:
            crownCue(phase: phase)
        case .selectMode, .pageChanged:
            EmptyView()
        }
    }

    /// 点击目标使用扩散圆环和手指图标；长按额外保留中心实心光点。
    private func tapCue(
        holds: Bool,
        phase: Bool
    ) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(phase ? 0.08 : 0.82), lineWidth: 2)
                .frame(width: 35, height: 35)
                .scaleEffect(phase ? 1.35 : 0.62)

            if holds {
                Circle()
                    .fill(Color.white.opacity(phase ? 0.72 : 0.24))
                    .frame(width: 10, height: 10)
                    .scaleEffect(phase ? 0.78 : 1.25)
            }

            Image(systemName: holds ? "hand.point.up.left.fill" : "hand.tap.fill")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.white)
                // 手指与扩散圆环共用相位；缩放以真实点击位置为中心。
                .scaleEffect(phase ? 1.12 : 0.82)
                .offset(y: phase ? -2 : 2)
        }
    }

    /// 用指尖沿箭头轨迹移动，手掌留在箭头下方；横纵向共用同一接触点。
    private func swipeCue(
        axis: CalendarPagingDragAxis,
        phase: Bool
    ) -> some View {
        let handSize: CGFloat = 25
        // hand.draw.fill 的指尖位于字形中心左上方。补偿这段距离，
        // 让实际触点落在箭头上，而不是让手掌中心沿着箭头移动。
        let fingertipOffset = CGSize(width: handSize * 0.28, height: handSize * 0.46)

        return ZStack {
            Image(
                systemName: axis == .horizontal
                    ? "arrow.left.and.right"
                    : "arrow.up.and.down"
            )
            .font(.system(size: 30, weight: .light))
            .foregroundStyle(.white.opacity(0.68))

            Image(systemName: "hand.draw.fill")
                .font(.system(size: handSize, weight: .medium))
                .foregroundStyle(.white)
                .offset(
                    x: fingertipOffset.width + (axis == .horizontal ? (phase ? 17 : -17) : 0),
                    y: fingertipOffset.height + (axis == .vertical ? (phase ? 17 : -17) : 0)
                )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
    }

    /// 手指贴着实体表冠上下拨动，刻纹同步滚动，表达“用手指旋转表冠”。
    /// 这里只动画几何位移，不使用模糊或阴影，避免教学循环掉帧。
    private func crownCue(phase: Bool) -> some View {
        let cueHeight: CGFloat = 70
        let rightEdgeInset: CGFloat = 1
        let verticalTravel: CGFloat = phase ? 9 : -9
        let crownCenterY = min(
            viewportSize.height - cueHeight * 0.5,
            max(
                cueHeight * 0.5,
                viewportSize.height
                    * WatchOnboardingOverlayLayout.crownCenterHeightRatio
            )
        )

        return ZStack(alignment: .topTrailing) {
            Color.clear

            // 仅保留手指与表冠，翻页方向由中央的滑动示意表达。
            HStack(spacing: 0) {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(134))
                    .frame(width: 28, height: 34)
                    // 指尖略微进入表冠左缘，纵向运动时始终保持接触。
                    .offset(x: 4, y: verticalTravel)

                ZStack {
                    Capsule()
                        .fill(Color.black.opacity(0.42))
                    Capsule()
                        .stroke(Color.white.opacity(0.92), lineWidth: 1.5)

                    VStack(spacing: 3) {
                        ForEach(0..<9, id: \.self) { _ in
                            Capsule()
                                .fill(Color.white.opacity(0.78))
                                .frame(width: 6, height: 1)
                        }
                    }
                    // 刻纹与手指同向移动，表现手指正在拨动实体表冠。
                    .offset(y: verticalTravel * 0.55)
                    .mask(Capsule())
                }
                .frame(width: 12, height: 43)
            }
            .fixedSize()
            .frame(height: cueHeight)
            // padding 属于可见组合外缘：表冠胶囊距屏幕右侧恰好 1pt，
            // SF Symbol 自带的透明字形边距不参与贴边计算。
            .padding(.trailing, rightEdgeInset)
            .offset(y: crownCenterY - cueHeight * 0.5)
        }
        .frame(width: viewportSize.width, height: viewportSize.height)
    }
}

/// 纯黑欢迎页。标题位于表盘几何中心，底部斜向柔光文字提示用户轻点开始。
private struct WatchOnboardingWelcomeView: View {
    let isReady: Bool
    let start: () -> Void
    let openWidgetTutorial: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var titleVisible = false
    @State private var promptVisible = false
    @State private var press = WatchPressSession()
    @GestureState private var pressGestureIsActive = false
    @State private var pressStartedAt: ContinuousClock.Instant?
    @State private var holdTask: Task<Void, Never>?
    @State private var holdFeedback: WatchHoldFeedbackPulse?
    @State private var didCompleteHold = false

    private var isHolding: Bool {
        scenePhase == .active && press.isActive && !didCompleteHold
    }

    var body: some View {
        // 与模式按钮相同，由一套按压手势提交点击或长按，防止松手时补发开始操作。
        Button(action: {}) {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 6) {
                    WatchOnboardingSweepingLightText(
                        text: watchLocalizedString("欢迎使用 XDYou"),
                        font: .title3.weight(.semibold),
                        baseOpacity: 1
                    )
                    WatchOnboardingSweepingLightText(
                        text: watchLocalizedString("Apple Watch 课表"),
                        font: .caption,
                        baseOpacity: 0.72
                    )
                }
                .opacity(titleVisible ? 1 : 0)
                .scaleEffect(titleVisible ? 1 : 0.94)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )

                Group {
                    if isReady {
                        WatchOnboardingSweepingLightText(
                            text: watchLocalizedString("轻点屏幕以开始"),
                            font: .caption.weight(.semibold),
                            baseOpacity: 1
                        )
                        .transition(.opacity)
                    } else {
                        VStack(spacing: 7) {
                            Text(verbatim: watchLocalizedString(
                                "正在加载新手引导"
                            ))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.88))

                            // 预热任务没有稳定的分项百分比，使用白色不定量
                            // 进度条表达“仍在工作”，避免伪造数值进度。
                            WatchOnboardingLoadingBar()
                        }
                        .transition(.opacity)
                    }
                }
                .opacity(promptVisible ? 1 : 0)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
                .padding(.bottom, 24)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(welcomePressGesture)
        .sensoryFeedback(trigger: holdFeedback) { _, pulse in
            guard isHolding else { return nil }
            return pulse?.feedback
        }
        .accessibilityAction { startIfReady() }
        .accessibilityAction(named: Text(verbatim: watchLocalizedString("小组件使用指南"))) {
            openWidgetTutorial()
        }
        .animation(.easeInOut(duration: 0.24), value: isReady)
        .onAppear {
            withAnimation(WatchOnboardingMotion.welcome) {
                titleVisible = true
            }
            withAnimation(WatchOnboardingMotion.welcomePrompt.delay(0.12)) {
                promptVisible = true
            }
        }
        .onChange(of: isReady) { wasReady, isReady in
            // 只在本次预热由未完成变为完成时反馈；命中缓存、欢迎页已经
            // 以 ready 状态创建时不会无缘无故震动。
            guard !wasReady, isReady, !press.isActive else { return }
            WatchHaptics.onboardingSuccess()
        }
        .onChange(of: pressGestureIsActive) { _, isActive in
            // 系统取消手势时没有 onEnded，仍需停止震动，且不能补成一次点击。
            if !isActive, press.isActive || press.isCancelled {
                resetWelcomePress()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { cancelWelcomePress() }
        }
        .onDisappear(perform: resetWelcomePress)
    }

    private var welcomePressGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($pressGestureIsActive) { _, active, _ in active = true }
            .onChanged { value in
                guard hypot(value.translation.width, value.translation.height) <= 36 else {
                    cancelWelcomePress()
                    return
                }
                beginWelcomePressIfNeeded()
            }
            .onEnded { _ in finishWelcomePress() }
    }

    private func beginWelcomePressIfNeeded() {
        guard scenePhase == .active, press.begin() else { return }
        didCompleteHold = false
        cancelHoldFeedback()
        pressStartedAt = ContinuousClock().now
        // 组件图片不依赖实操预热，欢迎页仍在加载时也允许使用长按入口。
        holdTask = makeWatchHoldFeedbackTask(
            isActive: { isHolding },
            onPulse: { holdFeedback = $0 },
            onComplete: completeWelcomeHold
        )
    }

    private func finishWelcomePress() {
        let elapsed = pressStartedAt.map { $0.duration(to: ContinuousClock().now) }
        // 主线程忙时计时回调可能晚到；实际按满三秒的松手仍只提交一次长按。
        if let elapsed, elapsed >= WatchHoldFeedbackPulse.holdDuration {
            completeWelcomeHold()
        }
        let isTap = elapsed.map { $0 < WatchHoldFeedbackPulse.startDelay } ?? false
        let shouldTap = press.finish(didTriggerLongPress: didCompleteHold || !isTap)
        resetWelcomePress()
        if shouldTap { startIfReady() }
    }

    private func completeWelcomeHold() {
        guard isHolding else { return }
        didCompleteHold = true
        cancelHoldFeedback()
        openWidgetTutorial()
    }

    private func startIfReady() {
        guard scenePhase == .active, isReady else { return }
        start()
    }

    private func cancelHoldFeedback() {
        holdTask?.cancel()
        holdTask = nil
        holdFeedback = nil
    }

    private func cancelWelcomePress() {
        press.cancel()
        pressStartedAt = nil
        cancelHoldFeedback()
    }

    private func resetWelcomePress() {
        cancelHoldFeedback()
        press.reset()
        pressStartedAt = nil
        didCompleteHold = false
    }
}

/// 欢迎页使用的白色不定量进度条。
///
/// 只移动一个固定宽度的高亮段，渲染开销远低于复杂 Canvas，同时不会显示
/// 没有真实依据的百分比。往返动画保证等待时间较长时仍能看到持续进展。
private struct WatchOnboardingLoadingBar: View {
    @State private var movesToTrailingEdge = false

    var body: some View {
        GeometryReader { proxy in
            let segmentWidth = max(18, proxy.size.width * 0.34)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.52),
                                Color.white,
                                Color.white.opacity(0.52),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: segmentWidth)
                    .offset(
                        x: movesToTrailingEdge
                            ? max(0, proxy.size.width - segmentWidth)
                            : 0
                    )
            }
            .clipShape(Capsule())
        }
        .frame(width: 92, height: 4)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.92)
                    .repeatForever(autoreverses: true)
            ) {
                movesToTrailingEdge = true
            }
        }
        .accessibilityHidden(true)
    }
}

/// 纯黑过渡页共用的斜向扫光文字。
///
/// 低亮白色保证文字始终可读，较亮的宽柔光带从左下向右上穿过字形。
/// 扫光进度使用单调的正弦速度修正：运动会自然加速、减速，但不会反向；
/// 循环复位发生在光带完全离开文字以后，因此不会出现可见跳帧。
struct WatchOnboardingSweepingLightText: View {
    @Environment(\.watchOnboardingAnimationsPaused) private var animationsPaused
    let text: String
    let font: Font
    let baseOpacity: Double

    /// 一次扫光的总时长；光带越宽，速度变化越柔和。
    private let sweepDuration: TimeInterval = 4.0

    var body: some View {
        Text(verbatim: text)
            .font(font)
            .foregroundStyle(.white.opacity(baseOpacity * 0.78))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .overlay {
                TimelineView(.animation(minimumInterval: 1 / 30, paused: animationsPaused)) { timeline in
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let height = proxy.size.height
                        let bandWidth = max(48, width * 0.68)
                        let progress = sweepProgress(at: timeline.date)
                        let travel = width + bandWidth * 2

                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(
                                    color: .white.opacity(baseOpacity * 0.08),
                                    location: 0.18
                                ),
                                .init(
                                    color: .white.opacity(baseOpacity * 0.58),
                                    location: 0.50
                                ),
                                .init(
                                    color: .white.opacity(baseOpacity * 0.08),
                                    location: 0.82
                                ),
                                .init(color: .clear, location: 1),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: bandWidth, height: max(60, height * 3.4))
                        .rotationEffect(.degrees(-20))
                        .blur(radius: 2.2)
                        .offset(
                            x: -bandWidth + travel * progress,
                            y: -max(20, height * 1.2)
                        )
                    }
                }
                .mask {
                    Text(verbatim: text)
                        .font(font)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .accessibilityLabel(Text(verbatim: text))
    }

    /// 返回 0...1 的单向非匀速进度。
    ///
    /// 正弦项只改变瞬时速度且幅度小于线性项，确保扫光始终向前运动。
    private func sweepProgress(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: sweepDuration)
        let linearProgress = elapsed / sweepDuration
        let speedVariation = sin(linearProgress * .pi * 2) * 0.045
        return CGFloat(linearProgress - speedVariation)
    }
}

/// 目录里的提示跟随真实列表项滚动，不依赖屏幕坐标估算。
struct WatchOnboardingMenuCue: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        PhaseAnimator(reduceMotion ? [false] : [false, true]) { phase in
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .scaleEffect(phase ? 1.12 : 0.82)
                .padding(.trailing, 5)
        } animation: { _ in
            WatchOnboardingMotion.operationHint
        }
        .accessibilityHidden(true)
    }
}
