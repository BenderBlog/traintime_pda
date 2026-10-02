// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import SwiftUI

/// 手机向手表分阶段发送课表时使用的范围。
///
/// 分阶段的目的，是让当天内容最快出现；随后再逐步扩大到 14 天和整个学期。
extension WatchScheduleScope {
    /// 刷新动画旁显示的当前阶段本地化文字。
    var progressTitle: String {
        switch self {
        case .today:
            watchLocalizedString("正在获取今天")
        case .fourteenDays:
            watchLocalizedString("正在获取近 14 天")
        case .semester:
            watchLocalizedString("正在获取整个学期")
        }
    }
}

/// 节次推断使用的标准时间边界，单位为当天零点后的分钟数。
///
/// 只有旧缓存或特殊日程缺少明确节次时才使用这些边界。正常课程会直接采用
/// 手机端传来的 `startSection` 和 `endSection`，因此不会受推断误差影响。
private enum CoursePeriodReference {
    static let validRange = 1...11
    static let startMinutes = [
        510, 560, 625, 675, 840, 890, 955, 1005, 1140, 1195, 1240,
    ]
    static let endMinutes = [
        555, 605, 670, 720, 885, 935, 1000, 1050, 1185, 1235, 1285,
    ]
}

/// 手表端统一使用的日程模型。
///
/// 名称沿用 `WatchCourse` 以保持缓存兼容，但 `kind` 也可以表示考试和实验。
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

    /// 把手机传来的毫秒时间戳转换为 Foundation 日期。
    var startAt: Date {
        WatchScheduleDate.date(fromEpochMilliseconds: startAtEpochMs)
    }

    /// 日程结束时间。
    var endAt: Date {
        WatchScheduleDate.date(fromEpochMilliseconds: endAtEpochMs)
    }

    /// 开始节次。缺少明确节次时，按开始时间寻找最近的标准节次。
    var startPeriod: Int {
        normalizedPeriod(startSection) ?? inferredPeriod(
            from: startAt,
            isStart: true
        )
    }

    /// 结束节次。缺少明确节次时，按结束时间寻找最近的标准节次。
    var endPeriod: Int {
        normalizedPeriod(endSection) ?? inferredPeriod(
            from: endAt,
            isStart: false
        )
    }

    /// 将手机端 ARGB 颜色转换为 SwiftUI 颜色。
    var color: Color {
        let value = unsignedARGBValue()
        return Color(
            red: colorComponent(value, shift: 16),
            green: colorComponent(value, shift: 8),
            blue: colorComponent(value, shift: 0)
        )
    }

    /// 在详情页中显示的日程类型名称；普通课程无需额外标签。
    var kindTitle: String? {
        switch kind {
        case "exam":
            watchLocalizedString("考试")
        case "physicsExperiment":
            watchLocalizedString("物理实验")
        case "otherExperiment":
            watchLocalizedString("实验")
        default:
            nil
        }
    }

    /// 与日程类型匹配的 SF Symbol。
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

    var isExam: Bool { kind == "exam" }
    var isExperiment: Bool { kind == "physicsExperiment" || kind == "otherExperiment" }

    var classroomText: String? { WatchScheduleText.nonempty(classroom) }

    /// 只翻译快照生成器添加的考试座位前缀，缓存和学校原始备注保持原文。
    var localizedNote: String? {
        guard let note = WatchScheduleText.nonempty(note) else { return nil }
        guard isExam, note.hasPrefix("座位 "),
              let seat = WatchScheduleText.nonempty(String(note.dropFirst(3)))
        else { return note }
        return watchLocalizedFormat("座位 %@", seat)
    }

    /// App 卡片和 Widget 共用位置/教师/考试备注的选择及空值处理。
    func locationSummary(
        includingDetails: Bool,
        fallbackLocation: String? = nil
    ) -> (text: String, systemImage: String)? {
        let location = classroomText ?? fallbackLocation
        var values = [String]()
        if let location { values.append(location) }
        if includingDetails,
           let details = WatchScheduleText.singleLine(isExam ? localizedNote : teacher) {
            values.append(details)
        }
        guard !values.isEmpty else { return nil }
        let symbol = location != nil ? "mappin.and.ellipse" : (isExam ? "number.square" : "person")
        return (values.joined(separator: " · "), symbol)
    }

    /// 只接受课表支持范围内的明确节次。
    private func normalizedPeriod(_ value: Int?) -> Int? {
        guard let value,
              CoursePeriodReference.validRange.contains(value)
        else {
            return nil
        }
        return value
    }

    /// 根据时间与标准节次边界的距离推断最接近的节次。
    private func inferredPeriod(from date: Date, isStart: Bool) -> Int {
        let minutes = minutesSinceStartOfDay(for: date)
        let boundaries = isStart
            ? CoursePeriodReference.startMinutes
            : CoursePeriodReference.endMinutes
        return nearestPeriod(to: minutes, boundaries: boundaries)
    }

    /// 计算某个时间是当天第几分钟。
    private func minutesSinceStartOfDay(for date: Date) -> Int {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: date
        )
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    /// 从标准边界中选择距离目标分钟数最近的一项。
    private func nearestPeriod(
        to minutes: Int,
        boundaries: [Int]
    ) -> Int {
        let nearest = boundaries.enumerated().min {
            abs($0.element - minutes) < abs($1.element - minutes)
        }
        return (nearest?.offset ?? 0) + 1
    }

    /// 将可能缺失的 ARGB 值转为无符号位图，默认使用 Material 蓝色。
    private func unsignedARGBValue() -> UInt64 {
        UInt64(bitPattern: colorARGB ?? Int64(0xFF2196F3))
    }

    /// 从 ARGB 位图中提取并归一化单个 RGB 通道。
    private func colorComponent(
        _ value: UInt64,
        shift: UInt64
    ) -> Double {
        Double((value >> shift) & 0xFF) / 255
    }
}

