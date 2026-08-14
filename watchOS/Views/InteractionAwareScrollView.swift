// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 新手教学中由手指直接驱动内容的视觉方式。
///
/// 它只补足“教学已经识别拖动、原生 ScrollView 却没有建立滚动会话”的
/// 情况，不参与教学结果判断，也不会把触摸伪装成表冠输入。
enum TeachingTouchScrollEffect {
    case disabled
    /// 短内容没有真实滚动范围时，显示有限的橡皮筋位移并在抬手后归位。
    case elastic
    /// 长列表把触摸位移映射为原生 ScrollView 的绝对滚动位置。
    case nativePosition

    var isEnabled: Bool {
        self != .disabled
    }
}

/// 能检测触摸/表冠导致的滚动，并通知根页面隐藏悬浮按钮。
struct InteractionAwareScrollView<Content: View>: View {
    let onScroll: () -> Void
    /// 原生滚动阶段确认输入来自 Digital Crown 时单独通知。
    var onCrownInput: () -> Void = {}
    /// 原生滚动阶段确认手指已经带动内容时单独通知。
    var onTouchInput: () -> Void = {}
    var centersShortContent = false
    /// `LazyVStack` 必须保留 ScrollView 提供的原生尺寸提案。若对懒加载
    /// 内容使用短内容所需的 `.fixedSize` 测量时，系统可能只建立一屏滚动
    /// 范围；懒加载路径保留原生尺寸提案以建立完整滚动范围。
    var usesLazyContentLayout = false
    /// 教学短内容也允许使用系统橡皮筋随手指移动；正常页面仍按内容尺寸
    /// 决定是否滚动，不改变既有布局和滚动范围。
    var alwaysAllowsBounce = false
    /// 需要可靠区分触摸与表冠、且实体表可能不发送 `.tracking` 时挂载兜底。
    ///
    /// 默认只记录输入来源；仅当调用方明确打开教学视觉代理时，同一份手势
    /// 数据才会额外推动内容。教学判定入口与原生表冠来源判断保持不变。
    var usesShortContentTouchFallback = false
    /// 教学专用视觉滚动。正常使用与其他教学步骤始终保持 `.disabled`。
    var teachingTouchScrollEffect: TeachingTouchScrollEffect = .disabled
    /// 顶层详情覆盖周视图时，由内部原生 ScrollView 主动接管表冠焦点。
    var requestsCrownFocus = false
    var protectsInitialTopEdge = false
    var alwaysProtectsInitialTopEdge = false
    var protectedTopInsetRatio: CGFloat = 0.13
    var topScrollTarget: AnyHashable = AnyHashable(
        "interaction-aware-scroll-top"
    )
    @ViewBuilder let content: () -> Content
    @State private var offsetTracker = ScrollOffsetTracker()
    @State private var intrinsicContentHeight: CGFloat = 0
    @State private var nativeScrollSawTouchTracking = false
    @State private var nativeScrollReportedInput = false
    /// 部分实体表在短内容橡皮筋滚动时会跳过 `.tracking`，直接进入
    /// `.interacting`。这两个状态只补记“手指正在接触”，不接管滚动。
    @State private var nativeTouchGestureIsActive = false
    @State private var nativeTouchMarkerGeneration = 0
    /// 记录当前手指是否已经形成明确的纵向拖动。短内容只发生橡皮筋
    /// 位移时，watchOS 偶尔不会建立完整 ScrollPhase，会由它在抬手后
    /// 兜底提交一次真实触摸滚动。
    @State private var nativeTouchGestureMovedVertically = false
    /// 同一次拖动可能同时经过 DragGesture 兜底和系统 `.idle`。使用代次
    /// 去重，确保教学只收到一次完成事件，不会自动跨过相邻步骤。
    @State private var nativeTouchCompletionGeneration = -1
    /// 教学触摸的起点与显示状态。检测结果仍由上面的原有状态负责；这些值
    /// 只改变内容的可见位置，避免视觉驱动反过来影响操作类型判断。
    @State private var teachingDragStartScrollOffset: CGFloat = 0
    @State private var teachingRequestedScrollOffset: CGFloat = 0
    @State private var teachingElasticOffset: CGFloat = 0
    @FocusState private var nativeScrollFocused: Bool

