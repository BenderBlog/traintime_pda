// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  ClasstableWidgetBundle.swift
//  ClasstableWidget
//
//  Created by BenderBlog Rodriguez on 2024/1/7.
//

import ActivityKit
import SwiftUI
import WidgetKit

@main
struct ClasstableWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClasstableWidget()

        /// The class which is going on, shown in the Dynamic Island and on the
        /// lock screen.
        if #available(iOSApplicationExtension 16.2, *) {
            CourseLiveActivityWidget()
        }
    }
}

/// The state of the class which is going on.
///
/// The very same declaration is compiled into the app as well, ActivityKit
/// matches the two by name.
@available(iOSApplicationExtension 16.2, *)
struct CourseActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var name: String
        /// A very short form of the name, for the collapsed island.
        var shortTitle: String
        /// The classroom and the teacher.
        var location: String
        /// "第 3-4 节"
        var periodText: String
        /// "08:30 - 10:05"
        var timeText: String
        /// "下一节 10:25 · B-106"
        var nextText: String
        /// "即将开始", shown while the class has not begun yet.
        var upcomingText: String
        /// How many class periods the lesson takes.
        var periods: Int
        var startDate: Date
        var endDate: Date
        /// The colour of the course card, in the `#RRGGBB` form.
        var colorHex: String
    }

    var courseId: String
}

@available(iOSApplicationExtension 16.2, *)
struct CourseLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CourseActivityAttributes.self) { context in
            CourseActivityLockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    /// The name alone, without the badge.
                    ///
                    /// The badge would only repeat the name which is written
                    /// out right next to it - the Android side defaults to no
                    /// badge for the same reason - and in this region it is
                    /// drawn as a blob with its top right corner bitten off,
                    /// whether it is wrapped in a `Label` or laid out by hand,
                    /// while the very same badge is a clean rounded square in
                    /// the collapsed island. The collapsed island, which has
                    /// room for a couple of characters and nothing else, keeps
                    /// it.
                    ///
                    /// One line only: measured with the class period on a line
                    /// of its own, the panel grew six points where a line is
                    /// worth twenty one, and the system took the missing line
                    /// out of the bottom of the panel, cutting the last row in
                    /// half. The period sits next to the time below instead,
                    /// where there is room for it.
                    Text(context.state.name)
                        .font(.caption)
                        .lineLimit(1)
                        /// This region masks its content a couple of points in
                        /// from its own leading edge - the same mask that took
                        /// the corner off the badge when the badge lived here -
                        /// and it cuts the first character of the name by about
                        /// two points. A four point inset was not enough to
                        /// clear it, so the name is given a wider berth.
                        .padding(.leading, 10)
                        .foregroundStyle(CourseActivityColor.of(context.state.colorHex))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    CourseActivityCountdown(state: context.state)
                        .font(.caption)
                        .monospacedDigit()
                        .frame(maxWidth: 64)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    CourseActivityProgress(state: context.state)
                }
            } compactLeading: {
                CourseActivityBadge(state: context.state)
            } compactTrailing: {
                CourseActivityCountdown(state: context.state)
                    .monospacedDigit()
                    .frame(maxWidth: 56)
            } minimal: {
                CourseActivityBadge(
                    state: context.state,
                    singleCharacter: true
                )
            }
            .keylineTint(CourseActivityColor.of(context.state.colorHex))
        }
    }
}

/// The short name of the course on its own colour.
///
/// The collapsed island has room for a couple of characters only; showing the
/// name there tells more than the icon of the app would.
@available(iOSApplicationExtension 16.2, *)
private struct CourseActivityBadge: View {
    let state: CourseActivityAttributes.ContentState
    var singleCharacter: Bool = false

    var body: some View {
        Text(label)
            /// Two Chinese characters measure 21.9 points at 11, which is wider
            /// than the badge: the text could only be made to fit by shrinking
            /// it to the very edge, where the ink of the outer strokes was
            /// shaved off, or by insetting it, which came out as a badge with a
            /// corner bitten out of it. Nine points leaves about a point of
            /// colour on either side without asking the layout for anything.
            .font(.system(size: 9, weight: .semibold))
            .lineLimit(1)
            /// A safety net for the long single words of a Latin course name.
            .minimumScaleFactor(0.8)
            .foregroundStyle(.white)
            .frame(width: 20, height: 20)
            .background(
                CourseActivityColor.of(state.colorHex),
                in: RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
    }

    private var label: String {
        let name = state.shortTitle.isEmpty ? state.name : state.shortTitle
        return singleCharacter ? String(name.prefix(1)) : String(name.prefix(2))
    }
}

/// The countdown shown inside the island: it runs towards the beginning of the
/// class, and towards its end once the class has started. The system keeps it
/// up to date on its own.
///
/// Once the class is over there is nothing left to count towards - the widget
/// would otherwise keep counting past the end - so a tick takes its place, and
/// the activity itself goes stale at the same moment.
@available(iOSApplicationExtension 16.2, *)
private struct CourseActivityCountdown: View {
    let state: CourseActivityAttributes.ContentState

