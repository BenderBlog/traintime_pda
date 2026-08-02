// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 新手引导统一采用接近 watchOS 系统控件的短促响应节奏。
///
/// 动画参数集中在这里，避免各页面分别累积固定等待时间。结果绘制允许圆环和
/// 标记轻微重叠，输入完成后能立即得到反馈，而不需要等待上一段完全结束。
enum WatchOnboardingMotion {
    static let prompt = Animation.easeOut(duration: 0.24)
    // 用户开始真实操作后，整个说明层在半秒内柔和隐去；比直接移除视图
    // 更不容易在低功耗表盘上产生一帧跳变。
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
    static let ring = Animation.easeOut(duration: 0.46)
    static let result = Animation.spring(
        response: 0.38,
        dampingFraction: 0.78
    )
    static let operationHint = Animation.easeInOut(duration: 0.88)
    /// 五个功能分段之间使用纯黑过场，淡入淡出比普通步骤稍慢，给用户
    /// 留出明确的“开始介绍下一视图”节奏，同时不会拖慢后续实操。
    static let sectionIntro = Animation.easeInOut(duration: 0.34)

    static let resultOverlapDelayNanoseconds: UInt64 = 300_000_000
    static let sectionIntroFadeNanoseconds: UInt64 = 340_000_000
    static let successVisibleDuration: TimeInterval = 0.95
    /// 概览最后一步已经由纯黑成功反馈完整遮住底层，课程列表会同时在
    /// 背后预挂载；跨章节不必再保留一整段普通步骤的停留时间。
    static let overviewExitTapResultDelay: TimeInterval = 0.18
    static let overviewExitSuccessVisibleDuration: TimeInterval = 0.62
    static let errorVisibleDuration: TimeInterval = 1.35
    /// 点击完成后先让真实页面变化短暂可见，再覆盖正确结果。
    static let tapResultDelay: TimeInterval = 0.35
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

    /// 左翻页提示在 198pt 参考表盘上的最终横坐标为 21pt。
    /// 使用最终比例，代码不再叠加额外的固定点数偏移。
    static let previousPageCueXRatio: CGFloat = 0.106

    /// 右翻页提示在 198pt 参考表盘上的最终横坐标为 124pt。
    /// 保存最终比例而非继续叠加固定偏移，避免不同表盘尺寸下位置漂移。
    static let nextPageCueXRatio: CGFloat = 0.626
}

/// 五个顶层视图对应的教学分段。
///
/// 分段页只是实操之间的视觉过场，不占用教学步骤，也不改变进度。
/// 标题直接复用视图目录的本地化名称，避免目录与引导出现两套译文。
enum WatchOnboardingSection: Equatable {
    case overview
    case courseList
    case day
    case week
    case month

    var mode: WatchCalendarMode {
        switch self {
        case .overview: .overview
        case .courseList: .courseList
        case .day: .day
        case .week: .week
        case .month: .month
        }
    }

    var title: String {
        mode.title
    }

    /// 五个真实视图依次占第 1...5 阶段；欢迎页不参与章节进度。
    var progressStage: Int {
        switch self {
        case .overview: 1
        case .courseList: 2
        case .day: 3
        case .week: 4
        case .month: 5
        }
    }

    /// 只在每个视图的第一项教学前插入分段页。
    static func starting(at step: WatchOnboardingStep) -> Self? {
        switch step {
        case .overviewSwipe:
            .overview
        case .courseListSwipe:
            .courseList
        case .dayBrowseSwipe:
            .day
        case .weekPagingArrow:
            .week
        case .monthPagingArrow:
            .month
        default:
            nil
        }
    }
}

/// 课程列表章节开始前的底层渲染准备状态。
///
/// 状态只显示在纯黑章节页上，不会叠在正在进行的操作教学之上。
enum WatchOnboardingPreparationState: Equatable {
    case ready
    case loading
    case completed
}

