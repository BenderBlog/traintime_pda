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

    /// Store 在 App 启动或课表原子替换时已经完成分组，这里只读取结果。
    private var groups: [WatchCourseDayGroup] {
        store.courseListGroups
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            InteractionAwareScrollView(
                onScroll: onCrownInteraction,
                centersShortContent: true,
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
        guard !didPositionInitialDate,
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
