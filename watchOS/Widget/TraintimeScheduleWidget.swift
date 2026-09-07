// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import AppIntents
import SwiftUI
import WidgetKit

private enum CircularScheduleTypography {
    static let primary = Font.system(size: 12, weight: .semibold)
    static let secondary = Font.system(size: 8, weight: .medium)
    static let minimumScale: CGFloat = 0.85
}

struct TraintimeScheduleWidgetEntry: TimelineEntry {
    let date: Date
    let schedule: WatchSchedulePresentation
    let integrated: WatchSchedulePresentation
}

struct TraintimeScheduleWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TraintimeScheduleWidgetEntry {
        makeEntry(at: Date(), resolved: sampleSchedule())
    }

    func getSnapshot(
        in context: Context, completion: @escaping (TraintimeScheduleWidgetEntry) -> Void
    ) {
        completion(
            makeEntry(
                at: Date(),
                resolved: WatchWidgetShared.loadResolvedSchedule()
                    ?? (context.isPreview ? sampleSchedule() : nil)))
    }

    func getTimeline(
        in context: Context, completion: @escaping (Timeline<TraintimeScheduleWidgetEntry>) -> Void
    ) {
        let now = Date()
        let resolved = WatchWidgetShared.loadResolvedSchedule()
        let expiry =
            WatchWidgetShared.defaults?.object(forKey: WatchWidgetShared.previewExpiresKey) as? Date
        let dates = WatchSchedulePresentation.timelineDates(
            resolved: resolved, now: now, previewExpiry: expiry)
        let entries = dates.map { makeEntry(at: $0, resolved: resolved) }
        completion(
            Timeline(entries: entries, policy: .after(dates.last ?? now.addingTimeInterval(3600))))
    }

    private func makeEntry(at date: Date, resolved: WatchResolvedSchedule?)
        -> TraintimeScheduleWidgetEntry
    {
        let defaults = WatchWidgetShared.defaults
        let signedOut = defaults?.bool(forKey: WatchWidgetShared.signedOutKey) ?? false
        let normal = WatchSchedulePresentation(resolved: resolved, at: date, signedOut: signedOut)
        let expiry =
            defaults?.object(forKey: WatchWidgetShared.previewExpiresKey) as? Date ?? .distantPast
        let preview =
            normal.current != nil
            && defaults?.string(forKey: WatchWidgetShared.selectedCurrentCourseKey)
                == normal.current?.id
            && date < expiry
        return .init(
            date: date, schedule: normal,
            integrated: WatchSchedulePresentation(
                resolved: resolved, at: date, signedOut: signedOut, preview: preview))
    }

    private func sampleSchedule() -> WatchResolvedSchedule? {
        let now = Date()
        let calendar = WatchSchedulePresentation.calendar(offsetMinutes: 480)
        let start = now.addingTimeInterval(-600)
        let end = now.addingTimeInterval(2400)
        let course = WatchCourse(
            id: "preview", name: watchLocalizedString("高等数学"), teacher: nil, classroom: "B-302",
            startAtEpochMs: Int64(start.timeIntervalSince1970 * 1000),
            endAtEpochMs: Int64(end.timeIntervalSince1970 * 1000),
            startSection: 1, endSection: 2, colorARGB: 0xFF21_96F3, kind: "course", note: nil)
        let snapshot = WatchScheduleSnapshot(
            schemaVersion: 4, generatedAtEpochMs: Int64(now.timeIntervalSince1970 * 1000),
            semesterStartEpochMs: nil, currentWeekIndex: 1,
            validThroughEpochMs: Int64(now.addingTimeInterval(604800).timeIntervalSince1970 * 1000),
            rangeStartEpochMs: Int64(calendar.startOfDay(for: now).timeIntervalSince1970 * 1000),
            rangeEndEpochMs: Int64(now.addingTimeInterval(604800).timeIntervalSince1970 * 1000),
            timeZoneOffsetMinutes: 480, reminderMinutes: 15, courses: [course])
        return WatchScheduleResolver.resolve([.fourteenDays: snapshot])
    }
}

struct ToggleScheduleWidgetCourseIntent: AppIntent {
    static let title: LocalizedStringResource = "切换当前与下一节课"
    static let openAppWhenRun = false
    @Parameter(title: "当前课程 ID") var currentCourseID: String
    init() { currentCourseID = "" }
    init(currentCourseID: String) { self.currentCourseID = currentCourseID }

