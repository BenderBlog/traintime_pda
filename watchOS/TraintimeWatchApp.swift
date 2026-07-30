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
                .task {
                    // 首次进入时恢复的本地缓存已经可以显示；随后激活手机通信，
                    // 新数据会按“当天、14 天、整学期”逐阶段替换。
                    WatchConnectivityManager.shared.activate(store: store)
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    // 每次回到前台都尝试静默更新。管理器会忽略重复的刷新请求，
                    // 因而不会因为系统多次发送 active 而并发同步。
                    WatchConnectivityManager.shared.beginProgressiveRefresh()
                }
        }
    }
}
