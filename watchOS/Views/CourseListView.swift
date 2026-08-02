// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 按自然日分组的完整课程列表。
///
/// 列表与日视图复用 `CourseRow`，从而保证课程、考试和实验的颜色、地点及
/// 教师/座位信息使用同一套展示规则。
struct CourseListView: View {
    @EnvironmentObject private var store: WatchScheduleStore
    @State private var didPositionInitialDate = false
    let onCrownInteraction: () -> Void
    let onCrownInput: () -> Void
    let onTouchInput: () -> Void
    var alwaysAllowsTeachingBounce = false
    /// 正常打开列表时定位到今天或最近日程；新手教学只需要演示滚动，
    /// 跳过这次跨整学期的 ScrollViewReader 定位，避免实体表为了寻找
    /// 目标 ID 在首帧同步展开大量 LazyVStack 布局。
    var positionsInitialDate = true

    /// Store 在 App 启动或课表原子替换时已经完成分组，这里只读取结果。
    private var groups: [WatchCourseDayGroup] {
        store.courseListGroups
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            InteractionAwareScrollView(
                onScroll: onCrownInteraction,
                onCrownInput: onCrownInput,
                onTouchInput: onTouchInput,
                centersShortContent: true,
                // 非空列表使用 LazyVStack，必须让原生 ScrollView 直接建立
                // 完整滚动范围；空状态仍走短内容测量并保持垂直居中。
                usesLazyContentLayout: !groups.isEmpty,
                alwaysAllowsBounce: alwaysAllowsTeachingBounce,
                // 教学时额外旁路标记真实手指拖动的来源，但列表位移仍完全
                // 交给原生 ScrollView。实体表即使跳过 `.tracking`、直接进入
                // `.interacting`，结束后也不会被误判成表冠旋转。
                usesShortContentTouchFallback: alwaysAllowsTeachingBounce,
                protectsInitialTopEdge: true
            ) {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "暂无课程",
                        systemImage: "list.bullet"
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(groups) { group in
                            Text(
                                group.date,
                                format: .dateTime
                                    .month()
                                    .day()
                                    .weekday(.wide)
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.top, 2)
                            .padding(.trailing, 32)
                            .id(group.date)

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
            .onAppear {
                positionInitialDate(using: scrollProxy)
            }
            .onChange(of: groups.map(\.date)) { _, _ in
                positionInitialDate(using: scrollProxy)
            }
        }
    }

    /// 首次进入课程列表时定位到今天；今天无课则定位到最近的日程日期。
    private func positionInitialDate(using scrollProxy: ScrollViewProxy) {
        guard positionsInitialDate,
              !didPositionInitialDate,
              let targetDate = initialTargetDate
        else {
            return
        }
        didPositionInitialDate = true

        // 等待列表完成首轮布局后再定位；锚点放在中间，避免目标日期标题
        // 被顶部状态栏虚化遮住。
        DispatchQueue.main.async {
            scrollProxy.scrollTo(targetDate, anchor: .center)
        }
    }

    /// 今天优先；没有今天时按自然日距离选择最近日期，同距离时优先未来。
    private var initialTargetDate: Date? {
        store.courseListInitialDate
    }
}
