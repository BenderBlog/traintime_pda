// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 概览页面：正在进行的课程优先，否则显示未来最近一节。
struct OverviewScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    let onCrownInteraction: () -> Void
    let onCrownInput: () -> Void
    let onTouchInput: () -> Void
    var alwaysAllowsTeachingBounce = false
    /// 只在“概览·上下滑动”教学步骤中让触摸实际带动短内容。
    var drivesTeachingTouchScroll = false
    var inputContext = 0

    var body: some View {
        InteractionAwareScrollView(
            onScroll: onCrownInteraction,
            onCrownInput: onCrownInput,
            onTouchInput: onTouchInput,
            centersShortContent: true,
            alwaysAllowsBounce: alwaysAllowsTeachingBounce,
            usesShortContentTouchFallback: alwaysAllowsTeachingBounce,
            inputContext: inputContext,
            teachingTouchScrollEffect: drivesTeachingTouchScroll
                ? .elastic
                : .disabled,
            protectsInitialTopEdge: true
        ) {
            TimelineView(.explicit(store.presentationTimelineDates)) { context in
                let presentation = store.presentation(at: context.date)
                VStack(alignment: .leading, spacing: 8) {
                    if let course = presentation.focus {
                        timeline(for: presentation)
                            .padding(.trailing, 34)
                        CourseRow(
                            course: course,
                            showsDate: true,
                            isProminent: true
                        )
                    } else {
                        ContentUnavailableView(
                            presentation.title,
                            systemImage: presentation.emptySymbol
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2)
                .padding(.top, 2)
            }
        }
    }

    /// 显示当前状态或距下一节课的相对时间。
    private func timeline(for presentation: WatchSchedulePresentation) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(presentation.title)
                .foregroundStyle(presentation.focus?.color ?? .secondary)
            if let target = presentation.timeTarget,
                presentation.state != .finishing && !presentation.isAboutToStart
            {
                Text(presentation.timeLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if presentation.usesCountdown {
                    Text(
                        timerInterval: presentation.date...max(presentation.date, target),
                        countsDown: true
                    )
                    .monospacedDigit()
                } else {
                    Text(presentation.dayLabel(for: target) + " " + presentation.clockText(target))
                }
            }
        }
        .font(.headline)
    }
}
