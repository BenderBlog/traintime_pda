// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 手表课表支持的四种顶层展示方式。
private enum WatchCalendarMode: String, CaseIterable, Identifiable {
    case nextCourse
    case courseList
    case day
    case week

    var id: String { rawValue }

    /// 视图选择列表中的中文名称。
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

    /// 视图选择列表中的 SF Symbol。
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

/// 根页面的响应式布局参数。
///
/// 集中维护尺寸计算可以防止不同表径下的按钮与内容各自使用一套比例。
/// 这些函数保留已确认的视觉数值，只把散落的公式收拢到一个位置。
private enum RootScheduleLayout {
    static let controlContentSize: CGFloat = 20
    static let completionBottomInset: CGFloat = 31

    static func edgeInset(for size: CGSize) -> CGFloat {
        max(2, min(size.width, size.height) * 0.02)
    }

    static func refreshTopInset(for height: CGFloat) -> CGFloat {
        max(20, height * 0.21)
    }

    static func modeBottomInset(for height: CGFloat) -> CGFloat {
        max(10, height * 0.08)
    }

    static func contentTopInset(
        for mode: WatchCalendarMode,
        height: CGFloat
    ) -> CGFloat {
        switch mode {
        case .day, .week:
            0
        case .nextCourse, .courseList:
            max(4, height * 0.1)
        }
    }
}

/// Apple Watch 课表的根容器。
///
/// 该视图负责模式切换、刷新入口、自动隐藏控件和同步完成提示；具体课程内容
/// 由四个子视图分别承担，避免在根页面中混入日/周布局细节。
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
                let edgeInset = RootScheduleLayout.edgeInset(
                    for: proxy.size
                )
                let topInset = RootScheduleLayout.contentTopInset(
                    for: mode,
                    height: proxy.size.height
                )

                ZStack {
                    // 课表主体铺满表盘；非周视图轻点内容可唤回按钮。
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

                    // 按比例下移刷新按钮，避免遮住系统时钟。
                    refreshControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topTrailing
                        )
                        .padding(
                            .top,
                            RootScheduleLayout.refreshTopInset(
                                for: proxy.size.height
                            )
                        )
                        .padding(.trailing, edgeInset)

                    // 模式按钮悬浮在右下角，不挤压课表主体。
                    modeControl
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                        .padding(.trailing, edgeInset)
                        .padding(
                            .bottom,
                            RootScheduleLayout.modeBottomInset(
                                for: proxy.size.height
                            )
                        )

                    // 提示不截获手势，显示期间仍可滚动或点击课程。
                    if showsSyncCompletion {
                        syncCompletionToast
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottom
                            )
                            .padding(
                                .bottom,
                                RootScheduleLayout.completionBottomInset
                            )
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

    /// 根据当前模式选择内容，并统一传入表冠交互回调。
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

    /// 完全没有缓存时显示；离线但有缓存时仍会展示课表。
    private var emptyState: some View {
        ContentUnavailableView {
            Label("暂无课表", systemImage: "iphone.and.arrow.forward")
        } description: {
            Text(store.syncError ?? "请在配对的 iPhone 上打开应用并刷新课表")
        }
        .padding(.horizontal, 4)
    }

    /// watchOS 26 使用液态玻璃，旧系统回退到标准描边样式。
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

    /// 触发强制渐进刷新；图标转动由 Store 的刷新状态驱动。
    private var refreshButton: some View {
        Button {
            revealControls()
            connectivity.beginProgressiveRefresh(force: true)
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.caption.weight(.semibold))
                .rotationEffect(.degrees(refreshRotation))
                .frame(
                    width: RootScheduleLayout.controlContentSize,
                    height: RootScheduleLayout.controlContentSize
                )
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

    /// 视图切换按钮的系统版本适配。
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

    /// 打开模式选择 Sheet，不在主页面堆叠菜单内容。
    private var modeButton: some View {
        Button {
            revealControls()
            showsModePicker = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.bold))
                .frame(
                    width: RootScheduleLayout.controlContentSize,
                    height: RootScheduleLayout.controlContentSize
                )
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

    /// 选中模式后立即关闭列表；课表数据和缓存不会被重置。
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

    /// 同步提示的系统版本适配。
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

    /// 提示本体保持紧凑，避免遮挡底部的模式按钮。
    private var syncCompletionLabel: some View {
        Label("同步完成", systemImage: "checkmark.circle.fill")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
    }

    /// 开始或停止刷新图标的连续旋转。
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

    /// 用刷新完成计数区分多轮异步提示，旧任务不会隐藏新提示。
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

    /// 显示两个悬浮按钮，并重新开始自动隐藏倒计时。
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

    /// 表冠或滚动发生时立即隐藏按钮，释放课程内容区域。
    private func hideControls() {
        hideControlsTask?.cancel()
        withAnimation(.easeIn(duration: 0.16)) {
            controlsVisible = false
        }
    }
}

/// “下一节课”页面：正在进行的课程优先，否则显示未来最近一节。
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

    /// 显示当前状态或距下一节课的相对时间。
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
