// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import AppIntents
import SwiftUI
import WidgetKit

/// 小组件的布局常量集中放在这里，避免在视图树中散落“魔法数字”。
///
/// 综合组件右侧的周分布区约占三成宽度；同时设置绝对上限，
/// 防止未来系统提供更宽的组件尺寸时，分布区被无意义地放大。
private enum ScheduleWidgetLayout {
    static let smartStackMatrixWidthRatio: CGFloat = 0.32
    static let maximumSmartStackMatrixWidth: CGFloat = 54
    static let smartStackMatrixContentInset: CGFloat = 2.5
    static let smartStackMatrixCellAspectRatio: CGFloat = 1
    static let smartStackMatrixMinimumVerticalGap: CGFloat = 2.2
    static let maximumTimelineEntryCount = 18
    static let fallbackReloadInterval: TimeInterval = 6 * 60 * 60
    static let rectangularColumnSpacing: CGFloat = 5
    static let circularTimeFontSize: CGFloat = 13
    static let circularLocationFontSize: CGFloat = 8
    static let cornerTimeFontSize: CGFloat = 12
    static let rectangularCornerRadius: CGFloat = 6
    static let matrixCellAspectRatio: CGFloat = 0.68
    static let matrixCellCornerRatio: CGFloat = 0.28
}

/// 全部课程组件共用的图标语义，避免同一功能在不同 family 中出现不同符号。
private enum ScheduleWidgetIconKind {
    case course
    case timeLocation
    case progress
    case today
    case week
    case empty

    var systemName: String {
        switch self {
        case .course:
            return "book.closed.fill"
        case .progress:
            return "chart.bar.fill"
        case .today:
            return "calendar.day.timeline.left"
        case .week:
            return "calendar"
        case .timeLocation, .empty:
            // 这两种使用组合符号，不从单个 SF Symbol 名称读取。
            return ""
        }
    }
}

/// 统一图标尺寸、字重和渲染颜色。
///
/// 时间地点使用“时钟 + 定位点”组合；无课使用“日历 + 减号”组合。这样不依赖
/// 较新系统才有的 badge 变体，也不会再用“完成”符号表达“暂无课程”。
private struct ScheduleWidgetIcon: View {
    let kind: ScheduleWidgetIconKind
    let color: Color
    let size: CGFloat

    var body: some View {
        Group {
            switch kind {
            case .timeLocation:
                overlaidIcon(
                    base: "clock.fill",
                    badge: "mappin.circle.fill"
                )
            case .empty:
                overlaidIcon(
                    base: "calendar",
                    badge: "minus.circle.fill"
                )
            default:
                Image(systemName: kind.systemName)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .symbolRenderingMode(.monochrome)
        .frame(width: size * 1.2, height: size * 1.2)
        .accessibilityHidden(true)
    }

    /// 小徽标放在主体右下角，在紧凑空间内同时表达两个相关概念。
    private func overlaidIcon(base: String, badge: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: base)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(color)

            Image(systemName: badge)
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(color)
                .offset(x: size * 0.12, y: size * 0.08)
        }
    }
}

/// 时间线中的单个显示状态。
///
/// Provider 已经提前算好当前课程、下一节课程以及用户的切换选择，
/// 视图层只负责渲染，避免在 SwiftUI `body` 中读写缓存。
struct TraintimeScheduleWidgetEntry: TimelineEntry {
    let date: Date
    let currentCourse: WatchCourse?
    let nextCourse: WatchCourse?
    let displaysNextCourse: Bool
    let todayCourses: [WatchCourse]
    let thisWeekCourses: [WatchCourse]

    /// 实际应显示的课程。
    ///
    /// 有课时默认显示当前课程；用户主动切换后显示下一节。
    /// 没有正在进行的课程时，直接显示下一节课程。
    var displayedCourse: WatchCourse? {
        if displaysNextCourse, let nextCourse {
            return nextCourse
        }
        return currentCourse ?? nextCourse
    }

    /// 只有“当前”和“下一节”同时存在时才显示切换按钮。
    var canToggleCourse: Bool {
        currentCourse != nil && nextCourse != nil
    }

    /// 当前条目展示的是正在进行的课程，而不是用户主动切换后的下一节。
    var displaysCurrentCourse: Bool {
        guard let displayedCourse, let currentCourse else { return false }
        return displayedCourse.id == currentCourse.id
    }

}

/// 当前课程与下一节课程的计算结果。
private struct WidgetCourseSelection {
    let current: WatchCourse?
    let next: WatchCourse?
}

/// 为表盘 Complication 与 Smart Stack 提供占位内容、快照和正式时间线。
struct TraintimeScheduleWidgetProvider: TimelineProvider {
    /// 组件库预览使用的快速占位数据。
    func placeholder(in context: Context) -> TraintimeScheduleWidgetEntry {
        let now = Date()
        return makeEntry(at: now, snapshot: placeholderSnapshot(at: now))
    }

    /// 系统只需要一张静态快照时，从 App Group 读取当前最佳缓存。
    func getSnapshot(
        in context: Context,
        completion: @escaping (TraintimeScheduleWidgetEntry) -> Void
    ) {
        let now = Date()
        let cachedSnapshot = WatchWidgetShared.loadPreferredSnapshot(now: now)
        let snapshot = cachedSnapshot
            ?? (context.isPreview ? placeholderSnapshot(at: now) : nil)
        completion(makeEntry(at: now, snapshot: snapshot))
    }

