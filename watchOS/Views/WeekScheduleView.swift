// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

struct CourseListView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    let onCrownInteraction: () -> Void

    private var groups: [CourseDayGroup] {
        let grouped = Dictionary(grouping: store.allCourses) {
            Calendar.current.startOfDay(for: $0.startAt)
        }
        return grouped.keys.sorted().map { date in
            CourseDayGroup(date: date, courses: grouped[date] ?? [])
        }
    }

    var body: some View {
        if groups.isEmpty {
            ContentUnavailableView("暂无课程", systemImage: "list.bullet")
        } else {
            InteractionAwareScrollView(onScroll: onCrownInteraction) {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(groups) { group in
                        Text(
                            group.date,
                            format: .dateTime.month().day().weekday(.wide)
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.top, 2)
                        .padding(.trailing, 32)

                        ForEach(group.courses) { course in
                            CourseRow(
                                course: course,
                                showsInlineMetadata: true
                            )
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 1)
            }
        }
    }
}

struct DayScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    let onCrownInteraction: () -> Void

    private var courses: [WatchCourse] {
        store.courses(on: selectedDate)
    }

    var body: some View {
        GeometryReader { proxy in
            let topBarContentInset = max(26, proxy.size.height * 0.13)

            VStack(spacing: max(2, proxy.size.height * 0.012)) {
                if courses.isEmpty {
                    ContentUnavailableView(
                        "当天没有课程",
                        systemImage: "cup.and.saucer"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    InteractionAwareScrollView(
                        onScroll: onCrownInteraction
                    ) {
                        LazyVStack(spacing: 5) {
                            ForEach(courses) { course in
                                CourseRow(
                                    course: course,
                                    showsInlineMetadata: true
                                )
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.top, 1)
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .padding(.top, topBarContentInset)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DateNavigationHeader(
                    title: selectedDate.formatted(
                        .dateTime.month().day().weekday(.short)
                    ),
                    previous: { moveDay(-1) },
                    next: { moveDay(1) }
                )
                .frame(width: 116)
                .offset(y: -10)
            }
        }
    }

    private func moveDay(_ amount: Int) {
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: amount,
            to: selectedDate
        ) ?? selectedDate
    }
}

struct WeekScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var anchorDate = Date()
    @State private var selectedCourse: WatchCourse?
    @State private var crownValue = 0.0
    @FocusState private var crownFocused: Bool
    let onEmptyTap: () -> Void
    let onCrownInteraction: () -> Void

    private var weekStart: Date {
        startOfWeek(containing: anchorDate)
    }

    private var courses: [WatchCourse] {
        let end = Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: weekStart
        ) ?? weekStart
        return store.allCourses.filter {
            $0.startAt >= weekStart && $0.startAt < end
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                let topBarContentInset = max(26, proxy.size.height * 0.13)
                let weekdayHeight = max(15, proxy.size.height * 0.075)

                VStack(spacing: max(1, proxy.size.height * 0.008)) {
                    WeekdayHeader(weekStart: weekStart)
                        .frame(height: weekdayHeight)
                        .offset(y: 2)

                    WeekPeriodGrid(
                        courses: courses,
                        select: selectCourse,
                        onEmptyTap: handleEmptyTap
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
                }
                .padding(.top, topBarContentInset)
            }

            if let selectedCourse {
                CourseDetailView(
                    course: selectedCourse,
                    showsTopCloseButton: true
                ) {
                    withAnimation(detailAnimation) {
                        self.selectedCourse = nil
                    }
                    crownFocused = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }

            crownObserver
        }
        .toolbar {
            if selectedCourse == nil {
                ToolbarItem(placement: .topBarLeading) {
                    DateNavigationHeader(
                        title: weekTitle,
                        previous: { moveWeek(-1) },
                        next: { moveWeek(1) }
                    )
                    .frame(width: 116)
                    .offset(y: -10)
                }
            }
        }
        .onAppear {
            selectedCourse = nil
            crownFocused = true
        }
    }

    private var weekTitle: String {
        if let reference = store.synchronizedWeekReference {
            let referenceWeek = startOfWeek(containing: reference.date)
            let elapsedDays = Calendar.current.dateComponents(
                [.day],
                from: referenceWeek,
                to: weekStart
            ).day ?? 0
            let zeroBasedIndex = reference.zeroBasedIndex + elapsedDays / 7
            return "第\(max(1, zeroBasedIndex + 1))周"
        }

        let termStart = startOfWeek(
            containing: store.semesterStart ?? weekStart
        )
        let elapsedDays = Calendar.current.dateComponents(
            [.day],
            from: termStart,
            to: weekStart
        ).day ?? 0
        return "第\(max(1, elapsedDays / 7 + 1))周"
    }

    private func moveWeek(_ amount: Int) {
        anchorDate = Calendar.current.date(
            byAdding: .day,
            value: amount * 7,
            to: anchorDate
        ) ?? anchorDate
    }

    private func selectCourse(_ course: WatchCourse) {
        crownFocused = false
        onCrownInteraction()
        withAnimation(detailAnimation) {
            selectedCourse = course
        }
    }

    private var detailAnimation: Animation {
        .spring(response: 0.38, dampingFraction: 0.84)
    }

    private func handleEmptyTap() {
        crownFocused = true
        onEmptyTap()
    }

    private var crownObserver: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .focusable()
            .focused($crownFocused)
            .digitalCrownRotation($crownValue)
            .onChange(of: crownValue) { _, _ in
                onCrownInteraction()
            }
            .accessibilityHidden(true)
    }
}

