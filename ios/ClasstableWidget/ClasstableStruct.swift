//
//  ClasstableStruct.swift
//  Runner
//
//  Created by sprt on 2024/1/6.
//  SPDX-License-Identifier: MPL-2.0
//

import Foundation

struct ClasstableStruct : Codable {
    var list : [ClasstableStructItems]
}

struct ClasstableStructItems : Codable {
    var name : String
    var teacher : String
    var place : String
    var start_time : Int
    var end_time : Int
}

var TimeArray : [String] = [
    "08:30",
    "09:15",
    "09:20",
    "10:05",
    "10:25",
    "11:10",
    "11:15",
    "12:00",
    "14:00",
    "14:45",
    "14:50",
    "15:35",
    "15:55",
    "16:40",
    "16:45",
    "17:30",
    "19:00",
    "19:45",
    "19:55",
    "20:30",
]
