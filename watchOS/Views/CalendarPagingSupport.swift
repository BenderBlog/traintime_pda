// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 表冠横向翻页在新会话或反转方向后的渐进速度状态。
///
/// 前两张完整页面使用 50% 行程，第三张起恢复标准行程；只统计表冠真正
/// 跨过的页面，触摸拖动和吸附动画不会改变计数。
struct CalendarCrownPageRamp {
    private(set) var committedPageCount = 0

    var distanceScale: CGFloat {
        committedPageCount < 2 ? 0.5 : 1
    }

    mutating func register(_ update: WatchCrownTurnUpdate) {
        if update.startsNewSession || update.reversesDirection {
            committedPageCount = 0
        }
    }

    mutating func recordCommittedPage() {
        committedPageCount = min(2, committedPageCount + 1)
    }

    mutating func reset() {
        committedPageCount = 0
    }
}

/// 单个触摸层判定横向翻页或纵向滚动的轴向。
enum CalendarPagingDragAxis: Equatable {
    case horizontal
    case vertical
}

/// 三页分页器中的稳定页面描述。
///
/// `relativePage` 决定页面此刻位于左、中、右哪一格；`id` 使用真实日期。
/// 日期推进后，SwiftUI 因而可以把已渲染的页面移动到新位置，而不是把三页
/// 全部销毁重建。
struct CalendarPagerPage: Identifiable {
    let relativePage: Int
    let id: Date
}

/// 仿系统日历的三页横向容器。
///
/// 前一页、当前页、后一页始终并排预渲染，外部只需要提供一个连续像素偏移。
/// 手指横拖和表冠旋转因此能看到同一套跟手动画；日期数据只在吸附动画结束
/// 后替换，避免中途出现空白或旧页闪烁。
struct CalendarHorizontalPager<Page: View>: View {
    let pageOffset: CGFloat
    let interactionResetToken: Int
    let pageIdentity: (Int) -> Date
    let page: (Int) -> Page
    let onViewportWidthChange: (CGFloat) -> Void
    let onViewportHeightChange: (CGFloat) -> Void
    let onHorizontalDragBegan: () -> Void
    let onHorizontalDragChanged: (CGFloat) -> Void
    let onHorizontalDragEnded: (DragGesture.Value) -> Void
    let onVerticalDragBegan: () -> Void
    let onVerticalDragChanged: (CGFloat) -> Void
    let onVerticalDragEnded: (DragGesture.Value) -> Void
    let onDragAxisLocked: (CalendarPagingDragAxis) -> Void
    let onDragFinished: () -> Void

    @State private var dragAxis: CalendarPagingDragAxis?
    @State private var horizontalDragStarted = false
    @State private var verticalDragStarted = false
    @State private var dragStartTime: Date?

    /// 给初始细小抖动约一到两帧的观察窗口，再锁定整次触摸的方向。
    /// 一旦锁定，手指中途偏斜也不会让横纵手势互相抢占。
    private let directionDetectionWindow: TimeInterval = 0.035
    private let directionDetectionDistance: CGFloat = 5
    private let directionDominanceRatio: CGFloat = 1.1

    init(
        pageOffset: CGFloat,
        interactionResetToken: Int = 0,
        pageIdentity: @escaping (Int) -> Date,
        @ViewBuilder page: @escaping (Int) -> Page,
        onViewportWidthChange: @escaping (CGFloat) -> Void,
        onViewportHeightChange: @escaping (CGFloat) -> Void,
        onHorizontalDragBegan: @escaping () -> Void,
        onHorizontalDragChanged: @escaping (CGFloat) -> Void,
        onHorizontalDragEnded: @escaping (DragGesture.Value) -> Void,
        onVerticalDragBegan: @escaping () -> Void,
        onVerticalDragChanged: @escaping (CGFloat) -> Void,
        onVerticalDragEnded: @escaping (DragGesture.Value) -> Void,
        onDragAxisLocked: @escaping (CalendarPagingDragAxis) -> Void,
        onDragFinished: @escaping () -> Void
    ) {
        self.pageOffset = pageOffset
        self.interactionResetToken = interactionResetToken
        self.pageIdentity = pageIdentity
        self.page = page
        self.onViewportWidthChange = onViewportWidthChange
        self.onViewportHeightChange = onViewportHeightChange
        self.onHorizontalDragBegan = onHorizontalDragBegan
        self.onHorizontalDragChanged = onHorizontalDragChanged
        self.onHorizontalDragEnded = onHorizontalDragEnded
        self.onVerticalDragBegan = onVerticalDragBegan
        self.onVerticalDragChanged = onVerticalDragChanged
        self.onVerticalDragEnded = onVerticalDragEnded
        self.onDragAxisLocked = onDragAxisLocked
        self.onDragFinished = onDragFinished
    }

