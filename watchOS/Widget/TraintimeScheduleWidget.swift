// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import AppIntents
import SwiftUI
import WidgetKit

/// 小组件的布局常量集中放在这里，避免在视图树中散落“魔法数字”。
///
/// 右侧点阵必须最多占组件宽度的四分之一；同时设置绝对上限，
/// 防止未来系统提供更宽的组件尺寸时，点阵被无意义地放大。
private enum ScheduleWidgetLayout {
    static let matrixWidthRatio: CGFloat = 0.25
    static let maximumMatrixWidth: CGFloat = 42
    static let columnSpacing: CGFloat = 5
    static let maximumTimelineEntryCount = 18
    static let fallbackReloadInterval: TimeInterval = 6 * 60 * 60
}

/// 时间线中的单个显示状态。
///
/// Provider 已经提前算好当前课程、下一节课程以及用户的切换选择，
/// 视图层只负责渲染，避免在 SwiftUI `body` 中读写缓存。
struct TraintimeScheduleWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WatchScheduleSnapshot?
    let currentCourse: WatchCourse?
    let nextCourse: WatchCourse?
    let displaysNextCourse: Bool

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
}

/// 当前课程与下一节课程的计算结果。
private struct WidgetCourseSelection {
    let current: WatchCourse?
    let next: WatchCourse?
}

/// 为 Smart Stack 提供占位内容、快照和正式时间线。
struct TraintimeScheduleWidgetProvider: TimelineProvider {
    /// 组件库预览使用的快速占位数据。
    func placeholder(in context: Context) -> TraintimeScheduleWidgetEntry {
        makeEntry(at: Date(), snapshot: nil)
    }