    func perform() async throws -> some IntentResult {
        guard let defaults = WatchWidgetShared.defaults else { return .result() }
        let now = Date()
        let schedule = WatchSchedulePresentation(
            resolved: WatchWidgetShared.loadResolvedSchedule(), at: now)
        guard let current = schedule.current, current.id == currentCourseID, schedule.next != nil
        else { return .result() }
        let expiry =
            defaults.object(forKey: WatchWidgetShared.previewExpiresKey) as? Date ?? .distantPast
        if defaults.string(forKey: WatchWidgetShared.selectedCurrentCourseKey) == current.id
            && now < expiry
        {
            defaults.removeObject(forKey: WatchWidgetShared.selectedCurrentCourseKey)
            defaults.removeObject(forKey: WatchWidgetShared.previewExpiresKey)
        } else {
            defaults.set(current.id, forKey: WatchWidgetShared.selectedCurrentCourseKey)
            // 五分钟或当前课程下课时自动回到正常状态，取先到者。
            defaults.set(
                min(current.endAt, schedule.next!.startAt, now.addingTimeInterval(300)),
                forKey: WatchWidgetShared.previewExpiresKey)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: WatchWidgetShared.widgetKind)
        return .result()
    }
}

private enum ScheduleWidgetRole {
    case integrated, name, timeLocation, overview
}

/// 长方形组件用一行时间范围呈现起止时刻，省去重复的上下课标签。
private struct ScheduleTime: View {
    let schedule: WatchSchedulePresentation

    var body: some View {
        if let start = schedule.startTimeText, let end = schedule.endTimeText {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(start)
                Spacer(minLength: 0)
                Text("–")
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Text(end)
            }
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                watchLocalizedString("上课") + " " + start + "，"
                    + watchLocalizedString("下课") + " " + end)
        }
    }
}

private struct ScheduleProgress: View {
    let progress: Double
    let color: Color

    var body: some View {
        // 普通形状只接收模型校验后的有限进度值，不使用系统计时进度视图。
        Capsule()
            .fill(.secondary.opacity(0.25))
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(color)
                    .scaleEffect(x: progress, y: 1, anchor: .leading)
                    .widgetAccentable()
            }
            .frame(height: 3)
            .accessibilityLabel(watchLocalizedString("课程进度"))
            .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
    }
}