    /// 建立正式时间线。
    ///
    /// 除“现在”以外，还在课程开始和结束时插入时间线节点，
    /// 这样系统无需频繁唤醒扩展，也能及时把“下一节”切换成“当前”。
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TraintimeScheduleWidgetEntry>) -> Void
    ) {
        let now = Date()
        let snapshot = WatchWidgetShared.loadPreferredSnapshot(now: now)
        let dates = timelineDates(
            from: snapshot?.courses ?? [],
            now: now
        )
        let entries = dates.map {
            makeEntry(at: $0, snapshot: snapshot)
        }
        completion(
            Timeline(
                entries: entries,
                policy: .after(fallbackReloadDate(from: now))
            )
        )
    }

    /// 生成一个完全可渲染的时间线条目。
    private func makeEntry(
        at date: Date,
        snapshot: WatchScheduleSnapshot?
    ) -> TraintimeScheduleWidgetEntry {
        let courses = sortedCourses(in: snapshot)
        let selection = selectCourses(from: courses, at: date)
        let calendar = Calendar.current

        return TraintimeScheduleWidgetEntry(
            date: date,
            currentCourse: selection.current,
            nextCourse: selection.next,
            displaysNextCourse: shouldDisplayNextCourse(
                selection: selection
            ),
            todayCourses: courses.filter {
                calendar.isDate($0.startAt, inSameDayAs: date)
            },
            thisWeekCourses: coursesInReferenceWeek(
                courses,
                date: date,
                calendar: calendar
            )
        )
    }

    /// 预先提取本周课程，所有专用组件直接复用结果，不在 `body` 中扫描快照。
    private func coursesInReferenceWeek(
        _ courses: [WatchCourse],
        date: Date,
        calendar: Calendar
    ) -> [WatchCourse] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date)
        else { return [] }
        return courses.filter { interval.contains($0.startAt) }
    }

    /// 按开始时间排序，确保手机端即使传来乱序数据也能稳定选择课程。
    private func sortedCourses(
        in snapshot: WatchScheduleSnapshot?
    ) -> [WatchCourse] {
        (snapshot?.courses ?? []).sorted {
            if $0.startAt == $1.startAt {
                return $0.endAt < $1.endAt
            }
            return $0.startAt < $1.startAt
        }
    }

    /// 找出指定时刻正在进行的课程和此后的第一节课程。
    private func selectCourses(
        from courses: [WatchCourse],
        at date: Date
    ) -> WidgetCourseSelection {
        let current = courses.first {
            $0.startAt <= date && date < $0.endAt
        }
        let next = courses.first { $0.startAt > date }
        return WidgetCourseSelection(current: current, next: next)
    }

    /// 根据课程边界生成系统需要更新组件的时刻。
    ///
    /// 只保留未来节点并去重，限制数量是为了避免向 WidgetKit
    /// 一次提交过大的时间线；超过部分会在兜底刷新时重新生成。
    private func timelineDates(
        from courses: [WatchCourse],
        now: Date
    ) -> [Date] {
        let futureBoundaries = courses
            .flatMap { [$0.startAt, $0.endAt] }
            .filter { $0 > now }
            .sorted()

        let uniqueDates = Array(Set([now] + futureBoundaries)).sorted()
        return Array(
            uniqueDates.prefix(
                ScheduleWidgetLayout.maximumTimelineEntryCount
            )
        )
    }

    /// 判断用户是否要求暂时显示下一节课程。
    private func shouldDisplayNextCourse(
        selection: WidgetCourseSelection
    ) -> Bool {
        guard let currentID = selection.current?.id,
              selection.next != nil
        else {
            return false
        }
        return WatchWidgetShared.defaults?.string(
            forKey: WatchWidgetShared.selectedCurrentCourseKey
        ) == currentID
    }

    /// 即使当天没有课程边界，也每六小时重新读取一次共享缓存。
    private func fallbackReloadDate(from now: Date) -> Date {
        now.addingTimeInterval(
            ScheduleWidgetLayout.fallbackReloadInterval
        )
    }

    /// 组件库没有真实缓存时仍展示完整结构，避免用户只能看到“暂无课程”。
    private func placeholderSnapshot(at now: Date) -> WatchScheduleSnapshot {
        let calendar = Calendar.current
        let start = calendar.date(
            bySettingHour: 8,
            minute: 30,
            second: 0,
            of: now
        ) ?? now.addingTimeInterval(30 * 60)
        let normalizedStart = start > now
            ? start
            : now.addingTimeInterval(30 * 60)
        let end = normalizedStart.addingTimeInterval(95 * 60)
        let course = WatchCourse(
            id: "widget-placeholder",
            name: "CCD成像技术",
            teacher: nil,
            classroom: "A425",
            startAtEpochMs: Int64(normalizedStart.timeIntervalSince1970 * 1_000),
            endAtEpochMs: Int64(end.timeIntervalSince1970 * 1_000),
            startSection: 1,
            endSection: 2,
            colorARGB: Int64(0xFF3F51B5),
            kind: nil,
            note: nil
        )
        return WatchScheduleSnapshot(
            schemaVersion: 4,
            generatedAtEpochMs: Int64(now.timeIntervalSince1970 * 1_000),
            semesterStartEpochMs: nil,
            currentWeekIndex: nil,
            validThroughEpochMs: Int64(end.timeIntervalSince1970 * 1_000),
            rangeStartEpochMs: Int64(normalizedStart.timeIntervalSince1970 * 1_000),
            rangeEndEpochMs: Int64(end.timeIntervalSince1970 * 1_000),
            timeZoneOffsetMinutes: TimeZone.current.secondsFromGMT() / 60,
            reminderMinutes: 15,
            courses: [course]
        )
    }
}

