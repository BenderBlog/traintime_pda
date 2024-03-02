//
//  ExamModule.swift
//  ClasstableWidgetExtension
//
//  Created by BenderBlog Rodriguez on 2024/1/18.
//  SPDX-License-Identifier: MPL-2.0
//
//  Refrence to /lib/model/xidian_ids/exam.dart
//

import Foundation

struct ExamData : Codable {
    let subject : [Subject]
    let toBeArranged : [ToBeArranged]
}

class Subject : Codable {
    let subject : String
    let typeStr : String
    let startTimeStr : String
    let endTimeStr : String
    let time : String
    let place : String
    let seat : Int
    
    var startTime : Date {
        get {
            let format : String = "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            return dateFormatter.date(from: startTimeStr)!
        }
    }
    
    var endTime : Date {
        get {
            let format : String = "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            return dateFormatter.date(from: endTimeStr)!
        }
    }
    
    var type : String {
        get {
            if (typeStr.contains("期末考试")) { return "期末考试"; }
            if (typeStr.contains("期中考试")) { return "期中考试"; }
            if (typeStr.contains("结课考试")) { return "结课考试"; }
            if (typeStr.contains("入学")) { return "入学考试"; }
            return typeStr;
        }
    }
}

struct ToBeArranged : Codable {
    let subject : String
    let id : String
}
