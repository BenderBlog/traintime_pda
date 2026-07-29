// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

private enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case nextCourse
    case courseList
    case day
    case week

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nextCourse:
            "下一节课"
        case .courseList:
            "课程列表"
        case .day:
            "日视图"
        case .week:
            "周视图"
        }
    }

    var systemImage: String {
        switch self {
        case .nextCourse:
            "forward.end"
        case .courseList:
            "list.bullet"
        case .day:
            "calendar.day.timeline.left"
        case .week:
            "calendar"
        }
    }
}

struct RootScheduleView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var mode = WatchCalendarMode.nextCourse
    @State private var showsModePicker = false
    @State private var showsSyncCompletion = false
    @State private var refreshRotation = 0.0
    @State private var controlsVisible = true
    @State private var hideControlsTask: Task<Void, Never>?
    private let connectivity = WatchConnectivityManager.shared

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let edgeInset = max(
                    2,
                    min(proxy.size.width, proxy.size.height) * 0.02
                )
                let topInset = contentTopInset(for: proxy.size.height)

                ZStack {
                    content
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .padding(.horizontal, edgeInset)
                        .padding(.top, topInset)
                        .padding(.bottom, edgeInset)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                guard mode != .week else { return }
                                revealControls()
                            }
                        )

                    refreshControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topTrailing
                        )
                        .padding(.top, max(20, proxy.size.height * 0.21))
                        .padding(.trailing, edgeInset)

                    modeControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                        .padding(.trailing, edgeInset)
                        .padding(
                            .bottom,
                            max(10, proxy.size.height * 0.08)
                        )

                    if showsSyncCompletion {
                        syncCompletionToast
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottom
                            )
                            .padding(.bottom, 31)
                            .allowsHitTesting(false)
                            .transition(
                                .opacity.combined(with: .scale(scale: 0.84))
                            )
                    }
                }
            }
            .ignoresSafeArea()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showsModePicker) {
            modePicker
        }
        .onAppear {
            updateRefreshAnimation(isRefreshing: store.isRefreshing)
            revealControls()
        }
        .onDisappear {
            hideControlsTask?.cancel()
        }
        .onChange(of: store.isRefreshing) { _, isRefreshing in
            updateRefreshAnimation(isRefreshing: isRefreshing)
        }
        .onChange(of: store.completedRefreshCount) { _, count in
            guard count > 0 else { return }
            showCompletion(for: count)
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.snapshot == nil {
            emptyState
        } else {
            switch mode {
            case .nextCourse:
                NextCourseView(onCrownInteraction: hideControls)
            case .courseList:
                CourseListView(onCrownInteraction: hideControls)
            case .day:
                DayScheduleView(onCrownInteraction: hideControls)
            case .week:
                WeekScheduleView(
                    onEmptyTap: revealControls,
                    onCrownInteraction: hideControls
                )
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("暂无课表", systemImage: "iphone.and.arrow.forward")
        } description: {
            Text(store.syncError ?? "请在配对的 iPhone 上打开应用并刷新课表")
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var refreshControl: some View {
        if #available(watchOS 26.0, *) {
            refreshButton
                .buttonStyle(.glass)
        } else {
            refreshButton
                .buttonStyle(.bordered)
        }
    }

    private var refreshButton: some View {
        Button {
            revealControls()
            connectivity.beginProgressiveRefresh(force: true)
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.caption.weight(.semibold))
                .rotationEffect(.degrees(refreshRotation))
                .frame(width: 20, height: 20)
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .opacity(controlsVisible ? 1 : 0)
        .scaleEffect(controlsVisible ? 1 : 0.82)
        .allowsHitTesting(controlsVisible)
        .animation(.easeOut(duration: 0.2), value: controlsVisible)
        .accessibilityLabel(store.isRefreshing ? "正在刷新" : "从手机刷新")
    }

    @ViewBuilder
    private var modeControl: some View {
        if #available(watchOS 26.0, *) {
            modeButton
                .buttonStyle(.glass)
        } else {
            modeButton
                .buttonStyle(.bordered)
        }
    }

    private var modeButton: some View {
        Button {
            revealControls()
            showsModePicker = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.bold))
                .frame(width: 20, height: 20)
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .opacity(controlsVisible ? 1 : 0)
        .scaleEffect(controlsVisible ? 1 : 0.82)
        .allowsHitTesting(controlsVisible)
        .animation(.easeOut(duration: 0.2), value: controlsVisible)
        .accessibilityLabel("切换课表视图")
    }

    private var modePicker: some View {
        NavigationStack {
            List {
                Section("切换视图") {
                    ForEach(WatchCalendarMode.allCases) { candidate in
                        Button {
                            mode = candidate
                            showsModePicker = false
                        } label: {
                            HStack {
                                Label(
                                    candidate.title,
                                    systemImage: candidate.systemImage
                                )
                                Spacer()
                                if candidate == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var syncCompletionToast: some View {
        if #available(watchOS 26.0, *) {
            syncCompletionLabel
                .glassEffect(.regular, in: Capsule())
                .glassEffectTransition(.materialize)
        } else {
            syncCompletionLabel
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var syncCompletionLabel: some View {
        Label("同步完成", systemImage: "checkmark.circle.fill")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
    }

    private func updateRefreshAnimation(isRefreshing: Bool) {
        if isRefreshing {
            refreshRotation = 0
            withAnimation(
                .linear(duration: 0.8).repeatForever(autoreverses: false)
            ) {
                refreshRotation = 360
            }
        } else {
            withAnimation(.easeOut(duration: 0.18)) {
                refreshRotation = 0
            }
        }
    }

    private func showCompletion(for count: Int) {
        withAnimation(
            .spring(
                response: 0.36,
                dampingFraction: 0.62,
                blendDuration: 0.08
            )
        ) {
            showsSyncCompletion = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard count == store.completedRefreshCount else { return }
            withAnimation(.easeInOut(duration: 0.28)) {
                showsSyncCompletion = false
            }
        }
    }

    private func contentTopInset(for height: CGFloat) -> CGFloat {
        switch mode {
        case .day, .week:
            0
        case .nextCourse, .courseList:
            max(4, height * 0.1)
        }
    }

    private func revealControls() {
        hideControlsTask?.cancel()
        withAnimation(.easeOut(duration: 0.18)) {
            controlsVisible = true
        }
        hideControlsTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.2)) {
                controlsVisible = false
            }
        }
    }

    private func hideControls() {
        hideControlsTask?.cancel()
        withAnimation(.easeIn(duration: 0.16)) {
            controlsVisible = false
        }
    }
}

private struct NextCourseView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    let onCrownInteraction: () -> Void

    var body: some View {
        InteractionAwareScrollView(onScroll: onCrownInteraction) {
            VStack(alignment: .leading, spacing: 8) {
                if store.isStale {
                    Label(
                        "课表可能已过期",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .padding(.trailing, 34)
                }

                if let course = store.nextCourse {
                    timeline(for: course)
                        .padding(.trailing, 34)
                    CourseRow(
                        course: course,
                        showsDate: true,
                        isProminent: true
                    )
                } else {
                    ContentUnavailableView(
                        "没有下一节课",
                        systemImage: "checkmark.circle"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
            .padding(.top, 2)
        }
    }

    private func timeline(for course: WatchCourse) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            if course.startAt <= Date(), course.endAt > Date() {
                Text("正在上课")
                    .foregroundStyle(course.color)
            } else {
                Text("距离上课")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(course.startAt, style: .relative)
                    .foregroundStyle(course.color)
            }
        }
        .font(.headline)
    }
}
