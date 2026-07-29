// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

struct CourseRow: View {
    let course: WatchCourse
    var showsDate = false
    var isProminent = false
    var showsInlineMetadata = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(course.color)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                if showsDate {
                    Text(course.startAt, format: .dateTime.month().day().weekday())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(course.name)
                    .font(isProminent ? .title3.weight(.semibold) : .headline)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text(twentyFourHourTime(course.startAt))
                    Text("–")
                    Text(twentyFourHourTime(course.endAt))
                }
                .font(.caption.monospacedDigit())

                if let locationSummary {
                    Label(
                        locationSummary.text,
                        systemImage: locationSummary.systemImage
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                }

                if isProminent,
                   let teacher = course.teacher,
                   !teacher.isEmpty
                {
                    Label(teacher, systemImage: "person")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, isProminent ? 9 : 5)
        .padding(.horizontal, isProminent ? 9 : 7)
        .background(
            course.color.opacity(0.16),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }

    private var locationSummary: (text: String, systemImage: String)? {
        let classroom = course.classroom?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        var values = [String]()

        if let classroom, !classroom.isEmpty {
            values.append(classroom)
        }

        if showsInlineMetadata {
            let metadata = course.kind == "exam"
                ? course.note
                : course.teacher
            if let metadata = metadata?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ), !metadata.isEmpty {
                values.append(metadata)
            }
        }

        guard !values.isEmpty else { return nil }
        let systemImage: String
        if let classroom, !classroom.isEmpty {
            systemImage = "mappin.and.ellipse"
        } else if course.kind == "exam" {
            systemImage = "number.square"
        } else {
            systemImage = "person"
        }
        return (values.joined(separator: " · "), systemImage)
    }
}

struct CourseDetailView: View {
    let course: WatchCourse
    var showsTopCloseButton = false
    let dismiss: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let detailTopInset = max(24, proxy.size.height * 0.13)
            let detailContentTopInset = showsTopCloseButton
                ? max(18, proxy.size.height * 0.06)
                : detailTopInset

            ZStack(alignment: .topTrailing) {
                Color.black
                    .overlay(course.color.opacity(0.08))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(course.name)
                            .font(.title3.weight(.semibold))
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                            .padding(
                                .trailing,
                                showsTopCloseButton
                                    ? max(52, proxy.size.width * 0.27)
                                    : 0
                            )

                        RoundedRectangle(
                            cornerRadius: 2,
                            style: .continuous
                        )
                        .fill(course.color)
                        .frame(width: max(34, proxy.size.width * 0.24), height: 4)

                        if let kindTitle = course.kindTitle {
                            Label(
                                kindTitle,
                                systemImage: course.kindSystemImage
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(course.color)
                        }

                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(
                                    course.startAt,
                                    format: .dateTime
                                        .month()
                                        .day()
                                        .weekday(.wide)
                                )
                                Text(
                                    "\(twentyFourHourTime(course.startAt)) – \(twentyFourHourTime(course.endAt))"
                                )
                                .monospacedDigit()
                            }
                        } icon: {
                            Image(systemName: "clock")
                                .foregroundStyle(course.color)
                        }

                        if let classroom = course.classroom,
                           !classroom.isEmpty
                        {
                            Label(
                                classroom,
                                systemImage: "mappin.and.ellipse"
                            )
                        }
                        if let teacher = course.teacher, !teacher.isEmpty {
                            Label(teacher, systemImage: "person")
                        }
                        if let note = course.note, !note.isEmpty {
                            Label(note, systemImage: "info.circle")
                        }

                        if !showsTopCloseButton {
                            Button("完成") {
                                dismiss()
                            }
                            .tint(course.color)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, max(8, proxy.size.width * 0.045))
                    .padding(.top, detailContentTopInset)
                    .padding(.bottom, 8)
                }
                .detailTopEdgeEffectHidden()

                if showsTopCloseButton {
                    topCloseButton
                        .scaleEffect(0.82)
                        .padding(.top, detailTopInset)
                        .padding(.trailing, max(3, proxy.size.width * 0.018))
                }
            }
        }
    }

    @ViewBuilder
    private var topCloseButton: some View {
        if #available(watchOS 26.0, *) {
            closeButton
                .buttonStyle(.glass)
        } else {
            closeButton
                .buttonStyle(.bordered)
        }
    }

    private var closeButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .font(.caption.weight(.semibold))
                .frame(width: 20, height: 20)
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .accessibilityLabel("关闭课程详情")
    }
}

private func twentyFourHourTime(_ date: Date) -> String {
    date.formatted(
        Date.VerbatimFormatStyle(
            format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: Calendar(identifier: .gregorian)
        )
    )
}

private extension View {
    @ViewBuilder
    func detailTopEdgeEffectHidden() -> some View {
        if #available(watchOS 26.0, *) {
            scrollEdgeEffectHidden(true, for: .top)
        } else {
            self
        }
    }
}