    var body: some View {
        GeometryReader { proxy in
            let pages = (-1...1).map {
                CalendarPagerPage(
                    relativePage: $0,
                    id: pageIdentity($0)
                )
            }
            HStack(spacing: 0) {
                ForEach(pages) { descriptor in
                    page(descriptor.relativePage)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        // 恢复页面内部原有的命中层级，使日视图纵向接管、
                        // 轻点收口和周课程点击继续由内容页优先处理。手势虽然
                        // 挂在页面上，但位移使用外层固定命名坐标，不会因页面
                        // 自身移动而产生坐标反馈抽动。
                        .simultaneousGesture(pagingGesture)
                }
            }
            // 三张页面保持原有、完全对称的三屏布局，避免把超宽内容再次
            // 压入单屏容器后造成前一页与后一页的非对称裁剪。
            .frame(
                width: proxy.size.width * 3,
                height: proxy.size.height,
                alignment: .leading
            )
            .offset(x: -proxy.size.width + pageOffset)
            .onAppear {
                onViewportWidthChange(proxy.size.width)
                onViewportHeightChange(proxy.size.height)
            }
            .onChange(of: proxy.size.width) { _, width in
                onViewportWidthChange(width)
            }
            .onChange(of: proxy.size.height) { _, height in
                onViewportHeightChange(height)
            }
            .onChange(of: interactionResetToken) { _, _ in
                resetTouchRecognition()
            }
        }
        // 页面中的 DragGesture 统一引用这个固定坐标系；页面视觉平移不会
        // 改变下一帧 translation 的测量原点。
        .coordinateSpace(name: "calendarPagingInput")
        .clipped()
    }

    /// 吸附开始时清空本次触摸的轴判断和累计状态。
    ///
    /// 当前手势稍后即使补发 `onEnded`，父视图已经进入 transition 状态，
    /// 不会再次创建吸附；这里仍调用结束回调以恢复纵向 ScrollView 开关。
    private func resetTouchRecognition() {
        dragAxis = nil
        horizontalDragStarted = false
        verticalDragStarted = false
        dragStartTime = nil
        onDragFinished()
    }

    private var pagingGesture: some Gesture {
        DragGesture(
            minimumDistance: 2,
            coordinateSpace: .named("calendarPagingInput")
        )
            .onChanged { value in
                if dragStartTime == nil {
                    dragStartTime = value.time
                }
                if dragAxis == nil {
                    let horizontal = abs(value.translation.width)
                    let vertical = abs(value.translation.height)
                    let elapsed = value.time.timeIntervalSince(
                        dragStartTime ?? value.time
                    )
                    let movedEnough = max(horizontal, vertical)
                        >= directionDetectionDistance
                    let horizontalDominates = horizontal
                        >= vertical * directionDominanceRatio
                    let verticalDominates = vertical
                        >= horizontal * directionDominanceRatio

                    // 明确的单轴移动可以立即锁定；斜向或非常轻微的移动最多
                    // 观察 35ms，随后选择累计位移较大的轴，减少开始拖动时
                    // 页面静止、随后突然追上手指的迟滞感。
                    guard (movedEnough
                            && (horizontalDominates || verticalDominates))
                            || elapsed >= directionDetectionWindow
                    else {
                        return
                    }
                    let lockedAxis: CalendarPagingDragAxis = horizontal > vertical
                        ? .horizontal
                        : .vertical
                    dragAxis = lockedAxis
                    onDragAxisLocked(lockedAxis)
                }

                switch dragAxis {
                case .horizontal:
                    if !horizontalDragStarted {
                        horizontalDragStarted = true
                        onHorizontalDragBegan()
                    }
                    onHorizontalDragChanged(value.translation.width)
                case .vertical:
                    if !verticalDragStarted {
                        verticalDragStarted = true
                        onVerticalDragBegan()
                    }
                    onVerticalDragChanged(value.translation.height)
                case nil:
                    break
                }
            }
            .onEnded { value in
                if dragAxis == .horizontal, horizontalDragStarted {
                    onHorizontalDragEnded(value)
                }
                if dragAxis == .vertical, verticalDragStarted {
                    onVerticalDragEnded(value)
                }
                dragAxis = nil
                horizontalDragStarted = false
                verticalDragStarted = false
                dragStartTime = nil
                onDragFinished()
            }
    }
}

