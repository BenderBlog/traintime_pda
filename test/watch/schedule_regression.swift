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
    static func course(
        _ id: String, start: Date, end: Date, place: String = "B-302", kind: String = "course"
    ) -> WatchCourse
    {
        .init(
            id: id, name: id, teacher: nil, classroom: place, startAtEpochMs: ms(start),
            endAtEpochMs: ms(end),
            startSection: 1, endSection: 2, colorARGB: -1, kind: kind, note: nil)
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
    static func overviewRegressions() {
        let first = course("A", start: date(7, 8, 30), end: date(7, 10, 5))
        let exam = course("Exam", start: date(7, 11), end: date(7, 12), kind: "exam")
        let second = course("B", start: date(7, 14), end: date(7, 15, 35))
        let lab = course("Lab", start: date(7, 17), end: date(7, 18), kind: "physicsExperiment")
        let tomorrow = course("Tomorrow", start: date(8, 8, 30), end: date(8, 10, 5))
        let full = WatchScheduleResolver.resolve([
            .semester: snapshot([first, exam, second, lab, tomorrow])
        ])!
        func overview(_ time: Date) -> WatchOverviewSummary {
            WatchOverviewSummary(WatchSchedulePresentation(resolved: full, at: time))
        }
        let morning = overview(date(7, 9))
        check(morning.current?.id == first.id && morning.next?.id == exam.id,
            "Overview selects the ongoing and nearest upcoming events")
        check(morning.today?.remaining.courses == 2 && morning.today?.remaining.exams == 1
            && morning.today?.remaining.experiments == 1,
            "Remaining events include ongoing classes and distinguish exams and labs")
        check(morning.today?.additionalEndTime == lab.endAt,
            "Overview supplies the final end beyond the two visible cards")
        check(overview(date(7, 11)).week?.upcoming.exams == 0,
            "An exam already in progress is not an upcoming exam")
        let evening = overview(date(7, 18))
        check(evening.current == nil && evening.next?.id == tomorrow.id,
            "After today ends only the next event is shown")
        check(evening.today?.remaining.total == 0 && evening.today?.completedCount == 4,
            "Today's completed summary does not switch to tomorrow")

        let twoEvents = WatchScheduleResolver.resolve([.semester: snapshot([first, second])])!
        check(WatchOverviewSummary(.init(resolved: twoEvents, at: date(7, 9)))
            .today?.additionalEndTime == nil,
            "Do not repeat an end time already shown in a card")
        let freshToday = WatchScheduleResolver.resolve([
            .semester: snapshot([first, tomorrow], valid: date(7)),
            .today: snapshot([first], generated: date(7, 7), end: date(8), valid: date(8)),
        ])!
        let partial = WatchOverviewSummary(.init(resolved: freshToday, at: date(7, 9)))
        check(partial.current?.id == first.id && partial.next == nil && partial.week == nil,
            "Fresh today data cannot make stale future events or weekly totals reliable")
        check(WatchOverviewSummary(.init(resolved: nil, at: date(7))).today == nil,
            "Missing overview data is not a confirmed zero")

        for url in [WatchWidgetDestination.overview.url,
                    URL(string: "xdyou-watch://course?id=A&date=0")!,
                    URL(string: "xdyou-watch://day?date=0")!] {
            check(WatchWidgetDestination(url: url) == .overview,
                "Current and legacy widget links all open Overview")
        }
        check(WatchWidgetDestination(url: URL(string: "https://example.com/overview")!) == nil,
            "Unrelated URLs do not change the current page")
    }

    static func main() throws {
        try sharedDataRegressions()
        overviewRegressions()
        let first = course("A", start: date(7, 8, 30), end: date(7, 10, 5))
        let second = course("B", start: date(7, 14), end: date(7, 15, 35), place: "C-101")
        let tomorrow = course("C", start: date(8, 8, 30), end: date(8, 10, 5))
        let full = WatchScheduleResolver.resolve([.semester: snapshot([tomorrow, second, first])])!
        func state(_ time: Date, preview: Bool = false) -> WatchSchedulePresentation {
            .init(resolved: full, at: time, preview: preview)
        }
        check(state(date(7, 7)).state == .upcoming, "No first-class waiting tier")
        check(state(date(7, 8, 14, 59)).state == .upcoming, "15-minute lower boundary")
        check(state(date(7, 8, 15)).state == .imminent, "Upcoming status at 15 minutes")
        for time in [date(7, 7, 30), date(7, 8, 15), date(7, 8, 29, 1),
                     date(7, 8, 30), date(7, 10, 4, 59)] {
            check(state(time).startTimeText == "08:30", "Start time stays visible near boundaries")
            check(state(time).endTimeText == "10:05", "End time stays visible near boundaries")
            check(state(time).timeRangeText == "08:30–10:05", "Always display actual time range")
        }
        check(state(date(7, 8, 30)).state == .ongoing, "At start select current course")
        check(state(date(7, 10, 4)).state == .ongoing, "Exactly one minute until dismissal")
        check(state(date(7, 10, 4, 59)).state == .ongoing, "Keep clock times until actual dismissal")
        check(state(date(7, 8, 29, 59)).courseProgress == nil, "No progress before class")
        check(state(date(7, 8, 30)).courseProgress == 0, "Progress begins at the start of class")
        check(state(date(7, 9, 17, 30)).courseProgress == 0.5, "Halfway class progress is finite")
        check(state(date(7, 10, 4, 59)).courseProgress! < 1, "Progress stays bounded before end")
        check(state(date(7, 10, 5)).courseProgress == nil, "Hide progress at the end of class")
        check(state(date(7, 10, 5)).focus?.id == "B", "End is an exclusive boundary")
        check(
            state(date(7, 10, 5)).clockText(second.startAt) == "14:00",
            "Gap displays next start time")
        check(state(date(7, 9)).focus?.id == "A", "Split widgets keep current course")
        check(state(date(7, 9), preview: true).focus?.id == "B", "Integrated preview selects next")
        check(state(date(7, 9), preview: true).title == "下一节", "Next course uses a concise title")
        check(state(date(7, 9), preview: true).courseProgress == nil, "Next preview has no progress")
        check(state(date(7, 9), preview: true).timeRangeText == "14:00–15:35", "Preview uses next times")
        check(state(date(7, 16)).state == .todayFinished, "Switch after actual final class")
        check(state(date(7, 16)).dayLabel(for: tomorrow.startAt) == "明日", "Tomorrow is labeled")
        check(state(date(7, 16)).summaryDate == date(7, 16), "Overview stays on today after class")
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
        let overnight = course("Night", start: date(7, 23, 30), end: date(8, 0, 30))
        let overnightResolved = WatchScheduleResolver.resolve([.semester: snapshot([overnight])])!
        check(
            WatchSchedulePresentation(resolved: overnightResolved, at: date(7, 23, 45))
                .timeRangeText == "23:30–明日 00:30", "Overnight dismissal has a day label")
        check(
            WatchSchedulePresentation(resolved: nil, at: date(7)).timeRangeText == nil,
            "Missing data never invents class times")
        check(
            WatchSchedulePresentation(resolved: nil, at: date(7)).courseProgress == nil,
            "Missing data never displays progress")

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
        check(dates.contains(first.startAt) && dates.contains(first.endAt), "Exact class boundaries")
        check(dates.contains(date(7, 8, 35)), "Refresh finite progress during class")
        check(!dates.contains(date(7, 12, 5)), "Do not refresh progress between classes")
        check(
            !dates.contains(first.endAt.addingTimeInterval(-60 + 0.001)),
            "No obsolete countdown-only boundary")
        check(dates.allSatisfy { $0 <= date(9) }, "Progress timeline stays within two-day horizon")
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

    static func sharedDataRegressions() throws {
        let languageCases: [(String?, WatchLanguage?)] = [
            ("zh_CN", .simplifiedChinese), ("zh-SG", .simplifiedChinese),
            ("zh-Hant", .traditionalChinese), ("zh-HK", .traditionalChinese),
            ("zh-MO", .traditionalChinese), ("zh-Hans-TW", .simplifiedChinese),
            ("zh-Hant-CN", .traditionalChinese), (" en-GB ", .english),
            ("en_US", .english), ("english", nil), ("zh-invalid-language", .simplifiedChinese),
            ("fr-FR", nil), (nil, nil),
        ]
        for (identifier, expected) in languageCases {
            check(WatchLanguage(identifier: identifier) == expected,
                "Phone and Watch normalize the same language aliases: \(identifier ?? "nil")")
        }
        check(WatchLanguage.traditionalChinese.resourceName == "zh-Hant",
            "Traditional Chinese selects the script resource rather than a region-only bundle")
        check(WatchScheduleDate.calendar(offsetMinutes: Int.max).timeZone == .current,
            "An invalid timezone offset cannot overflow during decoding")
        check(WatchScheduleDate.epochMilliseconds(
            for: WatchScheduleDate.date(fromEpochMilliseconds: 1_000_123)) == 1_000_123,
            "Milliseconds round-trip through the shared conversion")
        check(WatchScheduleText.compactLocation("信远 Ⅱ-105 ") == "Ⅱ-105",
            "Compact location retains the exact Roman numeral and classroom number")

        check(!WatchSyncProtocol.acceptsPagination(scope: .semester, offset: 50, nextOffset: 50, hasMore: true),
            "A repeated page cannot create an endless transfer")
        check(!WatchSyncProtocol.acceptsPagination(scope: .today, offset: 0, nextOffset: 50, hasMore: true),
            "Partial daily snapshots are not treated as a completed range")
        check(WatchSyncProtocol.acceptsPagination(scope: .semester, offset: 50, nextOffset: 100, hasMore: true),
            "Normal semester pagination continues")
        check(WatchSyncProtocol.acceptsPagination(scope: .semester, offset: 0, nextOffset: 0, hasMore: false),
            "An empty completed semester remains valid")

        let early = course("A", start: date(7, 8), end: date(7, 9))
        let late = course("B", start: date(7, 10), end: date(7, 11))
        var firstPage = snapshot([late])
        firstPage.sourceRevision = 8
        firstPage.semesterEndEpochMs = ms(date(28))
        let lastPage = firstPage.replacingCourses([early])
        var transfer = WatchSemesterTransfer()
        try transfer.append(firstPage)
        try transfer.append(lastPage)
        let completed = try transfer.completedSnapshot()
        check(completed.courses.map(\.id) == ["A", "B"], "Pages are sorted only when assembled")
        check(completed.sourceRevision == 8 && completed.semesterEndEpochMs == ms(date(28)),
            "Assembly retains the original revision and full term boundary")

        var changedPage = lastPage
        changedPage.sourceRevision = 9
        do {
            try transfer.append(changedPage)
            check(false, "Pages from another source revision must be rejected")
        } catch WatchScheduleDataError.inconsistentSemester {
            let unchanged = try transfer.completedSnapshot()
            check(unchanged == completed, "Rejected pages cannot modify the accumulated data")
        }
        transfer.reset(keepingCapacity: true)
        try transfer.append(firstPage.replacingCourses([]))
        let empty = try transfer.completedSnapshot()
        check(empty.courses.isEmpty, "Reset removes courses and keeps empty semesters valid")

        let json = try WatchCacheCoding.encodeJSON(firstPage)
        let decoded = try WatchScheduleCoding.decode(json)
        check(decoded == firstPage, "Shared decoder preserves all supported fields")
        var root = try JSONSerialization.jsonObject(with: Data(json.utf8)) as! [String: Any]
        root["schemaVersion"] = 999
        let unsupported = String(decoding: try JSONSerialization.data(withJSONObject: root), as: UTF8.self)
        do {
            _ = try WatchScheduleCoding.decode(unsupported)
            check(false, "Unsupported schemas must fail before replacing a cache")
        } catch WatchScheduleDataError.unsupportedSchema(let version) {
            check(version == 999, "Diagnostics retain the rejected schema version")
        }
    }
}
