// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI
import WidgetKit

/// Apple Watch Widget Extension 入口。
///
/// 当前只注册课程 Smart Stack 组件；以后新增圆形或角落复杂功能时仍可在
/// 同一 Bundle 中追加，而无需改动现有组件类型标识。
@main
struct TraintimeWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        TraintimeScheduleWidget()
    }
}
