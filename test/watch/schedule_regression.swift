// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

@main
struct ScheduleRegression {
    static var assertions = 0
    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        assertions += 1
        guard condition() else { fatalError(message) }
    }
    static func date(_ day: Int = 7, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0) -> Date
    {
        WatchSchedulePresentation.calendar(offsetMinutes: 480).date(
            from: DateComponents(
                year: 2026, month: 9, day: day, hour: hour, minute: minute, second: second))!
    }
    static func ms(_ value: Date) -> Int64 { Int64(value.timeIntervalSince1970 * 1000) }
    static func course(_ id: String, start: Date, end: Date, place: String = "B-302") -> WatchCourse
    {
        .init(
            id: id, name: id, teacher: nil, classroom: place, startAtEpochMs: ms(start),
            endAtEpochMs: ms(end),
            startSection: 1, endSection: 2, colorARGB: -1, kind: "course", note: nil)
    }
    static func snapshot(
        _ courses: [WatchCourse], generated: Date = date(6), start: Date = date(7),
        end: Date = date(28), valid: Date = date(28), term: Date = date(7)
    ) -> WatchScheduleSnapshot {
        .init(
            schemaVersion: 4, generatedAtEpochMs: ms(generated), semesterStartEpochMs: ms(term),
            currentWeekIndex: 0,
            validThroughEpochMs: ms(valid), rangeStartEpochMs: ms(start), rangeEndEpochMs: ms(end),
            timeZoneOffsetMinutes: 480, reminderMinutes: 5, courses: courses)
    }
    static func main() throws {
        let first = course("A", start: date(7, 8, 30), end: date(7, 10, 5))
        let second = course("B", start: date(7, 14), end: date(7, 15, 35), place: "C-101")
        let tomorrow = course("C", start: date(8, 8, 30), end: date(8, 10, 5))
        let full = WatchScheduleResolver.resolve([.semester: snapshot([tomorrow, second, first])])!
        func state(_ time: Date, preview: Bool = false) -> WatchSchedulePresentation {
            .init(resolved: full, at: time, preview: preview)
        }
        check(state(date(7, 7)).state == .upcoming, "No first-class waiting tier")
        check(!state(date(7, 7, 30)).usesCountdown, "No 60-minute tier")
        check(state(date(7, 8, 14, 59)).state == .upcoming, "15-minute lower boundary")
        check(state(date(7, 8, 15)).timeLabel == "距上课", "Exactly 15 minutes begins countdown")
        check(state(date(7, 8, 29)).timeLabel == "距上课", "Exactly one minute is still countdown")
        check(state(date(7, 8, 29, 1)).timeLabel == "即将上课", "Less than a minute before class")
        check(state(date(7, 8, 30)).timeLabel == "距下课", "At start select current course")
        check(state(date(7, 10, 4)).state == .ongoing, "Exactly one minute until dismissal")
        check(state(date(7, 10, 4, 1)).timeLabel == "即将下课", "Less than a minute until dismissal")
        check(state(date(7, 10, 5)).focus?.id == "B", "End is an exclusive boundary")
        check(
            state(date(7, 10, 5)).clockText(second.startAt) == "14:00",
            "Gap displays next start time")
        check(state(date(7, 9)).focus?.id == "A", "Split widgets keep current course")
        check(state(date(7, 9), preview: true).focus?.id == "B", "Integrated preview selects next")
        check(state(date(7, 9), preview: true).title == "预览下一节", "Preview explicitly labeled")
        check(state(date(7, 16)).state == .todayFinished, "Switch after actual final class")
        check(state(date(7, 16)).dayLabel(for: tomorrow.startAt) == "明日", "Tomorrow is labeled")
        check(state(date(7, 16)).summaryDate == tomorrow.startAt, "Overview follows next day")
        check(state(date(28)).title == "本学期结束，开心玩耍吧！", "Semester ending text")
        check(state(date(9)).state == .noMoreCourses, "No more courses differs from semester end")
        check(state(date(6)).state == .semesterUpcoming, "Term not started")
        let late = course("Late", start: date(7, 19), end: date(7, 20, 35))
        let lateResolved = WatchScheduleResolver.resolve([.semester: snapshot([late, tomorrow])])!
        check(
            WatchSchedulePresentation(resolved: lateResolved, at: date(7, 20)).isCurrent,
            "20:00 does not override class")
        check(
            WatchSchedulePresentation(resolved: lateResolved, at: date(7, 20, 35)).state
                == .todayFinished, "20:35 is actual switch")
        let friday = course("Friday", start: date(11, 9), end: date(11, 10))
        let sunday = course("Sunday", start: date(13, 9), end: date(13, 10))
        let monday = course("Monday", start: date(14, 9), end: date(14, 10))
        let week = WatchScheduleResolver.resolve([.semester: snapshot([friday, sunday, monday])])!
        let onSunday = WatchSchedulePresentation(resolved: week, at: date(13, 8))
        check(
            onSunday.weekCourses.map(\.id) == ["Friday", "Sunday"],
            "Sunday belongs to Monday-start school week")
        check(onSunday.weekInterval.start == date(7), "Week matrix starts on Monday")
        check(
            onSunday.clockText(date(13, 9)) == "09:00",
            "School timezone preserved independently of host timezone")

        let changed = course("A", start: date(7, 8, 30), end: date(7, 10, 5), place: "D-404")
        let today = snapshot([changed], generated: date(7, 7), end: date(8), valid: date(8))
        let merged = WatchScheduleResolver.resolve([.semester: full.snapshot, .today: today])!
        check(
            merged.snapshot.courses.map(\.id) == ["A", "C"],
            "New today data removes canceled B and retains other dates")
        check(
            merged.snapshot.courses.first?.classroom == "D-404",
            "New location replaces old semester location")
        let empty = snapshot([], generated: date(7, 7), end: date(8), valid: date(8))
        check(
            WatchScheduleResolver.resolve([.semester: full.snapshot, .today: empty])!.snapshot
                .courses.map(\.id) == ["C"], "Empty range deletes old courses")
        var clockAdjusted = today
        clockAdjusted.sourceRevision = ms(date(9))
        var olderRevision = full.snapshot
        olderRevision.sourceRevision = ms(date(8))
        let monotonic = WatchScheduleResolver.resolve([
            .semester: olderRevision, .today: clockAdjusted,
        ])!
        check(
            monotonic.snapshot.courses.first?.classroom == "D-404",
            "State revision takes priority over adjusted generation clock")
        let refreshedSemester = snapshot([], generated: date(7, 8))
        check(
            WatchScheduleResolver.resolve([.semester: refreshedSemester, .today: today])!.snapshot
                .courses.isEmpty, "Newest full semester is authoritative")
        let newTerm = snapshot([], generated: date(8), start: date(14), term: date(14))
        check(
            WatchScheduleResolver.resolve([.semester: full.snapshot, .today: newTerm])!.snapshot
                .courses.isEmpty, "New semester cannot inherit old semester")
        let partial = WatchScheduleResolver.resolve([.today: empty])!
        check(
            WatchSchedulePresentation(resolved: partial, at: date(7, 12)).state == .todayFree,
            "Known empty today")
        check(
            !WatchSchedulePresentation(resolved: partial, at: date(7, 12)).weekIsComplete,
            "Partial cache cannot report complete week")
        check(
            WatchSchedulePresentation(resolved: partial, at: date(8, 12)).state == .expired,
            "Expired cache is explicit")
        check(
            WatchSchedulePresentation(resolved: nil, at: date(7)).state == .noData,
            "Missing data differs from no courses")
        check(
            WatchSchedulePresentation(resolved: nil, at: date(7), signedOut: true).state
                == .signedOut, "Signed-out state")
        let gap = WatchScheduleResolver.resolve([
            .today: empty,
            .fourteenDays: snapshot(
                [tomorrow], generated: date(7, 8), start: date(9), end: date(10)),
        ])!
        check(
            !gap.covers(date(7), through: date(10), at: date(7, 12)),
            "Coverage gaps are not invented")
        let staleBase = snapshot([first, tomorrow], valid: date(7))
        let refreshedToday = WatchScheduleResolver.resolve([.semester: staleBase, .today: today])!
        check(
            !refreshedToday.covers(date(8), through: date(9), at: date(7, 12)),
            "Today refresh cannot extend freshness of rest of semester")
        check(
            refreshedToday.covers(date(7), through: date(8), at: date(7, 12)),
            "Today range remains fresh")
        let dates = WatchSchedulePresentation.timelineDates(
            resolved: full, now: date(7, 7), previewExpiry: date(7, 9, 5))
        check(dates.first == date(7, 7), "Timeline begins now")
        check(dates == Array(Set(dates)).sorted(), "Timeline sorted and deduplicated")
        check(dates.contains(date(7, 8, 15)), "Timeline includes 15-minute boundary")
        check(dates.contains(date(8)), "Timeline includes midnight")
        check(dates.contains(date(7, 9, 5)), "Preview timeout is scheduled")
        check(
            dates.contains(first.endAt.addingTimeInterval(-60 + 0.001)),
            "Timeline includes finishing label boundary")
        _ = first.color  // Signed ARGB values do not trap.

        check(
            !WatchScheduleStateOrder.accepts(
                revision: 4, generation: "old", installedRevision: 5, installedGeneration: "new",
                carriesSchedule: true), "Late replies cannot restore logged-out data")
        check(
            !WatchScheduleStateOrder.accepts(
                revision: nil, generation: nil, installedRevision: 5, installedGeneration: "new",
                carriesSchedule: true), "Legacy data cannot bypass new clear")
        check(
            !WatchScheduleStateOrder.accepts(
                revision: 5, generation: "old", installedRevision: 5, installedGeneration: "new",
                carriesSchedule: true), "Equal revision cannot change account")
        check(
            WatchScheduleStateOrder.accepts(
                revision: 6, generation: "newer", installedRevision: 5, installedGeneration: "new",
                carriesSchedule: true), "New account can install newer data")
        check(
            WatchScheduleStateOrder.accepts(
                revision: nil, generation: nil, installedRevision: 5, installedGeneration: "new",
                carriesSchedule: false), "Language-only messages remain compatible")
        check(
            WatchScheduleStateOrder.accepts(
                revision: nil, generation: nil, installedRevision: 0, installedGeneration: nil,
                carriesSchedule: true), "First legacy migration remains supported")
        let suite = "TraintimeWatchRegression.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        for scope in WatchScheduleScope.allCases {
            defaults.set("old", forKey: WatchWidgetShared.cacheKey(for: scope))
        }
        defaults.set("old", forKey: WatchPersistentCacheKey.installedSemesterVersion)
        defaults.set(true, forKey: WatchPersistentCacheKey.completedOnboarding)
        defaults.set("A", forKey: WatchWidgetShared.selectedCurrentCourseKey)
        WatchWidgetShared.clearSchedule(in: defaults)
        check(
            WatchScheduleScope.allCases.allSatisfy {
                defaults.object(forKey: WatchWidgetShared.cacheKey(for: $0)) == nil
            }, "Clear removes all stage caches")
        check(
            defaults.object(forKey: WatchPersistentCacheKey.installedSemesterVersion) == nil,
            "Clear removes installed version")
        check(
            defaults.object(forKey: WatchWidgetShared.selectedCurrentCourseKey) == nil,
            "Clear removes preview")
        check(
            defaults.bool(forKey: WatchPersistentCacheKey.completedOnboarding),
            "Clear preserves onboarding preference")
        print("Passed \(assertions) schedule/cache/order regression checks")
    }
}
