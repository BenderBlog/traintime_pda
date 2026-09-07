// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

/// 每段数据保留自己的有效期；局部刷新不能把旧学期的其他日期续期。
struct WatchScheduleCoverage {
    let start: Date
    let end: Date
    let validThrough: Date
}

struct WatchResolvedSchedule {
    let snapshot: WatchScheduleSnapshot
    let coverage: [WatchScheduleCoverage]
    let semesterEnd: Date?
    let scope: WatchScheduleScope

    func covers(_ start: Date, through end: Date, at now: Date) -> Bool {
        var cursor = start
        for range in coverage.sorted(by: { $0.start < $1.start })
        where range.validThrough >= now && range.end > cursor {
            if range.start > cursor { return false }
            cursor = max(cursor, range.end)
            if cursor >= end { return true }
        }
        return false
    }
}

enum WatchScheduleResolver {
    /// 同一学期按生成时间覆盖明确范围；同一版本的完整快照最后安装。
    /// 空数组也具有删除语义，不能因为非空旧缓存而忽略。
    static func resolve(
        _ caches: [WatchScheduleScope: WatchScheduleSnapshot]
    ) -> WatchResolvedSchedule? {
        let ordered = caches.sorted {
            if $0.value.freshnessStamp != $1.value.freshnessStamp {
                return $0.value.freshnessStamp < $1.value.freshnessStamp
            }
            return rank($0.key) < rank($1.key)
        }
        guard let newest = ordered.last else { return nil }
        let sameTerm = ordered.filter {
            $0.value.semesterStartEpochMs == newest.value.semesterStartEpochMs
        }
        var courses: [String: WatchCourse] = [:]
        var coverage: [WatchScheduleCoverage] = []
        var semesterEnd: Date?
        var scope = newest.key
        for (incomingScope, incoming) in sameTerm {
            let start = incoming.rangeStart
            let end = incoming.rangeEnd
            if let endEpoch = incoming.semesterEndEpochMs {
                semesterEnd = WatchScheduleDate.date(fromEpochMilliseconds: endEpoch)
            }
            guard end > start else { continue }
            if incomingScope == .semester {
                courses.removeAll()
                coverage.removeAll()
                semesterEnd = end
                scope = .semester
            }
            courses = courses.filter {
                $0.value.startAt < start || $0.value.startAt >= end
            }
            for course in incoming.courses
            where course.endAt > course.startAt && course.startAt >= start && course.startAt < end {
                courses[course.id] = course
            }
            coverage = coverage.flatMap { range -> [WatchScheduleCoverage] in
                guard range.start < end && range.end > start else { return [range] }
                var pieces: [WatchScheduleCoverage] = []
                if range.start < start {
                    pieces.append(
                        .init(start: range.start, end: start, validThrough: range.validThrough))
                }
                if range.end > end {
                    pieces.append(
                        .init(start: end, end: range.end, validThrough: range.validThrough))
                }
                return pieces
            }
            coverage.append(.init(start: start, end: end, validThrough: incoming.validThrough))
        }
        let metadata = newest.value
        let snapshot = WatchScheduleSnapshot(
            schemaVersion: metadata.schemaVersion,
            generatedAtEpochMs: metadata.generatedAtEpochMs,
            semesterStartEpochMs: metadata.semesterStartEpochMs,
            currentWeekIndex: metadata.currentWeekIndex,
            validThroughEpochMs: Int64(
                (coverage.map(\.validThrough).max() ?? metadata.validThrough).timeIntervalSince1970
                    * 1_000),
            rangeStartEpochMs: Int64(
                (coverage.map(\.start).min() ?? metadata.rangeStart).timeIntervalSince1970 * 1_000),
            rangeEndEpochMs: Int64(
                (coverage.map(\.end).max() ?? metadata.rangeEnd).timeIntervalSince1970 * 1_000),
            timeZoneOffsetMinutes: metadata.timeZoneOffsetMinutes,
            reminderMinutes: metadata.reminderMinutes,
            courses: sorted(Array(courses.values)),
            semesterEndEpochMs: semesterEnd.map { Int64($0.timeIntervalSince1970 * 1_000) },
            sourceRevision: metadata.sourceRevision
        )
        return .init(snapshot: snapshot, coverage: coverage, semesterEnd: semesterEnd, scope: scope)
    }

    static func sorted(_ courses: [WatchCourse]) -> [WatchCourse] {
        courses.sorted {
            if $0.startAtEpochMs != $1.startAtEpochMs { return $0.startAtEpochMs < $1.startAtEpochMs }
            if $0.endAtEpochMs != $1.endAtEpochMs { return $0.endAtEpochMs < $1.endAtEpochMs }
            return $0.id < $1.id
        }
    }