/// Smart Stack 内“当前/下一节”切换按钮对应的交互意图。
struct ToggleScheduleWidgetCourseIntent: AppIntent {
    static let title: LocalizedStringResource = "切换当前与下一节课"
    static let description = IntentDescription(
        "在当前课程和下一节课程之间切换。"
    )
    static let openAppWhenRun = false

    /// 由当前时间线条目直接传入课程 ID。
    ///
    /// 不再依赖 Provider 写入全局“当前课程”，从而避免预生成未来时间线时
    /// 把交互状态错误地推进到未来课程。
    @Parameter(title: "当前课程 ID")
    var currentCourseID: String

    /// App Intents 框架反射类型时需要无参数初始化器。
    init() {
        currentCourseID = ""
    }

    /// 小组件按钮创建意图时注入当前条目对应的课程 ID。
    init(currentCourseID: String) {
        self.currentCourseID = currentCourseID
    }

    /// 切换只修改一个轻量标记，不启动手表 App。
    func perform() async throws -> some IntentResult {
        guard let defaults = WatchWidgetShared.defaults,
              !currentCourseID.isEmpty
        else {
            return .result()
        }

        toggleNextCourseSelection(
            in: defaults,
            currentCourseID: currentCourseID
        )
        reloadWidget()
        return .result()
    }

    /// 同一个意图再次触发时恢复显示当前课程。
    private func toggleNextCourseSelection(
        in defaults: UserDefaults,
        currentCourseID: String
    ) {
        let selectedID = defaults.string(
            forKey: WatchWidgetShared.selectedCurrentCourseKey
        )
        if selectedID == currentCourseID {
            defaults.removeObject(
                forKey: WatchWidgetShared.selectedCurrentCourseKey
            )
        } else {
            defaults.set(
                currentCourseID,
                forKey: WatchWidgetShared.selectedCurrentCourseKey
            )
        }
    }

    /// 通知 WidgetKit 立即重新读取切换标记。
    private func reloadWidget() {
        for kind in WatchWidgetShared.allWidgetKinds {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
    }
}

/// 课程文本统一格式化，避免各个 View 重复处理空格和 24 小时制。
private enum ScheduleWidgetTextFormatter {
    /// 返回不受系统 12/24 小时偏好影响的 24 小时制时间。
    static func clockText(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents(
            [.hour, .minute],
            from: date
        )
        return String(
            format: "%02d:%02d",
            parts.hour ?? 0,
            parts.minute ?? 0
        )
    }

    /// 生成紧凑的课程时间范围。
    static func timeRange(for course: WatchCourse) -> String {
        "\(clockText(course.startAt))–\(clockText(course.endAt))"
    }

    /// 表盘空间有限：下一节突出开始时间，当前课程则突出结束时间。
    static func primaryTime(
        for course: WatchCourse,
        isCurrent: Bool
    ) -> String {
        clockText(isCurrent ? course.endAt : course.startAt)
    }

    /// 清理手机端可能传来的空白地点；空值使用明确的占位文字。
    static func location(for course: WatchCourse) -> String {
        let value = course.classroom?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? ""
        return value.isEmpty ? watchLocalizedString("地点未定") : value
    }

    /// 单行复杂功能按“时间、地点、课程名”排序，优先保住用户指定的信息。
    static func inlineText(
        for course: WatchCourse,
        isCurrent: Bool
    ) -> String {
        let time = primaryTime(for: course, isCurrent: isCurrent)
        let location = location(for: course)
        return "\(time) \(location) · \(course.name)"
    }

    /// 返回课程进度，所有 Gauge 与百分比共用同一套边界处理。
    static func progress(
        for course: WatchCourse,
        at date: Date
    ) -> Double {
        let duration = course.endAt.timeIntervalSince(course.startAt)
        guard duration > 0 else { return 0 }
        return min(
            1,
            max(0, date.timeIntervalSince(course.startAt) / duration)
        )
    }

    /// 返回向上取整的剩余分钟，避免各 family 出现不一致的倒计时。
    static func remainingMinutes(
        for course: WatchCourse,
        at date: Date
    ) -> Int {
        Int(ceil(max(0, course.endAt.timeIntervalSince(date)) / 60))
    }
}

/// 按系统分配的 family 选择专用布局。
///
/// 四种 Complication 共用同一个 Timeline 和课程选择结果，避免每个尺寸各自
/// 计算“当前/下一节”。矩形组件在 Smart Stack 与表盘中保持同一信息结构；
/// 系统渲染模式只调整颜色，不改变组件承载的信息。
struct TraintimeScheduleWidgetView: View {
    let entry: TraintimeScheduleWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                InlineScheduleComplication(entry: entry)
            case .accessoryCircular:
                CircularScheduleComplication(entry: entry)
            case .accessoryCorner:
                CornerScheduleComplication(entry: entry)
            case .accessoryRectangular:
                RectangularScheduleComplication(entry: entry)
            default:
                RectangularScheduleComplication(entry: entry)
            }
        }
        .containerBackground(for: .widget) {
            ScheduleWidgetBackground(entry: entry, family: family)
        }
    }
}

/// 各 family 共用的低对比度容器背景。
private struct ScheduleWidgetBackground: View {
    let entry: TraintimeScheduleWidgetEntry
    let family: WidgetFamily

    var body: some View {
        if family == .accessoryRectangular {
            RoundedRectangle(
                cornerRadius: ScheduleWidgetLayout.rectangularCornerRadius,
                style: .continuous
            )
                .fill(
                    (entry.displayedCourse?.color ?? Color.indigo)
                        .opacity(0.18)
                        .gradient
                )
        } else {
            Color.clear
        }
    }
}

