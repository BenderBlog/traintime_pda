// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

/// 单个日期格的预计算数据；绘制阶段不再重复调用 `Calendar`。
struct MonthCalendarCell: Equatable {
    let date: Date
    let text: String
}

/// 单个月份预计算模型；最多保存 42 个轻量日期值，不创建按钮视图。
struct MonthCalendarPageModel: Identifiable, Equatable {
    let monthStart: Date
    let cells: [MonthCalendarCell?]
    let rowCount: Int

    var id: Date { monthStart }
}

/// 某个有日程日期底部的五段节次标记。
///
/// 数组固定对应 `1–2、3–4、5–6、7–8、9–10` 节；`nil` 表示该段没有
/// 日程，Canvas 会使用暗白色占位。没有任何日程的日期不会创建此模型。
struct MonthPeriodMarker {
    let segmentCourses: [WatchCourse?]
}

/// 月份分页器的一组原子缓存。
///
/// 日期网格和课程标记必须来自同一个月份窗口。把两份字典包装成一个值，
/// 可以避免连续跨月和吸附完成时只替换其中一份，造成日期与色条短暂错位。
struct MonthCalendarWindow {
    let models: [Date: MonthCalendarPageModel]
    let periodMarkers: [Date: [Int: MonthPeriodMarker]]
}

/// 月视图专用的内存缓存。
///
/// Store 只需要提供持久化派生索引，月份日期模型、五段标记和三页窗口的生命
/// 周期全部由该类型管理。日期模型不依赖课表，可以跨同步复用；五段标记引用
/// 当前课表中的课程，因此课表索引替换时必须单独失效。
struct MonthCalendarCache {
    private var models: [Date: MonthCalendarPageModel] = [:]
    private var periodMarkers: [Date: [Int: MonthPeriodMarker]] = [:]

    /// 预生成目标月份前、中、后三页所需的全部轻量数据。
    mutating func prewarm(
        around date: Date,
        periodCourseIDsByDay: [Date: [String?]],
        coursesByID: [String: WatchCourse]
    ) {
        for month in monthCalendarPageStarts(centeredOn: date) {
            let model = model(for: month)
            guard periodMarkers[month] == nil else { continue }
            periodMarkers[month] = makePeriodMarkers(
                for: model,
                periodCourseIDsByDay: periodCourseIDsByDay,
                coursesByID: coursesByID
            )
        }
    }

    /// 返回已成组准备好的三页窗口，确保日期和颜色标记来自同一批缓存。
    mutating func window(
        centeredOn date: Date,
        periodCourseIDsByDay: [Date: [String?]],
        coursesByID: [String: WatchCourse]
    ) -> MonthCalendarWindow {
        prewarm(
            around: date,
            periodCourseIDsByDay: periodCourseIDsByDay,
            coursesByID: coursesByID
        )
        let starts = monthCalendarPageStarts(centeredOn: date)
        return MonthCalendarWindow(
            models: Dictionary(
                uniqueKeysWithValues: starts.compactMap { month in
                    models[month].map { (month, $0) }
                }
            ),
            periodMarkers: Dictionary(
                uniqueKeysWithValues: starts.map { month in
                    (month, periodMarkers[month] ?? [:])
                }
            )
        )
    }

    /// 课表发生变化时只清除课程相关标记，保留确定性的月份日期网格。
    mutating func invalidateScheduleMarkers() {
        periodMarkers.removeAll(keepingCapacity: true)
    }

    /// 返回已有模型；缺失时只计算一次并存入缓存。
    private mutating func model(for month: Date) -> MonthCalendarPageModel {
        let normalizedMonth = monthCalendarStart(for: month)
        if let cached = models[normalizedMonth] {
            return cached
        }
        let newModel = makeMonthCalendarPageModel(for: normalizedMonth)
        models[normalizedMonth] = newModel
        return newModel
    }

    /// 把持久化课程 ID 索引转换为 Canvas 可直接读取的课程引用。
    private func makePeriodMarkers(
        for model: MonthCalendarPageModel,
        periodCourseIDsByDay: [Date: [String?]],
        coursesByID: [String: WatchCourse]
    ) -> [Int: MonthPeriodMarker] {
        var markers: [Int: MonthPeriodMarker] = [:]
        markers.reserveCapacity(model.cells.count)
        let calendar = Calendar.current

        for (index, cell) in model.cells.enumerated() {
            guard let cell else { continue }
            let day = calendar.startOfDay(for: cell.date)
            guard let courseIDs = periodCourseIDsByDay[day] else { continue }
            let courses = courseIDs.map { courseID in
                courseID.flatMap { coursesByID[$0] }
            }
            markers[index] = MonthPeriodMarker(segmentCourses: courses)
        }
        return markers
    }
}

/// 返回一个月窗口内的三个自然月起点。
func monthCalendarPageStarts(centeredOn month: Date) -> [Date] {
    let calendar = Calendar.current
    let normalizedMonth = monthCalendarStart(for: month)
    let previous = calendar.date(
        byAdding: .month,
        value: -1,
        to: normalizedMonth
    ) ?? normalizedMonth
    let next = calendar.date(
        byAdding: .month,
        value: 1,
        to: normalizedMonth
    ) ?? normalizedMonth
    return [previous, normalizedMonth, next].map {
        monthCalendarStart(for: $0)
    }
}

/// 将一个自然月预计算成周一开头的 5 或 6 行日期模型。
func makeMonthCalendarPageModel(
    for month: Date
) -> MonthCalendarPageModel {
    let calendar = Calendar.current
    let monthStart = monthCalendarStart(for: month)
    guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart)
    else {
        return MonthCalendarPageModel(
            monthStart: monthStart,
            cells: [],
            rowCount: 5
        )
    }

    // Apple weekday: 周日为 1；转换成“周一为第 0 列”的偏移。
    let leadingEmptyCount = (calendar.component(.weekday, from: monthStart) + 5) % 7
    let usedCellCount = leadingEmptyCount + dayRange.count
    let rowCount = min(6, max(5, Int(ceil(Double(usedCellCount) / 7))))
    let totalCellCount = rowCount * 7

    var cells = Array<MonthCalendarCell?>(
        repeating: nil,
        count: totalCellCount
    )
    for dayOffset in 0..<dayRange.count {
        guard let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: monthStart
        ) else {
            continue
        }
        cells[leadingEmptyCount + dayOffset] = MonthCalendarCell(
            date: date,
            text: String(dayOffset + 1)
        )
    }
    return MonthCalendarPageModel(
        monthStart: monthStart,
        cells: cells,
        rowCount: rowCount
    )
}

func monthCalendarStart(for date: Date) -> Date {
    let components = Calendar.current.dateComponents(
        [.year, .month],
        from: date
    )
    return Calendar.current.date(from: components) ?? date
}