/// 引导点击位置的语义名称。
///
/// 位置以真实页面的稳定布局为基准计算，而不是把说明文字本身做成按钮。
/// 用户因此会在刷新、模式、日期标题、箭头或详情关闭按钮的实际位置完成操作。
enum WatchOnboardingTapTarget: Equatable {
    case anywhere
    case refresh
    case mode
    case content
    case headerPrevious
    case headerNext
    case headerTitle
    case calendarDate
    case weekCourse
    case detailClose
    case monthTitle

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
    /// 是稳定的。直接按表盘宽度缩放这组已确认坐标，避免分页重建时等待
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
/// 按星期和节次反算，不再经过这个渲染后采样器。
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

/// 引导可以自动识别的原子操作。
///
/// 每一步只匹配一个原子操作。产生相同页面效果的箭头、滑动和表冠被拆成相邻
/// 步骤，让初次使用者分别实际操作一次。
enum WatchOnboardingOperation: Equatable {
    case tap(WatchOnboardingTapTarget)
    case longPress(WatchOnboardingTapTarget)
    case verticalSwipe
    case horizontalSwipe
    case crown
    /// 日视图连续旋转表冠并真正跨过一个日期页面。
    case crownPage
}

/// 交互式新手引导的顺序状态机。
///
/// 顺序严格跟随模式目录：概览、课程列表、日视图、周视图、月视图。日视图
/// 的基础操作结束后会提前进入一次日期选择器，完整演示打开、选中和返回。
enum WatchOnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case overviewSwipe
    case overviewCrown
    case overviewControlsHide
    case overviewControlsShow
    case overviewRefresh
    case overviewSwitcherTap
    case courseListSwipe
    case courseListCrown
    case dayBrowseSwipe
    case dayBrowseCrown
    case dayPagingArrow
    case dayPagingNext
    case dayPagingSwipe
    case dayPagingCrown
    case dayDatePickerOpen
    case dayDatePickerSelect
    case weekPagingArrow
    case weekPagingNext
    case weekPagingSwipe
    case weekPagingCrown
    case weekCourse
    case courseDetailClose
    case monthPagingArrow
    case monthPagingNext
    case monthPagingSwipe
    case monthPagingCrown
    case monthSelect
    case monthExit
    /// 教学全部完成后，最后说明如何再次进入引导。
    case overviewSwitcherHold

    var id: Int { rawValue }

    var requiredMode: WatchCalendarMode {
        switch self {
        case .welcome, .overviewSwipe, .overviewCrown, .overviewRefresh,
             .overviewControlsHide, .overviewControlsShow,
             .overviewSwitcherTap, .overviewSwitcherHold:
            .overview
        case .courseListSwipe, .courseListCrown:
            .courseList
        case .dayBrowseSwipe, .dayBrowseCrown,
             .dayPagingArrow, .dayPagingNext,
             .dayPagingSwipe, .dayPagingCrown,
             .dayDatePickerOpen, .dayDatePickerSelect:
            .day
        case .weekPagingArrow, .weekPagingNext,
             .weekPagingSwipe, .weekPagingCrown,
             .weekCourse, .courseDetailClose:
            .week
        case .monthPagingArrow, .monthPagingNext,
             .monthPagingSwipe, .monthPagingCrown,
             .monthSelect, .monthExit:
            .month
        }
    }

    /// 日期选择步骤需要根视图提前挂载独立月历层。
    var presentsDayDatePicker: Bool {
        self == .dayDatePickerSelect
    }

    /// 这两步需要让按钮真正随点击隐藏或显示，根视图不能强制覆盖状态。
    var teachesControlVisibility: Bool {
        self == .overviewControlsHide || self == .overviewControlsShow
    }

    var title: String {
        switch self {
        case .welcome:
            watchLocalizedString("欢迎使用 XDYou")
        case .overviewSwipe, .overviewCrown:
            onboardingTitle(.overview, action: "浏览课程")
        case .overviewControlsHide, .overviewControlsShow:
            onboardingTitle(.overview, action: "悬浮按钮")
        case .overviewRefresh:
            onboardingTitle(.overview, action: "刷新课表")
        case .overviewSwitcherTap:
            onboardingTitle(.overview, action: "切换视图")
        case .overviewSwitcherHold:
            onboardingTitle(.overview, action: "重新打开引导")
        case .courseListSwipe, .courseListCrown:
            onboardingTitle(.courseList, action: "浏览课程")
        case .dayBrowseSwipe, .dayBrowseCrown:
            onboardingTitle(.day, action: "浏览课程")
        case .dayPagingArrow, .dayPagingNext,
             .dayPagingSwipe, .dayPagingCrown:
            onboardingTitle(.day, action: "翻页")
        case .dayDatePickerOpen:
            onboardingTitle(.day, action: "打开日期选择器")
        case .dayDatePickerSelect:
            onboardingTitleText("日期选择器", action: "选择日期")
        case .weekPagingArrow, .weekPagingNext,
             .weekPagingSwipe, .weekPagingCrown:
            onboardingTitle(.week, action: "翻页")
        case .weekCourse:
            onboardingTitle(.week, action: "查看课程")
        case .courseDetailClose:
            onboardingTitleText("课程详情", action: "关闭详情")
        case .monthPagingArrow, .monthPagingNext,
             .monthPagingSwipe, .monthPagingCrown:
            onboardingTitle(.month, action: "翻页")
        case .monthSelect:
            onboardingTitle(.month, action: "选择日期")
        case .monthExit:
            onboardingTitle(.month, action: "退出")
        }
    }

