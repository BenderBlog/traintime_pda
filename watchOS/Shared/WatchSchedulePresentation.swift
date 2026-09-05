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
                semesterEnd = Date(timeIntervalSince1970: Double(endEpoch) / 1_000)
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
            if $0.startAt != $1.startAt { return $0.startAt < $1.startAt }
            if $0.endAt != $1.endAt { return $0.endAt < $1.endAt }
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
    case todayFree, todayFinished, upcoming, imminent, ongoing, finishing
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
                state = candidate.endAt.timeIntervalSince(date) < 60 ? .finishing : .ongoing
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
        var result = Calendar(identifier: .gregorian)
        result.firstWeekday = 2
        result.minimumDaysInFirstWeek = 4
        result.timeZone = offsetMinutes.flatMap { TimeZone(secondsFromGMT: $0 * 60) } ?? .current
        return result
    }

    var isCurrent: Bool { focus.map { $0.startAt <= date && date < $0.endAt } ?? false }
    var usesCountdown: Bool { isCurrent || state == .imminent }
    var isAboutToStart: Bool {
        state == .imminent && (focus?.startAt.timeIntervalSince(date) ?? 60) < 60
    }
    var timeLabel: String {
        if state == .finishing { return watchLocalizedString("即将下课") }
        if isAboutToStart { return watchLocalizedString("即将上课") }
        return watchLocalizedString(isCurrent ? "距下课" : (usesCountdown ? "距上课" : "上课"))
    }
    var timeTarget: Date? { isCurrent ? focus?.endAt : focus?.startAt }
    var progressInterval: ClosedRange<Date>? {
        guard let focus else { return nil }
        if isCurrent { return focus.startAt...focus.endAt }
        if state == .imminent { return focus.startAt.addingTimeInterval(-15 * 60)...focus.startAt }
        return nil
    }
    var title: String {
        if isPreview { return watchLocalizedString("预览下一节") }
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
        case .finishing: return watchLocalizedString("即将下课")
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
        let formatter = DateFormatter()
        formatter.locale = WatchWidgetShared.preferredLocale
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: target)
    }
    var location: String {
        let value = focus?.classroom?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? watchLocalizedString("地点待定") : value
    }
    var summaryDate: Date {
        if let focus, !calendar.isDate(focus.startAt, inSameDayAs: date), current == nil {
            return focus.startAt
        }
        return date
    }
    var summaryCourses: [WatchCourse] {
        (resolved?.snapshot.courses ?? []).filter {
            calendar.isDate($0.startAt, inSameDayAs: summaryDate)
        }
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
                course.startAt.addingTimeInterval(-900),
                course.startAt.addingTimeInterval(-60 + 0.001), course.startAt,
                course.endAt.addingTimeInterval(-60 + 0.001), course.endAt,
            ])
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
