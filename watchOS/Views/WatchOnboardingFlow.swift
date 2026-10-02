// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case overview, courseList, day, week, month

    var id: String { rawValue }
    var usesSelectedDate: Bool { self == .day || self == .week || self == .month }
    var hidesFloatingControlsOnEntry: Bool { self == .day || self == .month }
}

enum WatchOnboardingTapTarget: Equatable {
    case anywhere, refresh, mode, content
    case headerPrevious, headerNext, headerTitle
    case calendarDate, weekCourse, detailClose, monthTitle
}

enum WatchOnboardingOperation: Equatable {
    case tap(WatchOnboardingTapTarget)
    case longPress(WatchOnboardingTapTarget)
    case verticalSwipe, horizontalSwipe, crown, crownPage
    case selectMode(WatchCalendarMode)
    /// 由真实日期变化提交，未跨页的拖动、表冠刻度和边界回弹不计完成。
    case pageChanged
}

/// 连续动作共用任务编号；只有完整任务结束才播放成功反馈。
enum WatchOnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case overviewSwipe, overviewCrown
    case overviewControlsHide, overviewControlsShow
    case overviewRefresh
    case courseListOpen, courseListSelect
    case courseListBrowse
    case dayOpen, daySelect
    case dayPaging, dayPagingCrown
    case weekOpen, weekSelect
    case weekPaging
    case weekCourse, courseDetailClose
    case monthOpen, monthChoose
    case monthPaging, monthSelect
    case dayDatePickerOpen, dayDatePickerSelect
    case restartHold

    static let taskCount = 16
    var id: Int { rawValue }
    var next: Self? { Self(rawValue: rawValue + 1) }

    var taskNumber: Int {
        switch self {
        case .welcome: 0
        case .overviewSwipe: 1
        case .overviewCrown: 2
        case .overviewControlsHide, .overviewControlsShow: 3
        case .overviewRefresh: 4
        case .courseListOpen, .courseListSelect: 5
        case .courseListBrowse: 6
        case .dayOpen, .daySelect: 7
        case .dayPaging: 8
        case .dayPagingCrown: 9
        case .weekOpen, .weekSelect: 10
        case .weekPaging: 11
        case .weekCourse, .courseDetailClose: 12
        case .monthOpen, .monthChoose: 13
        case .monthPaging, .monthSelect: 14
        case .dayDatePickerOpen, .dayDatePickerSelect: 15
        case .restartHold: 16
        }
    }

    var completesTask: Bool {
        next?.taskNumber != taskNumber && self != .welcome
    }

    var requiredMode: WatchCalendarMode {
        switch self {
        case .welcome, .overviewSwipe, .overviewCrown,
             .overviewControlsHide, .overviewControlsShow, .overviewRefresh,
             .courseListOpen, .courseListSelect: .overview
        case .courseListBrowse, .dayOpen, .daySelect: .courseList
        case .dayPaging, .dayPagingCrown, .weekOpen, .weekSelect,
             .dayDatePickerOpen, .dayDatePickerSelect, .restartHold: .day
        case .weekPaging, .weekCourse, .courseDetailClose, .monthOpen, .monthChoose: .week
        case .monthPaging, .monthSelect: .month
        }
    }

    var destinationMode: WatchCalendarMode? {
        switch self {
        case .courseListOpen, .courseListSelect: .courseList
        case .dayOpen, .daySelect: .day
        case .weekOpen, .weekSelect: .week
        case .monthOpen, .monthChoose: .month
        default: nil
        }
    }

    var isModeSelection: Bool {
        switch self {
        case .courseListSelect, .daySelect, .weekSelect, .monthChoose: true
        default: false
        }
    }

    var menuOpenStep: Self? {
        isModeSelection ? Self(rawValue: rawValue - 1) : nil
    }

    var teachesControlVisibility: Bool {
        self == .overviewControlsHide || self == .overviewControlsShow
    }

    var isPaging: Bool { self == .dayPaging || self == .weekPaging || self == .monthPaging }

    /// 全部可用方式同时用于绘制示意；实际翻页另由 pageChanged 确认。
    var operations: [WatchOnboardingOperation] {
        switch self {
        case .welcome: [.tap(.anywhere)]
        case .overviewSwipe: [.verticalSwipe]
        case .overviewCrown: [.crown]
        case .overviewControlsHide, .overviewControlsShow: [.tap(.content)]
        case .overviewRefresh: [.tap(.refresh)]
        case .courseListOpen, .dayOpen, .weekOpen, .monthOpen: [.tap(.mode)]
        case .courseListSelect: [.selectMode(.courseList)]
        case .courseListBrowse: [.verticalSwipe, .crown]
        case .daySelect: [.selectMode(.day)]
        case .weekSelect: [.selectMode(.week)]
        case .monthChoose: [.selectMode(.month)]
        case .dayPaging:
            [.horizontalSwipe, .tap(.headerPrevious), .tap(.headerNext)]
        case .weekPaging, .monthPaging:
            [.horizontalSwipe, .tap(.headerPrevious), .tap(.headerNext), .crown]
        case .dayPagingCrown: [.crownPage]
        case .weekCourse: [.tap(.weekCourse)]
        case .courseDetailClose: [.tap(.detailClose)]
        case .monthSelect, .dayDatePickerSelect: [.tap(.calendarDate)]
        case .dayDatePickerOpen: [.tap(.headerTitle)]
        case .restartHold: [.longPress(.mode)]
        }
    }

    func accepts(_ operation: WatchOnboardingOperation) -> Bool {
        isPaging ? operation == .pageChanged : operations.contains(operation)
    }

    /// 浏览和不足一页的位移只恢复提示；不会重置页面或误算为完成。
    func ignores(_ operation: WatchOnboardingOperation) -> Bool {
        if isPaging, operations.contains(operation) { return true }
        switch operation {
        case .verticalSwipe, .horizontalSwipe, .crown, .crownPage, .pageChanged:
            return self != .overviewSwipe && self != .overviewCrown
        default:
            return false
        }
    }
}