    /// 系统只需要一张静态快照时，从 App Group 读取当前最佳缓存。
    func getSnapshot(
        in context: Context,
        completion: @escaping (TraintimeScheduleWidgetEntry) -> Void
    ) {
        let now = Date()
        completion(
            makeEntry(
                at: now,
                snapshot: WatchWidgetShared.loadPreferredSnapshot(now: now)
            )
        )
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

        return TraintimeScheduleWidgetEntry(
            date: date,
            snapshot: snapshot,
            currentCourse: selection.current,
            nextCourse: selection.next,
            displaysNextCourse: shouldDisplayNextCourse(
                selection: selection
            )
        )
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
        WidgetCenter.shared.reloadTimelines(
            ofKind: WatchWidgetShared.widgetKind
        )
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

    /// 清理手机端可能传来的空白地点；空值使用明确的占位文字。
    static func location(for course: WatchCourse) -> String {
        let value = course.classroom?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? ""
        return value.isEmpty ? String(localized: "地点未定") : value
    }
}

/// Smart Stack 的矩形课程组件。
struct TraintimeScheduleWidgetView: View {
    let entry: TraintimeScheduleWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            widgetContent(in: proxy.size)
        }
        .containerBackground(for: .widget) {
            widgetBackground
        }
    }

    /// 将主信息区与右侧点阵按计算后的比例排版。
    private func widgetContent(in size: CGSize) -> some View {
        let matrixWidth = matrixWidth(for: size.width)
        let informationWidth = max(
            0,
            size.width
                - matrixWidth
                - ScheduleWidgetLayout.columnSpacing
        )

        return HStack(spacing: ScheduleWidgetLayout.columnSpacing) {
            courseInformation
                .frame(width: informationWidth, alignment: .leading)

            WeekDotMatrix(
                snapshot: entry.snapshot,
                referenceDate: entry.date
            )
            .frame(width: matrixWidth)
        }
    }

    /// 右侧点阵最多占总宽度 1/4，并受绝对宽度上限保护。
    private func matrixWidth(for totalWidth: CGFloat) -> CGFloat {
        min(
            totalWidth * ScheduleWidgetLayout.matrixWidthRatio,
            ScheduleWidgetLayout.maximumMatrixWidth
        )
    }

    /// 使用当前显示课程的颜色生成低对比度背景。
    private var widgetBackground: some View {
        Rectangle()
            .fill(
                (entry.displayedCourse?.color ?? Color.indigo)
                    .opacity(0.18)
                    .gradient
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
                toggleButton
            }
        }
    }

    /// 时间和地点保持在一行，空间不足时优先截断地点。
    private func courseMetadata(for course: WatchCourse) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "clock")
            Text(ScheduleWidgetTextFormatter.timeRange(for: course))
            Text("·")
            Image(systemName: "mappin.and.ellipse")
            Text(ScheduleWidgetTextFormatter.location(for: course))
                .lineLimit(1)
        }
        .font(.system(size: 8.5, weight: .medium))
        .foregroundStyle(.secondary)
    }

    /// 仅在当前课程与下一节课程同时存在时显示。
    private var toggleButton: some View {
        Button(
            intent: ToggleScheduleWidgetCourseIntent(
                currentCourseID: entry.currentCourse?.id ?? ""
            )
        ) {
            Image(systemName: toggleButtonSystemImage)
                .font(.system(size: 8, weight: .bold))
                .frame(width: 15, height: 15)
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
            Text("暂无课程")
                .font(.system(size: 11, weight: .semibold))
            Text("打开手表应用同步课表")
                .font(.system(size: 8.5))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    /// “当前/下一节”状态标题。
    private var statusTitle: String {
        guard entry.currentCourse != nil else {
            return String(localized: "下一节")
        }
        return entry.displaysNextCourse
            ? String(localized: "下一节")
            : String(localized: "当前")
    }
}

/// 点阵单元的几何参数。
private struct DotMatrixMetrics {
    let cellSize: CGFloat
    let horizontalGap: CGFloat
    let verticalGap: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat

    /// 返回指定行列的圆点矩形。
    func rect(row: Int, column: Int) -> CGRect {
        CGRect(
            x: xOffset
                + CGFloat(column) * (cellSize + horizontalGap),
            y: yOffset
                + CGFloat(row) * (cellSize + verticalGap),
            width: cellSize,
            height: cellSize
        )
    }
}

/// 右侧 5×7 周课程点阵。
///
/// 7 列对应周一到周日；5 行分别对应 1–2、3–4、5–6、7–8、
/// 9–10 节。某个范围内存在课程时使用课程颜色，否则显示灰色圆点。
private struct WeekDotMatrix: View {
    let snapshot: WatchScheduleSnapshot?
    let referenceDate: Date

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
                    drawDot(
                        context: &context,
                        rect: metrics.rect(row: row, column: column),
                        color: dotColor(row: row, weekday: column)
                    )
                }
            }
        }
        .accessibilityLabel("本周课程点阵")
    }

    /// 根据可用宽高计算自适应圆点尺寸与居中偏移。
    private func makeMetrics(for size: CGSize) -> DotMatrixMetrics {
        let horizontalGap = max(1.2, size.width * 0.035)
        let verticalGap = max(1.2, size.height * 0.045)
        let cellSize = max(
            0,
            min(
                (size.width - horizontalGap * 6) / 7,
                (size.height - verticalGap * 4) / 5
            )
        )
        let gridWidth = cellSize * 7 + horizontalGap * 6
        let gridHeight = cellSize * 5 + verticalGap * 4

        return DotMatrixMetrics(
            cellSize: cellSize,
            horizontalGap: horizontalGap,
            verticalGap: verticalGap,
            xOffset: max(0, (size.width - gridWidth) / 2),
            yOffset: max(0, (size.height - gridHeight) / 2)
        )
    }

    /// 绘制一个点阵圆点。
    private func drawDot(
        context: inout GraphicsContext,
        rect: CGRect,
        color: Color
    ) {
        context.fill(
            Path(ellipseIn: rect),
            with: .color(color)
        )
    }

    /// 课程存在时返回课程色，否则返回低对比度占位色。
    private func dotColor(row: Int, weekday: Int) -> Color {
        courseForDot(row: row, weekday: weekday)?.color
            ?? Color.secondary.opacity(0.22)
    }

    /// 查找覆盖指定点阵单元的第一条课程。
    private func courseForDot(
        row: Int,
        weekday: Int
    ) -> WatchCourse? {
        guard Self.rowRanges.indices.contains(row),
              let date = dateForWeekday(weekday)
        else {
            return nil
        }

        let periodRange = Self.rowRanges[row]
        return snapshot?.courses.first {
            Calendar.current.isDate($0.startAt, inSameDayAs: date)
                && rangesOverlap(
                    courseStart: $0.startPeriod,
                    courseEnd: $0.endPeriod,
                    target: periodRange
                )
        }
    }

    /// 将“周一为第 0 列”的索引转换成实际日期。
    private func dateForWeekday(_ weekday: Int) -> Date? {
        guard (0..<7).contains(weekday) else { return nil }
        return Calendar.current.date(
            byAdding: .day,
            value: weekday,
            to: mondayOfReferenceWeek()
        )
    }

    /// 计算参考日期所在周的周一零点，不依赖设备区域的首日设置。
    private func mondayOfReferenceWeek() -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: referenceDate)
        let systemWeekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (systemWeekday + 5) % 7
        return calendar.date(
            byAdding: .day,
            value: -daysSinceMonday,
            to: startOfDay
        ) ?? startOfDay
    }

    /// 判断课程节次与点阵的两节课范围是否相交。
    private func rangesOverlap(
        courseStart: Int,
        courseEnd: Int,
        target: ClosedRange<Int>
    ) -> Bool {
        courseStart <= target.upperBound
            && courseEnd >= target.lowerBound
    }
}

/// 注册可在 Apple Watch Smart Stack 中添加的组件。
struct TraintimeScheduleWidget: Widget {
    let kind = WatchWidgetShared.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TraintimeScheduleWidgetProvider()
        ) { entry in
            TraintimeScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("当前课程")
        .description("查看当前或下一节课程与本周课程分布。")
        .supportedFamilies([.accessoryRectangular])
    }
}