/// 一次完整同步阶段的课表快照。
///
/// 快照包含有效期和范围边界，因此 App 与 Widget 可以判断何时使用缓存、
/// 何时回退到其他阶段的数据。
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
    /// 完整学期边界，在当天/14 天切片中也保留。旧协议缺少时由学期缓存补齐。
    var semesterEndEpochMs: Int64? = nil
    /// 手机单调递增的状态修订号，用于时钟调整后的缓存排序。
    var sourceRevision: Int64? = nil
    var freshnessStamp: Int64 { sourceRevision ?? generatedAtEpochMs }

    /// 快照在手机端生成的时间。
    var generatedAt: Date {
        WatchScheduleDate.date(fromEpochMilliseconds: generatedAtEpochMs)
    }

    /// 学期第一周参考日期；旧数据可能没有该字段。
    var semesterStart: Date? {
        guard let semesterStartEpochMs else { return nil }
        return WatchScheduleDate.date(fromEpochMilliseconds: semesterStartEpochMs)
    }

    /// 当前缓存建议被视为有效的截止时间。
    var validThrough: Date {
        WatchScheduleDate.date(fromEpochMilliseconds: validThroughEpochMs)
    }

    /// 快照覆盖范围的开始；旧缓存缺少范围时使用最早日程，不依赖输入排序。
    var rangeStart: Date {
        guard let rangeStartEpochMs else {
            return courses.min(by: { $0.startAtEpochMs < $1.startAtEpochMs })?.startAt ?? generatedAt
        }
        return WatchScheduleDate.date(fromEpochMilliseconds: rangeStartEpochMs)
    }

    /// 快照覆盖范围的结束；旧缓存缺少范围时使用最晚结束时间。
    var rangeEnd: Date {
        guard let rangeEndEpochMs else {
            return courses.max(by: { $0.endAtEpochMs < $1.endAtEpochMs })?.endAt ?? validThrough
        }
        return WatchScheduleDate.date(fromEpochMilliseconds: rangeEndEpochMs)
    }

    /// 分页合并只替换课程数组，所有协议元数据集中在这里保留。
    func replacingCourses(_ courses: [WatchCourse]) -> Self {
        Self(
            schemaVersion: schemaVersion,
            generatedAtEpochMs: generatedAtEpochMs,
            semesterStartEpochMs: semesterStartEpochMs,
            currentWeekIndex: currentWeekIndex,
            validThroughEpochMs: validThroughEpochMs,
            rangeStartEpochMs: rangeStartEpochMs,
            rangeEndEpochMs: rangeEndEpochMs,
            timeZoneOffsetMinutes: timeZoneOffsetMinutes,
            reminderMinutes: reminderMinutes,
            courses: courses,
            semesterEndEpochMs: semesterEndEpochMs,
            sourceRevision: sourceRevision
        )
    }
}

/// 分页事务只在内存累积；元数据一致且最后一页完成后才能生成可安装快照。
struct WatchSemesterTransfer {
    private var metadata: WatchScheduleSnapshot?
    private var coursesByID: [String: WatchCourse] = [:]

    mutating func append(_ chunk: WatchScheduleSnapshot) throws {
        let incomingMetadata = chunk.replacingCourses([])
        if let metadata, metadata != incomingMetadata {
            throw WatchScheduleDataError.inconsistentSemester
        }
        metadata = incomingMetadata
        for course in chunk.courses { coursesByID[course.id] = course }
    }

    func completedSnapshot() throws -> WatchScheduleSnapshot {
        guard let metadata else { throw WatchScheduleDataError.inconsistentSemester }
        return metadata.replacingCourses(WatchScheduleResolver.sorted(Array(coursesByID.values)))
    }

    mutating func reset(keepingCapacity: Bool) {
        metadata = nil
        coursesByID.removeAll(keepingCapacity: keepingCapacity)
    }
}

/// 数据层错误只进入现有诊断日志；用户提示由调用方使用本地化资源提供。
enum WatchScheduleDataError: LocalizedError {
    case unsupportedSchema(Int)
    case inconsistentSemester
    case outdatedSnapshot

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version): "Unsupported schedule schema: \(version)"
        case .inconsistentSemester: "Semester chunks have inconsistent metadata"
        case .outdatedSnapshot: "Schedule snapshot is older than the installed cache"
        }
    }
}
