// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 概览以今日摘要为入口，最多展示当前与下一项，其余安排只做统计。
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
            centersShortContent: false,
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
                let summary = WatchOverviewSummary(presentation)
                VStack(alignment: .leading, spacing: 12) {
                    todaySummary(summary.today, presentation: presentation)
                        .padding(.trailing, 34)

                    if let current = summary.current {
                        featuredCourse(current, isCurrent: true, presentation: presentation)
                    }
                    if let next = summary.next {
                        featuredCourse(next, isCurrent: false, presentation: presentation)
                    }

                    if presentation.state == .noMoreCourses {
                        Text(presentation.title)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else if let week = summary.week {
                        weekSummary(week)
                    } else if summary.today != nil && summary.next == nil {
                        Text(watchLocalizedString("后续课表待同步"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2)
                .padding(.top, 2)
                .padding(.bottom, 12)
                .environment(\.calendar, presentation.calendar)
                .environment(\.timeZone, presentation.calendar.timeZone)
            }
        }
    }

    private func todaySummary(
        _ day: WatchOverviewSummary.Day?, presentation: WatchSchedulePresentation
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(presentation.date, format: .dateTime.month().day().weekday())
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let day {
                Text(todayTitle(day))
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                if day.all.total > 0 {
                    // 已全部结束时显示今天完成的构成，不摆三个“剩余 0”。
                    Text(countsText(day.remaining.total > 0 ? day.remaining : day.all))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if day.completedCount > 0 && day.remaining.total > 0 {
                    Text(watchLocalizedFormat("已完成 %d 项", day.completedCount))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let end = day.additionalEndTime {
                    Label(
                        watchLocalizedFormat("%@ 全部结束",
                            presentation.compactDateTimeText(for: end)),
                        systemImage: "flag.checkered")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text([.noData, .signedOut, .expired, .semesterUpcoming, .semesterEnded]
                    .contains(presentation.state)
                    ? presentation.title : watchLocalizedString("今日概览待同步"))
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                if [.noData, .signedOut, .expired, .unconfirmed].contains(presentation.state) {
                    Text(watchLocalizedString("打开手机更新课表"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func todayTitle(_ day: WatchOverviewSummary.Day) -> String {
        if day.all.total == 0 { return watchLocalizedString("今日没有安排") }
        if day.remaining.total == 0 { return watchLocalizedString("今日安排已完成") }
        return watchLocalizedFormat("今日还剩 %d 项", day.remaining.total)
    }

    private func countsText(_ counts: WatchOverviewSummary.Counts) -> String {
        watchLocalizedFormat("课程 %d · 考试 %d · 实验 %d",
            counts.courses, counts.exams, counts.experiments)
    }

    /// 时间和元数据只在卡片中出现，同一天的日期也不重复显示。
    private func featuredCourse(
        _ course: WatchCourse, isCurrent: Bool, presentation: WatchSchedulePresentation
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(courseContext(course, isCurrent: isCurrent))
                .font(.caption.weight(.semibold))
                .foregroundStyle(course.color)
            CourseRow(
                course: course,
                showsDate: !presentation.calendar.isDate(course.startAt, inSameDayAs: presentation.date),
                showsInlineMetadata: true)
        }
    }

    private func courseContext(_ course: WatchCourse, isCurrent: Bool) -> String {
        switch course.kind {
        case "exam":
            return watchLocalizedString(isCurrent ? "正在考试" : "下一场考试")
        case "physicsExperiment", "otherExperiment":
            return watchLocalizedString(isCurrent ? "正在实验" : "下一项实验")
        default:
            return watchLocalizedString(isCurrent ? "正在上课" : "下一节")
        }
    }

    private func weekSummary(_ week: WatchOverviewSummary.Week) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
            Text(week.remainingDays > 0
                ? watchLocalizedFormat("本周还有 %d 天安排", week.remainingDays)
                : watchLocalizedString("本周没有后续安排"))
                .font(.caption.weight(.semibold))

            if week.remainingDays > 0 {
                Label(week.upcoming.exams > 0
                    ? watchLocalizedFormat("待考 %d 场", week.upcoming.exams)
                    : watchLocalizedString("本周暂无待考"),
                    systemImage: "pencil.and.list.clipboard")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if week.upcoming.experiments > 0 {
                    Label(
                        watchLocalizedFormat("待做实验 %d 项", week.upcoming.experiments),
                        systemImage: "flask")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
