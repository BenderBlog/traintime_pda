// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import SwiftUI

enum WatchScheduleScope: String, CaseIterable {
    case today
    case fourteenDays
    case semester

    var progressTitle: String {
        switch self {
        case .today:
            "正在获取今天"
        case .fourteenDays:
            "正在获取近 14 天"
        case .semester:
            "正在获取整个学期"
        }
    }

    var next: WatchScheduleScope? {
        switch self {
        case .today:
            .fourteenDays
        case .fourteenDays:
            .semester
        case .semester:
            nil
        }
    }
}

struct WatchCourse: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let teacher: String?
    let classroom: String?
    let startAtEpochMs: Int64
    let endAtEpochMs: Int64
    let startSection: Int?
    let endSection: Int?
    let colorARGB: Int64?
    let kind: String?
    let note: String?

    var startAt: Date {
        Date(timeIntervalSince1970: TimeInterval(startAtEpochMs) / 1_000)
    }

    var endAt: Date {
        Date(timeIntervalSince1970: TimeInterval(endAtEpochMs) / 1_000)
    }

    var startPeriod: Int {
        normalizedPeriod(startSection) ?? inferredPeriod(
            from: startAt,
            isStart: true
        )
    }

    var endPeriod: Int {
        normalizedPeriod(endSection) ?? inferredPeriod(
            from: endAt,
            isStart: false
        )
    }

    var color: Color {
        let value = UInt64(colorARGB ?? Int64(0xFF2196F3))
        return Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    var kindTitle: String? {
        switch kind {
        case "exam":
            "考试"
        case "physicsExperiment":
            "物理实验"
        case "otherExperiment":
            "实验"
        default:
            nil
        }
    }

    var kindSystemImage: String {
        switch kind {
        case "exam":
            "pencil.and.list.clipboard"
        case "physicsExperiment", "otherExperiment":
            "flask"
        default:
            "book.closed"
        }
    }

    private func normalizedPeriod(_ value: Int?) -> Int? {
        guard let value, (1...11).contains(value) else { return nil }
        return value
    }

    private func inferredPeriod(from date: Date, isStart: Bool) -> Int {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: date
        )
        let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let boundaries = isStart
            ? [510, 560, 625, 675, 840, 890, 955, 1005, 1140, 1195, 1240]
            : [555, 605, 670, 720, 885, 935, 1000, 1050, 1185, 1235, 1285]
        let nearest = boundaries.enumerated().min {
            abs($0.element - minutes) < abs($1.element - minutes)
        }
        return (nearest?.offset ?? 0) + 1
    }
}

struct WatchScheduleSnapshot: Codable, Equatable {
    let schemaVersion: Int
    let generatedAtEpochMs: Int64
    let semesterStartEpochMs: Int64?
    let currentWeekIndex: Int?
    let validThroughEpochMs: Int64
    let rangeStartEpochMs: Int64?
    let rangeEndEpochMs: Int64?
    let timeZoneOffsetMinutes: Int
    let reminderMinutes: Int
    let courses: [WatchCourse]

    var generatedAt: Date {
        Date(timeIntervalSince1970: TimeInterval(generatedAtEpochMs) / 1_000)
    }

    var semesterStart: Date? {
        guard let semesterStartEpochMs else { return nil }
        return Date(
            timeIntervalSince1970:
                TimeInterval(semesterStartEpochMs) / 1_000
        )
    }

    var validThrough: Date {
        Date(timeIntervalSince1970: TimeInterval(validThroughEpochMs) / 1_000)
    }

    var rangeStart: Date {
        guard let rangeStartEpochMs else {
            return courses.first?.startAt ?? generatedAt
        }
        return Date(
            timeIntervalSince1970: TimeInterval(rangeStartEpochMs) / 1_000
        )
    }

    var rangeEnd: Date {
        guard let rangeEndEpochMs else {
            return courses.last?.endAt ?? validThrough
        }
        return Date(
            timeIntervalSince1970: TimeInterval(rangeEndEpochMs) / 1_000
        )
    }
}