/// 单行表盘 Complication：空间不足时优先保留开始/结束时间与地点。
private struct InlineScheduleComplication: View {
    let entry: TraintimeScheduleWidgetEntry

    var body: some View {
        if let course = entry.displayedCourse {
            Label {
                Text(
                    ScheduleWidgetTextFormatter.inlineText(
                        for: course,
                        isCurrent: entry.displaysCurrentCourse
                    )
                )
            } icon: {
                ScheduleWidgetIcon(
                    kind: .course,
                    color: course.color,
                    size: 11
                )
            }
        } else {
            Label {
                Text(watchLocalizedString("暂无课程"))
            } icon: {
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 11
                )
            }
        }
    }
}

/// 圆形表盘 Complication：中央同时容纳关键时间与地点，外圈表示当前课程进度。
private struct CircularScheduleComplication: View {
    let entry: TraintimeScheduleWidgetEntry

    var body: some View {
        if let course = entry.displayedCourse {
            Gauge(value: courseProgress(for: course), in: 0...1) {
                EmptyView()
            } currentValueLabel: {
                VStack(spacing: -1) {
                    Text(
                        ScheduleWidgetTextFormatter.primaryTime(
                            for: course,
                            isCurrent: entry.displaysCurrentCourse
                        )
                    )
                    .font(.system(
                        size: ScheduleWidgetLayout.circularTimeFontSize,
                        weight: .bold,
                        design: .rounded
                    ))
                    .minimumScaleFactor(0.65)

                    Text(ScheduleWidgetTextFormatter.location(for: course))
                        .font(.system(
                            size: ScheduleWidgetLayout.circularLocationFontSize,
                            weight: .semibold,
                            design: .rounded
                        ))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(course.color)
            .widgetAccentable()
            .accessibilityLabel(accessibilityText(for: course))
        } else {
            ZStack {
                AccessoryWidgetBackground()
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 16
                )
            }
            .accessibilityLabel(watchLocalizedString("暂无课程"))
        }
    }

    /// 只有当前课程需要进度；下一节课以空环表达“尚未开始”。
    private func courseProgress(for course: WatchCourse) -> Double {
        guard entry.displaysCurrentCourse else { return 0 }
        return ScheduleWidgetTextFormatter.progress(
            for: course,
            at: entry.date
        )
    }

    private func accessibilityText(for course: WatchCourse) -> String {
        ScheduleWidgetTextFormatter.inlineText(
            for: course,
            isCurrent: entry.displaysCurrentCourse
        )
    }
}

/// 表角 Complication：中央显示关键时间，沿表角曲线显示地点。
private struct CornerScheduleComplication: View {
    let entry: TraintimeScheduleWidgetEntry

    var body: some View {
        if let course = entry.displayedCourse {
            ZStack {
                AccessoryWidgetBackground()
                Text(
                    ScheduleWidgetTextFormatter.primaryTime(
                        for: course,
                        isCurrent: entry.displaysCurrentCourse
                    )
                )
                .font(.system(
                    size: ScheduleWidgetLayout.cornerTimeFontSize,
                    weight: .bold,
                    design: .rounded
                ))
                .minimumScaleFactor(0.6)
            }
            .widgetLabel {
                Label {
                    Text(ScheduleWidgetTextFormatter.location(for: course))
                } icon: {
                    ScheduleWidgetIcon(
                        kind: .timeLocation,
                        color: course.color,
                        size: 9
                    )
                }
            }
            .widgetAccentable()
            .accessibilityLabel(
                ScheduleWidgetTextFormatter.inlineText(
                    for: course,
                    isCurrent: entry.displaysCurrentCourse
                )
            )
        } else {
            ZStack {
                AccessoryWidgetBackground()
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 13
                )
            }
            .widgetLabel {
                Text(watchLocalizedString("暂无课程"))
            }
        }
    }
}