/// 一次触摸结束时推算出的目标页和横向速度。
struct HorizontalPageMotion {
    let direction: Int
    let velocity: CGFloat
}

/// 一次吸附动画已经归一化的方向、终点和时长。
struct HorizontalPageSnap {
    let direction: Int
    let target: CGFloat
    let duration: Double
}

/// 表冠一次更新对应的横向像素位移与吸附速度。
struct CalendarCrownPageMotion {
    let offsetDelta: CGFloat
    let velocity: CGFloat
}

/// 表冠横向分页的速度响应方式。
///
/// `balanced` 保留周/月视图已经确认的手感；`precisionAccelerated` 用于
/// 日视图，让慢转进入更细的像素级控制区，快速旋转时再明显提高页移倍率。
enum CalendarCrownVelocityProfile {
    case balanced
    case precisionAccelerated
}

/// 连续三页容器将越过的整页归一化后的结果。
struct ContinuousPageOffsetUpdate {
    let offset: CGFloat
    let crossedPage: Int
}

/// 在不触发隐式动画的事务中原子更新分页或滚动状态。
///
/// 三页容器跨过整页后需要同时切换数据基准并归一化偏移；统一使用该函数可
/// 避免某个调用点遗漏 `transaction.animation = nil` 而产生闪动。
func performWithoutAnimation(_ updates: () -> Void) {
    var transaction = Transaction()
    transaction.animation = nil
    withTransaction(transaction) {
        updates()
    }
}

/// 创建日、周、月视图共用的页面提交任务。
///
/// 动画结束后多等待 15ms，让 SwiftUI 先提交最后一帧；调用方仍用
/// 自己的 token 拒绝已经过期的完成回调。
func makeCalendarPageCompletionTask(
    after animationDuration: Double,
    action: @escaping @MainActor () -> Void
) -> Task<Void, Never> {
    Task { @MainActor in
        try? await Task.sleep(
            nanoseconds: UInt64(
                (animationDuration + 0.015) * 1_000_000_000
            )
        )
        guard !Task.isCancelled else { return }
        action()
    }
}

/// 日、周、月视图共享的表冠输入参数。
///
/// 三个页面只提供各自的事件处理函数；刻度范围、步长、灵敏度和系统声音
/// 开关集中在这里，避免后续只修改其中一个页面而产生不同手感。业务触觉由
/// `WatchHaptics` 在真正翻页或到达边界时触发，系统表冠声音保持关闭。
struct CalendarPagingCrownInputModifier: ViewModifier {
    @Binding var detent: Double
    let focused: FocusState<Bool>.Binding
    let onChange: (DigitalCrownEvent) -> Void
    let onIdle: () -> Void

    func body(content: Content) -> some View {
        content
            .focusable()
            .focused(focused)
            .digitalCrownRotation(
                detent: $detent,
                from: -1_000,
                through: 1_000,
                by: 0.25,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: false,
                onChange: onChange,
                onIdle: onIdle
            )
    }
}

extension View {
    /// 安装日历分页统一表冠行为，不改变调用视图的尺寸与命中区域。
    func calendarPagingCrownInput(
        detent: Binding<Double>,
        focused: FocusState<Bool>.Binding,
        onChange: @escaping (DigitalCrownEvent) -> Void,
        onIdle: @escaping () -> Void
    ) -> some View {
        modifier(
            CalendarPagingCrownInputModifier(
                detent: detent,
                focused: focused,
                onChange: onChange,
                onIdle: onIdle
            )
        )
    }
}

