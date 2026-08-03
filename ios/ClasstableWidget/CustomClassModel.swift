// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  CustomClassModel.swift
//  ClasstableWidgetExtension
//
//  Reference to /lib/model/pda_service/custom_class.dart

import Foundation

struct CustomClassTimeRange : Codable {
    let id: String
    let startTimeStr: String
    let endTimeStr: String

    private enum CodingKeys: String, CodingKey {
        case id
        case startTimeStr = "start_time"
        case endTimeStr = "end_time"
    }

    private static let localDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func parseISO8601(_ string: String) -> Date {
        return Self.localDateFormatter.date(from: string)
            ?? Self.isoFormatter.date(from: string)
            ?? Self.isoFormatterNoFraction.date(from: string)
            ?? Date(timeIntervalSince1970: 0)
    }

    var startTime: Date {
        return Self.parseISO8601(startTimeStr)
    }

    var endTime: Date {
        return Self.parseISO8601(endTimeStr)
    }
}

struct CustomClass : Codable {
    let id: String
    let name: String
    let teacher: String?
    let classroom: String?
    let timeRanges: [CustomClassTimeRange]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case teacher
        case classroom
        case timeRanges = "time_ranges"
    }
}
