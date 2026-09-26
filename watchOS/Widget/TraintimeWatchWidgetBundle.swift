// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI
import WidgetKit

/// Apple Watch Widget Extension 入口。
///
/// 长方形仅提供综合组件；名称、时间地点、日程概览用于圆形与单行表盘位置。
/// 它们共用同一个 Provider 与 App Group 缓存，不会重复请求或复制课表数据。
@main
struct TraintimeWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        TraintimeScheduleWidget()
        TraintimeCourseNameWidget()
        TraintimeCourseTimeLocationWidget()
        TraintimeTodayScheduleWidget()
    }
}