    private static func rank(_ scope: WatchScheduleScope) -> Int {
        switch scope {
        case .today: 0
        case .fourteenDays: 1
        case .semester: 2
        }
    }
}

enum WatchScheduleState: Equatable {
    case noData, signedOut, expired, unconfirmed
    case semesterUpcoming, semesterEnded, noMoreCourses
    case todayFree, todayFinished, upcoming, imminent, ongoing
}

/// 所有组件共享的课程选择。仅综合组件的临时预览允许替换 focus。
struct WatchSchedulePresentation {
    let date: Date
    let resolved: WatchResolvedSchedule?
    let calendar: Calendar
    let current: WatchCourse?
    let next: WatchCourse?
    let focus: WatchCourse?
    let state: WatchScheduleState
    let isPreview: Bool
    let todayCourses: [WatchCourse]

    init(
        resolved: WatchResolvedSchedule?, at date: Date, signedOut: Bool = false,
        preview: Bool = false
    ) {
        self.date = date
        self.resolved = resolved
        let calendar = Self.calendar(offsetMinutes: resolved?.snapshot.timeZoneOffsetMinutes)
        self.calendar = calendar
        let courses = resolved?.snapshot.courses ?? []
        current = courses.first { $0.startAt <= date && date < $0.endAt }
        next = courses.first { $0.startAt > date }
        isPreview = preview && current != nil && next != nil
        let candidate = isPreview ? next : (current ?? next)
        todayCourses = courses.filter { calendar.isDate($0.startAt, inSameDayAs: date) }

        guard let resolved else {
            focus = nil
            state = signedOut ? .signedOut : .noData
            return
        }
        if let end = resolved.semesterEnd, date >= end {
            focus = nil
            state = .semesterEnded
        } else if date > resolved.snapshot.validThrough {
            focus = nil
            state = .expired
        } else if let start = resolved.snapshot.semesterStart, date < start {
            focus = candidate
            state = .semesterUpcoming
        } else if !resolved.covers(
            date, through: candidate?.startAt.addingTimeInterval(1) ?? date.addingTimeInterval(1),
            at: date)
        {
            focus = nil
            state = .unconfirmed
        } else if let candidate {
            focus = candidate
            if candidate.startAt <= date {
                state = .ongoing
            } else if candidate.startAt.timeIntervalSince(date) <= 15 * 60 {
                state = .imminent
            } else if !calendar.isDate(candidate.startAt, inSameDayAs: date) {
                state = todayCourses.isEmpty ? .todayFree : .todayFinished
            } else {
                state = .upcoming
            }
        } else {
            focus = nil
            if let end = resolved.semesterEnd, resolved.covers(date, through: end, at: date) {
                state = .noMoreCourses
            } else if let end = calendar.date(
                byAdding: .day, value: 1, to: calendar.startOfDay(for: date)),
                resolved.covers(date, through: end, at: date)
            {
                state = todayCourses.isEmpty ? .todayFree : .todayFinished
            } else {
                state = .unconfirmed
            }
        }
    }

    static func calendar(offsetMinutes: Int?) -> Calendar {
        WatchScheduleDate.calendar(offsetMinutes: offsetMinutes)
    }

