// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

@main
struct TraintimeWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = WatchScheduleStore()

    var body: some Scene {
        WindowGroup {
            RootScheduleView()
                .environmentObject(store)
                .task {
                    WatchConnectivityManager.shared.activate(store: store)
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    WatchConnectivityManager.shared.beginProgressiveRefresh()
                }
        }
    }
}