    /// 面向第一次使用者的说明只描述当前要执行的动作。
    ///
    /// 页面名称由上方标题给出，目标位置由动画指出，因此这里不重复解释实现
    /// 方式、同步阶段或页面定义，避免小屏幕上的说明超过必要长度。
    var message: String {
        switch self {
        case .welcome:
            watchLocalizedString("轻点屏幕以开始")
        case .overviewSwipe:
            watchLocalizedString("用手指上下滑动屏幕，以浏览当前课程和下一节课程。")
        case .courseListSwipe, .dayBrowseSwipe:
            watchLocalizedString("用手指上下滑动屏幕，以浏览当前页面中的课程。")
        case .overviewCrown:
            watchLocalizedString("旋转数码表冠，以浏览当前课程和下一节课程。")
        case .courseListCrown, .dayBrowseCrown:
            watchLocalizedString("旋转数码表冠，以浏览当前页面中的课程。")
        case .overviewControlsHide:
            watchLocalizedString("用手指轻点页面空白处，以隐藏右侧操作按钮。")
        case .overviewControlsShow:
            watchLocalizedString("用手指再次轻点页面空白处，以显示右侧操作按钮。")
        case .overviewRefresh:
            watchLocalizedString("用手指轻点刷新按钮，以从 iPhone 更新课表。")
        case .overviewSwitcherTap:
            watchLocalizedString("用手指轻点右下角切换按钮，以打开视图目录。")
        case .overviewSwitcherHold:
            watchLocalizedString("用手指按住右下角切换按钮三秒，以重新进入新手引导。")
        case .dayPagingArrow, .weekPagingArrow, .monthPagingArrow:
            watchLocalizedString("用手指轻点左侧箭头，以切换到上一页。")
        case .dayPagingNext, .weekPagingNext, .monthPagingNext:
            watchLocalizedString("用手指轻点右侧箭头，以切换到下一页。")
        case .dayPagingSwipe:
            watchLocalizedString("用手指左右滑动屏幕，以切换前后日期。")
        case .weekPagingSwipe:
            watchLocalizedString("用手指左右滑动屏幕，以切换前后周。")
        case .monthPagingSwipe:
            watchLocalizedString("用手指左右滑动屏幕，以切换前后月份。")
        case .dayPagingCrown:
            watchLocalizedString("连续旋转数码表冠并越过课程边界，以连续切换日期。")
        case .dayDatePickerOpen:
            watchLocalizedString("用手指轻点顶部日期标题，以打开日期选择器。")
        case .dayDatePickerSelect:
            watchLocalizedString("用手指轻点一个日期，以切换到该日期的日视图。")
        case .weekPagingCrown:
            watchLocalizedString("旋转数码表冠，以连续切换前后周。")
        case .monthPagingCrown:
            watchLocalizedString("旋转数码表冠，以连续切换前后月份。")
        case .weekCourse:
            watchLocalizedString("用手指轻点高亮的课程色块，以打开课程详情。")
        case .courseDetailClose:
            watchLocalizedString("用手指轻点关闭按钮，以返回周视图。")
        case .monthSelect:
            watchLocalizedString("用手指轻点一个日期，以打开该日期的日视图。")
        case .monthExit:
            watchLocalizedString("用手指轻点顶部月份标题，以退出月视图。")
        }
    }

    /// 使用目录中的本地化视图名拼出统一的“视图·任务”教学标题。
    private func onboardingTitle(
        _ mode: WatchCalendarMode,
        action: String
    ) -> String {
        "\(mode.title)·\(watchLocalizedString(action))"
    }

    /// 非目录页面（日期选择器、课程详情）使用相同标题格式。
    private func onboardingTitleText(
        _ page: String,
        action: String
    ) -> String {
        "\(watchLocalizedString(page))·\(watchLocalizedString(action))"
    }

    /// 每个教学步骤只验证一个动作；步骤推进后再配置下一项。
    var operation: WatchOnboardingOperation {
        switch self {
        case .welcome:
            .tap(.anywhere)
        case .overviewSwipe:
            .verticalSwipe
        case .overviewCrown:
            .crown
        case .overviewControlsHide:
            .tap(.content)
        case .overviewControlsShow:
            .tap(.content)
        case .overviewRefresh:
            .tap(.refresh)
        case .overviewSwitcherTap:
            .tap(.mode)
        case .overviewSwitcherHold:
            .longPress(.mode)
        case .courseListSwipe:
            .verticalSwipe
        case .courseListCrown:
            .crown
        case .dayBrowseSwipe:
            .verticalSwipe
        case .dayBrowseCrown:
            .crown
        case .dayPagingArrow:
            .tap(.headerPrevious)
        case .dayPagingNext:
            .tap(.headerNext)
        case .dayPagingSwipe:
            .horizontalSwipe
        case .dayPagingCrown:
            .crownPage
        case .dayDatePickerOpen:
            .tap(.headerTitle)
        case .dayDatePickerSelect:
            .tap(.calendarDate)
        case .weekPagingArrow:
            .tap(.headerPrevious)
        case .weekPagingNext:
            .tap(.headerNext)
        case .weekPagingSwipe:
            .horizontalSwipe
        case .weekPagingCrown:
            .crown
        case .weekCourse:
            .tap(.weekCourse)
        case .courseDetailClose:
            .tap(.detailClose)
        case .monthPagingArrow:
            .tap(.headerPrevious)
        case .monthPagingNext:
            .tap(.headerNext)
        case .monthPagingSwipe:
            .horizontalSwipe
        case .monthPagingCrown:
            .crown
        case .monthSelect:
            .tap(.calendarDate)
        case .monthExit:
            .tap(.monthTitle)
        }
    }
}