    var isCurrent: Bool { focus.map { $0.startAt <= date && date < $0.endAt } ?? false }
    var startTimeText: String? { focus.map { clockText($0.startAt) } }
    var endTimeText: String? {
        guard let focus else { return nil }
        let day = calendar.isDate(focus.startAt, inSameDayAs: focus.endAt)
            ? "" : dayLabel(for: focus.endAt) + " "
        return day + clockText(focus.endAt)
    }
    var timeRangeText: String? {
        guard let startTimeText, let endTimeText else { return nil }
        return startTimeText + "–" + endTimeText
    }
    /// 小尺寸只显示当前需要关注的一个时刻，日期由外围布局单独标注。
    var compactTime: (label: String, value: String)? {
        guard let focus else { return nil }
        return (
            watchLocalizedString(isCurrent ? "下课" : "上课"),
            clockText(isCurrent ? focus.endAt : focus.startAt)
        )
    }
    /// 只有焦点课程正在进行时才显示进度；预览下一节不会沿用当前课程的进度。
    var courseProgress: Double? {
        guard isCurrent, let focus else { return nil }
        let duration = focus.endAt.timeIntervalSince(focus.startAt)
        let elapsed = date.timeIntervalSince(focus.startAt)
        guard duration.isFinite, duration > 0, elapsed.isFinite else { return nil }
        return min(1, max(0, elapsed / duration))
    }
    var title: String {
        if isPreview { return watchLocalizedString("下一节") }
        switch state {
        case .noData: return watchLocalizedString("请先同步课表")
        case .signedOut: return watchLocalizedString("请在手机登录")
        case .expired: return watchLocalizedString("课表待更新")
        case .unconfirmed: return watchLocalizedString("后续课表待同步")
        case .semesterUpcoming: return watchLocalizedString("学期尚未开始")
        case .semesterEnded: return watchLocalizedString("本学期结束，开心玩耍吧！")
        case .noMoreCourses: return watchLocalizedString("本学期后续无课")
        case .todayFree: return watchLocalizedString("今日无课")
        case .todayFinished: return watchLocalizedString("今日已下课")
        case .upcoming: return watchLocalizedString("下一节")
        case .imminent: return watchLocalizedString("即将上课")
        case .ongoing: return watchLocalizedString("正在上课")
        }
    }
    var compactTitle: String {
        state == .semesterEnded ? watchLocalizedString("学期结束啦") : title
    }
    var emptySymbol: String {
        switch state {
        case .noData, .unconfirmed, .expired: "arrow.triangle.2.circlepath"
        case .signedOut: "person.crop.circle.badge.exclamationmark"
        default: "cup.and.saucer.fill"
        }
    }
    func dayLabel(for target: Date) -> String {
        let days =
            calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: target)
            ).day ?? 0
        if days == 0 { return watchLocalizedString("今日") }
        if days == 1 { return watchLocalizedString("明日") }
        if days == 2 { return watchLocalizedString("后天") }
        let formatter = DateFormatter()
        formatter.locale = WatchWidgetShared.preferredLocale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate("MdEEE")
        return formatter.string(from: target)
    }
    func clockText(_ target: Date) -> String {
        WatchScheduleDate.clockText(target, timeZone: calendar.timeZone)
    }
    /// 小组件的紧凑日期：今天省略、明天直写，其余固定为月/日。
    func compactDayLabel(for target: Date) -> String {
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: target)
        ).day ?? 0
        if days == 0 { return "" }
        if days == 1 { return watchLocalizedString("明天") }
        let formatter = DateFormatter()
        formatter.locale = WatchWidgetShared.preferredLocale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "M/d"
        return formatter.string(from: target)
    }
    func compactDateTimeText(for target: Date) -> String {
        let day = compactDayLabel(for: target)
        let time = clockText(target)
        if day.isEmpty { return time }
        if day == watchLocalizedString("明天") {
            return watchLocalizedFormat("明天%@", time)
        }
        return day + " " + time
    }
    var location: String {
        focus?.classroomText ?? watchLocalizedString("地点待定")
    }
    /// 小尺寸组件省略信远楼名，保留原有分区编号和教室号。
    var compactLocation: String {
        WatchScheduleText.compactLocation(location)
    }
    /// 长方形与 App 课程卡片一致：位置后补充教师，考试则补充座位等备注。
    var locationSummary: String {
        focus?.locationSummary(includingDetails: true, fallbackLocation: location)?.text ?? location
    }
    /// 日程概览始终汇总今天；下一次安排只作为次要信息展示。
    var summaryDate: Date { date }
    var summaryCourses: [WatchCourse] {
        todayCourses
    }
    var weekInterval: DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: summaryDate)!
    }
    var weekCourses: [WatchCourse] {
        (resolved?.snapshot.courses ?? []).filter {
            $0.startAt >= weekInterval.start && $0.startAt < weekInterval.end
        }
    }
    var summaryIsComplete: Bool {
        let start = calendar.startOfDay(for: summaryDate)
        return resolved?.covers(
            start, through: calendar.date(byAdding: .day, value: 1, to: start)!, at: date) ?? false
    }
    var weekIsComplete: Bool {
        resolved?.covers(weekInterval.start, through: weekInterval.end, at: date) ?? false
    }

    static func timelineDates(
        resolved: WatchResolvedSchedule?, now: Date, previewExpiry: Date? = nil
    ) -> [Date] {
        let calendar = calendar(offsetMinutes: resolved?.snapshot.timeZoneOffsetMinutes)
        let horizon = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: now))!
        var dates: Set<Date> = [now, horizon]
        for course in resolved?.snapshot.courses ?? [] {
            dates.formUnion([
                course.startAt.addingTimeInterval(-900), course.startAt, course.endAt,
            ])
            // 使用有限数值绘制进度条，避免系统 timerInterval 布局在表盘渲染中
            // 产生 NaN 坐标。仅在上课期间每五分钟更新，起止时刻仍精确切换。
            let start = max(now, course.startAt)
            let end = min(horizon, course.endAt)
            guard start < end else { continue }
            var progressDate = course.startAt.addingTimeInterval(
                (floor(start.timeIntervalSince(course.startAt) / 300) + 1) * 300)
            while progressDate < end {
                dates.insert(progressDate)
                progressDate = progressDate.addingTimeInterval(300)
            }
        }
        for offset in 1...2 {
            dates.insert(
                calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now))!)
        }
        for range in resolved?.coverage ?? [] {
            dates.formUnion([range.start, range.end, range.validThrough.addingTimeInterval(1)])
        }
        if let end = resolved?.semesterEnd { dates.insert(end) }
        if let previewExpiry { dates.insert(previewExpiry) }
        return dates.filter { $0 >= now && $0 <= horizon }.sorted()
    }
}

