// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 课程列表、日视图和概览页共用的卡片。
///
/// 通过参数控制日期、突出样式和同行元数据，避免三个页面各自维护一份容易
/// 分叉的课程卡片代码。
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

    /// 生成“位置 · 教师”或“位置 · 座位”的单行摘要。
    ///
    /// `lineLimit(1)` 与尾部截断由调用处统一负责，窄表盘不会把卡片撑宽。
    private var locationSummary: (text: String, systemImage: String)? {
        let classroom = normalizedText(course.classroom)
        var values = [String]()

        if let classroom {
            values.append(classroom)
        }

        if showsInlineMetadata {
            let metadata = course.kind == "exam"
                ? course.note
                : course.teacher
            if let metadata = normalizedText(metadata) {
                values.append(metadata)
            }
        }

        guard !values.isEmpty else { return nil }
        let systemImage: String
        if classroom != nil {
            systemImage = "mappin.and.ellipse"
        } else if course.kind == "exam" {
            systemImage = "number.square"
        } else {
            systemImage = "person"
        }
        return (values.joined(separator: " · "), systemImage)
    }
}

/// 周视图课程色块对应的详情页。
///
/// 详情页拥有独立背景并从底部弹出；日视图和列表不创建该视图，因此不会
/// 误触进入详情。关闭按钮仅在周视图模式启用。
struct CourseDetailView: View {
    let course: WatchCourse
    var showsTopCloseButton = false
    let onScroll: () -> Void
    let onCrownInput: () -> Void
    let onTouchInput: () -> Void
    let onCloseButtonFrameChange: (CGRect) -> Void
    let dismiss: () -> Void
    @State private var isDismissing = false

    var body: some View {
        GeometryReader { proxy in
            // 在系统状态栏下方为课程内容保留一整行空白。关闭按钮会在
            // ScrollView 内用反向补偿保持原位置，因此只下移课程信息。
            let detailContentTopInset: CGFloat = 27
            let closeButtonTopInset = max(30, proxy.size.height * 0.16)

            ZStack(alignment: .topTrailing) {
                Color.black
                    .overlay(course.color.opacity(0.08))
                    .ignoresSafeArea()

                // 与概览、课程列表复用同一滚动输入桥。详情内容已有真实
                // 滚动范围，不再附加 DragGesture；系统 ScrollPhase 同时
                // 驱动画面和上报教学输入，避免检测成功但页面没有位移。
                InteractionAwareScrollView(
                    onScroll: onScroll,
                    onCrownInput: onCrownInput,
                    onTouchInput: onTouchInput,
                    requestsCrownFocus: true
                ) {
                    ZStack(alignment: .topTrailing) {
                        detailContent(width: proxy.size.width)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                        if showsTopCloseButton {
                            topCloseButton
                                .scaleEffect(0.82)
                                // 在最终缩放与滚动布局之后读取位置，教学点击
                                // 动画才能始终与屏幕上真正看到的关闭按钮同心。
                                .background {
                                    WatchOnboardingFrameReader(
                                        report: onCloseButtonFrameChange
                                    )
                                }
                                // 外层内容稍后统一添加顶部 inset；减去该值
                                // 后，按钮首次出现的位置与固定版本完全相同。
                                .padding(
                                    .top,
                                    max(
                                        0,
                                        closeButtonTopInset
                                            - detailContentTopInset
                                    )
                                )
                                .padding(
                                    .trailing,
                                    max(3, proxy.size.width * 0.018)
                                )
                        }
                    }
                    .padding(.horizontal, max(8, proxy.size.width * 0.045))
                    .padding(.top, detailContentTopInset)
                    // 不移动初始内容，只增加可滚动的尾部安全区，让教师、
                    // 座位号等最后一行能离开圆角屏幕的底部裁切区域。
                    .padding(.bottom, max(8, proxy.size.height * 0.2))
                    // 详情很短时也保留一段真实滚动距离。它不改变首屏内容
                    // 的起点，只让原生 ScrollView 能接收并响应数码表冠。
                    .frame(
                        minHeight: proxy.size.height
                            + max(24, proxy.size.height * 0.12),
                        alignment: .top
                    )
                }
                .detailTopEdgeEffectHidden()
            }
            .onAppear {
                isDismissing = false
            }
        }
    }

