// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 概览页面：正在进行的课程优先，否则显示未来最近一节。
struct OverviewScheduleView: View {
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
