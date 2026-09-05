// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import AppIntents
import SwiftUI
import WidgetKit

private enum ScheduleWidgetLayout {
    static let matrixCellAspectRatio: CGFloat = 0.68
    static let matrixCellCornerRatio: CGFloat = 0.28
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
            id: "preview", name: "高等数学", teacher: nil, classroom: "B-302",
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

/// 始终由日期驱动，避免使用 entry.date 冻结剩余分钟数和进度。
private struct ScheduleTime: View {
    let schedule: WatchSchedulePresentation
    var compact = false

    var body: some View {
        VStack(spacing: 0) {
            Text(schedule.timeLabel)
                .font(.system(size: compact ? 7 : 9, weight: .medium))
                .lineLimit(1)
            if schedule.state != .finishing && !schedule.isAboutToStart {
                timeValue
                    .font(.system(size: compact ? 12 : 17, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }

    @ViewBuilder var timeValue: some View {
        if let target = schedule.timeTarget {
            if schedule.usesCountdown {
                Text(
                    timerInterval: schedule.date...max(schedule.date, target), countsDown: true,
                    showsHours: true)
            } else {
                Text(schedule.clockText(target))
            }
        }
    }
}

private struct ScheduleProgress: View {
    let interval: ClosedRange<Date>
    var body: some View {
        ProgressView(timerInterval: interval, countsDown: false) {
            EmptyView()
        } currentValueLabel: {
            EmptyView()
        }
        .progressViewStyle(.linear)
        .accessibilityLabel(watchLocalizedString("课程进度"))
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
    }

    private var inline: some View {
        Group {
            if role == .overview {
                Label(summaryText, systemImage: "calendar")
            } else if let course = schedule.focus {
                if role == .name {
                    Text(nameContext + " · " + course.name)
                } else {
                    inlineTime + Text(" · " + schedule.location)
                }
            } else {
                Label(schedule.compactTitle, systemImage: schedule.emptySymbol)
            }
        }
    }

    private var inlineTime: Text {
        let day =
            schedule.focus.map {
                schedule.calendar.isDate($0.startAt, inSameDayAs: schedule.date)
                    ? "" : schedule.dayLabel(for: $0.startAt) + " "
            } ?? ""
        let prefix = Text(day + schedule.timeLabel + " ")
        guard schedule.state != .finishing, !schedule.isAboutToStart,
            let target = schedule.timeTarget
        else { return prefix }
        if schedule.usesCountdown {
            return prefix
                + Text(
                    timerInterval: schedule.date...max(schedule.date, target), countsDown: true,
                    showsHours: true)
        }
        return prefix + Text(schedule.clockText(target))
    }

    @ViewBuilder private var circular: some View {
        if role == .overview {
            summaryCircle
        } else if let course = schedule.focus {
            if role == .name {
                VStack(spacing: 1) {
                    Image(systemName: course.kindSystemImage).font(.system(size: 10))
                        .foregroundStyle(color)
                    Text(nameContext).font(.system(size: 7))
                    Text(course.name).font(.system(size: 11, weight: .semibold)).lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
                .multilineTextAlignment(.center)
                .widgetAccentable()
            } else if let interval = schedule.progressInterval {
                ProgressView(timerInterval: interval, countsDown: false) {
                    EmptyView()
                } currentValueLabel: {
                    compactTimeLocation
                }
                .progressViewStyle(.circular)
                .tint(color)
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    compactTimeLocation
                }
            }
        } else {
            emptyCompact
        }
    }

    private var compactTimeLocation: some View {
        VStack(spacing: 0) {
            if let course = schedule.focus,
                !schedule.calendar.isDate(course.startAt, inSameDayAs: schedule.date)
            {
                Text(schedule.dayLabel(for: course.startAt)).font(.system(size: 7)).lineLimit(1)
            }
            ScheduleTime(schedule: schedule, compact: true)
            Text(schedule.location).font(.system(size: 9, weight: .semibold)).lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .multilineTextAlignment(.center)
        .widgetAccentable()
    }

    @ViewBuilder private var corner: some View {
        if role == .overview {
            summaryCircle.widgetLabel { Text(summaryText) }
        } else if let course = schedule.focus {
            if role == .name {
                Image(systemName: course.kindSystemImage)
                    .foregroundStyle(color)
                    .widgetLabel { Text(nameContext + " · " + course.name) }
            } else {
                ScheduleTime(schedule: schedule, compact: true)
                    .widgetLabel {
                        if let interval = schedule.progressInterval {
                            ProgressView(timerInterval: interval, countsDown: false) {
                                Text(schedule.location)
                            } currentValueLabel: {
                                EmptyView()
                            }
                        } else {
                            Text(schedule.dayLabel(for: course.startAt) + " · " + schedule.location)
                        }
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
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 3) {
                    Text(
                        role == .name
                            ? nameContext
                            : (role == .integrated
                                ? contextTitle + " · " + course.name : contextTitle)
                    )
                    .font(.system(size: 10, weight: .medium)).lineLimit(1).minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    if role == .integrated, let current = entry.schedule.current,
                        entry.schedule.next != nil
                    {
                        Button(
                            intent: ToggleScheduleWidgetCourseIntent(currentCourseID: current.id)
                        ) {
                            Image(
                                systemName: schedule.isPreview
                                    ? "arrow.uturn.backward" : "arrow.right"
                            )
                            .font(.system(size: 11, weight: .semibold)).frame(width: 20, height: 18)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(watchLocalizedString("切换当前与下一节课"))
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
                    HStack(alignment: .center, spacing: 8) {
                        ScheduleTime(schedule: schedule)
                            .fixedSize(horizontal: true, vertical: false)
                        Text(schedule.location)
                            .font(.system(size: 16, weight: .semibold)).lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    if let interval = schedule.progressInterval {
                        ScheduleProgress(interval: interval).tint(color)
                    }
                }
            }
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
        VStack(spacing: 2) {
            Image(systemName: schedule.emptySymbol).font(.system(size: 14))
            Text(schedule.compactTitle).font(.system(size: 9, weight: .medium)).lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .multilineTextAlignment(.center)
        .accessibilityLabel(schedule.title)
    }
    private var summaryRemaining: Int {
        schedule.summaryCourses.filter { $0.endAt > schedule.date }.count
    }
    private var summaryText: String {
        guard schedule.summaryIsComplete else {
            switch schedule.state {
            case .semesterEnded, .signedOut, .noData, .expired: return schedule.compactTitle
            default: return watchLocalizedString("日程概览待同步")
            }
        }
        return String(
            format: watchLocalizedString("%@ %d 项 · 还剩 %d 项"),
            schedule.dayLabel(for: schedule.summaryDate), schedule.summaryCourses.count,
            summaryRemaining)
    }
    @ViewBuilder private var summaryCircle: some View {
        if schedule.summaryIsComplete && !schedule.summaryCourses.isEmpty {
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
        } else if schedule.summaryIsComplete {
            VStack(spacing: 2) {
                Image(systemName: "cup.and.saucer.fill")
                Text(watchLocalizedString("今日无课")).font(.system(size: 9))
            }
        } else {
            VStack(spacing: 2) {
                Image(systemName: schedule.emptySymbol)
                Text(summaryText).font(.system(size: 9)).lineLimit(2)
            }
        }
    }
    private var overviewRectangle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summaryText).font(.system(size: 11, weight: .semibold)).lineLimit(1)
                .minimumScaleFactor(0.8)
            if schedule.summaryIsComplete {
                TodayPeriodStrip(courses: schedule.summaryCourses, date: schedule.date).frame(
                    height: 7)
            }
            if schedule.weekIsComplete {
                HStack(spacing: 6) {
                    Text(weekLabel).font(.system(size: 9)).lineLimit(2)
                    WeekDotMatrix(
                        courses: schedule.weekCourses, referenceDate: schedule.summaryDate,
                        calendar: schedule.calendar
                    )
                    .frame(maxWidth: 75, maxHeight: 33)
                }
                .foregroundStyle(.secondary)
            } else {
                Text(watchLocalizedString("本周日程待同步")).font(.system(size: 9)).foregroundStyle(
                    .secondary)
            }
        }
    }
    private var weekLabel: String {
        let currentWeek = schedule.calendar.dateInterval(of: .weekOfYear, for: schedule.date)!
        let label =
            currentWeek.start == schedule.weekInterval.start
            ? watchLocalizedString("本周") : schedule.dayLabel(for: schedule.weekInterval.start)
        return String(format: watchLocalizedString("%@ %d 项"), label, schedule.weekCourses.count)
    }
}

private struct TodayPeriodStrip: View {
    let courses: [WatchCourse]
    let date: Date
    private static let ranges = [1...2, 3...4, 5...6, 7...8, 9...10]
    var body: some View {
        HStack(spacing: 3) {
            ForEach(Self.ranges.indices, id: \.self) { index in
                let matching = courses.filter {
                    $0.startPeriod <= Self.ranges[index].upperBound
                        && $0.endPeriod >= Self.ranges[index].lowerBound
                }
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        matching.first?.color.opacity(
                            matching.allSatisfy { $0.endAt <= date } ? 0.35 : 1)
                            ?? Color.secondary.opacity(0.2))
            }
        }
        .accessibilityLabel(watchLocalizedString("今日节次分布"))
    }
}
/// 点阵单元的几何参数。
private struct DotMatrixMetrics {
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let horizontalGap: CGFloat
    let verticalGap: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat

    /// 返回指定行列的短圆角矩形区域。
    func rect(row: Int, column: Int) -> CGRect {
        CGRect(
            x: xOffset
                + CGFloat(column) * (cellWidth + horizontalGap),
            y: yOffset
                + CGFloat(row) * (cellHeight + verticalGap),
            width: cellWidth,
            height: cellHeight
        )
    }
}

/// 右侧 5×7 周课程点阵。
///
/// 7 列对应周一到周日；5 行分别对应 1–2、3–4、5–6、7–8、
/// 9–10 节。短圆角矩形横向铺满可用宽度；有课程时直接使用同步的课程色，
/// 否则保留低对比度占位色。
private struct WeekDotMatrix: View {
    let contentInset: CGFloat
    let cellAspectRatio: CGFloat
    let minimumVerticalGap: CGFloat
    private let courseColors: [Int: Color]

    init(
        courses: [WatchCourse],
        referenceDate: Date,
        calendar: Calendar,
        contentInset: CGFloat = 0,
        cellAspectRatio: CGFloat = ScheduleWidgetLayout.matrixCellAspectRatio,
        minimumVerticalGap: CGFloat = 1.2
    ) {
        self.contentInset = contentInset
        self.cellAspectRatio = cellAspectRatio
        self.minimumVerticalGap = minimumVerticalGap
        self.courseColors = Self.makeCourseColorIndex(
            courses: courses,
            referenceDate: referenceDate,
            calendar: calendar
        )
    }

    private static let rowRanges = [
        1...2,
        3...4,
        5...6,
        7...8,
        9...10,
    ]

    var body: some View {
        Canvas { context, size in
            let metrics = makeMetrics(for: size)

            for row in Self.rowRanges.indices {
                for column in 0..<7 {
                    drawCell(
                        context: &context,
                        rect: metrics.rect(row: row, column: column),
                        color: dotColor(row: row, weekday: column)
                    )
                }
            }
        }
        .accessibilityLabel(watchLocalizedString("本周课程点阵"))
    }

    /// 根据可用宽高计算自适应短矩形。
    ///
    /// 宽度独立计算并完整占满七列，高度按固定比例收窄，
    /// 在有限空间内维持清晰的课程节次标记。
    private func makeMetrics(for size: CGSize) -> DotMatrixMetrics {
        let availableWidth = max(0, size.width - contentInset * 2)
        let availableHeight = max(0, size.height - contentInset * 2)
        let horizontalGap = max(1, min(1.8, availableWidth * 0.018))
        let verticalGap = max(
            minimumVerticalGap,
            min(3, availableHeight * 0.05)
        )
        let cellWidth = max(
            0,
            (availableWidth - horizontalGap * 6) / 7
        )
        let maximumCellHeight = max(
            0,
            (availableHeight - verticalGap * 4) / 5
        )
        let cellHeight = min(
            maximumCellHeight,
            cellWidth * cellAspectRatio
        )
        let gridHeight = cellHeight * 5 + verticalGap * 4

        return DotMatrixMetrics(
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            horizontalGap: horizontalGap,
            verticalGap: verticalGap,
            xOffset: contentInset,
            yOffset: contentInset + max(0, (availableHeight - gridHeight) / 2)
        )
    }

    /// 绘制轻微圆角的课程单元；圆角不会达到胶囊形态。
    private func drawCell(
        context: inout GraphicsContext,
        rect: CGRect,
        color: Color
    ) {
        let cornerRadius = min(
            rect.height * ScheduleWidgetLayout.matrixCellCornerRatio,
            rect.width * ScheduleWidgetLayout.matrixCellCornerRatio
        )
        context.fill(
            Path(
                roundedRect: rect,
                cornerSize: CGSize(
                    width: cornerRadius,
                    height: cornerRadius
                )
            ),
            with: .color(color)
        )
    }

    /// 课程存在时返回课程色，否则返回低对比度占位色。
    private func dotColor(row: Int, weekday: Int) -> Color {
        courseColors[Self.colorKey(row: row, weekday: weekday)]
            ?? Color.secondary.opacity(0.22)
    }

    /// 把行列压缩为一个稳定键，Canvas 绘制阶段只进行 O(1) 查询。
    private static func colorKey(row: Int, weekday: Int) -> Int {
        row * 7 + weekday
    }

    /// 初始化时一次建立 5×7 颜色索引，避免 Canvas 每帧重复扫描完整课表。
    private static func makeCourseColorIndex(
        courses: [WatchCourse],
        referenceDate: Date,
        calendar: Calendar
    ) -> [Int: Color] {
        let startOfDay = calendar.startOfDay(for: referenceDate)
        let systemWeekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (systemWeekday + 5) % 7
        let monday =
            calendar.date(
                byAdding: .day,
                value: -daysSinceMonday,
                to: startOfDay
            ) ?? startOfDay

        var result: [Int: Color] = [:]
        for course in courses {
            let courseDay = calendar.startOfDay(for: course.startAt)
            guard
                let weekday = calendar.dateComponents(
                    [.day],
                    from: monday,
                    to: courseDay
                ).day,
                (0..<7).contains(weekday)
            else { continue }

            for row in rowRanges.indices {
                let range = rowRanges[row]
                guard course.startPeriod <= range.upperBound,
                    course.endPeriod >= range.lowerBound
                else { continue }
                let key = colorKey(row: row, weekday: weekday)
                if result[key] == nil {
                    result[key] = course.color
                }
            }
        }
        return result
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
        .supportedFamilies([
            .accessoryInline, .accessoryCircular, .accessoryCorner, .accessoryRectangular,
        ])
    }
}

struct TraintimeScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.widgetKind, role: .integrated, name: "综合课表",
            summary: "按上课状态显示时间、地点和课程，小尺寸优先显示倒计时与地点。"
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
            summary: "显示距上课、距下课、地点和进度，与课程名称组件保持一致。"
        ).body
    }
}
struct TraintimeTodayScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        ScheduleConfiguration(
            kind: WatchWidgetShared.todayScheduleWidgetKind, role: .overview, name: "日程概览",
            summary: "显示日程数量、完成情况和日周分布，当天结束后预览下一次安排。"
        ).body
    }
}