/// 日、周、月分页共用的表冠停止协调器。
///
/// watchOS 正常会在停止旋转后发送 `onIdle`，但实体表在焦点切换或系统
/// ScrollView 参与时偶尔会漏发。协调器同时维护两种互斥计时：
///
/// - 每个有效刻度重置 360ms 兜底；
/// - 收到 `onIdle` 后改用 90ms 短确认窗。
///
/// 新刻度、页面吸附或视图退出都会调用 `cancel()`，因此同一页面永远只有
/// 一个待执行任务。三种视图不再分别维护相同的 Task 生命周期代码。
final class CalendarCrownIdleCoordinator {
    private static let fallbackDelay: UInt64 = 360_000_000
    private static let idleConfirmationDelay: UInt64 = 90_000_000
    private var task: Task<Void, Never>?

    /// 安装实体表漏发 `onIdle` 时使用的较长兜底计时。
    func scheduleFallback(
        action: @escaping @MainActor () -> Void
    ) {
        schedule(afterNanoseconds: Self.fallbackDelay, action: action)
    }

    /// 系统已报告空闲时，用短窗口确认期间没有新刻度。
    func scheduleIdleConfirmation(
        action: @escaping @MainActor () -> Void
    ) {
        schedule(
            afterNanoseconds: Self.idleConfirmationDelay,
            action: action
        )
    }

    /// 取消旧任务后安装唯一的新停止检测任务。
    private func schedule(
        afterNanoseconds: UInt64,
        action: @escaping @MainActor () -> Void
    ) {
        cancel()
        task = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: afterNanoseconds)
            guard !Task.isCancelled else { return }
            self?.task = nil
            action()
        }
    }

    /// 新输入和页面生命周期变化共用的取消入口。
    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}

/// 丢弃掉帧期间积压的旧表冠位移，只消费当前绘制周期内合理的输入量。
///
/// `DigitalCrownEvent.offset` 可能在主线程繁忙后一次跳过很多 detent。如果把
/// 差值全量应用，页面会在动画恢复时突然追赶。限制为两个 0.25 小刻度后，
/// 当前速度仍参与位移倍率，但历史积压不会污染下一帧。
func frameBoundCrownDelta(
    from previousOffset: Double,
    to currentOffset: Double
) -> Double {
    min(0.5, max(-0.5, currentOffset - previousOffset))
}

/// 根据页面的交互目标，把系统报告的表冠速度映射为像素位移倍率。
func calendarPageCrownSpeedScale(
    _ velocity: Double,
    profile: CalendarCrownVelocityProfile
) -> Double {
    let speed = abs(velocity)
    switch profile {
    case .balanced:
        return min(2.2, max(0.95, 0.88 + speed * 0.1))

    case .precisionAccelerated:
        // smoothstep 在两端导数均为 0，不会在跨过某个速度阈值时突然跳变。
        // 慢转最低约 0.62 倍，便于逐像素对齐；速度进入中高区后更早提升
        // 到约 4.2 倍，让快速拨动时能够连续跨日，同时不改变慢转下限。
        let normalizedSpeed = min(1, max(0, (speed - 0.8) / 7.0))
        let smoothSpeed = normalizedSpeed
            * normalizedSpeed
            * (3 - 2 * normalizedSpeed)
        return 0.62 + (4.2 - 0.62) * smoothSpeed
    }
}

/// 日、周、月横向分页相对于基础机械刻度的位移倍率。
private let calendarHorizontalCrownMotionScale: CGFloat = 1.32

/// 把一个表冠小刻度换算成日、周、月分页共用的横向像素行程。
func calendarPageCrownTickDistance(
    pageWidth: CGFloat,
    velocity: Double,
    profile: CalendarCrownVelocityProfile
) -> CGFloat {
    pageWidth
        * 0.0598
        * calendarHorizontalCrownMotionScale
        * calendarPageCrownSpeedScale(velocity, profile: profile)
}