/// 成功或错误时才会短暂出现在表盘中央的结果状态。
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
    private var operationAccepted: ((
        WatchOnboardingStep,
        WatchOnboardingOperation
    ) -> Void)?
    private var operationRejected: ((
        WatchOnboardingStep,
        WatchOnboardingOperation
    ) -> Void)?
    private var advance: (() -> Void)?

    func configure(
        step: WatchOnboardingStep,
        operationAccepted: @escaping (
            WatchOnboardingStep,
            WatchOnboardingOperation
        ) -> Void,
        operationRejected: @escaping (
            WatchOnboardingStep,
            WatchOnboardingOperation
        ) -> Void,
        advance: @escaping () -> Void
    ) {
        feedbackTask?.cancel()
        self.step = step
        self.operationAccepted = operationAccepted
        self.operationRejected = operationRejected
        self.advance = advance
        isEvaluating = false
        feedback = nil
        presentPrompt()
    }

    func clear() {
        feedbackTask?.cancel()
        feedbackTask = nil
        step = nil
        operationAccepted = nil
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

    func observe(
        _ operation: WatchOnboardingOperation,
        at location: CGPoint? = nil,
        controlCenters: WatchOnboardingControlCenters? = nil,
        in size: CGSize
    ) {
        guard let step, !isEvaluating
        else { return }
        let expectedOperation = step.operation

        beginOperation()

        guard operationsMatch(expectedOperation, operation),
              tapLocationMatches(
                  expected: expectedOperation,
                  location: location,
                  controlCenters: controlCenters,
                  size: size
              )
        else {
            operationRejected?(step, operation)
            showError()
            return
        }

        isEvaluating = true
        showsPrompt = false

        // 点击会直接改变真实页面（打开目录、翻页、进入详情等）。若立即
        // 黑屏显示对号，用户看不到刚完成的变化；短暂留出透明观察窗口后
        // 再确认成功。滑动和表冠没有这段额外等待，保持即时反馈。
        if expectedOperation.isTapInteraction {
            let delay = step == .overviewSwitcherTap
                ? WatchOnboardingMotion.overviewExitTapResultDelay
                : WatchOnboardingMotion.tapResultDelay
            feedbackTask?.cancel()
            feedbackTask = makeWatchAutoDismissTask(
                after: delay
            ) { [weak self] in
                guard let self,
                      self.step == step,
                      self.isEvaluating
                else { return }
                self.showSuccess(
                    step: step,
                    operation: expectedOperation
                )
            }
            return
        }

        showSuccess(step: step, operation: expectedOperation)
    }

    /// 正确结果的绘制、触觉、业务收尾和自动推进统一从这里执行。
    private func showSuccess(
        step: WatchOnboardingStep,
        operation: WatchOnboardingOperation
    ) {
        withAnimation(WatchOnboardingMotion.feedback) {
            feedback = .success
        }
        WatchHaptics.onboardingSuccess()
        operationAccepted?(step, operation)

        feedbackTask?.cancel()
        let visibleDuration = step == .overviewSwitcherTap
            ? WatchOnboardingMotion.overviewExitSuccessVisibleDuration
            : WatchOnboardingMotion.successVisibleDuration
        feedbackTask = makeWatchAutoDismissTask(
            after: visibleDuration
        ) { [weak self] in
            guard let self else { return }
            withAnimation(WatchOnboardingMotion.feedbackDismiss) {
                self.feedback = nil
            }
            self.advance?()
        }
    }

    private func showError() {
        isEvaluating = true
        // 错误反馈只叠加白色错号。原教学提示和动作示意保持在下层可见，
        // 不再由结果动画重复绘制第二份错误说明。
        withAnimation(WatchOnboardingMotion.feedback) {
            showsPrompt = true
            feedback = .error
        }
        WatchHaptics.onboardingError()
        feedbackTask?.cancel()
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

    private func operationsMatch(
        _ expected: WatchOnboardingOperation,
        _ received: WatchOnboardingOperation
    ) -> Bool {
        switch (expected, received) {
        case let (.tap(expectedTarget), .tap(receivedTarget)):
            expectedTarget == receivedTarget
        case let (.longPress(expectedTarget), .longPress(receivedTarget)):
            expectedTarget == receivedTarget
        case (.verticalSwipe, .verticalSwipe),
             (.horizontalSwipe, .horizontalSwipe),
             (.crown, .crown), (.crownPage, .crownPage):
            true
        default:
            false
        }
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

private extension WatchOnboardingOperation {
    /// 普通点击和长按都会立即改变底层界面，二者共享短暂观察延迟。
    var isTapInteraction: Bool {
        switch self {
        case .tap, .longPress:
            true
        default:
            false
        }
    }
}

/// 只负责显示的全屏引导层；欢迎页、分段页和完成页会接收继续轻点，
/// 其余实操步骤不参与命中，让输入直接抵达真实页面。
struct WatchOnboardingOverlay: View {
    let step: WatchOnboardingStep
    let sectionIntro: WatchOnboardingSection?
    let sectionPreparation: WatchOnboardingPreparationState
    let controlCenters: WatchOnboardingControlCenters
    let feedback: WatchOnboardingFeedback?
    let showsPrompt: Bool
    let showsCompletion: Bool
    let isInitialPreparationReady: Bool
    /// 欢迎页背后的第一段黑场与首个操作提示已完成首轮渲染。
    let initialPresentationPrepared: () -> Void
    let start: () -> Void
    let continueSectionIntro: () -> Void
    let finish: () -> Void
    @State private var animatedCompletedSteps: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let sectionIntro {
                    ZStack {
                        // 在纯黑章节页背后提前建立下一项提示使用的玻璃、
                        // Canvas 和动作动画资源。实体表第一次创建这些渲染
                        // 节点的开销不再落在用户轻点“概览”之后；0.001 只为
                        // 防止系统把整棵不可见子树直接裁掉，前方纯黑页会将
                        // 它完全遮住，不改变章节页显示。
                        onboardingPromptPrewarm(
                            for: step,
                            in: proxy.size
                        )
                            .opacity(0.001)
                            .allowsHitTesting(false)

                        WatchOnboardingSectionIntroView(
                            section: sectionIntro,
                            preparation: sectionPreparation,
                            continueAction: continueSectionIntro
                        )
                    }
                        // 章节页必须先于底层路由变化完整盖住表盘。插入不做
                        // 淡入，退出仍保留系统式淡出，杜绝首帧漏出页面切换。
                        .transition(
                            .asymmetric(insertion: .identity, removal: .opacity)
                        )
                } else if step == .welcome, showsPrompt, feedback == nil {
                    ZStack {
                        // 欢迎页的纯黑背景后提前创建第一段黑场和第一个实操
                        // 提示。实体表首次建立扫光、玻璃和 Canvas 管线的
                        // 开销发生在“正在加载”期间，而不是用户轻点之后。
                        initialOnboardingPresentationWarmup(in: proxy.size)

                        // 欢迎页是唯一主动接管触摸的教学页面；进入教程后，
                        // 所有遮罩都关闭命中测试，让输入直接抵达真实课表。
                        WatchOnboardingWelcomeView(
                            isReady: isInitialPreparationReady,
                            start: start
                        )
                    }
                    .transition(.opacity)
                } else {
                    ZStack {
                    Group {
                    if showsPrompt || showsCompletion {
                        if showsCompletion {
                            // 完整教学结束使用纯黑背景，不再透出课表内容。
                            Color.black
                                .ignoresSafeArea()
                                .transition(.opacity)

                            completionMessage
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .center
                                )
                        } else {
                            // 教学出现时稍微压低真实页面亮度，把注意力集中在
                            // 操作目标；整层连续透明，不制造横向分界线。
                            Color.black.opacity(0.32)
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
                                operation: step.operation,
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
                    }

                    if let feedback {
                        // 正确时完全黑屏确认；错误时保留真实页面，仅把白色
                        // 错号和操作提示叠在最上层，便于立即对照重试。
                        if feedback == .success {
                            Color.black
                                .ignoresSafeArea()
                        }

                        WatchOnboardingResultAnimation(
                            feedback: feedback
                        )
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                            .transition(.opacity)
                            // 正确/错误反馈属于教学动作的最终状态，覆盖其余
                            // 教学内容，但不会参与真实页面命中。
                            .zIndex(200)
                    }
                    }
                    .allowsHitTesting(false)

                    if showsCompletion {
                        // 完成页保持纯黑直到用户确认，避免固定计时在用户
                        // 尚未读完时自动闪退。透明按钮只存在于完成状态。
                        Button(action: finish) {
                            Color.clear
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            Text(verbatim: watchLocalizedString("轻点屏幕以开始"))
                        )
                    }
                    }
                }
            }
        }
        // 根导航容器会把普通内容放到状态栏下方；教学层跨越安全区后，
        // 标题与底部说明才能按整个表盘的固定参考位置摆放。
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
        .onAppear {
            animateProgress(
                to: showsCompletion
                    ? WatchOnboardingStep.allCases.count
                    : step.rawValue + 1
            )
        }
        .onChange(of: step.rawValue) { _, rawValue in
            animateProgress(to: rawValue + 1)
        }
        .onChange(of: showsCompletion) { _, isComplete in
            guard isComplete else { return }
            animateProgress(to: WatchOnboardingStep.allCases.count)
        }
    }

    /// 章节黑场期间仅预热下一项会使用的提示组件，不显示也不接收输入。
    ///
    /// 这里保持与实操层相同的尺寸、材质和动作类型，使真机提前完成首轮
    /// 字形、玻璃和 Canvas 管线准备；章节淡出后不再集中创建这些节点。
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
                operation: warmupStep.operation,
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

            WatchOnboardingSectionIntroView(
                section: .overview,
                preparation: .ready,
                continueAction: {}
            )
        }
        .opacity(0.001)
        .allowsHitTesting(false)
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
                for: instructionStep.operation
            ))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.96))
                .frame(width: 20, alignment: .center)

            Text(verbatim: instructionStep.message)
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
        for operation: WatchOnboardingOperation
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
        }
    }

    /// 所有步骤使用相同宽度的标题。连续进度直接成为标题材质的一部分，
    /// 不再创建会改变垂直布局的独立进度条。
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
        let total = max(1, WatchOnboardingStep.allCases.count - 1)
        let index = min(total, max(1, bannerStep.rawValue))
        return "\(index)/\(total) \(bannerStep.title)"
    }

    /// 所有教学步骤共用一条 0...1 连续进度。
    private var overallProgress: CGFloat {
        min(
            1,
            max(
                0,
                animatedCompletedSteps
                    / CGFloat(WatchOnboardingStep.allCases.count)
            )
        )
    }

    private func animateProgress(to completedSteps: Int) {
        withAnimation(WatchOnboardingMotion.progress) {
            animatedCompletedSteps = CGFloat(completedSteps)
        }
    }

    private var completionMessage: some View {
        VStack(spacing: 5) {
            Text(verbatim: watchLocalizedString("新手引导已完成"))
                .font(.headline)
            Text(verbatim: watchLocalizedString("轻点屏幕继续"))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.72))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .shadow(color: .black.opacity(0.85), radius: 4, y: 1)
    }

}

