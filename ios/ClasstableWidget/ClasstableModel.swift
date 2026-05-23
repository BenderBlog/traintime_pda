// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  ClasstableModel.swift
//  ClasstableWidgetExtension
//
//  Created by BenderBlog Rodriguez on 2024/1/13.
//
//  Refrence to /lib/model/xidian_ids/classtable.dart
//

import Foundation

/// Do not care but anyway...
struct NotArrangedClassDetail : Codable{
    var name : String
    var code : String?
    var number : String?
    var teacher : String?
}

struct Source: RawRepresentable, Codable, Equatable {
    static let empty = Source(rawValue: "empty")
    static let school = Source(rawValue: "school")
    static let experiment = Source(rawValue: "experiment")
    static let exam = Source(rawValue: "exam")
    static let user = Source(rawValue: "user")

    let rawValue: String
}

struct ClassDetail : Codable {
    var name : String
    var code : String?
    var number : String?
}

struct TimeArrangement : Codable {
    var index : Int
    var week_list : [Bool]
    var teacher : String?
    var day : Int
    var start : Int
    var stop : Int
    var source : Source
    var classroom : String?
    
    var step : Int {
        get { return stop - start;}
    }
}

struct ClassChange : Codable {
    struct ChangeType: RawRepresentable, Codable {
        static let change = ChangeType(rawValue: "change")
        static let stop = ChangeType(rawValue: "stop")
        static let patch = ChangeType(rawValue: "patch")

        let rawValue: String
    }
    
    /// KCH 课程号
    var classCode : String

    /// KXH 班级号
    var classNumber : String

    /// KCM 课程名
    var className : String

    /// 来自 SKZC 原周次信息，可能是空
    var originalAffectedWeeks : [Bool]?

    /// 来自 XSKZC 新周次信息，可能是空
    var newAffectedWeeks : [Bool]?

    /// YSKJS 原先的老师
    var originalTeacherData : String?

    /// XSKJS 新换的老师
    var newTeacherData : String?

    /// KSJS-JSJC 原先的课次信息
    var originalClassRange : [Int]

    /// XKSJS-XJSJC 新的课次信息
    var newClassRange : [Int]

    /// SKXQ 原先的星期
    var originalWeek : Int?

    /// XSKXQ 现在的星期
    var newWeek : Int?

    /// JASMC 旧教室
    var originalClassroom : String?

    /// XJASMC 新教室
    var newClassroom : String?

    var originalAffectedWeeksList : [Int] {
        get {
            if (originalAffectedWeeks == nil) {
              return [];
            }
            var toReturn : [Int] = [];
            for i in originalAffectedWeeks!.indices {
                if originalAffectedWeeks![i] {
                    toReturn.append(i)
                }
            }
            return toReturn;
        }
    }

    var newAffectedWeeksList : [Int] {
        get {
            if newAffectedWeeks == nil {
                return []
            }
            
            var toReturn : [Int] = [];
            for i in newAffectedWeeks!.indices {
                if newAffectedWeeks![i]{
                    toReturn.append(i)
                }
            }
            return toReturn;
        }
    }

    var isTeacherChanged : Bool {
        get {
            var originalTeacherCodeStr : [String] = originalTeacherData?.replacingOccurrences(of: " ", with: "").components(separatedBy: [",","/"]) ?? []
            originalTeacherCodeStr.removeAll(where: { $0.range(of: "[0-9]", options: .regularExpression) == nil })
            var originalTeacherCode : [Int] = []
            for i in originalTeacherCodeStr {
                originalTeacherCode.append(Int(i)!)
            }
            
            var newTeacherCodeStr : [String] = originalTeacherData?.replacingOccurrences(of: " ", with: "").components(separatedBy: [",","/"]) ?? []
            newTeacherCodeStr.removeAll(where: { $0.range(of: "[0-9]", options: .regularExpression) == nil })
            var newTeacherCode : [Int] = []
            for i in newTeacherCodeStr {
                newTeacherCode.append(Int(i)!)
            }
            
            return Set(originalTeacherCode) == Set(newTeacherCode)
        }
    }
}

struct ClassTableData : Codable {
    var semesterLength : Int
    var semesterCode : String
    var termStartDay : String
    var classDetail : [ClassDetail]
    var notArranged : [NotArrangedClassDetail]
    var timeArrangement : [TimeArrangement]
    var classChanges : [ClassChange]

    enum CodingKeys: String, CodingKey {
        case semesterLength, semesterCode, termStartDay
        case classDetail, notArranged
        case timeArrangement, classChanges
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        semesterLength = try container.decode(Int.self, forKey: .semesterLength)
        semesterCode = try container.decode(String.self, forKey: .semesterCode)
        termStartDay = try container.decode(String.self, forKey: .termStartDay)
        classDetail = try container.decode([ClassDetail].self, forKey: .classDetail)
        notArranged = try container.decodeIfPresent([NotArrangedClassDetail].self, forKey: .notArranged) ?? []
        timeArrangement = try container.decode([TimeArrangement].self, forKey: .timeArrangement)
        classChanges = try container.decodeIfPresent([ClassChange].self, forKey: .classChanges) ?? []
    }

    /// Only allowed to be used with classDetail
    func getClassName(t : TimeArrangement) -> String {
        switch (t.source) {
            case .school:
                return classDetail[t.index].name;
            case .user:
                return "Unknown Custom Class"
            case .exam:
                return "Unknown Exam"
            case .experiment:
                return "Unknown Experiment"
            case .empty:
                return "Unknown Empty"
            default:
                return "Unknown None"
        }
    }
}

var Time : [String] = [
  "8:30",
  "9:15",
  "9:20",
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
  "20:35",
]

var TimeInt : [(Int, Int)] = [
  (8,30),
  (9,15),
  (9,20),
  (10,05),
  (10,25),
  (11,10),
  (11,15),
  (12,00),
  (14,00),
  (14,45),
  (14,50),
  (15,35),
  (15,55),
  (16,40),
  (16,45),
  (17,30),
  (19,00),
  (19,45),
  (19,55),
  (20,35),
  (20,40),
  (21,25),
]
