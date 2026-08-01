// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 能检测触摸/表冠导致的滚动，并通知根页面隐藏悬浮按钮。
struct InteractionAwareScrollView<Content: View>: View {
    let onScroll: () -> Void
    var centersShortContent = false
    var protectsInitialTopEdge = false
    var alwaysProtectsInitialTopEdge = false
    var protectedTopInsetRatio: CGFloat = 0.13
    var topScrollTarget: AnyHashable = AnyHashable(
        "interaction-aware-scroll-top"
    )
    @ViewBuilder let content: () -> Content
    @State private var offsetTracker = ScrollOffsetTracker()
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
                .id(topScrollTarget)

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