/// 长方形布局同时服务表盘与 Smart Stack。
private struct RectangularScheduleComplication: View {
    let entry: TraintimeScheduleWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            rectangularContent(in: proxy.size)
        }
    }

    /// 将主信息区与右侧点阵按计算后的比例排版。
    ///
    /// 表盘可能要求强调色渲染，几何结构仍与组件库预览一致。
    private func rectangularContent(in size: CGSize) -> some View {
        let matrixWidth = matrixWidth(for: size.width)
        let informationWidth = max(
            0,
            size.width
                - matrixWidth
                - ScheduleWidgetLayout.rectangularColumnSpacing
        )

        return HStack(spacing: ScheduleWidgetLayout.rectangularColumnSpacing) {
            courseInformation
                .frame(width: informationWidth, alignment: .leading)

            WeekDotMatrix(
                courses: entry.thisWeekCourses,
                referenceDate: entry.date,
                contentInset: ScheduleWidgetLayout.smartStackMatrixContentInset,
                cellAspectRatio: ScheduleWidgetLayout.smartStackMatrixCellAspectRatio,
                minimumVerticalGap: ScheduleWidgetLayout.smartStackMatrixMinimumVerticalGap
            )
            .frame(width: matrixWidth)
        }
    }

    /// 右侧分布区约占总宽度三成，并受绝对宽度上限保护。
    private func matrixWidth(for totalWidth: CGFloat) -> CGFloat {
        min(
            totalWidth * ScheduleWidgetLayout.smartStackMatrixWidthRatio,
            ScheduleWidgetLayout.maximumSmartStackMatrixWidth
        )
    }

    /// 根据是否存在课程切换内容区。
    @ViewBuilder
    private var courseInformation: some View {
        if let course = entry.displayedCourse {
            populatedCourseInformation(for: course)
        } else {
            emptyCourseInformation
        }
    }

    /// 有课程时的完整信息区域。
    private func populatedCourseInformation(
        for course: WatchCourse
    ) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            courseHeader(for: course)

            Text(course.name)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            courseMetadata(for: course)
        }
    }

    /// 顶部状态文字与可选的交互按钮。
    private func courseHeader(for course: WatchCourse) -> some View {
        HStack(spacing: 3) {
            Text(statusTitle)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(course.color)

            Spacer(minLength: 1)

            if entry.canToggleCourse {
                toggleButton(color: course.color)
            }
        }
    }

    /// 时间和地点保持在一行，空间不足时优先截断地点。
    private func courseMetadata(for course: WatchCourse) -> some View {
        HStack(spacing: 3) {
            ScheduleWidgetIcon(
                kind: .timeLocation,
                color: course.color,
                size: 8
            )
            Text(metadataTime(for: course))
            Text("·")
            Text(ScheduleWidgetTextFormatter.location(for: course))
                .lineLimit(1)
        }
        .font(.system(size: 8.5, weight: .medium))
        .foregroundStyle(.secondary)
    }

    /// 矩形组件始终显示完整时间范围，保证添加前后的内容一致。
    private func metadataTime(for course: WatchCourse) -> String {
        ScheduleWidgetTextFormatter.timeRange(for: course)
    }

    /// 仅在当前课程与下一节课程同时存在时显示。
    private func toggleButton(color: Color) -> some View {
        Button(
            intent: ToggleScheduleWidgetCourseIntent(
                currentCourseID: entry.currentCourse?.id ?? ""
            )
        ) {
            Image(systemName: toggleButtonSystemImage)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 16, height: 16)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("切换当前与下一节课")
    }

    /// 箭头指向切换后将出现的内容。
    private var toggleButtonSystemImage: String {
        entry.displaysNextCourse ? "arrow.left" : "arrow.right"
    }

    /// 缓存尚未建立时提供明确操作提示。
    private var emptyCourseInformation: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: watchLocalizedString("暂无课程"))
                .font(.system(size: 11, weight: .semibold))
            Text(verbatim: watchLocalizedString("打开手表应用同步课表"))
                .font(.system(size: 8.5))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    /// “当前/下一节”状态标题。
    private var statusTitle: String {
        guard entry.currentCourse != nil else {
            return watchLocalizedString("下一节")
        }
        return entry.displaysNextCourse
            ? watchLocalizedString("下一节")
            : watchLocalizedString("当前")
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
        contentInset: CGFloat = 0,
        cellAspectRatio: CGFloat = ScheduleWidgetLayout.matrixCellAspectRatio,
        minimumVerticalGap: CGFloat = 1.2
    ) {
        self.contentInset = contentInset
        self.cellAspectRatio = cellAspectRatio
        self.minimumVerticalGap = minimumVerticalGap
        self.courseColors = Self.makeCourseColorIndex(
            courses: courses,
            referenceDate: referenceDate
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
        referenceDate: Date
    ) -> [Int: Color] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: referenceDate)
        let systemWeekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (systemWeekday + 5) % 7
        let monday = calendar.date(
            byAdding: .day,
            value: -daysSinceMonday,
            to: startOfDay
        ) ?? startOfDay

        var result: [Int: Color] = [:]
        for course in courses {
            let courseDay = calendar.startOfDay(for: course.startAt)
            guard let weekday = calendar.dateComponents(
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

/// 注册 Apple Watch 表盘 Complication 与 Smart Stack 共用的课程组件。
struct TraintimeScheduleWidget: Widget {
    let kind = WatchWidgetShared.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TraintimeScheduleWidgetProvider()
        ) { entry in
            TraintimeScheduleWidgetView(entry: entry)
                .environment(\.locale, WatchWidgetShared.preferredLocale)
        }
        .configurationDisplayName("XDYou 课表")
        .description("在表盘或智能叠放中查看当前和下一节课程。")
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
        ])
    }
}

// MARK: - 专用表盘组件

/// 专用组件类型。每一种只回答一个问题，避免综合组件在小尺寸中信息拥挤。
private enum FocusedScheduleWidgetKind {
    case name
    case timeLocation
    case progress
    case today
    case week

    /// 每种专用组件固定使用同一语义图标。
    var iconKind: ScheduleWidgetIconKind {
        switch self {
        case .name:
            return .course
        case .timeLocation:
            return .timeLocation
        case .progress:
            return .progress
        case .today:
            return .today
        case .week:
            return .week
        }
    }
}

/// 专用组件图标的课程色来源与矩形背景保持一致。
private func focusedAccentColor(
    entry: TraintimeScheduleWidgetEntry,
    kind: FocusedScheduleWidgetKind
) -> Color {
    switch kind {
    case .today:
        return entry.todayCourses.first?.color
            ?? entry.displayedCourse?.color
            ?? .secondary
    case .week:
        return entry.thisWeekCourses.first?.color
            ?? entry.displayedCourse?.color
            ?? .secondary
    default:
        return entry.displayedCourse?.color ?? .secondary
    }
}