private struct ScheduleWidgetView: View {
    let entry: TraintimeScheduleWidgetEntry
    let role: ScheduleWidgetRole
    @Environment(\.widgetFamily) private var family
    private var schedule: WatchSchedulePresentation {
        role == .integrated ? entry.integrated : entry.schedule
    }
    private var color: Color { schedule.focus?.color ?? .secondary }
    private var switchableCurrentCourse: WatchCourse? {
        guard role == .integrated, entry.schedule.next != nil else { return nil }
        return entry.schedule.current
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryInline: inline
            case .accessoryCorner: corner
            case .accessoryCircular: circular
            default: rectangular
            }
        }
        .containerBackground(for: .widget) { Color.clear }
        .environment(\.locale, WatchWidgetShared.preferredLocale)
        .widgetURL(WatchWidgetDestination.overview.url)
    }

    private var inline: some View {
        Group {
            if role == .overview {
                Label(summaryText, systemImage: "calendar")
            } else if let course = schedule.focus {
                if role == .name {
                    Text(nameContext + " · " + course.name)
                } else {
                    inlineTime + Text(" · " + schedule.compactLocation)
                }
            } else {
                Label(schedule.compactTitle, systemImage: schedule.emptySymbol)
            }
        }
    }

    private var inlineTime: Text {
        guard let time = schedule.compactTime, let course = schedule.focus else { return Text("") }
        let target = schedule.isCurrent ? course.endAt : course.startAt
        let dayLabel = schedule.compactDayLabel(for: target)
        let day = dayLabel.isEmpty ? "" : dayLabel + " "
        return Text(day + time.label + " " + time.value)
    }

    private var circular: some View {
        circularContent
            // 所有类型和空状态都进入同一个表盘着色组。全彩模式统一使用
            // 系统前景色，避免圆环单独使用课程色、文字却使用另一种颜色。
            .foregroundStyle(.primary)
            .tint(Color.primary)
            .symbolRenderingMode(.monochrome)
            .widgetAccentable()
    }

    @ViewBuilder private var circularContent: some View {
        if role == .overview {
            summaryCircle
        } else if let course = schedule.focus {
            if role == .name {
                VStack(spacing: 2) {
                    Text(nameContext).font(CircularScheduleTypography.secondary)
                        .foregroundStyle(.secondary).lineLimit(1)
                        .minimumScaleFactor(CircularScheduleTypography.minimumScale)
                    circularTitle(course.name)
                }
                .multilineTextAlignment(.center)
            } else {
                if let progress = schedule.courseProgress {
                    // 系统开口圆环负责轨道和进度圆点；底部开口放地点。
                    Gauge(value: progress, in: 0...1) {
                        compactLocation
                    } currentValueLabel: {
                        compactTimeValue
                    }
                    .gaugeStyle(.accessoryCircular)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(compactAccessibilityLabel)
                    .accessibilityValue(
                        Text(progress, format: .percent.precision(.fractionLength(0))))
                } else {
                    compactTimeLocation
                }
            }
        } else {
            emptyCompact
        }
    }

    private var compactTimeLocation: some View {
        VStack(spacing: 2) {
            Text(compactTimeHeading)
                .font(CircularScheduleTypography.secondary)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(CircularScheduleTypography.minimumScale)
            circularTitle(schedule.compactTime?.value ?? "", lineLimit: 1)
                .monospacedDigit()
            compactLocation
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(compactAccessibilityLabel)
    }

    private var compactTimeValue: some View {
        VStack(spacing: 0) {
            Text(compactTimeHeading)
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(.secondary)
            Text(schedule.compactTime?.value ?? "")
                .font(CircularScheduleTypography.primary)
                .monospacedDigit()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .multilineTextAlignment(.center)
    }

    private var compactLocation: some View {
        // 有无圆环都把位置作为主要信息，与时刻共用字号、字重和前景色。
        circularTitle(schedule.compactLocation, lineLimit: 1)
            .foregroundStyle(.primary)
    }

    private var compactAccessibilityLabel: String {
        [schedule.focus?.name, compactTimeHeading, schedule.compactTime?.value, schedule.location]
            .compactMap { $0 }.joined(separator: "，")
    }

    private func cornerText(
        _ value: String,
        font: Font = .system(size: 12, weight: .bold, design: .rounded)
    ) -> some View {
        Text(value)
            .font(font)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(color)
            .widgetAccentable()
    }

    /// 跨日提示合并进第一行，内容始终保持“上/下课、时刻、地点”三行。
    private var compactTimeHeading: String {
        guard let time = schedule.compactTime, let course = schedule.focus else { return "" }
        let target = schedule.isCurrent ? course.endAt : course.startAt
        let day = schedule.compactDayLabel(for: target)
        return day.isEmpty ? time.label : day + " " + time.label
    }

    @ViewBuilder private var corner: some View {
        if let course = schedule.focus {
            // 位置置于开头，空间不足时从尾部省略课程名，优先保留完整教室号。
            let courseLabel = [schedule.compactLocation, course.name]
                .filter { !$0.isEmpty }.joined(separator: " · ")
            if let progress = schedule.courseProgress {
                cornerText(courseLabel)
                    .widgetCurvesContent()
                    .widgetLabel {
                        // 数值 Gauge 由 WidgetKit 排成表角弧线，不展示百分比或时间。
                        Gauge(value: progress, in: 0...1) {
                            EmptyView()
                        }
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(color)
                        .accessibilityLabel(watchLocalizedString("课程进度"))
                    }
            } else {
                cornerText(
                    schedule.compactDateTimeText(for: course.startAt),
                    font: .system(size: 10, weight: .regular, design: .rounded)
                )
                    .widgetCurvesContent()
                    .widgetLabel {
                        cornerText(courseLabel)
                    }
            }
        } else {
            Image(systemName: schedule.emptySymbol).widgetLabel { Text(schedule.title) }
        }
    }

    @ViewBuilder private var rectangular: some View {
        if role == .overview
            && ![.semesterEnded, .signedOut, .noData, .expired].contains(schedule.state)
        {
            overviewRectangle
        } else if let course = schedule.focus {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Text(
                        role == .name
                            ? nameContext
                            : (role == .integrated
                                ? contextTitle + " · " + course.name : contextTitle)
                    )
                    .font(.system(size: role == .name ? 10 : 12, weight: .medium))
                    .lineLimit(1).minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    if switchableCurrentCourse != nil {
                        // 标题为按钮留出横向空间；更高的触摸区域在卡片上叠放，
                        // 不撑高标题行或挤压下面的时间、进度与地点。
                        Color.clear.frame(width: 40, height: 16)
                            .accessibilityHidden(true)
                    }
                }
                .foregroundStyle(color)
                if role == .name {
                    Label(course.name, systemImage: course.kindSystemImage)
                        .font(.system(size: 16, weight: .semibold)).lineLimit(2).minimumScaleFactor(
                            0.8)
                    if let kind = course.kindTitle {
                        Text(kind).font(.caption2).foregroundStyle(.secondary)
                    }
                } else {
                    ScheduleTime(schedule: schedule)
                    if let progress = schedule.courseProgress {
                        ScheduleProgress(progress: progress, color: color)
                            .padding(.vertical, 1)
                    }
                    Label(schedule.locationSummary, systemImage: "mappin")
                        .font(.system(size: 16, weight: .regular)).lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .truncationMode(.tail)
                        .foregroundStyle(.primary)
                }
            }
            .overlay(alignment: .topTrailing) {
                if let current = switchableCurrentCourse {
                    Button(
                        intent: ToggleScheduleWidgetCourseIntent(currentCourseID: current.id)
                    ) {
                        Image(systemName: schedule.isPreview ? "arrow.uturn.backward" : "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 20, height: 16)
                            .frame(width: 40, height: 32, alignment: .topTrailing)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(color)
                    .accessibilityLabel(watchLocalizedString("切换当前与下一节课"))
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        } else {
            HStack(spacing: 8) {
                Image(systemName: schedule.emptySymbol).font(.title3).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(schedule.title).font(.system(size: 13, weight: .semibold)).lineLimit(2)
                    if [.noData, .unconfirmed, .expired, .signedOut].contains(schedule.state) {
                        Text(watchLocalizedString("打开手机更新课表")).font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    } else if [.todayFinished, .todayFree].contains(schedule.state) {
                        Text(watchLocalizedString("后续课表待同步")).font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var contextTitle: String {
        guard let course = schedule.focus else { return schedule.title }
        if !schedule.calendar.isDate(course.startAt, inSameDayAs: schedule.date) {
            return schedule.title + " · " + schedule.dayLabel(for: course.startAt)
        }
        return schedule.title
    }
    private var nameContext: String {
        guard let course = schedule.focus else { return schedule.title }
        return schedule.calendar.isDate(course.startAt, inSameDayAs: schedule.date)
            ? schedule.title : schedule.dayLabel(for: course.startAt)
    }
    private var emptyCompact: some View {
        circularStatus(symbol: schedule.emptySymbol, title: schedule.compactTitle)
            .accessibilityLabel(schedule.title)
    }

    /// 课程名称、时刻、位置和日程状态共用主要文字样式。
    private func circularTitle(_ title: String, lineLimit: Int = 2) -> some View {
        Text(title)
            .font(CircularScheduleTypography.primary)
            .lineLimit(lineLimit)
            .minimumScaleFactor(CircularScheduleTypography.minimumScale)
            .truncationMode(.tail)
    }

    private func circularStatus(symbol: String, title: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: symbol).font(.system(size: 14))
            circularTitle(title)
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
    }
    private var summaryRemaining: Int {
        schedule.summaryCourses.filter { $0.endAt > schedule.date }.count
    }
    private var summaryIsAvailable: Bool {
        ![.semesterEnded, .signedOut, .noData, .expired].contains(schedule.state)
            && schedule.summaryIsComplete
    }
    private var summaryText: String {
        guard summaryIsAvailable else {
            switch schedule.state {
            case .semesterEnded, .signedOut, .noData, .expired: return schedule.compactTitle
            default: return watchLocalizedString("日程概览待同步")
            }
        }
        if schedule.summaryCourses.isEmpty { return watchLocalizedString("今日无课") }
        if summaryRemaining == 0 { return watchLocalizedString("今日已下课") }
        return watchLocalizedFormat("%@ %d 项 · 还剩 %d 项",
            schedule.dayLabel(for: schedule.summaryDate), schedule.summaryCourses.count,
            summaryRemaining)
    }
    @ViewBuilder private var summaryCircle: some View {
        if summaryIsAvailable && summaryRemaining > 0 {
            Gauge(
                value: Double(schedule.summaryCourses.count - summaryRemaining),
                in: 0...Double(schedule.summaryCourses.count)
            ) {
                Text(schedule.dayLabel(for: schedule.summaryDate))
            } currentValueLabel: {
                VStack(spacing: 0) {
                    Text(watchLocalizedString("还剩")).font(.system(size: 7))
                    Text("\(summaryRemaining)").font(
                        .system(size: 19, weight: .semibold, design: .rounded))
                }
            }
            .gaugeStyle(.accessoryCircular)
            .accessibilityLabel(summaryText)
        } else if summaryIsAvailable {
            circularStatus(
                symbol: schedule.summaryCourses.isEmpty ? "cup.and.saucer.fill" : "checkmark",
                title: summaryText)
        } else {
            circularStatus(symbol: schedule.emptySymbol, title: summaryText)
        }
    }
    private var overviewRectangle: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(watchLocalizedString("今日"))
                Spacer(minLength: 0)
                Text(schedule.weekIsComplete ? weekLabel : watchLocalizedString("本周日程待同步"))
                    .minimumScaleFactor(0.85)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.secondary)

            Text(summaryIsAvailable && summaryRemaining > 0
                ? watchLocalizedFormat("还剩 %d 项", summaryRemaining)
                : summaryText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.85)
                .widgetAccentable()

            if summaryIsAvailable {
                if summaryRemaining > 0,
                    let lastEnd = schedule.summaryCourses.map(\.endAt).max()
                {
                    Text(watchLocalizedFormat("%@ 全部结束",
                        schedule.compactDateTimeText(for: lastEnd)))
                        .font(.system(size: 11, weight: .medium))
                } else if let next = schedule.focus, next.startAt > schedule.date {
                    Text(watchLocalizedFormat("下一次 %@",
                        schedule.compactDateTimeText(for: next.startAt)))
                        .font(.system(size: 11, weight: .medium))
                } else if [.unconfirmed, .todayFree, .todayFinished].contains(schedule.state) {
                    Text(watchLocalizedString("后续课表待同步"))
                        .font(.system(size: 11))
                }
            } else {
                Text(watchLocalizedString("打开手机更新课表"))
                    .font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .padding(.horizontal, 2)
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var weekLabel: String {
        let currentWeek = schedule.calendar.dateInterval(of: .weekOfYear, for: schedule.date)!
        let label =
            currentWeek.start == schedule.weekInterval.start
            ? watchLocalizedString("本周") : schedule.dayLabel(for: schedule.weekInterval.start)
        return watchLocalizedFormat("%@ %d 项", label, schedule.weekCourses.count)
    }
}

private struct ScheduleConfiguration {
    let kind: String
    let role: ScheduleWidgetRole
    let name: LocalizedStringKey
    let summary: LocalizedStringKey
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TraintimeScheduleWidgetProvider()) { entry in
            ScheduleWidgetView(entry: entry, role: role)
        }
        .configurationDisplayName(name)
        .description(summary)
        .supportedFamilies(role == .integrated
            ? [.accessoryInline, .accessoryCircular, .accessoryCorner, .accessoryRectangular]
            : [.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct TraintimeScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.widgetKind, role: .integrated, name: "综合课表",
            summary: "显示当前或下一节课，上课期间显示课程进度。"
        ).body
    }
}
struct TraintimeCourseNameWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.courseNameWidgetKind, role: .name, name: "课程名称",
            summary: "显示课程名称和状态，搭配时间地点组件使用。"
        ).body
    }
}
struct TraintimeCourseTimeLocationWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.courseTimeLocationWidgetKind, role: .timeLocation, name: "时间地点",
            summary: "显示上课、下课时间与地点，与课程名称组件保持一致。"
        ).body
    }
}
struct TraintimeTodayScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.todayScheduleWidgetKind, role: .overview, name: "日程概览",
            summary: "显示今日剩余安排、结束时间和本周总数，轻点打开概览。"
        ).body
    }
}