/// 与欢迎页一致的纯黑分段提示页。
///
/// 该页面在存在期间主动覆盖并拦截底层输入；根视图会等淡出结束后才配置下一
/// 项教学检测，因此用户在过场期间触摸或转动表冠都不会被误判为已完成操作。
private struct WatchOnboardingSectionIntroView: View {
    let section: WatchOnboardingSection
    let preparation: WatchOnboardingPreparationState
    let continueAction: () -> Void
    @State private var contentVisible = false

    var body: some View {
        Button {
            guard preparation == .ready else { return }
            continueAction()
        } label: {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    WatchOnboardingSweepingLightText(
                        text: section.title,
                        font: .headline.weight(.semibold),
                        baseOpacity: 1
                    )
                    preparationMessage
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)
                .opacity(contentVisible ? 1 : 0)
                .scaleEffect(contentVisible ? 1 : 0.96)

                WatchOnboardingSectionProgressView(
                    stage: section.progressStage
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 30)
                .opacity(contentVisible ? 1 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(WatchOnboardingMotion.sectionIntro) {
                contentVisible = true
            }
        }
    }

    @ViewBuilder
    private var preparationMessage: some View {
        switch preparation {
        case .ready:
            WatchOnboardingSweepingLightText(
                text: watchLocalizedString("轻点以继续"),
                font: .caption2.weight(.medium),
                baseOpacity: 0.76
            )
        case .loading:
            VStack(spacing: 7) {
                ProgressView()
                    .controlSize(.small)
                    .tint(.white)
                Text(verbatim: watchLocalizedString(
                    "第一次载入课表，正在渲染底层数据"
                ))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
            }
        case .completed:
            VStack(spacing: 7) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text(verbatim: watchLocalizedString("底层数据已准备完成"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

/// 五个视图章节共用的阶段进度。
///
/// `n/5` 只统计真实功能视图；欢迎页和最终完成页不显示章节进度。进入
/// 第五段时只填满最后一格，五段之间始终保留原有间隔。
private struct WatchOnboardingSectionProgressView: View {
    let stage: Int
    @State private var currentSegmentFill: CGFloat = 0

    private let segmentCount = 5
    private let barWidth: CGFloat = 112
    private let barHeight: CGFloat = 5
    private let segmentSpacing: CGFloat = 4

    var body: some View {
        VStack(spacing: 5) {
            Text(verbatim: "\(min(5, max(1, stage)))/5")
                .font(.caption2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.88))

            HStack(spacing: segmentSpacing) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    segment(index)
                }
            }
            .frame(width: barWidth, height: barHeight)
        }
        .onAppear(perform: startAnimation)
    }

    /// `stage - 1` 是本次需要从 0 填满的格；更早的格保持完成状态。
    private func segment(_ index: Int) -> some View {
        let activeIndex = stage - 1
        let completed = index < activeIndex
        let isCurrent = index == activeIndex
        let fill = completed ? 1 : (isCurrent ? currentSegmentFill : 0)
        let segmentWidth = (
            barWidth - CGFloat(segmentCount - 1) * segmentSpacing
        ) / CGFloat(segmentCount)

        return Capsule()
            .fill(Color.white.opacity(0.15))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan.opacity(0.88)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: segmentWidth * fill)
            }
            .clipShape(Capsule())
            .frame(width: segmentWidth, height: barHeight)
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.52)) {
            currentSegmentFill = 1
        }
    }
}