/// 统一把日、周、月视图的表冠事件换算为分页运动。
func calendarCrownPageMotion(
    delta: Double,
    velocity: Double,
    pageWidth: CGFloat,
    distanceScale: CGFloat = 1,
    velocityProfile: CalendarCrownVelocityProfile = .balanced
) -> CalendarCrownPageMotion {
    let tickDistance = calendarPageCrownTickDistance(
        pageWidth: pageWidth,
        velocity: velocity,
        profile: velocityProfile
    ) * distanceScale
    return CalendarCrownPageMotion(
        offsetDelta: -CGFloat(delta / 0.25) * tickDistance,
        velocity: CGFloat(abs(velocity) / 0.25) * tickDistance
    )
}

/// 将完整越过一屏的偏移归一化回中间页附近。
///
/// 一次输入在 `frameBoundCrownDelta` 处已限制为不超过一屏，
/// 因此每次最多提交前或后一页。
func normalizedContinuousPageOffset(
    _ proposedOffset: CGFloat,
    pageWidth: CGFloat
) -> ContinuousPageOffsetUpdate {
    guard pageWidth > 0 else {
        return ContinuousPageOffsetUpdate(
            offset: proposedOffset,
            crossedPage: 0
        )
    }
    if proposedOffset <= -pageWidth {
        return ContinuousPageOffsetUpdate(
            offset: proposedOffset + pageWidth,
            crossedPage: 1
        )
    }
    if proposedOffset >= pageWidth {
        return ContinuousPageOffsetUpdate(
            offset: proposedOffset - pageWidth,
            crossedPage: -1
        )
    }
    return ContinuousPageOffsetUpdate(
        offset: proposedOffset,
        crossedPage: 0
    )
}

/// 日、周、月页面共用的快速吸附曲线。
func calendarPageSnapAnimation(duration: Double) -> Animation {
    // 使用无回摆系统弹簧衔接手指/表冠的当前位置；实际响应时长由剩余
    // 距离和输入速度共同决定，不再让所有吸附都播放同一段固定动画。
    .spring(
        duration: duration,
        bounce: 0,
        blendDuration: min(0.07, duration * 0.36)
    )
}

/// 结合实际位移和系统预测位移，选择最接近的前/当前/后页。
func horizontalDragMotion(
    _ value: DragGesture.Value,
    currentOffset: CGFloat,
    pageWidth: CGFloat
) -> HorizontalPageMotion {
    let projectedRemainder = value.predictedEndTranslation.width
        - value.translation.width
    // `predictedEndTranslation` 通常覆盖约 0.2 秒减速过程。先求带方向的
    // 释放速度，再分别处理“快甩”和“普通拖动”：快甩即使距离很短也按
    // 松手瞬间的运动趋势翻页；普通拖动则综合当前位置与短期预测位置。
    let signedVelocity = projectedRemainder / 0.2
    let velocity = abs(signedVelocity)
    let flickVelocityThreshold = pageWidth * 0.9
    let direction: Int
    if velocity >= flickVelocityThreshold {
        direction = signedVelocity < 0 ? 1 : -1
    } else {
        let projectedOffset = currentOffset + signedVelocity * 0.12
        direction = nearestPageDirection(
            for: projectedOffset,
            width: pageWidth,
            thresholdRatio: 0.28
        )
    }
    return HorizontalPageMotion(direction: direction, velocity: velocity)
}

/// 偏移超过指定页宽比例时选择相邻页，否则回到当前页。
///
/// 手指横滑使用 28%，轻拖即可完成翻页；表冠停止时省略该参数，继续采用
/// 50% 吸附线，避免轻转表冠便误切到相邻日期或周次。
func nearestPageDirection(
    for offset: CGFloat,
    width: CGFloat,
    thresholdRatio: CGFloat = 0.5
) -> Int {
    guard width > 0 else { return 0 }
    let threshold = width * min(0.5, max(0.2, thresholdRatio))
    if offset <= -threshold { return 1 }
    if offset >= threshold { return -1 }
    return 0
}