    var body: some View {
        GeometryReader { viewport in
            let protectedTopInset = max(
                26,
                viewport.size.height * protectedTopInsetRatio
            )
            let contentOverflows = usesLazyContentLayout
                || intrinsicContentHeight
                    + (protectsInitialTopEdge ? protectedTopInset : 0)
                    > viewport.size.height
            let shouldProtectTopEdge = protectsInitialTopEdge
                && (alwaysProtectsInitialTopEdge || contentOverflows)
            let initialTopInset = shouldProtectTopEdge
                ? protectedTopInset
                : 0

            let nativeScrollView = ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(
                            in: .named("watchScheduleScroll")
                        ).minY
                    )
                }
                .frame(height: 0)
                .id(topScrollTarget)

                scrollContent(
                    viewportHeight: viewport.size.height,
                    initialTopInset: initialTopInset,
                    contentOverflows: contentOverflows
                )
            }
            .coordinateSpace(name: "watchScheduleScroll")
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(
                alwaysAllowsBounce ? .always : .basedOnSize,
                axes: .vertical
            )
            // 教学视觉代理启用时由同一份 DragGesture 数据唯一驱动位置，
            // 避免系统滚动与代理同时响应而产生双倍位移。程序化定位仍可用。
            .scrollDisabled(disablesNativeScrollForTeaching)

            crownFocusedScrollView(
                touchObservedScrollView(
                    teachingPositionedScrollView(nativeScrollView)
                )
            )
            .watchNativeCrownInputDetection(
                sawTouchTracking: $nativeScrollSawTouchTracking,
                reportedInput: $nativeScrollReportedInput,
                onInteractionBegan: onScroll,
                onCrownInput: onCrownInput,
                onTouchInput: reportNativeTouchCompletion
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                guard let previousOffset = offsetTracker.previousOffset else {
                    offsetTracker.previousOffset = offset
                    return
                }
                offsetTracker.previousOffset = offset
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
            .task(id: requestsCrownFocus) {
                guard requestsCrownFocus else {
                    nativeScrollFocused = false
                    return
                }
                // 详情覆盖层与底层周视图会在同一事务内切换焦点。至少让出
                // 一次主线程更新，确保新的原生 ScrollView 已加入焦点树。
                nativeScrollFocused = false
                await Task.yield()
                guard !Task.isCancelled else { return }
                nativeScrollFocused = true
            }
            .onDisappear {
                nativeScrollFocused = false
            }
        }
    }

    /// 仅在当前系统确实具备对应视觉代理时禁用系统手势滚动。
    ///
    /// `.elastic` 完全由本视图的偏移实现；`.nativePosition` 则依赖
    /// watchOS 11 的 `ScrollPosition`。watchOS 10 没有该 API，必须保留
    /// 原生滚动，否则会出现教学能识别手势但课程列表完全不移动的问题。
    private var disablesNativeScrollForTeaching: Bool {
        switch teachingTouchScrollEffect {
        case .disabled:
            return false
        case .elastic:
            return true
        case .nativePosition:
            if #available(watchOS 11.0, *) {
                return true
            }
            return false
        }
    }

    /// watchOS 11 起使用 `ScrollPosition` 连续推动原生滚动容器。
    ///
    /// 可用性分支保证工程仍可部署到 watchOS 10；旧系统继续使用原生
    /// ScrollView，不会影响正常页面和已有表冠操作。
    @ViewBuilder
    private func teachingPositionedScrollView<ScrollContent: View>(
        _ scrollView: ScrollContent
    ) -> some View {
        if #available(watchOS 11.0, *),
           teachingTouchScrollEffect == .nativePosition
        {
            TeachingNativeScrollPositionBridge(
                requestedOffset: $teachingRequestedScrollOffset,
                content: scrollView
            )
        } else {
            scrollView
        }
    }

    /// 仅给明确需要可靠来源判定的教学页面添加触摸来源兜底。
    ///
    /// 条件分支发生在整个 ScrollView 外侧。手势使用 simultaneous 旁路；
    /// 正常页面只写入来源标记，指定教学步骤会把同一份位移交给视觉代理。
    @ViewBuilder
    private func touchObservedScrollView<ScrollContent: View>(
        _ scrollView: ScrollContent
    ) -> some View {
        if usesShortContentTouchFallback {
            scrollView.simultaneousGesture(nativeTouchSourceMarker)
        } else {
            scrollView
        }
    }

    /// 把焦点修饰器直接安装到原生 ScrollView，而不是详情页的外层容器。
    @ViewBuilder
    private func crownFocusedScrollView<ScrollContent: View>(
        _ scrollView: ScrollContent
    ) -> some View {
        if requestsCrownFocus {
            scrollView
                .focusable()
                .focused($nativeScrollFocused)
        } else {
            scrollView
        }
    }

    /// 根据内容实现选择滚动布局。
    ///
    /// 普通内容先测量自然高度，以便短内容垂直居中；懒加载内容完全交给
    /// ScrollView 建立滚动范围，只补最小视口高度和顶部安全距离。两条路径
    /// 使用相同的可见布局参数，不改变课程卡片本身的位置与样式。
    @ViewBuilder
    private func scrollContent(
        viewportHeight: CGFloat,
        initialTopInset: CGFloat,
        contentOverflows: Bool
    ) -> some View {
        if usesLazyContentLayout {
            content()
                .frame(
                    minHeight: max(0, viewportHeight - initialTopInset),
                    alignment: .top
                )
                .padding(.top, initialTopInset)
        } else {
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
                    minHeight: max(0, viewportHeight - initialTopInset),
                    alignment: centersShortContent && !contentOverflows
                        ? .center
                        : .top
                )
                // 长内容首次打开时从状态栏下方开始；这段 padding 位于
                // ScrollView 内，用户转动表冠或上滑后仍可进入顶部虚化区。
                .padding(.top, initialTopInset)
                .offset(
                    y: teachingTouchScrollEffect == .elastic
                        ? teachingElasticOffset
                        : 0
                )
        }
    }

    /// 给系统 ScrollView 补充触摸来源标记。
    ///
    /// watchOS 在内容不足一屏、仅发生橡皮筋位移时，实体设备偶尔不会发出
    /// `.tracking`，但仍会发出与表冠相同的 `.interacting`。这里使用同时
    /// `DragGesture` 识别真实手指接触。正常滚动由系统 `.idle` 提交；若
    /// 触摸没有形成滚动会话，则在抬手后兜底提交并自动清除来源标记。
    private var nativeTouchSourceMarker: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                if !nativeTouchGestureIsActive {
                    nativeTouchGestureIsActive = true
                    nativeTouchMarkerGeneration &+= 1
                    nativeTouchGestureMovedVertically = false
                    nativeScrollSawTouchTracking = true
                    onScroll()
                    beginTeachingTouchScroll()
                }

                updateTeachingTouchScroll(using: value)

                // 原有判定仍只确认用户确实做了纵向拖动。较小阈值适配表盘
                // 行程，同时用轴向占优过滤轻点抖动和明显的横向动作；上方
                // 的视觉代理更新不会改变这里的判断结果。
                let verticalDistance = abs(value.translation.height)
                let horizontalDistance = abs(value.translation.width)
                if verticalDistance >= 8,
                   verticalDistance >= horizontalDistance
                {
                    nativeTouchGestureMovedVertically = true
                }
            }
            .onEnded { value in
                nativeTouchGestureIsActive = false
                finishTeachingTouchScroll()
                let generation = nativeTouchMarkerGeneration
                let endedVertically = abs(value.translation.height) >= 8
                    && abs(value.translation.height)
                        >= abs(value.translation.width)
                let completedVerticalDrag =
                    nativeTouchGestureMovedVertically || endedVertically

                // 正常长内容由 ScrollPhase 在 `.idle` 统一提交；短内容若根本
                // 没有形成系统滚动会话，则在抬手后补交。等待一帧附近的短
                // 延迟，优先让系统阶段取得所有权，避免触摸/表冠来源竞争。
                if completedVerticalDrag {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        guard generation == nativeTouchMarkerGeneration,
                              nativeTouchCompletionGeneration != generation,
                              !nativeScrollReportedInput
                        else { return }
                        reportNativeTouchCompletion()
                        nativeScrollSawTouchTracking = false
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    guard generation == nativeTouchMarkerGeneration,
                          !nativeScrollReportedInput
                    else { return }
                    nativeScrollSawTouchTracking = false
                }
            }
    }

    /// 记录本轮拖动开始时的真实滚动位置。
    private func beginTeachingTouchScroll() {
        guard teachingTouchScrollEffect.isEnabled else { return }
        let currentOffset = max(0, -(offsetTracker.previousOffset ?? 0))
        teachingDragStartScrollOffset = currentOffset
        teachingRequestedScrollOffset = currentOffset
    }

    /// 使用手指总位移更新教学视觉位置，不改变已有的方向/阈值判定。
    private func updateTeachingTouchScroll(
        using value: DragGesture.Value
    ) {
        switch teachingTouchScrollEffect {
        case .disabled:
            return
        case .elastic:
            // 短内容没有可滚动区间，使用递减增益形成系统风格皮筋效果。
            // 最大位移受限，避免教学层下方的布局被拖出表盘。
            let translation = value.translation.height
            let magnitude = min(abs(translation), 80)
            let resistedMagnitude = min(26, magnitude * 0.34)
            teachingElasticOffset = translation < 0
                ? -resistedMagnitude
                : resistedMagnitude
        case .nativePosition:
            guard #available(watchOS 11.0, *) else { return }
            // 上滑（负 translation）对应增大内容偏移，下滑则减小。
            teachingRequestedScrollOffset = max(
                0,
                teachingDragStartScrollOffset - value.translation.height
            )
        }
    }

    /// 短内容抬手后柔和归位；长列表停在手指实际拖到的位置。
    private func finishTeachingTouchScroll() {
        guard teachingTouchScrollEffect == .elastic else { return }
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
            teachingElasticOffset = 0
        }
    }

    /// 合并系统 ScrollPhase 与短内容拖动兜底的唯一完成入口。
    private func reportNativeTouchCompletion() {
        let generation = nativeTouchMarkerGeneration
        // 安装了触摸标记的页面可能同时从 DragGesture 兜底与 ScrollPhase
        // 收到完成事件，需要按代次去重。未安装标记的普通长列表没有手势
        // 代次（永远为 0），其每一轮原生 `.idle` 本身已经唯一，不能用同一
        // 个 0 去重，否则首轮异常事件会吃掉后续所有真实触摸。
        if usesShortContentTouchFallback {
            guard nativeTouchCompletionGeneration != generation else {
                return
            }
            nativeTouchCompletionGeneration = generation
        }
        onTouchInput()
    }
}