    /// 详情页可滚动的业务内容。
    ///
    /// 这里只描述课程信息本身；滚动、表冠与边界皮筋全部交给外层原生
    /// ScrollView，避免内容长度接近一屏时零高度锚点无法产生实际位移。
    @ViewBuilder
    private func detailContent(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(course.name)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .padding(
                    .trailing,
                    showsTopCloseButton ? max(52, width * 0.27) : 0
                )

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(course.color)
                .frame(width: max(34, width * 0.24), height: 4)

            if let kindTitle = course.kindTitle {
                Label(kindTitle, systemImage: course.kindSystemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(course.color)
            }

            courseDateAndTime

            if let classroom = course.classroom, !classroom.isEmpty {
                Label(classroom, systemImage: "mappin.and.ellipse")
            }
            if let teacher = course.teacher, !teacher.isEmpty {
                Label(teacher, systemImage: "person")
            }
            if let note = course.note, !note.isEmpty {
                Label(note, systemImage: "info.circle")
            }

            if !showsTopCloseButton {
                Button("完成", action: closeDetail)
                    .tint(course.color)
            }
        }
    }

    /// 日期与 24 小时时间组合成一个语义完整的 Label。
    private var courseDateAndTime: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(
                    course.startAt,
                    format: .dateTime.month().day().weekday(.wide)
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
    }

    /// watchOS 26 的关闭按钮使用液态玻璃，旧系统使用描边样式。
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

    /// 保持与刷新、模式切换按钮一致的视觉尺寸。
    ///
    /// 按钮位于详情 ScrollView 内容层，随课程信息一起上下滚动。
    private var closeButton: some View {
        Button(action: closeDetail) {
            Image(systemName: "xmark")
                .font(.caption.weight(.semibold))
                .frame(width: 20, height: 20)
        }
        .controlSize(.small)
        .buttonBorderShape(.circle)
        .fixedSize()
        .contentShape(Circle())
        .disabled(isDismissing)
        .accessibilityLabel("关闭课程详情")
    }

    /// 先停止详情交互，下一次主线程循环再移除覆盖层。
    ///
    /// 实体 Apple Watch 上，表冠焦点、ScrollView 回弹和根层转场若在同一
    /// 事务内同时变更，系统偶发会保留旧命中层，表现为需要点击两次或退出
    /// 卡顿。这里让关闭成为幂等操作，并给系统一个循环提交状态变化；不会
    /// 增加肉眼可见的延迟，也不改变详情页布局或退出动画。
    private func closeDetail() {
        guard !isDismissing else { return }
        isDismissing = true
        WatchHaptics.selection()
        DispatchQueue.main.async {
            dismiss()
        }
    }
}

/// 统一生成不受系统 12/24 小时偏好影响的 `HH:mm` 文本。
private func twentyFourHourTime(_ date: Date) -> String {
    date.formatted(
        Date.VerbatimFormatStyle(
            format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: Calendar(identifier: .gregorian)
        )
    )
}

/// 清理可选文本：去除首尾空白并把空字符串统一视为缺失值。
private func normalizedText(_ value: String?) -> String? {
    let normalized = value?.trimmingCharacters(
        in: .whitespacesAndNewlines
    )
    guard let normalized, !normalized.isEmpty else { return nil }
    return normalized
}

private extension View {
    /// 详情页只关闭顶部滚动边缘虚化，避免课程名被系统效果遮住。
    @ViewBuilder
    func detailTopEdgeEffectHidden() -> some View {
        if #available(watchOS 26.0, *) {
            scrollEdgeEffectHidden(true, for: .top)
        } else {
            self
        }
    }
}