/// 直接画在真实操作位置上的视觉示范。
///
/// 滑动提示位于屏幕中央，点击/长按使用语义目标的真实坐标，表冠提示根据
/// 系统表冠方向贴近左侧或右侧实体表冠。它只负责绘制且由父层禁用命中，
/// 不会抢走底层输入。
private struct WatchOnboardingOperationCue: View {
    let operation: WatchOnboardingOperation
    let viewportSize: CGSize
    let controlCenters: WatchOnboardingControlCenters
    /// 点击步骤只在首个有效实测坐标到达时锁定一次；页面后续布局采样不会
    /// 再驱动 `.position`，因此提示不会从回退点缓慢漂向实际按钮。
    @State private var lockedTapPoint: CGPoint? = nil

    @ViewBuilder
    var body: some View {
        switch operation {
        case let .tap(target):
            tapAnimation(target: target, holds: false)
        case let .longPress(target):
            tapAnimation(target: target, holds: true)
        case .verticalSwipe:
            phaseAnimation { phase in
                swipeCue(axis: .vertical, phase: phase)
            }
        case .horizontalSwipe:
            phaseAnimation { phase in
                swipeCue(axis: .horizontal, phase: phase)
            }
        case .crown:
            phaseAnimation { phase in
                crownCue(phase: phase, showsPagingHint: false)
            }
        case .crownPage:
            phaseAnimation { phase in
                crownCue(phase: phase, showsPagingHint: true)
            }
        }
    }