/// 把教学层给出的绝对偏移写入 SwiftUI 原生 ScrollView。
///
/// 单独放进 watchOS 11 可用性类型中，避免 `ScrollPosition` 抬高整个 App
/// 的最低系统版本。每个拖动采样关闭隐式动画，使列表逐帧贴合手指，而不是
/// 累积一串尚未完成的吸附动画。
@available(watchOS 11.0, *)
private struct TeachingNativeScrollPositionBridge<Content: View>: View {
    @Binding var requestedOffset: CGFloat
    @State private var position = ScrollPosition(y: 0)
    let content: Content

    var body: some View {
        content
            .scrollPosition($position)
            .onChange(of: requestedOffset) { _, offset in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    position.scrollTo(y: max(0, offset))
                }
            }
    }
}

extension View {
    /// watchOS 11 起用原生滚动阶段识别表冠；旧系统保持原页面。
    ///
    /// 可用性分支收口在这个修饰器内，避免把整个滚动组件的
    /// 最低系统从 watchOS 10 提高到 watchOS 11。
    @ViewBuilder
    func watchNativeCrownInputDetection(
        sawTouchTracking: Binding<Bool>,
        reportedInput: Binding<Bool>,
        onInteractionBegan: @escaping () -> Void,
        onCrownInput: @escaping () -> Void,
        onTouchInput: @escaping () -> Void
    ) -> some View {
        if #available(watchOS 11.0, *) {
            onScrollPhaseChange { oldPhase, newPhase in
                if newPhase == .tracking {
                    sawTouchTracking.wrappedValue = true
                    if !reportedInput.wrappedValue {
                        reportedInput.wrappedValue = true
                        onInteractionBegan()
                    }
                    return
                }
                if newPhase == .interacting,
                   !reportedInput.wrappedValue
                {
                    reportedInput.wrappedValue = true
                    // 表冠刚进入系统滚动阶段就通知根页面隐去教学说明；
                    // 完成判定仍留到 `.idle`，不会在持续旋转时提前播放结果。
                    onInteractionBegan()
                }
                if newPhase == .idle {
                    // `.interacting` 只标记来源；等系统确认完全停止后才上报，
                    // 教学结果不会在手指仍按住或表冠仍旋转时遮住真实页面。
                    if reportedInput.wrappedValue {
                        if sawTouchTracking.wrappedValue
                            || oldPhase == .tracking
                        {
                            onTouchInput()
                        } else {
                            onCrownInput()
                        }
                    }
                    sawTouchTracking.wrappedValue = false
                    reportedInput.wrappedValue = false
                }
            }
        } else {
            self
        }
    }
}

/// 只记录滚动采样值，不参与 SwiftUI 依赖追踪。
///
/// 引用型记录器可比较相邻采样并触发控件隐藏，但不会把
/// 每个像素的不可见偏移发布为 SwiftUI 状态，避免整个列表重新布局。
private final class ScrollOffsetTracker {
    var previousOffset: CGFloat?
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
