// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  ExperimentModel.swift
//  ClasstableWidgetExtension
//
//  Created by BenderBlog Rodriguez on 2024/2/29.
//

import Foundation

class ExperimentData : Codable {
    var name : String
    var classroom : String
    var timeRangesMap : [[String: String]]
    var teacher : String

    private enum CodingKeys: String, CodingKey {
        case name
        case classroom
        case timeRangesMap = "timeRanges"
        case teacher
    }

    var timeRanges: [(Date, Date)] {
        var toReturn: [(Date, Date)] = []
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for data in timeRangesMap {
            let startTimeStr = data["$1"]
            let stopTimeStr = data["$2"]
            if startTimeStr == nil || stopTimeStr == nil {
                continue
            }
            let startTime = dateFormatter.date(from: startTimeStr!)
            let stopTime = dateFormatter.date(from: stopTimeStr!)
            if startTime == nil || stopTime == nil {
                continue
            }
            toReturn.append((startTime!, stopTime!))
        }
        return toReturn
    }
}