/// 概览只保留当前与下一项的详情，其余安排以可靠的日/周统计呈现。
struct WatchOverviewSummary {
    struct Counts {
        let courses: Int
        let exams: Int
        let experiments: Int
        var total: Int { courses + exams + experiments }

        init(_ items: [WatchCourse]) {
            var examCount = 0
            var experimentCount = 0
            for item in items {
                if item.isExam { examCount += 1 }
                else if item.isExperiment { experimentCount += 1 }
            }
            exams = examCount
            experiments = experimentCount
            courses = items.count - exams - experiments
        }
    }

    struct Day {
        let all: Counts
        let remaining: Counts
        let completedCount: Int
        /// 只有末项时间未出现在两张卡片中时，才在摘要里补充今日结束时间。
        let additionalEndTime: Date?
    }

    struct Week {
        let remainingDays: Int
        let upcoming: Counts
    }

    let current: WatchCourse?
    let next: WatchCourse?
    let today: Day?
    let week: Week?

    init(_ presentation: WatchSchedulePresentation) {
        let usable = ![.noData, .signedOut, .expired, .semesterEnded].contains(presentation.state)
        let current = usable && presentation.isCurrent ? presentation.focus : nil
        let next = presentation.next.flatMap { candidate -> WatchCourse? in
            guard usable else { return nil }
            // 正在上课时也需要确认中间覆盖完整，不能把旧缓存中的某节课
            // 当成下一节。当前无课时复用共享状态已选中的焦点课程。
            guard presentation.focus?.id == candidate.id
                || presentation.resolved?.covers(
                    presentation.date, through: candidate.startAt.addingTimeInterval(1),
                    at: presentation.date) == true
            else { return nil }
            return candidate
        }
        self.current = current
        self.next = next

        if usable && presentation.summaryIsComplete {
            let all = presentation.summaryCourses
            let remaining = all.filter { $0.endAt > presentation.date }
            let lastEnd = remaining.map(\.endAt).max()
            let displayedEnds = [current?.endAt, next?.endAt].compactMap { $0 }
            today = Day(
                all: Counts(all), remaining: Counts(remaining),
                completedCount: all.count - remaining.count,
                additionalEndTime: lastEnd.flatMap { displayedEnds.contains($0) ? nil : $0 })
        } else {
            today = nil
        }

        // 本周这里只展示未来安排；已过去的日期未同步，不影响这部分统计。
        if usable && presentation.resolved?.covers(
            presentation.date, through: presentation.weekInterval.end, at: presentation.date) == true
        {
            let remaining = presentation.weekCourses.filter { $0.endAt > presentation.date }
            week = Week(
                remainingDays: Set(remaining.map {
                    presentation.calendar.startOfDay(for: $0.startAt)
                }).count,
                upcoming: Counts(remaining.filter { $0.startAt > presentation.date }))
        } else {
            week = nil
        }
    }
}

/// 无正文的语言消息不参与课表排序；旧版课表只允许在首次迁移前安装。
enum WatchScheduleStateOrder {
    static func accepts(
        revision: Int?, generation: String?, installedRevision: Int,
        installedGeneration: String?, carriesSchedule: Bool
    ) -> Bool {
        guard carriesSchedule else { return true }
        guard let revision else { return installedRevision == 0 }
        guard revision >= installedRevision else { return false }
        if let installedGeneration {
            guard let generation else { return false }
            if revision == installedRevision && generation != installedGeneration { return false }
        }
        return true
    }
}