private struct CourseDayGroup: Identifiable {
    let date: Date
    let courses: [WatchCourse]

    var id: Date { date }
}

private struct DateNavigationHeader: View {
    let title: String
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        HStack(spacing: 1) {
            Button(action: previous) {
                Image(systemName: "chevron.left")
                    .frame(width: 18, height: 20)
            }

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .monospacedDigit()
                .frame(maxWidth: .infinity)

            Button(action: next) {
                Image(systemName: "chevron.right")
                    .frame(width: 18, height: 20)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 22)
    }
}

private struct WeekdayHeader: View {
    let weekStart: Date
    private let symbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        GeometryReader { proxy in
            let fontSize = max(6, min(8, proxy.size.width * 0.035))
            let labelWidth = max(11, min(15, proxy.size.width * 0.075))
            let month = Calendar.current.component(.month, from: weekStart)
            HStack(spacing: 0) {
                Text("\(month)月")
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .frame(width: labelWidth)

                ForEach(0..<7, id: \.self) { index in
                    let date = Calendar.current.date(
                        byAdding: .day,
                        value: index,
                        to: weekStart
                    ) ?? weekStart
                    VStack(spacing: -1) {
                        Text(symbols[index])
                        Text(date, format: .dateTime.day())
                    }
                    .font(.system(size: fontSize, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        Calendar.current.isDateInToday(date)
                            ? Color.accentColor
                            : Color.secondary
                    )
                }
            }
        }
    }
}

private struct WeekPeriodGrid: View {
    let courses: [WatchCourse]
    let select: (WatchCourse) -> Void
    let onEmptyTap: () -> Void

    private let maximumPeriod = 10
    private let totalUnits: CGFloat = 56

    private var visibleCourses: [WatchCourse] {
        courses.filter { $0.startPeriod <= maximumPeriod }
    }