/// 统一生成日、周、月页面的吸附参数。
///
/// 调用方可以在生成前按业务范围调整方向，例如周视图在学期边界把方向改为
/// `0`。这里仅处理视觉参数，不修改日期、周次或触觉状态。
func horizontalPageSnap(
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
/// 系统 `onIdle` 会立即触发；响应时长随剩余距离增加、随释放速度缩短。
/// 85–220ms 只是防止瞬移和拖尾的安全区间，并非固定播放时间。
func pageSnapDuration(
    from current: CGFloat,
    to target: CGFloat,
    velocity: CGFloat,
    width: CGFloat
) -> Double {
    let remainingRatio = min(1, abs(target - current) / max(1, width))
    let normalizedVelocity = abs(velocity) / max(1, width)
    let distanceResponse = 0.085 + Double(remainingRatio) * 0.135
    let velocityReduction = min(
        0.065,
        log1p(Double(normalizedVelocity)) * 0.022
    )
    return min(0.22, max(0.085, distanceResponse - velocityReduction))
}

/// 独立日期选择页从底部进入和退回时使用的短促弹簧。
let monthScheduleTransitionAnimation = Animation.spring(
    duration: 0.3,
    bounce: 0.06,
    blendDuration: 0.06
)

/// 获取系统本地化的极短星期符号，并转换为周一到周日顺序。
///
/// 日历月页和周页共用这一份本地化结果，避免两处各自维护星期顺序。
func mondayFirstWeekdaySymbols() -> [String] {
    var calendar = Calendar.current
    calendar.locale = WatchWidgetShared.preferredLocale
    let symbols = calendar.veryShortStandaloneWeekdaySymbols
    guard symbols.count == 7 else {
        return ["M", "T", "W", "T", "F", "S", "S"]
    }
    return Array(symbols[1...6]) + [symbols[0]]
}

/// 日/周视图左上角共用的日期导航条。
struct DateNavigationHeader: View {
    let title: String
    let previous: () -> Void
    let next: () -> Void
    var titleAction: (() -> Void)? = nil

    /// 可见标题仍为 22pt；透明命中层向下延伸约一行，避免小表盘上难以点中。
    private let visibleHeight: CGFloat = 22
    private let interactionHeight: CGFloat = 42
    private let sideInteractionWidth: CGFloat = 30

    var body: some View {
        HStack(spacing: 1) {
            Image(systemName: "chevron.left")
                .frame(width: 18, height: 20)
                .accessibilityHidden(true)

            // 可见标题始终只是文本；是否可点击由下面的透明命中层决定。
            // 若把没有动作的周次标题做成 disabled Button，watchOS 会自动
            // 降低其亮度，导致“第几周”看起来发灰。
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .monospacedDigit()
                .frame(maxWidth: .infinity)

            Image(systemName: "chevron.right")
                .frame(width: 18, height: 20)
                .accessibilityHidden(true)
        }
        .frame(height: visibleHeight)
        // 单个透明命中层覆盖标题自身并继续向下延伸，不参与可见 HStack 的
        // 布局。日、周、月三个页面因此共享完全相同的扩大触控区域。
        .overlay(alignment: .top) {
            interactionOverlay
        }
    }

    /// 把左箭头、标题和右箭头划分为互不重叠的三块命中区域。
    private var interactionOverlay: some View {
        HStack(spacing: 0) {
            navigationHitTarget(
                action: previous,
                accessibilityLabel: "上一项"
            )
            .frame(width: sideInteractionWidth)

            if let titleAction {
                navigationHitTarget(
                    action: titleAction,
                    accessibilityLabel: "选择日期"
                )
                .frame(maxWidth: .infinity)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
            }

            navigationHitTarget(
                action: next,
                accessibilityLabel: "下一项"
            )
            .frame(width: sideInteractionWidth)
        }
        .frame(height: interactionHeight)
    }

    /// 创建不绘制任何内容、只负责扩大命中范围的按钮。
    private func navigationHitTarget(
        action: @escaping () -> Void,
        accessibilityLabel: LocalizedStringKey
    ) -> some View {
        Button(action: action) {
            // watchOS 真机的 Toolbar 会把完全透明的按钮标签从
            // 命中树中剔除，结果是箭头可见但按不动。使用几乎
            // 不可见的实体填充保留真实按钮命中，不改变任何
            // 主观布局或可见颜色。
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