    @ViewBuilder
    private func phaseAnimation<Content: View>(
        @ViewBuilder content: @escaping (Bool) -> Content
    ) -> some View {
        PhaseAnimator([false, true]) { phase in
            content(phase)
                .compositingGroup()
        } animation: { _ in
            WatchOnboardingMotion.operationHint
        }
    }

    @ViewBuilder
    private func tapAnimation(
        target: WatchOnboardingTapTarget,
        holds: Bool
    ) -> some View {
        Group {
            if let lockedTapPoint {
                PhaseAnimator([false, true]) { phase in
                    tapCue(holds: holds, phase: phase)
                } animation: { _ in
                    WatchOnboardingMotion.operationHint
                }
                // 坐标位于循环动画之外，只在第一次得到真实几何时直接安装；
                // PhaseAnimator 此后只改变圆环和手指大小，绝不会插值位置。
                .position(lockedTapPoint)
                .compositingGroup()
            } else {
                Color.clear
            }
        }
        // Toolbar 和周网格可能晚一帧上报。每次中心集合变化时只尝试
        // 补齐尚未锁定的位置，已经显示的提示保持不动。
        .onAppear { lockTapPointIfPossible(target) }
        .onChange(of: controlCenters) { _, _ in
            lockTapPointIfPossible(target)
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
                // 与外层扩散圆环共用相位，让手指也产生清晰的按压呼吸感；
                // 圆环原有缩放范围和真实点击坐标均保持不变。
                .scaleEffect(phase ? 1.12 : 0.82)
                .offset(y: phase ? -2 : 2)
        }
    }

    private func lockTapPointIfPossible(
        _ target: WatchOnboardingTapTarget
    ) {
        guard lockedTapPoint == nil,
              let point = target.cuePoint(
                  in: viewportSize,
                  controlCenters: controlCenters
              )
        else { return }
        // 不包裹 withAnimation：提示第一次出现时直接位于目标圆心。
        lockedTapPoint = point
    }

