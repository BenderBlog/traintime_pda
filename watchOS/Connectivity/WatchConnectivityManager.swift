// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    private enum Key {
        static let scheduleJSON = "scheduleJSON"
        static let requestSchedule = "requestSchedule"
        static let scope = "scheduleScope"
        static let offset = "scheduleOffset"
        static let nextOffset = "scheduleNextOffset"
        static let hasMore = "scheduleHasMore"
    }

    private weak var store: WatchScheduleStore?
    private var refreshID = UUID()

    private override init() {
        super.init()
    }

    @MainActor
    func activate(store: WatchScheduleStore) {
        self.store = store
        guard WCSession.isSupported() else {
            store.failRefresh("此设备不支持与 iPhone 同步")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()

        consumeApplicationContext(session.receivedApplicationContext)
        if session.activationState == .activated {
            beginProgressiveRefresh()
        }
    }

    @MainActor
    func beginProgressiveRefresh(force: Bool = false) {
        guard let store else { return }
        if store.isRefreshing && !force { return }

        refreshID = UUID()
        let currentRefreshID = refreshID
        store.beginRefresh()
        request(scope: .today, offset: 0, refreshID: refreshID)
        scheduleTimeout(for: currentRefreshID)
    }

    @MainActor
    private func scheduleTimeout(for refreshID: UUID) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 12_000_000_000)
            guard !Task.isCancelled,
                  let self,
                  refreshID == self.refreshID,
                  self.store?.isRefreshing == true
            else {
                return
            }

            let context = WCSession.default.receivedApplicationContext
            if self.consumeApplicationContext(context) {
                self.store?.finishRefresh()
            } else {
                self.store?.failRefresh("暂时无法连接 iPhone")
            }
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            Task { @MainActor [weak self] in
                self?.store?.failRefresh("无法连接 iPhone：\(error.localizedDescription)")
            }
            return
        }
        guard activationState == .activated else { return }
        Task { @MainActor [weak self] in
            self?.consumeApplicationContext(session.receivedApplicationContext)
            self?.beginProgressiveRefresh()
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor [weak self] in
            self?.consumeApplicationContext(applicationContext)
        }
    }

    @MainActor
    private func request(
        scope: WatchScheduleScope,
        offset: Int,
        refreshID: UUID
    ) {
        guard refreshID == self.refreshID, let store else { return }
        let session = WCSession.default
        guard session.activationState == .activated else {
            session.activate()
            return
        }

        guard session.isReachable else {
            if !consumeApplicationContext(session.receivedApplicationContext) {
                store.failRefresh("请在配对的 iPhone 上打开 Traintime PDA")
            } else {
                store.finishRefresh()
            }
            return
        }

        session.sendMessage(
            [
                Key.requestSchedule: true,
                Key.scope: scope.rawValue,
                Key.offset: offset,
            ],
            replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.handle(
                        reply: reply,
                        expectedScope: scope,
                        offset: offset,
                        refreshID: refreshID
                    )
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    guard let self, refreshID == self.refreshID else { return }
                    if !self.consumeApplicationContext(
                        session.receivedApplicationContext
                    ) {
                        self.store?.failRefresh(
                            "同步失败：\(error.localizedDescription)"
                        )
                    } else {
                        self.store?.finishRefresh()
                    }
                }
            }
        )
    }

    @MainActor
    private func handle(
        reply: [String: Any],
        expectedScope: WatchScheduleScope,
        offset: Int,
        refreshID: UUID
    ) {
        guard refreshID == self.refreshID, let store else { return }
        let scope = WatchScheduleScope(
            rawValue: reply[Key.scope] as? String ?? ""
        ) ?? expectedScope
        let json = reply[Key.scheduleJSON] as? String ?? ""
        let hasMore = reply[Key.hasMore] as? Bool ?? false
        let nextOffset = reply[Key.nextOffset] as? Int ?? 0

        if scope == .semester {
            let accepted = store.appendSemesterChunk(
                json: json,
                isFinal: !hasMore
            )
            guard accepted else { return }
            if hasMore {
                request(
                    scope: .semester,
                    offset: nextOffset,
                    refreshID: refreshID
                )
            }
            return
        }

        guard store.replaceSchedule(json: json, scope: scope) else {
            store.failRefresh("手机端暂无课表，请先刷新手机课表")
            return
        }

        guard let next = scope.next else {
            store.finishRefresh()
            return
        }
        if next == .semester {
            store.beginSemesterTransfer()
        } else {
            store.setLoadingScope(next)
        }
        request(scope: next, offset: 0, refreshID: refreshID)
    }

    @MainActor
    @discardableResult
    private func consumeApplicationContext(
        _ context: [String: Any]
    ) -> Bool {
        guard let json = context[Key.scheduleJSON] as? String,
              !json.isEmpty
        else {
            return false
        }
        let scope = WatchScheduleScope(
            rawValue: context[Key.scope] as? String ?? ""
        ) ?? .fourteenDays
        return store?.replaceSchedule(json: json, scope: scope) ?? false
    }
}