    var body: some View {
        GeometryReader { proxy in
            let labelWidth = max(11, min(15, proxy.size.width * 0.075))
            let labelFontSize = max(5.5, min(7, proxy.size.width * 0.032))
            let columnWidth = max(1, (proxy.size.width - labelWidth) / 7)
            let unitHeight = max(0.5, proxy.size.height / totalUnits)

            ZStack(alignment: .topLeading) {
                Color.clear

                gridLines(
                    size: proxy.size,
                    labelWidth: labelWidth,
                    columnWidth: columnWidth,
                    unitHeight: unitHeight
                )

                ForEach(1...maximumPeriod, id: \.self) { period in
                    Text("\(period)")
                        .font(.system(size: labelFontSize, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: labelWidth, height: 8)
                        .offset(
                            x: 0,
                            y: periodStartUnit(period) * unitHeight
                                + 2.5 * unitHeight - 4
                        )
                }

                ForEach(visibleCourses) { course in
                    let start = periodStartUnit(course.startPeriod)
                    let end = periodEndUnit(course.endPeriod)
                    let weekday = weekdayIndex(for: course.startAt)

                    RoundedRectangle(
                        cornerRadius: 2.5,
                        style: .continuous
                    )
                    .fill(course.color)
                    .frame(
                        width: max(3, columnWidth - 1.5),
                        height: max(3, (end - start) * unitHeight - 1)
                    )
                    .offset(
                        x: labelWidth + CGFloat(weekday) * columnWidth + 0.75,
                        y: start * unitHeight + 0.5
                    )
                    .contentShape(Rectangle())
                    .accessibilityLabel(
                        "\(course.name)，第\(course.startPeriod)到\(course.endPeriod)节"
                    )
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction {
                        select(course)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        if let course = course(
                            at: value.location,
                            labelWidth: labelWidth,
                            columnWidth: columnWidth,
                            unitHeight: unitHeight
                        ) {
                            select(course)
                        } else {
                            onEmptyTap()
                        }
                    }
            )
        }
    }

    private func course(
        at location: CGPoint,
        labelWidth: CGFloat,
        columnWidth: CGFloat,
        unitHeight: CGFloat
    ) -> WatchCourse? {
        visibleCourses.last { course in
            let start = periodStartUnit(course.startPeriod)
            let end = periodEndUnit(course.endPeriod)
            let weekday = weekdayIndex(for: course.startAt)
            let frame = CGRect(
                x: labelWidth + CGFloat(weekday) * columnWidth + 0.75,
                y: start * unitHeight + 0.5,
                width: max(3, columnWidth - 1.5),
                height: max(3, (end - start) * unitHeight - 1)
            )
            return frame.contains(location)
        }
    }

    private func gridLines(
        size: CGSize,
        labelWidth: CGFloat,
        columnWidth: CGFloat,
        unitHeight: CGFloat
    ) -> some View {
        Path { path in
            for column in 0...7 {
                let x = labelWidth + CGFloat(column) * columnWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            for period in 1...maximumPeriod {
                let y = periodStartUnit(period) * unitHeight
                path.move(to: CGPoint(x: labelWidth, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            path.move(to: CGPoint(x: labelWidth, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
        }
        .stroke(.secondary.opacity(0.18), lineWidth: 0.5)
    }

    private func periodStartUnit(_ period: Int) -> CGFloat {
        let period = min(maximumPeriod, max(1, period))
        if period <= 4 {
            return CGFloat(period - 1) * 5
        }
        if period <= 8 {
            return CGFloat(period - 1) * 5 + 3
        }
        return CGFloat(period - 1) * 5 + 6
    }

    private func periodEndUnit(_ period: Int) -> CGFloat {
        periodStartUnit(period) + 5
    }

    private func weekdayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return max(0, min(6, (weekday + 5) % 7))
    }
}

private func startOfWeek(containing date: Date) -> Date {
    let calendar = Calendar.current
    let day = calendar.startOfDay(for: date)
    let weekday = calendar.component(.weekday, from: day)
    return calendar.date(
        byAdding: .day,
        value: -(weekday + 5) % 7,
        to: day
    ) ?? day
}

struct InteractionAwareScrollView<Content: View>: View {
    let onScroll: () -> Void
    @ViewBuilder let content: () -> Content
    @State private var previousOffset: CGFloat?

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(
                        in: .named("watchScheduleScroll")
                    ).minY
                )
            }
            .frame(height: 0)

            content()
        }
        .coordinateSpace(name: "watchScheduleScroll")
        .scrollIndicators(.hidden)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            guard let previousOffset else {
                self.previousOffset = offset
                return
            }
            self.previousOffset = offset
            guard abs(offset - previousOffset) > 0.25 else { return }
            onScroll()
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
