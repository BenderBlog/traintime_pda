// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

/// 在 macOS 上直接编译生产状态机和缓存代码；所有持久化均使用临时 suite。
@main
@MainActor
struct InteractionRegression {
    static var assertions = 0

    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        assertions += 1
        precondition(condition(), message)
    }

    static func date(_ day: Int, hour: Int = 8) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour))!
    }

    static func ms(_ date: Date) -> Int64 { Int64(date.timeIntervalSince1970 * 1_000) }

    static func course(_ id: String, day: Int = 7, section: Int = 1) -> WatchCourse {
        WatchCourse(
            id: id, name: id, teacher: nil, classroom: "A-101",
            startAtEpochMs: ms(date(day)), endAtEpochMs: ms(date(day, hour: 10)),
            startSection: section, endSection: section + 1,
            colorARGB: -1, kind: "course", note: nil)
    }

    static func snapshot(_ courses: [WatchCourse], revision: Int64 = 1) -> WatchScheduleSnapshot {
        var result = WatchScheduleSnapshot(
            schemaVersion: 4,
            generatedAtEpochMs: ms(date(1)), semesterStartEpochMs: ms(date(1, hour: 0)),
            currentWeekIndex: 0, validThroughEpochMs: ms(date(30, hour: 0)),
            rangeStartEpochMs: ms(date(1, hour: 0)), rangeEndEpochMs: ms(date(30, hour: 0)),
            timeZoneOffsetMinutes: 480, reminderMinutes: 5, courses: courses)
        result.sourceRevision = revision
        return result
    }

    static func main() async throws {
        testPressAndCrown()
        await testCompletionCancellation()
        testMonthCache()
        try await testDayLayoutCache()
        try await testStoreCache()
        print("Passed \(assertions) interaction/lifecycle/cache regression checks")
    }

    static func testPressAndCrown() {
        var press = WatchPressSession()
        check(press.begin(), "First touch begins a press")
        check(!press.begin(), "Repeated movement does not restart the long-press timer")
        press.cancel()
        check(!press.begin(), "Dragging back into the button cannot revive a cancelled press")
        check(
            !press.finish(didTriggerLongPress: false),
            "Cancelled release cannot open the mode picker")
        check(press.begin(), "The next independent touch still works")
        check(press.finish(didTriggerLongPress: false), "A normal short press taps once")
        check(!press.finish(didTriggerLongPress: false), "Duplicate end is ignored")
        check(press.begin(), "Long press begins")
        check(!press.finish(didTriggerLongPress: true), "Long press does not also tap")
        _ = press.begin()
        press.reset()
        check(!press.finish(didTriggerLongPress: false), "Leaving a page cannot complete its press")

        var crown = WatchCrownTurnSession()
        check(crown.register(delta: 0, now: 0) == nil, "Focus resets are not crown input")
        check(crown.register(delta: .nan, now: 0) == nil, "NaN is rejected")
        check(crown.register(delta: .infinity, now: 0) == nil, "Infinite input is rejected")
        check(crown.register(delta: 0.25, now: .nan) == nil, "Invalid timestamps are rejected")
        check(
            crown.register(delta: 0.25, now: 0)?.startsNewSession == true,
            "Zero is a valid initial uptime")
        check(
            crown.register(delta: 0.25, now: 0.1)?.startsNewSession == false,
            "Continuous rotation keeps its session")
        check(
            crown.register(delta: -0.25, now: 0.2)?.reversesDirection == true,
            "Direction reversal is reported")
        check(
            crown.register(delta: -0.25, now: 0.54)?.startsNewSession == false,
            "The 0.35-second threshold is preserved")
        check(
            crown.register(delta: -0.25, now: 0.9)?.startsNewSession == true,
            "A later rotation starts a new session")
        check(
            crown.register(delta: 0.25, now: 0.8)?.startsNewSession == true,
            "A backwards test clock cannot retain stale direction")
        crown.reset()
        check(
            crown.register(delta: 0.25, now: 1)?.startsNewSession == true,
            "Snap completion resets the session")
    }

    static func testCompletionCancellation() async {
        var gate = WatchInputCompletionGate()
        gate.begin()
        let first = gate.generation
        check(gate.completeTouch(for: first), "Native idle completes a touch")
        check(!gate.completeTouch(for: first), "Drag fallback cannot complete the same touch twice")
        gate.begin()
        check(!gate.completeTouch(for: first), "Old-step callback cannot complete a new step")
        check(gate.completeTouch(for: gate.generation), "New-step touch remains valid")

        var completed: [String] = []
        let old = makeWatchAutoDismissTask(after: 0.01) { completed.append("old") }
        old.cancel()
        let current = makeWatchAutoDismissTask(after: 0.02) { completed.append("current") }
        await old.value
        await current.value
        check(completed == ["current"], "Cancelled UI tasks never run after replacement")

        let crownIdle = CalendarCrownIdleCoordinator()
        crownIdle.scheduleFallback { completed.append("fallback") }
        crownIdle.scheduleIdleConfirmation { completed.append("idle") }
        try? await Task.sleep(nanoseconds: 400_000_000)
        check(completed == ["current", "idle"], "Native idle replaces rather than duplicates fallback snapping")
        crownIdle.scheduleIdleConfirmation { completed.append("cancelled") }
        crownIdle.cancel()
        try? await Task.sleep(nanoseconds: 120_000_000)
        check(completed == ["current", "idle"], "Leaving the page cancels a pending crown snap")
    }

    static func testMonthCache() {
        var cache = MonthCalendarCache()
        let dates = (0...8).map {
            Calendar.current.date(byAdding: .month, value: $0 * 3, to: date(7))!
        }
        for day in dates {
            let window = cache.window(centeredOn: day, periodCourseIDsByDay: [:], coursesByID: [:])
            check(window.models.count == 3, "Each retained window still has three pages")
            check(
                window.models.values.allSatisfy { $0.cells.count == $0.rowCount * 7 },
                "Cached month grids remain complete")
        }
        check(!cache.isPrepared(around: dates[0]), "Unbounded browsing evicts the oldest window")
        check(
            dates.dropFirst().allSatisfy { cache.isPrepared(around: $0) },
            "The eight most recent windows remain cached")
        _ = cache.window(centeredOn: dates[1], periodCourseIDsByDay: [:], coursesByID: [:])
        _ = cache.window(centeredOn: dates[0], periodCourseIDsByDay: [:], coursesByID: [:])
        check(cache.isPrepared(around: dates[1]), "An accessed window becomes most recent")
        check(!cache.isPrepared(around: dates[2]), "LRU eviction respects refreshed access order")
        cache.invalidateScheduleMarkers()
        check(
            !cache.isPrepared(around: dates[0]),
            "Schedule replacement invalidates assembled windows")

        let sample = course("new")
        let dayStart = Calendar.current.startOfDay(for: sample.startAt)
        let window = cache.window(
            centeredOn: sample.startAt,
            periodCourseIDsByDay: [dayStart: [sample.id, nil, nil, nil, nil]],
            coursesByID: [sample.id: sample])
        check(
            window.periodMarkers.values.flatMap { $0.values }.contains {
                $0.segmentCourses.contains { $0?.id == sample.id }
            }, "Rebuilt month markers reference the new schedule")
    }

    static func waitForCache(_ defaults: UserDefaults, key: String) async {
        for _ in 0..<150 {
            if defaults.data(forKey: key) != nil { return }
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }

    static func testDayLayoutCache() async throws {
        let suite = "watch-layout-regression-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let key = WatchPersistentCacheKey.dayCourseLayout
        let tracker = DayCourseLayoutTracker(defaults: defaults)
        tracker.configure(signature: "revision-1|large")
        tracker.suspendPersistence()
        tracker.update(metrics: .init(cardHeights: ["A": 100, "B": 150, "invalid": .nan]))
        let courses = [course("A"), course("B")]
        let offset = tracker.contentOffset(for: 0.5, courses: courses, spacing: 5)
        check(offset == -52.5, "Crown interpolation uses measured card heights")
        check(
            tracker.position(forContentOffset: offset, courses: courses, spacing: 5) == 0.5,
            "Touch and crown positions round-trip without jumping")
        check(
            tracker.contentHeight(courses: courses, spacing: 5) == 255,
            "Content height includes existing spacing")
        try await Task.sleep(nanoseconds: 1_650_000_000)
        check(
            defaults.data(forKey: key) == nil,
            "Measurements cannot restart disk writes while suspended")
        tracker.resumePersistence()
        await waitForCache(defaults, key: key)
        check(defaults.data(forKey: key) != nil, "Idle resumes pending persistence")
        let restored = DayCourseLayoutTracker(defaults: defaults)
        restored.configure(signature: "revision-1|large")
        check(
            restored.contentHeight(courses: courses, spacing: 5) == 255,
            "Matching layout signatures restore measured heights")
        restored.configure(signature: "revision-2|accessibility")
        check(
            restored.contentHeight(courses: courses, spacing: 5) == 149,
            "New source or font discards old heights")

        tracker.update(metrics: .init(cardHeights: ["A": 110]))
        WatchWidgetShared.clearSchedule(in: defaults)
        try await Task.sleep(nanoseconds: 1_650_000_000)
        check(
            defaults.data(forKey: key) == nil, "A pending writer cannot resurrect a cleared cache")
        tracker.configure(signature: "revision-1|large")
        check(
            tracker.contentHeight(courses: courses, spacing: 5) == 149,
            "Clear generation invalidates memory even if signature repeats")
        tracker.suspendPersistence()
        restored.suspendPersistence()
    }

    static func testStoreCache() async throws {
        let suite = "watch-store-regression-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let key = WatchPersistentCacheKey.scheduleRenderIndex
        let original = snapshot([course("A"), course("B", day: 8)])
        let store = WatchScheduleStore(defaults: defaults, sharedDefaults: nil, reloadWidgets: {})
        let originalJSON = try WatchCacheCoding.encodeJSON(original)
        check(
            store.replaceSchedule(json: originalJSON, scope: .semester), "Store installs valid data"
        )
        await waitForCache(defaults, key: key)
        let data = defaults.data(forKey: key)!
        var index = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        check(
            index["schemaVersion"] as? Int == 2,
            "Render cache schema includes revision and calendar identity")
        let source = index["source"] as! [String: Any]
        check(source["sourceRevision"] as? Int == 1, "Monotonic source revision is persisted")
        check(
            source["timeZoneIdentifier"] as? String == Calendar.current.timeZone.identifier,
            "Day grouping records its timezone")

        // 相同生成时间、相同 ID 与数量，只有课程节次和修订号变化。
        let changed = snapshot([course("A", section: 3), course("B", day: 8)], revision: 2)
        defaults.set(
            try WatchCacheCoding.encodeJSON(changed), forKey: WatchWidgetShared.semesterCacheKey)
        let revised = WatchScheduleStore(defaults: defaults, sharedDefaults: nil, reloadWidgets: {})
        let month = revised.preparedMonthCalendarWindow(centeredOn: date(7))
        let markers = month.periodMarkers.values.flatMap { $0.values }
        check(
            markers.contains { $0.segmentCourses[1]?.id == "A" },
            "A new revision rebuilds period markers despite equal generation and count")
        check(
            !markers.contains { $0.segmentCourses[0]?.id == "A" },
            "Old period markers are not reused")

        defaults.set(
            try WatchCacheCoding.encodeJSON(original), forKey: WatchWidgetShared.semesterCacheKey)
        var days = index["days"] as! [[String: Any]]
        days[0]["periodCourseIDs"] = ["B", NSNull(), NSNull(), NSNull(), NSNull()] as [Any]
        index["days"] = days
        defaults.set(try JSONSerialization.data(withJSONObject: index), forKey: key)
        let recovered = WatchScheduleStore(
            defaults: defaults, sharedDefaults: nil, reloadWidgets: {})
        check(
            recovered.courses(on: date(7)).map(\.id) == ["A"],
            "Malformed derived caches preserve original schedule data")
        let repaired = recovered.preparedMonthCalendarWindow(centeredOn: date(7))
        let model = repaired.models[monthCalendarStart(for: date(7))]!
        let cell = model.cells.firstIndex {
            $0.map { Calendar.current.isDate($0.date, inSameDayAs: date(7)) } ?? false
        }!
        check(
            repaired.periodMarkers[model.monthStart]?[cell]?.segmentCourses[0]?.id == "A",
            "A marker cannot reference a course from another day")

        recovered.clearSchedule(signedOut: true)
        check(
            recovered.allCourses.isEmpty && recovered.courseListGroups.isEmpty,
            "Clear removes visible and derived data together")
        check(recovered.recommendedOnboardingDate == nil, "Clear removes the teaching date")
        check(
            recovered.presentation(at: date(7)).state == .signedOut,
            "Cached overview resolution is cleared with the schedule")
        check(defaults.data(forKey: key) == nil, "Clear deletes persisted render indexes")
    }
}