    var body: some View {
        if Date() < state.startDate {
            Text(timerInterval: Date()...state.startDate, countsDown: true)
        } else if Date() < state.endDate {
            Text(timerInterval: Date()...state.endDate, countsDown: true)
        } else {
            Image(systemName: "checkmark")
        }
    }
}

/// The progress of the class, from its start to its end. It is animated by the
/// system as well.
@available(iOSApplicationExtension 16.2, *)
private struct CourseActivityProgress: View {
    let state: CourseActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(headline)
                    .font(.caption2)
                    .monospacedDigit()
                    .lineLimit(1)

                Spacer(minLength: 4)

                if !state.location.isEmpty {
                    Text(state.location)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            .foregroundStyle(.secondary)

            ProgressView(
                timerInterval: state.startDate...state.endDate,
                countsDown: false
            )
            .tint(CourseActivityColor.of(state.colorHex))
            /// A progress view built from a timer carries a label with the time
            /// left in it. That label is a line of its own, and the island has
            /// no room for it: it pushed the footnote out of the expanded
            /// island, where the system cut it in half. The countdown is
            /// already shown next to the course, so the label goes.
            .labelsHidden()
            /// Its own height is not a number the layout can count on, so the
            /// bar is pinned to one: what it reports and what it draws agree.
            .frame(height: 4)

            if !footnote.isEmpty {
                Text(footnote)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        /// The expanded island draws its panel a few points shorter than the
        /// content it was given - measured by taking a line away and watching
        /// the panel follow, only ever a few points short - which left the
        /// bottom half of this last line outside the panel. Asking the slack
        /// back here gives the line its room again. The lock screen, which
        /// shares this view, simply gets a little more air under the bar.
        .padding(.bottom, 8)
    }

    /// The line above the bar: which periods the class takes, and when it runs.
    ///
    /// The island shows the period here rather than under the name, so that the
    /// name and the countdown each stay on one line. Nothing is dropped: the
    /// period, the time and the room are all still on the card.
    private var headline: String {
        [state.periodText, state.timeText.isEmpty ? timeRange : state.timeText]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    /// The line under the bar.
    ///
    /// Before the class begins the countdown runs towards its start, which looks
    /// exactly like the countdown to the end of a class, so the hint that it has
    /// not begun yet comes first - the same line the Android side shows. Once it
    /// has begun the class which comes next is worth more than the clock.
    private var footnote: String {
        if Date() < state.startDate {
            return [state.upcomingText, state.timeText]
                .filter { !$0.isEmpty }
                .joined(separator: " · ")
        }
        return state.nextText.isEmpty ? state.timeText : state.nextText
    }

    private var timeRange: String {
        "\(CourseActivityColor.time(state.startDate)) - \(CourseActivityColor.time(state.endDate))"
    }
}

/// The same information, laid out for the lock screen.
@available(iOSApplicationExtension 16.2, *)
private struct CourseActivityLockScreenView: View {
    let context: ActivityViewContext<CourseActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundStyle(CourseActivityColor.of(context.state.colorHex))

            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.name)
                    .font(.headline)
                    .lineLimit(1)

                CourseActivityProgress(state: context.state)
            }

            Spacer(minLength: 8)

            CourseActivityCountdown(state: context.state)
                .font(.callout)
                .monospacedDigit()
        }
        .padding()
        .foregroundStyle(.white)
    }
}

@available(iOSApplicationExtension 16.2, *)
enum CourseActivityColor {
    /// Turns the `#RRGGBB` (or `#AARRGGBB`) string of the app into a colour.
    static func of(_ hex: String) -> Color {
        var value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if value.count == 6 {
            value = "FF" + value
        }
        guard value.count == 8, let raw = UInt64(value, radix: 16) else {
            return .accentColor
        }

        return Color(
            .sRGB,
            red: Double((raw >> 16) & 0xFF) / 255.0,
            green: Double((raw >> 8) & 0xFF) / 255.0,
            blue: Double(raw & 0xFF) / 255.0,
            opacity: Double((raw >> 24) & 0xFF) / 255.0
        )
    }

    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