/// 专用组件共享的根视图；各 family 只负责选择适合该形状的表达方式。
private struct FocusedScheduleWidgetView: View {
    let entry: TraintimeScheduleWidgetEntry
    let kind: FocusedScheduleWidgetKind
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                FocusedInlineComplication(entry: entry, kind: kind)
            case .accessoryCircular:
                FocusedCircularComplication(entry: entry, kind: kind)
            case .accessoryCorner:
                FocusedCornerComplication(entry: entry, kind: kind)
            case .accessoryRectangular:
                FocusedRectangularComplication(entry: entry, kind: kind)
            default:
                FocusedCircularComplication(entry: entry, kind: kind)
            }
        }
        .containerBackground(for: .widget) {
            if family == .accessoryRectangular {
                RoundedRectangle(
                    cornerRadius: ScheduleWidgetLayout.rectangularCornerRadius,
                    style: .continuous
                )
                    .fill(
                        rectangularAccentColor
                            .opacity(0.18)
                            .gradient
                    )
            } else {
                Color.clear
            }
        }
    }

    /// 分布组件优先采用其统计范围内的真实课程色，其他组件采用当前展示课程色。
    private var rectangularAccentColor: Color {
        focusedAccentColor(entry: entry, kind: kind)
    }
}

/// 单行专用布局严格只显示一个领域，便于在同一表盘组合多个组件。
private struct FocusedInlineComplication: View {
    let entry: TraintimeScheduleWidgetEntry
    let kind: FocusedScheduleWidgetKind

    var body: some View {
        Label {
            Text(labelText)
        } icon: {
            ScheduleWidgetIcon(
                kind: hasRelevantData ? kind.iconKind : .empty,
                color: accentColor,
                size: 10
            )
        }
    }

    private var labelText: String {
        switch kind {
        case .name:
            return entry.displayedCourse?.name
                ?? watchLocalizedString("暂无课程")
        case .timeLocation:
            return timeLocationText
        case .progress:
            return progressText
        case .today:
            return String(
                format: watchLocalizedString("今日 %d 节"),
                entry.todayCourses.count
            )
        case .week:
            return String(
                format: watchLocalizedString("本周 %d 节"),
                entry.thisWeekCourses.count
            )
        }
    }

    private var hasRelevantData: Bool {
        switch kind {
        case .name, .timeLocation:
            return entry.displayedCourse != nil
        case .progress:
            return entry.currentCourse != nil
        case .today:
            return !entry.todayCourses.isEmpty
        case .week:
            return !entry.thisWeekCourses.isEmpty
        }
    }

    private var accentColor: Color {
        hasRelevantData
            ? focusedAccentColor(entry: entry, kind: kind)
            : .secondary
    }

    private var timeLocationText: String {
        guard let course = entry.displayedCourse else {
            return watchLocalizedString("暂无课程")
        }
        return "\(ScheduleWidgetTextFormatter.clockText(course.startAt)) · \(ScheduleWidgetTextFormatter.location(for: course))"
    }

    private var progressText: String {
        guard let course = entry.currentCourse else {
            return watchLocalizedString("当前无课")
        }
        let remaining = Int(ceil(
            max(0, course.endAt.timeIntervalSince(entry.date)) / 60
        ))
        return String(
            format: watchLocalizedString("剩余 %d 分钟"),
            remaining
        )
    }
}

/// 圆形专用布局：中央只突出一个核心值，避免塞入完整课程卡片。
private struct FocusedCircularComplication: View {
    let entry: TraintimeScheduleWidgetEntry
    let kind: FocusedScheduleWidgetKind

    var body: some View {
        switch kind {
        case .name:
            circularName
        case .timeLocation:
            circularTimeLocation
        case .progress:
            circularProgress
        case .today:
            circularCount(
                count: entry.todayCourses.count,
                kind: .today,
                color: focusedAccentColor(entry: entry, kind: .today)
            )
        case .week:
            circularCount(
                count: entry.thisWeekCourses.count,
                kind: .week,
                color: focusedAccentColor(entry: entry, kind: .week)
            )
        }
    }

    private var circularName: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let course = entry.displayedCourse {
                VStack(spacing: -1) {
                    ScheduleWidgetIcon(
                        kind: .course,
                        color: course.color,
                        size: 8
                    )
                    Text(course.name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.55)
                }
                .padding(4)
            } else {
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 14
                )
            }
        }
        .widgetAccentable()
    }

    private var circularTimeLocation: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let course = entry.displayedCourse {
                VStack(spacing: -1) {
                    ScheduleWidgetIcon(
                        kind: .timeLocation,
                        color: course.color,
                        size: 7
                    )
                    Text(ScheduleWidgetTextFormatter.clockText(course.startAt))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text(ScheduleWidgetTextFormatter.location(for: course))
                        .font(.system(size: 7.5, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
            } else {
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 14
                )
            }
        }
        .widgetAccentable()
    }

    private var circularProgress: some View {
        Group {
            if let course = entry.currentCourse {
                Gauge(
                    value: ScheduleWidgetTextFormatter.progress(
                        for: course,
                        at: entry.date
                    ),
                    in: 0...1
                ) {
                    EmptyView()
                } currentValueLabel: {
                    VStack(spacing: -1) {
                        ScheduleWidgetIcon(
                            kind: .progress,
                            color: course.color,
                            size: 7
                        )
                        Text(verbatim: String(
                            ScheduleWidgetTextFormatter.remainingMinutes(
                                for: course,
                                at: entry.date
                            )
                        ))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        Text(verbatim: watchLocalizedString("分钟"))
                            .font(.system(size: 6.5, weight: .semibold))
                    }
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(course.color)
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 0) {
                        ScheduleWidgetIcon(
                            kind: .empty,
                            color: .secondary,
                            size: 11
                        )
                        Text(watchLocalizedString("当前无课"))
                            .font(.system(size: 7.5, weight: .semibold))
                    }
                }
            }
        }
        .widgetAccentable()
    }

    private func circularCount(
        count: Int,
        kind: ScheduleWidgetIconKind,
        color: Color
    ) -> some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -1) {
                ScheduleWidgetIcon(
                    kind: count > 0 ? kind : .empty,
                    color: count > 0 ? color : .secondary,
                    size: 8
                )
                Text(verbatim: "\(count)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
        }
        .widgetAccentable()
    }

}

