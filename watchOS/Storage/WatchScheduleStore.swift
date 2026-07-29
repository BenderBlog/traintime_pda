// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Combine
import Foundation

@MainActor
final class WatchScheduleStore: ObservableObject {
    @Published private(set) var snapshot: WatchScheduleSnapshot?
    @Published private(set) var syncError: String?
    @Published private(set) var loadingScope: WatchScheduleScope?
    @Published private(set) var loadedScope: WatchScheduleScope?
    @Published private(set) var isRefreshing = false
    @Published private(set) var completedRefreshCount = 0

    private let defaults: UserDefaults
    private let semesterCacheKey = "watchScheduleSnapshot"
    private let fourteenDayCacheKey = "watchScheduleSnapshot.fourteenDays"
    private let todayCacheKey = "watchScheduleSnapshot.today"
    private var cachedSnapshots: [WatchScheduleScope: WatchScheduleSnapshot] = [:]
    private var semesterBuffer: [String: WatchCourse] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadCachedSchedule()
    }

    var isStale: Bool {
        guard let snapshot else { return true }
        return snapshot.validThrough < Date()
    }

    var allCourses: [WatchCourse] {
        snapshot?.courses.sorted { $0.startAt < $1.startAt } ?? []
    }

    var semesterStart: Date? {
        if let current = snapshot?.semesterStart {
            return current
        }
        if let semester = cachedSnapshots[.semester] {
            return semester.semesterStart ?? semester.rangeStart
        }
        guard loadedScope == .semester else { return nil }
        return snapshot?.rangeStart
    }

    var synchronizedWeekReference: (date: Date, zeroBasedIndex: Int)? {
        if let snapshot, let index = snapshot.currentWeekIndex {
            return (snapshot.generatedAt, index)
        }
        if let semester = cachedSnapshots[.semester],
           let index = semester.currentWeekIndex
        {
            return (semester.generatedAt, index)
        }
        return nil
    }

    var nextCourse: WatchCourse? {
        allCourses.first { $0.endAt > Date() }
    }

    func courses(on date: Date) -> [WatchCourse] {
        allCourses.filter {
            Calendar.current.isDate($0.startAt, inSameDayAs: date)
        }
    }

    func beginRefresh() {
        semesterBuffer.removeAll(keepingCapacity: true)
        restoreCacheIfNeeded()
        isRefreshing = true
        loadingScope = .today
        syncError = nil
    }

    func setLoadingScope(_ scope: WatchScheduleScope) {
        isRefreshing = true
        loadingScope = scope
    }

    func finishRefresh(showCompletion: Bool = false) {
        isRefreshing = false
        loadingScope = nil
        syncError = nil
        if showCompletion {
            completedRefreshCount += 1
        }
    }

    func failRefresh(_ message: String) {
        restoreCacheIfNeeded()
        isRefreshing = false
        loadingScope = nil
        syncError = message
    }

    @discardableResult
    func replaceSchedule(
        json: String,
        scope: WatchScheduleScope
    ) -> Bool {
        guard !json.isEmpty else {
            if snapshot == nil {
                syncError = "手机端暂无课表，请先在 iPhone 打开并刷新课表"
            }
            return false
        }

        do {
            let decoded = try decode(json)
            snapshot = decoded
            loadedScope = scope
            syncError = nil
            persistCompletedStage(
                snapshot: decoded,
                json: json,
                scope: scope
            )
            return true
        } catch {
            syncError = "课表数据无法读取"
            NSLog("[WatchScheduleStore] Decode failed: \(error)")
            return false
        }
    }

    func beginSemesterTransfer() {
        semesterBuffer.removeAll(keepingCapacity: true)
        setLoadingScope(.semester)
    }

    @discardableResult
    func appendSemesterChunk(json: String, isFinal: Bool) -> Bool {
        guard !json.isEmpty else {
            failRefresh("手机端没有可用的学期课表")
            return false
        }

        do {
            let decoded = try decode(json)
            for course in decoded.courses {
                semesterBuffer[course.id] = course
            }

            guard isFinal else { return true }
            let courses = semesterBuffer.values.sorted {
                $0.startAt < $1.startAt
            }
            let complete = WatchScheduleSnapshot(
                schemaVersion: decoded.schemaVersion,
                generatedAtEpochMs: decoded.generatedAtEpochMs,
                semesterStartEpochMs: decoded.semesterStartEpochMs,
                currentWeekIndex: decoded.currentWeekIndex,
                validThroughEpochMs: decoded.validThroughEpochMs,
                rangeStartEpochMs: decoded.rangeStartEpochMs,
                rangeEndEpochMs: decoded.rangeEndEpochMs,
                timeZoneOffsetMinutes: decoded.timeZoneOffsetMinutes,
                reminderMinutes: decoded.reminderMinutes,
                courses: courses
            )
            let encoded = try JSONEncoder().encode(complete)
            let encodedJSON = String(decoding: encoded, as: UTF8.self)
            persistCompletedStage(
                snapshot: complete,
                json: encodedJSON,
                scope: .semester
            )
            snapshot = complete
            loadedScope = .semester
            semesterBuffer.removeAll(keepingCapacity: false)
            finishRefresh(showCompletion: true)
            return true
        } catch {
            semesterBuffer.removeAll(keepingCapacity: false)
            failRefresh("全学期课表无法合并")
            NSLog("[WatchScheduleStore] Semester merge failed: \(error)")
            return false
        }
    }

    private func decode(_ json: String) throws -> WatchScheduleSnapshot {
        let decoded = try JSONDecoder().decode(
            WatchScheduleSnapshot.self,
            from: Data(json.utf8)
        )
        guard (1...4).contains(decoded.schemaVersion) else {
            throw ScheduleError.unsupportedSchema(decoded.schemaVersion)
        }
        return decoded
    }

    private func loadCachedSchedule() {
        let entries: [(WatchScheduleScope, String)] = [
            (.semester, semesterCacheKey),
            (.fourteenDays, fourteenDayCacheKey),
            (.today, todayCacheKey),
        ]

        for (scope, key) in entries {
            guard let json = defaults.string(forKey: key) else { continue }
            do {
                cachedSnapshots[scope] = try decode(json)
            } catch {
                NSLog(
                    "[WatchScheduleStore] Ignoring invalid \(scope.rawValue) cache: \(error)"
                )
            }
        }
        restoreCacheIfNeeded()
    }

    private func persistCompletedStage(
        snapshot: WatchScheduleSnapshot,
        json: String,
        scope: WatchScheduleScope
    ) {
        cachedSnapshots[scope] = snapshot
        defaults.set(json, forKey: cacheKey(for: scope))
    }

    private func cacheKey(for scope: WatchScheduleScope) -> String {
        switch scope {
        case .today:
            todayCacheKey
        case .fourteenDays:
            fourteenDayCacheKey
        case .semester:
            semesterCacheKey
        }
    }

    private func restoreCacheIfNeeded() {
        guard snapshot == nil, let cached = preferredCachedSnapshot() else {
            return
        }
        snapshot = cached.snapshot
        loadedScope = cached.scope
    }

    private func preferredCachedSnapshot()
        -> (scope: WatchScheduleScope, snapshot: WatchScheduleSnapshot)?
    {
        let priority: [WatchScheduleScope] = [
            .semester,
            .fourteenDays,
            .today,
        ]
        let now = Date()
        for scope in priority {
            guard let cached = cachedSnapshots[scope],
                  cached.validThrough >= now
            else {
                continue
            }
            return (scope, cached)
        }

        return cachedSnapshots.max {
            $0.value.generatedAt < $1.value.generatedAt
        }.map { (scope: $0.key, snapshot: $0.value) }
    }
}

private enum ScheduleError: LocalizedError {
    case unsupportedSchema(Int)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version):
            "Unsupported schedule schema: \(version)"
        }
    }
}
