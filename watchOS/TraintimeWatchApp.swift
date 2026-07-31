// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// Apple Watch 独立应用入口。
///
/// `WatchScheduleStore` 由场景根节点持有，所有子视图共享同一份缓存与刷新状态；
/// WatchConnectivity 单例只负责传输，不直接拥有界面状态。
@main
struct TraintimeWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = WatchScheduleStore()

    var body: some Scene {
        WindowGroup {
            RootScheduleView()
                .environmentObject(store)
                // 手机语言是产品内设置，不一定等于手表系统语言。将同步值注入
                // 根环境后，所有 SwiftUI Text 与日期格式会在原地立即刷新。
                .environment(\.locale, store.preferredLocale)
                .task {
                    // 首次进入时恢复的本地缓存已经可以显示；随后激活手机通信，
                    // 新数据会按“当天、14 天、整学期”逐阶段替换。
                    WatchConnectivityManager.shared.activate(store: store)
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    // 每次回到前台都建立新的实时回复等待窗口。旧缓存保持可见；
                    // 超时后根视图会按“有缓存提示、无缓存整页”分别处理。
                    WatchConnectivityManager.shared.beginLaunchRefresh()
                }
        }
    }
}