/// 表角专用布局：中央和曲面标签共同服务同一领域，不交叉补充其他领域。
private struct FocusedCornerComplication: View {
    let entry: TraintimeScheduleWidgetEntry
    let kind: FocusedScheduleWidgetKind

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            centerContent
        }
        .widgetLabel { labelContent }
        .widgetAccentable()
    }

    @ViewBuilder
    private var centerContent: some View {
        switch kind {
        case .name:
            ScheduleWidgetIcon(
                kind: entry.displayedCourse != nil ? .course : .empty,
                color: entry.displayedCourse?.color ?? .secondary,
                size: 13
            )
        case .timeLocation:
            if let course = entry.displayedCourse {
                VStack(spacing: -1) {
                    ScheduleWidgetIcon(
                        kind: .timeLocation,
                        color: course.color,
                        size: 7
                    )
                    Text(ScheduleWidgetTextFormatter.clockText(course.startAt))
                        .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    Text(ScheduleWidgetTextFormatter.location(for: course))
                        .font(.system(size: 7.5, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            } else {
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 13
                )
            }
        case .progress:
            if let course = entry.currentCourse {
                VStack(spacing: -1) {
                    ScheduleWidgetIcon(
                        kind: .progress,
                        color: course.color,
                        size: 7
                    )
                    Text(verbatim: "\(progressPercent(for: course))%")
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                }
            } else {
                ScheduleWidgetIcon(
                    kind: .empty,
                    color: .secondary,
                    size: 13
                )
            }
        case .today:
            cornerCount(
                entry.todayCourses.count,
                kind: .today,
                color: focusedAccentColor(entry: entry, kind: .today)
            )
        case .week:
            cornerCount(
                entry.thisWeekCourses.count,
                kind: .week,
                color: focusedAccentColor(entry: entry, kind: .week)
            )
        }
    }

    private func cornerCount(
        _ count: Int,
        kind: ScheduleWidgetIconKind,
        color: Color
    ) -> some View {
        VStack(spacing: -1) {
            ScheduleWidgetIcon(
                kind: count > 0 ? kind : .empty,
                color: count > 0 ? color : .secondary,
                size: 7
            )
            Text(verbatim: "\(count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
    }

    @ViewBuilder
    private var labelContent: some View {
        switch kind {
        case .name:
            Text(
                entry.displayedCourse?.name
                    ?? watchLocalizedString("暂无课程")
            )
        case .timeLocation:
            if let course = entry.displayedCourse {
                Text("\(ScheduleWidgetTextFormatter.clockText(course.startAt)) · \(ScheduleWidgetTextFormatter.location(for: course))")
            } else {
                Text(watchLocalizedString("暂无课程"))
            }
        case .progress:
            if let course = entry.currentCourse {
                Text(
                    String(
                        format: watchLocalizedString("剩余 %d 分钟"),
                        ScheduleWidgetTextFormatter.remainingMinutes(
                            for: course,
                            at: entry.date
                        )
                    )
                )
            } else {
                Text(watchLocalizedString("当前无课"))
            }
        case .today:
            Text(watchLocalizedString("今日课程"))
        case .week:
            Text(watchLocalizedString("本周课程"))
        }
    }

    private func progressPercent(for course: WatchCourse) -> Int {
        Int((ScheduleWidgetTextFormatter.progress(
            for: course,
            at: entry.date
        ) * 100).rounded())
    }

}

/// 长方形专用布局拥有更多横向空间，但仍严格保持单一信息职责。
private struct FocusedRectangularComplication: View {
    let entry: TraintimeScheduleWidgetEntry
    let kind: FocusedScheduleWidgetKind

    var body: some View {
        switch kind {
        case .name:
            nameContent
        case .timeLocation:
            timeLocationContent
        case .progress:
            progressContent
        case .today:
            todayContent
        case .week:
            weekContent
        }
    }

    private var nameContent: some View {
        HStack(spacing: 6) {
            ScheduleWidgetIcon(
                kind: entry.displayedCourse != nil ? .course : .empty,
                color: entry.displayedCourse?.color ?? .secondary,
                size: 15
            )
            if let course = entry.displayedCourse {
                Text(course.name)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
            } else {
                emptyLabel
            }
        }
        .widgetAccentable()
    }

    private var timeLocationContent: some View {
        HStack(spacing: 6) {
            ScheduleWidgetIcon(
                kind: entry.displayedCourse != nil ? .timeLocation : .empty,
                color: entry.displayedCourse?.color ?? .secondary,
                size: 15
            )
            if let course = entry.displayedCourse {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(ScheduleWidgetTextFormatter.clockText(course.startAt))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Divider()
                    Text(ScheduleWidgetTextFormatter.location(for: course))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            } else {
                emptyLabel
            }
        }
        .widgetAccentable()
    }

    private var progressContent: some View {
        Group {
            if let course = entry.currentCourse {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        ScheduleWidgetIcon(
                            kind: .progress,
                            color: course.color,
                            size: 10
                        )
                        Text(watchLocalizedString("课程进度"))
                            .font(.system(size: 10, weight: .semibold))
                        Spacer(minLength: 2)
                        Text(
                            String(
                                format: watchLocalizedString("剩余 %d 分钟"),
                                ScheduleWidgetTextFormatter.remainingMinutes(
                                    for: course,
                                    at: entry.date
                                )
                            )
                        )
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                    }
                    ProgressView(
                        value: ScheduleWidgetTextFormatter.progress(
                            for: course,
                            at: entry.date
                        )
                    )
                        .tint(course.color)
                }
            } else {
                Label {
                    Text(watchLocalizedString("当前无课"))
                } icon: {
                    ScheduleWidgetIcon(
                        kind: .empty,
                        color: .secondary,
                        size: 13
                    )
                }
                .font(.system(size: 11, weight: .semibold))
            }
        }
    }

    private var todayContent: some View {
        HStack(spacing: 7) {
            VStack(spacing: -2) {
                ScheduleWidgetIcon(
                    kind: entry.todayCourses.isEmpty ? .empty : .today,
                    color: entry.todayCourses.isEmpty
                        ? .secondary
                        : focusedAccentColor(entry: entry, kind: .today),
                    size: 8
                )
                Text(verbatim: "\(entry.todayCourses.count)")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                Text(watchLocalizedString("今日课程"))
                    .font(.system(size: 7.5, weight: .semibold))
            }
            .widgetAccentable()

            Divider()

            TodayPeriodStrip(courses: entry.todayCourses)
        }
    }

    private var weekContent: some View {
        HStack(spacing: 6) {
            VStack(spacing: -2) {
                ScheduleWidgetIcon(
                    kind: entry.thisWeekCourses.isEmpty ? .empty : .week,
                    color: entry.thisWeekCourses.isEmpty
                        ? .secondary
                        : focusedAccentColor(entry: entry, kind: .week),
                    size: 8
                )
                Text(verbatim: "\(entry.thisWeekCourses.count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text(watchLocalizedString("本周课程"))
                    .font(.system(size: 7.5, weight: .semibold))
            }
            .widgetAccentable()

            WeekDotMatrix(
                courses: entry.thisWeekCourses,
                referenceDate: entry.date
            )
        }
    }

    private var emptyLabel: some View {
        Text(watchLocalizedString("暂无课程"))
            .font(.system(size: 11, weight: .semibold))
    }

}

/// 今日课表专用的 5 段节次占用条，只表达“哪一段有课”，不重复课程文字。
private struct TodayPeriodStrip: View {
    let courses: [WatchCourse]

    private static let ranges = [
        1...2,
        3...4,
        5...6,
        7...8,
        9...10,
    ]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Self.ranges.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: Self.ranges[index]))
            }
        }
        .accessibilityLabel(watchLocalizedString("今日节次分布"))
    }

    private func color(for range: ClosedRange<Int>) -> Color {
        courses.first {
            $0.startPeriod <= range.upperBound
                && $0.endPeriod >= range.lowerBound
        }?.color ?? Color.secondary.opacity(0.22)
    }
}

