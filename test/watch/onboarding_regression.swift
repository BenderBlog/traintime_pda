// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

@main
struct OnboardingRegression {
    static var assertions = 0

    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        assertions += 1
        precondition(condition(), message)
    }

    static func main() {
        var step = WatchOnboardingStep.overviewSwipe
        var completedTasks = 0
        let journey: [WatchOnboardingOperation] = [
            .verticalSwipe, .crown,
            .tap(.content), .tap(.content), .tap(.refresh),
            .tap(.mode), .selectMode(.courseList),
            .crown,
            .tap(.mode), .selectMode(.day),
            .pageChanged, .crownPage,
            .tap(.mode), .selectMode(.week), .pageChanged,
            .tap(.weekCourse), .tap(.detailClose),
            .tap(.mode), .selectMode(.month),
            .pageChanged, .tap(.calendarDate),
            .tap(.headerTitle), .tap(.calendarDate),
        ]
        for operation in journey {
            check(step.accepts(operation), "Real user journey must advance at \(step)")
            if step.completesTask { completedTasks += 1 }
            guard let next = step.next else { preconditionFailure("Premature tutorial end") }
            if !step.completesTask {
                check(next.taskNumber == step.taskNumber, "Continuous actions keep their task number")
            }
            step = next
        }
        check(completedTasks == 15, "Exactly 15 tasks precede the final hold")
        check(step == .restartHold, "Returning from the calendar leads directly to the restart gesture")
        check(step.requiredMode == .day, "The last gesture preserves the selected day's page")
        check(step.accepts(.longPress(.mode)), "Holding the real mode control completes the last task")
        check(!step.accepts(.tap(.mode)), "A short tap cannot substitute for the three-second hold")
        check(step.completesTask && step.next == nil, "The hold finishes the tutorial instead of restarting it")
        check(step.taskNumber == WatchOnboardingStep.taskCount && step.taskNumber == 16,
              "The final progress indicator is 16/16")
        completedTasks += 1
        check(completedTasks == WatchOnboardingStep.taskCount, "All 16 tasks finish once")

        check(!WatchOnboardingStep.overviewSwipe.accepts(.crown), "Overview swipe must be practiced")
        check(!WatchOnboardingStep.overviewCrown.accepts(.verticalSwipe), "Overview Crown must also be practiced")
        check(WatchOnboardingStep.courseListSelect.next == .courseListBrowse,
              "The combined browsing lesson starts immediately after entering the list")
        let listBrowse = WatchOnboardingStep.courseListBrowse
        check(listBrowse.requiredMode == .courseList, "List browsing stays in the real course list")
        for operation in [WatchOnboardingOperation.verticalSwipe, .crown] {
            check(listBrowse.accepts(operation), "Either vertical swipe or Crown completes list browsing")
            check(listBrowse.operations.contains(operation), "Both list browsing animations are offered together")
        }
        check(!listBrowse.accepts(.horizontalSwipe), "A sideways swipe does not count as vertical browsing")
        check(listBrowse.completesTask, "List browsing is a single combined task")
        check(!WatchOnboardingStep.dayPagingCrown.accepts(.crown), "A few Crown ticks do not demonstrate crossing a day")
        check(WatchOnboardingStep.dayPagingCrown.ignores(.crown), "Incomplete Crown movement remains retryable")
        check(!WatchOnboardingStep.dayPagingCrown.accepts(.pageChanged), "An arrow cannot substitute for the dedicated Crown lesson")

        for paging in [WatchOnboardingStep.dayPaging, .weekPaging, .monthPaging] {
            for input in paging.operations {
                check(!paging.accepts(input), "Input without a completed page cannot advance \(paging)")
                check(paging.ignores(input), "Valid alternatives or a boundary bounce must not fail \(paging)")
            }
            check(paging.accepts(.pageChanged), "All paging methods converge on the real page change")
            check(paging.operations.contains(.horizontalSwipe), "Swipe animation is offered")
            check(paging.operations.contains(.tap(.headerPrevious)), "Previous arrow animates with swipe")
            check(paging.operations.contains(.tap(.headerNext)), "Next arrow animates with swipe")
        }
        for paging in [WatchOnboardingStep.weekPaging, .monthPaging] {
            check(paging.operations.contains(.crown), "Week and month also show the Crown simultaneously")
        }

        for selection in WatchOnboardingStep.allCases.filter(\.isModeSelection) {
            let target = selection.destinationMode!
            check(selection.menuOpenStep?.next == selection, "Dismissing a menu returns to its actual entry")
            check(!selection.menuOpenStep!.completesTask, "Opening a menu alone cannot complete a switch")
            for candidate in WatchCalendarMode.allCases {
                check(selection.accepts(.selectMode(candidate)) == (candidate == target),
                      "Only selecting the requested destination completes the route")
            }
            check(selection.ignores(.crown), "Scrolling the menu does not count as a selection or an error")
        }
        check(WatchOnboardingStep.courseDetailClose.ignores(.verticalSwipe), "Details remain readable before closing")
        check(WatchOnboardingStep.weekCourse.ignores(.pageChanged), "An empty week can be left to find a course")
        check(WatchOnboardingStep.monthSelect.ignores(.pageChanged), "Users can keep browsing months before choosing a day")

        let openDatePicker = WatchOnboardingStep.dayDatePickerOpen
        let selectDate = WatchOnboardingStep.dayDatePickerSelect
        check(WatchOnboardingStep.monthSelect.next == openDatePicker,
              "Returning from month view immediately teaches the day view's calendar entry")
        check(openDatePicker.requiredMode == .day && selectDate.requiredMode == .day,
              "The date picker round trip keeps the selected day as its underlying page")
        check(openDatePicker.accepts(.tap(.headerTitle)), "The calendar opens through the real date title")
        check(!openDatePicker.accepts(.tap(.mode)), "The mode menu cannot replace the date title lesson")
        check(openDatePicker.next == selectDate && openDatePicker.taskNumber == selectDate.taskNumber,
              "Opening the calendar and returning share one continuous task")
        check(!openDatePicker.completesTask, "Opening the calendar alone cannot complete the round trip")
        check(selectDate.accepts(.tap(.calendarDate)), "Picking a date completes the return to day view")
        check(!selectDate.accepts(.tap(.monthTitle)), "Cancelling the picker cannot complete date selection")
        check(selectDate.ignores(.pageChanged) && selectDate.ignores(.crown),
              "Browsing for a date does not prematurely complete or fail the return lesson")
        check(selectDate.completesTask && selectDate.next == .restartHold,
              "Finishing the round trip leaves the final three-second hold next")
        print("Passed \(assertions) onboarding flow regression checks")
    }
}