    /// 横向或纵向手势使用同一组系统手形，只改变运动轴。
    private func swipeCue(
        axis: CalendarPagingDragAxis,
        phase: Bool
    ) -> some View {
        ZStack {
            Image(
                systemName: axis == .horizontal
                    ? "arrow.left.and.right"
                    : "arrow.up.and.down"
            )
            .font(.system(size: 30, weight: .light))
            .foregroundStyle(.white.opacity(0.68))

            Image(systemName: "hand.draw.fill")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(.white)
                .offset(
                    x: axis == .horizontal ? (phase ? 17 : -17) : 0,
                    y: axis == .vertical ? (phase ? 17 : -17) : 0
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
    private func crownCue(
        phase: Bool,
        showsPagingHint: Bool
    ) -> some View {
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

            // 三个可见组件直接组成紧凑 HStack；不再用 58pt 透明容器推算
            // 横坐标。最末尾的自绘表冠胶囊就是整个动画的真实右边界。
            HStack(spacing: 0) {
                Image(
                    systemName: showsPagingHint
                        ? "arrow.left.and.right"
                        : "arrow.up.and.down"
                )
                .font(.system(size: 31, weight: .light))
                .foregroundStyle(.white.opacity(0.36))
                .frame(width: 31)

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
            // SF Symbol 自带的透明字形边距不再参与贴边计算。
            .padding(.trailing, rightEdgeInset)
            // 只改变横向锚定方式；中心纵坐标完全沿用原比例和上下限。
            .offset(y: crownCenterY - cueHeight * 0.5)
        }
        .frame(width: viewportSize.width, height: viewportSize.height)
    }
}

/// 纯黑欢迎页。标题位于表盘几何中心，底部斜向柔光文字提示用户轻点开始。
private struct WatchOnboardingWelcomeView: View {
    let isReady: Bool
    let start: () -> Void
    @State private var titleVisible = false
    @State private var promptVisible = false

    var body: some View {
        Button {
            guard isReady else { return }
            start()
        } label: {
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
            guard !wasReady, isReady else { return }
            WatchHaptics.onboardingSuccess()
        }
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
private struct WatchOnboardingSweepingLightText: View {
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
                TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
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

/// 参考系统确认反馈的紧凑“圆环—对号”动画。
///
/// 成功反馈保留协调的圆环和对号比例；错误反馈只绘制较小、较粗的白色错号，
/// 不再套一层容易显得拥挤的外圈。两种反馈占用相同容器，切换时不会跳位。
private struct WatchOnboardingResultAnimation: View {
    let feedback: WatchOnboardingFeedback
    @State private var ringProgress: CGFloat = 0
    @State private var resultProgress: CGFloat = 0
    @State private var resultScale: CGFloat = 0.82

    private var resultColor: Color {
        feedback == .success ? .green : .white
    }

    var body: some View {
        resultSymbol
            .task(animateResult)
            .accessibilityLabel(
                feedback == .success
                    ? watchLocalizedString("操作正确")
                    : watchLocalizedString("操作错误")
            )
    }

    /// 成功和错误共用相同的外部尺寸，只替换内部图形。
    private var resultSymbol: some View {
        ZStack {
            if feedback == .success {
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        resultColor,
                        style: StrokeStyle(lineWidth: 3.6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: resultColor.opacity(0.24), radius: 2.5)
                    .frame(width: 54, height: 54)

                WatchOnboardingCheckmarkShape()
                    .trim(from: 0, to: resultProgress)
                    .stroke(
                        resultColor,
                        style: StrokeStyle(
                            lineWidth: 4.6,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: 27, height: 22)
            } else {
                WatchOnboardingXmarkShape()
                    .trim(from: 0, to: resultProgress)
                    .stroke(
                        resultColor,
                        style: StrokeStyle(
                            lineWidth: 5.8,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: 37, height: 37)
                    .shadow(color: resultColor.opacity(0.18), radius: 2)
            }
        }
        .frame(width: 58, height: 58)
        .scaleEffect(resultScale)
    }

    /// 成功先画圆环再画对号；错误直接画错号，不执行无意义的圆环阶段。
    private func animateResult() async {
        if feedback == .success {
            withAnimation(WatchOnboardingMotion.ring) {
                ringProgress = 1
                resultScale = 1
            }
            try? await Task.sleep(
                nanoseconds: WatchOnboardingMotion.resultOverlapDelayNanoseconds
            )
            guard !Task.isCancelled else { return }
            withAnimation(WatchOnboardingMotion.result) {
                resultProgress = 1
            }
        } else {
            withAnimation(WatchOnboardingMotion.result) {
                resultProgress = 1
                resultScale = 1
            }
        }
    }
}

/// 从左下至右上一笔绘制的对号。
private struct WatchOnboardingCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(
            to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

/// 两条对角线组成的纯白错号。
private struct WatchOnboardingXmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
