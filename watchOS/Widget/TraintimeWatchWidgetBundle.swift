// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI
import WidgetKit

/// Apple Watch Widget Extension 入口。
///
/// 综合组件之外还注册名称、时间地点、进度、今日课表和本周分布五种专用组件。
/// 它们共用同一个 Provider 与 App Group 缓存，不会重复请求或复制课表数据。
@main
struct TraintimeWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        TraintimeScheduleWidget()
        TraintimeCourseNameWidget()
        TraintimeCourseTimeLocationWidget()
        TraintimeCourseProgressWidget()
        TraintimeTodayScheduleWidget()
        TraintimeWeekDistributionWidget()
    }
}
