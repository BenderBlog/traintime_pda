//
//  ExamModule.swift
//  ClasstableWidgetExtension
//
//  SPDX-License-Identifier: MPL-2.0
//
//  Refrence to /lib/model/xidian_ids/exam.dart
//

import Foundation


struct ExamData : Codable {
    var subject : [Subject]
}

struct Subject : Codable {
    var subject : String
    var typeStr : String
    var startTimeStr : String
    var endTimeStr : String
    var place : String
    var seat : Int
    
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