/// 专用组件共用注册逻辑的轻量包装。
private struct FocusedScheduleWidgetConfiguration {
    let kind: String
    let focus: FocusedScheduleWidgetKind
    let name: LocalizedStringKey
    let summary: LocalizedStringKey

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TraintimeScheduleWidgetProvider()
        ) { entry in
            FocusedScheduleWidgetView(entry: entry, kind: focus)
                .environment(\.locale, WatchWidgetShared.preferredLocale)
        }
        .configurationDisplayName(name)
        .description(summary)
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
        ])
    }
}

struct TraintimeCourseNameWidget: Widget {
    var body: some WidgetConfiguration {
        FocusedScheduleWidgetConfiguration(
            kind: WatchWidgetShared.courseNameWidgetKind,
            focus: .name,
            name: "课程名称",
            summary: "只显示当前或下一节课程的名称。"
        ).body
    }
}

/// 时间与地点需要共同回答“何时、去哪”这一件事，因此合并为一个专用组件。
/// 所有 family 都只展示课程开始时间，避免当前课程切换为结束时间造成语义变化。
struct TraintimeCourseTimeLocationWidget: Widget {
    var body: some WidgetConfiguration {
        FocusedScheduleWidgetConfiguration(
            kind: WatchWidgetShared.courseTimeLocationWidgetKind,
            focus: .timeLocation,
            name: "时间地点",
            summary: "显示当前或下一节课程的开始时间与地点。"
        ).body
    }
}

struct TraintimeCourseProgressWidget: Widget {
    var body: some WidgetConfiguration {
        FocusedScheduleWidgetConfiguration(
            kind: WatchWidgetShared.courseProgressWidgetKind,
            focus: .progress,
            name: "课程进度",
            summary: "只显示正在进行课程的进度和剩余时间。"
        ).body
    }
}

struct TraintimeTodayScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        FocusedScheduleWidgetConfiguration(
            kind: WatchWidgetShared.todayScheduleWidgetKind,
            focus: .today,
            name: "今日课表",
            summary: "只显示今日课程数量与节次占用。"
        ).body
    }
}

struct TraintimeWeekDistributionWidget: Widget {
    var body: some WidgetConfiguration {
        FocusedScheduleWidgetConfiguration(
            kind: WatchWidgetShared.weekDistributionWidgetKind,
            focus: .week,
            name: "本周分布",
            summary: "查看本周课程数量与节次分布。"
        ).body
    }
}
