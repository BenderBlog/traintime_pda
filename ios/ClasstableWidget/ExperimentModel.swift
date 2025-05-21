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
    var date : String
    var timeStr : String
    var teacher : String
    
    var startTime : Date {
        get {
            var dateNums : [Int] = []
            let splitedDate = date.components(separatedBy: "/")
            for i in splitedDate {
                dateNums.append(Int(i) ?? 0)
            }

            let calendar = Calendar.init(identifier: .gregorian)
            var components = DateComponents()
            components.year = dateNums[2]
            components.month = dateNums[0]
            components.day = dateNums[1]
            if (timeStr.contains("15")) {
                components.hour = 15
                components.minute = 55
            } else {
                components.hour = 18
                components.minute = 30
            }
            return calendar.date(from: components)!
        }
    }
    
    var endTime : Date {
        get {
            var dateNums : [Int] = []
            let splitedDate = date.components(separatedBy: "/")
            for i in splitedDate {
                dateNums.append(Int(i) ?? 0)
            }

            let calendar = Calendar.init(identifier: .gregorian)
            var components = DateComponents()
            components.year = dateNums[2]
            components.month = dateNums[0]
            components.day = dateNums[1]
            if (timeStr.contains("15")) {
                components.hour = 18
                components.minute = 10
            } else {
                components.hour = 20
                components.minute = 45
            }
            return calendar.date(from: components)!
        }
    }
}
