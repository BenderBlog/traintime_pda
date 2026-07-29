// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WatchConnectivity

final class PhoneWatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = PhoneWatchConnectivityManager()

    private enum Key {
        static let scheduleJSON = "scheduleJSON"
        static let requestSchedule = "requestSchedule"
        static let scope = "scheduleScope"
        static let offset = "scheduleOffset"
        static let nextOffset = "scheduleNextOffset"
        static let hasMore = "scheduleHasMore"
    }

    private enum Scope: String {
        case today
        case fourteenDays
        case semester
    }

    private let persistedScheduleKey = "TraintimeWatchSemesterSchedule"
    private let semesterChunkSize = 50
    private var pendingScheduleJSON: String?
    private var latestScheduleJSON: String?

    private override init() {
        latestScheduleJSON = UserDefaults.standard.string(
            forKey: persistedScheduleKey
        )
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    @discardableResult
    func syncSchedule(json: String) -> Bool {
        latestScheduleJSON = json
        if json.isEmpty {
            UserDefaults.standard.removeObject(forKey: persistedScheduleKey)
        } else {
            UserDefaults.standard.set(json, forKey: persistedScheduleKey)
        }
        guard WCSession.isSupported() else { return false }

        let session = WCSession.default
        guard session.activationState == .activated else {
            pendingScheduleJSON = json
            activate()
            return true
        }
        return updateApplicationContext(json: json, session: session)
    }

    @discardableResult
    func clearSchedule() -> Bool {
        return syncSchedule(json: "")
    }

    private func updateApplicationContext(
        json: String,
        session: WCSession
    ) -> Bool {
        let fallback = responsePayload(
            sourceJSON: json,
            scope: .fourteenDays,
            offset: 0
        )
        do {
            try session.updateApplicationContext([
                Key.scheduleJSON: fallback.json,
                Key.scope: Scope.fourteenDays.rawValue,
            ])
            pendingScheduleJSON = nil
            return true
        } catch {
            pendingScheduleJSON = json
            NSLog(
                "[WatchConnectivity] Failed to update application context: \(error)"
            )
            return false
        }
    }

    private func responsePayload(
        sourceJSON: String,
        scope: Scope,
        offset: Int
    ) -> (json: String, nextOffset: Int, hasMore: Bool) {
        guard !sourceJSON.isEmpty,
              let data = sourceJSON.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              var root = object as? [String: Any],
              let allCourses = root["courses"] as? [[String: Any]]
        else {
            return (sourceJSON, 0, false)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let filteredCourses: [[String: Any]]
        let rangeStart: Date
        let rangeEnd: Date
        let nextOffset: Int
        let hasMore: Bool

        switch scope {
        case .today:
            rangeStart = today
            rangeEnd = calendar.date(byAdding: .day, value: 1, to: today)
                ?? today
            filteredCourses = courses(
                allCourses,
                from: rangeStart,
                through: rangeEnd
            )
            nextOffset = 0
            hasMore = false
        case .fourteenDays:
            rangeStart = today
            rangeEnd = calendar.date(byAdding: .day, value: 14, to: today)
                ?? today
            filteredCourses = courses(
                allCourses,
                from: rangeStart,
                through: rangeEnd
            )
            nextOffset = 0
            hasMore = false
        case .semester:
            let safeOffset = max(0, min(offset, allCourses.count))
            let endOffset = min(
                safeOffset + semesterChunkSize,
                allCourses.count
            )
            filteredCourses = Array(allCourses[safeOffset..<endOffset])
            nextOffset = endOffset
            hasMore = endOffset < allCourses.count
            rangeStart = date(
                fromEpochMilliseconds: root["rangeStartEpochMs"]
            ) ?? today
            rangeEnd = date(
                fromEpochMilliseconds: root["rangeEndEpochMs"]
            ) ?? today
        }

        root["courses"] = filteredCourses
        root["rangeStartEpochMs"] = epochMilliseconds(for: rangeStart)
        root["rangeEndEpochMs"] = epochMilliseconds(for: rangeEnd)
        root["validThroughEpochMs"] = epochMilliseconds(for: rangeEnd)

        guard let filteredData = try? JSONSerialization.data(withJSONObject: root),
              let filteredJSON = String(data: filteredData, encoding: .utf8)
        else {
            return (sourceJSON, 0, false)
        }
        return (filteredJSON, nextOffset, hasMore)
    }

    private func courses(
        _ courses: [[String: Any]],
        from start: Date,
        through end: Date
    ) -> [[String: Any]] {
        let startMilliseconds = epochMilliseconds(for: start)
        let endMilliseconds = epochMilliseconds(for: end)
        return courses.filter { course in
            guard let number = course["startAtEpochMs"] as? NSNumber else {
                return false
            }
            let value = number.int64Value
            return value >= startMilliseconds && value < endMilliseconds
        }
    }

    private func date(fromEpochMilliseconds value: Any?) -> Date? {
        guard let number = value as? NSNumber else { return nil }
        return Date(
            timeIntervalSince1970: TimeInterval(number.int64Value) / 1_000
        )
    }

    private func epochMilliseconds(for date: Date) -> Int64 {
        Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            NSLog("[WatchConnectivity] Activation failed: \(error)")
            return
        }
        guard activationState == .activated, let pendingScheduleJSON else {
            return
        }
        _ = updateApplicationContext(
            json: pendingScheduleJSON,
            session: session
        )
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard message[Key.requestSchedule] as? Bool == true else {
            replyHandler([:])
            return
        }

        let requestedScope = Scope(
            rawValue: message[Key.scope] as? String ?? ""
        ) ?? .fourteenDays
        let requestedOffset = message[Key.offset] as? Int ?? 0
        let source = latestScheduleJSON
            ?? UserDefaults.standard.string(forKey: persistedScheduleKey)
            ?? session.applicationContext[Key.scheduleJSON] as? String
            ?? ""
        let response = responsePayload(
            sourceJSON: source,
            scope: requestedScope,
            offset: requestedOffset
        )
        replyHandler([
            Key.scheduleJSON: response.json,
            Key.scope: requestedScope.rawValue,
            Key.nextOffset: response.nextOffset,
            Key.hasMore: response.hasMore,
        ])
    }
}

final class WatchSyncApiImplementation: WatchSyncSwiftApi {
    func syncSchedule(
        payload: WatchSchedulePayload,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        completion(
            .success(
                PhoneWatchConnectivityManager.shared.syncSchedule(
                    json: payload.json
                )
            )
        )
    }

    func clearSchedule(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(
            .success(PhoneWatchConnectivityManager.shared.clearSchedule())
        )
    }
}
