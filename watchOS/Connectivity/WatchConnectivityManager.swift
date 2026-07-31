// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WatchConnectivity

/// 手机回复消息的强类型表示。
///
/// WatchConnectivity 使用 `[String: Any]`，先转换为该结构后，后续流程无需
/// 重复读取字符串键，也更容易审计默认值与分页行为。
private struct ScheduleReplyPayload {
    let scope: WatchScheduleScope
    let json: String
    let hasMore: Bool
    let nextOffset: Int
    let scheduleVersion: String?
    let isUnchanged: Bool
}

/// 管理 watchOS 与配对 iPhone 之间的课表同步。
///
/// 同步顺序固定为：当天 → 近 14 天 → 整学期分页。当天和 14 天阶段完整
/// 成功后只替换其日期范围，整学期分页全部完成后再整体替换。
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    /// 双端通信协议使用的键。修改时必须同步修改 iOS 端实现。
    private enum Key {
        static let scheduleJSON = "scheduleJSON"
        static let requestSchedule = "requestSchedule"
        static let scope = "scheduleScope"
        static let offset = "scheduleOffset"
        static let nextOffset = "scheduleNextOffset"
        static let hasMore = "scheduleHasMore"
        static let preferredLanguage = "preferredLanguage"
        static let scheduleVersion = "scheduleVersion"
        static let scheduleUnchanged = "scheduleUnchanged"
    }

    /// 一整轮渐进刷新允许的最长等待时间。
    private static let refreshTimeoutNanoseconds: UInt64 =
        12_000_000_000

    /// App 打开后等待手机首次实时回复的时间。
    private static let launchReplyTimeoutNanoseconds: UInt64 =
        3_000_000_000

    /// Store 由 App 生命周期持有，此处使用弱引用避免单例形成所有权环。
    private weak var store: WatchScheduleStore?

    /// 每轮刷新使用独立 ID，忽略上一轮迟到的回复和超时任务。
    private var refreshID = UUID()

    /// 当前三阶段响应必须全部属于同一个手机课表版本。
    private var activeIncomingScheduleVersion: String?

    /// 每次 App 打开时建立一次独立的实时回复等待窗口。
    ///
    /// 它不能复用普通刷新超时：手机不可达时普通刷新会立即回退到系统保存的
    /// Application Context，而启动提示需要继续等待真正的手机实时回复。
    private var launchAttemptID: UUID?
    private var launchAttemptRefreshID: UUID?

    private override init() {
        super.init()
    }

    /// 绑定 Store、激活 WCSession，并立即消费系统保存的最近上下文。
    @MainActor
    func activate(store: WatchScheduleStore) {
        self.store = store
        guard WCSession.isSupported() else {
            store.failRefresh(
                watchLocalizedString("此设备不支持与 iPhone 同步")
            )
            return
        }

        let session = WCSession.default
        configureAndActivate(session)
        consumeLatestApplicationContext(from: session)
        beginLaunchRefresh()
    }

    /// 启动或强制重启三阶段渐进刷新。
    @MainActor
    func beginProgressiveRefresh(force: Bool = false) {
        _ = startProgressiveRefresh(force: force)
    }

    /// App 每次打开或回到前台时调用：发起课表请求，并单独等待实时回复。
    ///
    /// Application Context 仍可立即恢复缓存，但旧上下文不算本轮手机回复；
    /// 只有实时消息返回后才会取消“打开手机”的提示。
    @MainActor
    func beginLaunchRefresh() {
        guard let store else { return }

        let attemptID = UUID()
        launchAttemptID = attemptID
        launchAttemptRefreshID = nil
        store.beginLaunchSyncAttempt()
        scheduleLaunchReplyTimeout(for: attemptID)

        let session = WCSession.default
        guard session.activationState == .activated else {
            if session.activationState == .notActivated {
                configureAndActivate(session)
            }
            return
        }
        startProgressiveRefreshForLaunchAttempt()
    }

    /// 创建一轮渐进刷新并返回其 ID，供启动实时回复与具体请求精确关联。
    @MainActor
    @discardableResult
    private func startProgressiveRefresh(force: Bool) -> UUID? {
        guard let store else { return nil }
        guard force || !store.isRefreshing else { return nil }

        let newRefreshID = UUID()
        refreshID = newRefreshID
        activeIncomingScheduleVersion = nil
        store.beginRefresh()
        request(
            scope: .today,
            offset: 0,
            refreshID: newRefreshID
        )
        scheduleTimeout(for: newRefreshID)
        return newRefreshID
    }

    /// WCSession 激活后为当前启动等待窗口发送唯一一轮渐进请求。
    @MainActor
    private func startProgressiveRefreshForLaunchAttempt() {
        guard launchAttemptID != nil,
              launchAttemptRefreshID == nil
        else {
            return
        }
        launchAttemptRefreshID = startProgressiveRefresh(force: true)
    }

    /// 设置 WCSession 代理并触发系统激活。
    private func configureAndActivate(_ session: WCSession) {
        session.delegate = self
        session.activate()
    }

    /// 12 秒内没有完成刷新时，优先尝试系统缓存的 Application Context。
    ///
    /// 超时任务携带刷新 ID；新一轮刷新启动后，旧任务即使醒来也不会改状态。
    @MainActor
    private func scheduleTimeout(for expectedRefreshID: UUID) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: Self.refreshTimeoutNanoseconds
            )
            guard !Task.isCancelled,
                  let self,
                  self.isActiveRefresh(expectedRefreshID),
                  self.store?.isRefreshing == true
            else {
                return
            }

            if self.consumeLatestApplicationContext(
                from: WCSession.default
            ) {
                self.store?.finishRefresh()
            } else {
                self.store?.failRefresh(
                    watchLocalizedString("暂时无法连接 iPhone")
                )
            }
        }
    }

    /// 启动请求超时只改变提示状态，不触碰任何已安装或正在展示的缓存。
    @MainActor
    private func scheduleLaunchReplyTimeout(for expectedAttemptID: UUID) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: Self.launchReplyTimeoutNanoseconds
            )
            guard !Task.isCancelled,
                  let self,
                  self.launchAttemptID == expectedAttemptID
            else {
                return
            }
            self.store?.markLaunchSyncTimedOut()
        }
    }

    /// WCSession 激活完成回调。
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            reportActivationFailure(error)
            return
        }
        guard activationState == .activated else { return }
        handleActivatedSession(session)
    }

    /// 手机推送新的 Application Context 时立即尝试安装。
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.receiveLivePhoneReply()
            let requiresFullSync =
                self.applicationContextRequiresFullSync(applicationContext)
            _ = self.consumeApplicationContext(applicationContext)
            if requiresFullSync {
                self.beginProgressiveRefresh()
            }
        }
    }

    /// 手机语言切换时会在 Application Context 之外补发实时消息。
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        Task { @MainActor [weak self] in
            self?.consumePreferredLanguage(from: message)
        }
    }

    /// 超时提示出现后用户再打开手机时，系统会更新可达状态。
    ///
    /// 只要当前仍有一轮启动等待尚未收到回复，就重建请求与超时窗口；手机
    /// 成功回复后 `receiveLivePhoneReply` 会自动撤下缓存提示或整页引导。
    func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable else { return }
        Task { @MainActor [weak self] in
            guard let self,
                  self.launchAttemptID != nil
            else {
                return
            }
            self.beginLaunchRefresh()
        }
    }

    /// 把激活错误切回主线程交给 Store 展示。
    private func reportActivationFailure(_ error: Error) {
        Task { @MainActor [weak self] in
            self?.store?.failRefresh(
                String.localizedStringWithFormat(
                    watchLocalizedString("无法连接 iPhone：%@"),
                    error.localizedDescription
                )
            )
        }
    }

    /// 激活成功后先消费系统上下文，再开始一轮实时刷新。
    ///
    /// 这里必须使用 `force`：用户可能在 Session 尚未激活时已经点了刷新，
    /// 此时 Store 已处于刷新状态；普通启动会被“正在刷新”的幂等保护拦下，
    /// 导致真正的请求永远没有发送，只能等到超时。
    private func handleActivatedSession(_ session: WCSession) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.consumeLatestApplicationContext(from: session)
            if self.launchAttemptID == nil {
                self.beginLaunchRefresh()
            } else {
                self.startProgressiveRefreshForLaunchAttempt()
            }
        }
    }

    /// 向手机请求指定范围和分页位置。
    @MainActor
    private func request(
        scope: WatchScheduleScope,
        offset: Int,
        refreshID expectedRefreshID: UUID
    ) {
        guard isActiveRefresh(expectedRefreshID),
              store != nil
        else {
            return
        }

        let session = WCSession.default
        guard session.activationState == .activated else {
            session.activate()
            return
        }

        guard session.isReachable else {
            handleUnreachableSession(session)
            return
        }

        sendRequest(
            through: session,
            scope: scope,
            offset: offset,
            installedScheduleVersion: store?.installedScheduleVersion,
            refreshID: expectedRefreshID
        )
    }

    /// 构造协议消息，所有字段在单一函数中维护。
    private func requestMessage(
        scope: WatchScheduleScope,
        offset: Int,
        installedScheduleVersion: String?
    ) -> [String: Any] {
        var message: [String: Any] = [
            Key.requestSchedule: true,
            Key.scope: scope.rawValue,
            Key.offset: offset,
        ]
        if let installedScheduleVersion {
            message[Key.scheduleVersion] = installedScheduleVersion
        }
        return message
    }

    /// 实际发送消息并把闭包结果重新调度到主线程。
    private func sendRequest(
        through session: WCSession,
        scope: WatchScheduleScope,
        offset: Int,
        installedScheduleVersion: String?,
        refreshID expectedRefreshID: UUID
    ) {
        session.sendMessage(
            requestMessage(
                scope: scope,
                offset: offset,
                installedScheduleVersion: installedScheduleVersion
            ),
            replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.receiveLivePhoneReply(
                        refreshID: expectedRefreshID
                    )
                    self?.handle(
                        reply: reply,
                        expectedScope: scope,
                        refreshID: expectedRefreshID
                    )
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    self?.handleSendFailure(
                        error,
                        session: session,
                        refreshID: expectedRefreshID
                    )
                }
            }
        )
    }

    /// 手机当前不可达时，退回系统最近保存的上下文。
    @MainActor
    private func handleUnreachableSession(_ session: WCSession) {
        guard let store else { return }
        if consumeLatestApplicationContext(from: session) {
            store.finishRefresh()
        } else {
            store.failRefresh(
                watchLocalizedString(
                    "请在配对的 iPhone 上打开 Traintime PDA"
                )
            )
        }
    }

    /// 实时消息失败后同样尝试 Application Context，保证离线体验。
    @MainActor
    private func handleSendFailure(
        _ error: Error,
        session: WCSession,
        refreshID expectedRefreshID: UUID
    ) {
        guard isActiveRefresh(expectedRefreshID) else { return }

        if consumeLatestApplicationContext(from: session) {
            store?.finishRefresh()
        } else {
            store?.failRefresh(
                String.localizedStringWithFormat(
                    watchLocalizedString("同步失败：%@"),
                    error.localizedDescription
                )
            )
        }
    }

    /// 解析并处理手机回复。
    @MainActor
    private func handle(
        reply: [String: Any],
        expectedScope: WatchScheduleScope,
        refreshID expectedRefreshID: UUID
    ) {
        guard isActiveRefresh(expectedRefreshID),
              let store
        else {
            return
        }

        // 每个课表请求的回复都携带语言，手表错过实时消息时也能自动修正。
        consumePreferredLanguage(from: reply)

        let payload = parseReply(
            reply,
            fallbackScope: expectedScope
        )

        // 版本一致时手机不会附带 JSON；直接结束刷新，现有本地课表不变。
        guard !finishUnchangedRefreshIfNeeded(payload, store: store) else {
            return
        }

        // 三阶段中途若手机课表再次变化，丢弃旧学期分页并从“当天”重启，
        // 防止把两个版本的课程拼成一份整学期缓存。
        guard acceptIncomingScheduleVersion(payload.scheduleVersion) else {
            beginProgressiveRefresh(force: true)
            return
        }

        if payload.scope == .semester {
            handleSemesterReply(
                payload,
                refreshID: expectedRefreshID
            )
            return
        }

        guard installCompletedRange(payload, into: store) else { return }

        continueAfterCompletedScope(
            payload.scope,
            refreshID: expectedRefreshID
        )
    }

    /// 处理手机返回的“版本未变化”轻量确认。
    ///
    /// 该回复没有 `scheduleJSON`。这里不能尝试走普通解码流程，也不能清空
    /// 当前页面；只结束刷新状态即可继续使用手表已经完整安装的学期缓存。
    @MainActor
    private func finishUnchangedRefreshIfNeeded(
        _ payload: ScheduleReplyPayload,
        store: WatchScheduleStore
    ) -> Bool {
        guard payload.isUnchanged else { return false }
        activeIncomingScheduleVersion = nil
        store.finishRefreshWithoutScheduleChanges()
        return true
    }

    /// 安装当天或近 14 天阶段，并集中处理无效载荷错误。
    ///
    /// 学期分页由 `handleSemesterReply` 负责，不会进入此函数。Store 会只替换
    /// 当前阶段覆盖的日期范围，因此当天阶段不会误删其他日期，14 天阶段也
    /// 不会提前覆盖尚未完成的整学期缓存。
    @MainActor
    private func installCompletedRange(
        _ payload: ScheduleReplyPayload,
        into store: WatchScheduleStore
    ) -> Bool {
        guard store.replaceSchedule(
            json: payload.json,
            scope: payload.scope
        ) else {
            store.failRefresh(
                watchLocalizedString("手机端暂无课表，请先刷新手机课表")
            )
            return false
        }
        return true
    }

    /// 把弱类型字典解析成稳定结构；缺失 scope 时使用请求中的预期范围。
    private func parseReply(
        _ reply: [String: Any],
        fallbackScope: WatchScheduleScope
    ) -> ScheduleReplyPayload {
        let scope = WatchScheduleScope(
            rawValue: reply[Key.scope] as? String ?? ""
        ) ?? fallbackScope

        return ScheduleReplyPayload(
            scope: scope,
            json: reply[Key.scheduleJSON] as? String ?? "",
            hasMore: reply[Key.hasMore] as? Bool ?? false,
            nextOffset: reply[Key.nextOffset] as? Int ?? 0,
            scheduleVersion: reply[Key.scheduleVersion] as? String,
            isUnchanged: reply[Key.scheduleUnchanged] as? Bool ?? false
        )
    }

    /// 锁定本轮手机课表版本，并拒绝中途出现的另一个版本。
    @MainActor
    private func acceptIncomingScheduleVersion(_ value: String?) -> Bool {
        guard let value, !value.isEmpty else {
            // 与尚未升级协议的手机保持兼容。
            return activeIncomingScheduleVersion == nil
        }
        guard let activeIncomingScheduleVersion else {
            self.activeIncomingScheduleVersion = value
            return true
        }
        return activeIncomingScheduleVersion == value
    }

    /// 合并学期分页；仍有下一页时继续请求，否则 Store 会结束整轮刷新。
    @MainActor
    private func handleSemesterReply(
        _ payload: ScheduleReplyPayload,
        refreshID expectedRefreshID: UUID
    ) {
        guard let store else { return }
        let accepted = store.appendSemesterChunk(
            json: payload.json,
            isFinal: !payload.hasMore,
            scheduleVersion: payload.scheduleVersion
        )
        guard accepted, payload.hasMore else { return }

        request(
            scope: .semester,
            offset: payload.nextOffset,
            refreshID: expectedRefreshID
        )
    }

    /// 一个非学期阶段成功后进入下一阶段。
    @MainActor
    private func continueAfterCompletedScope(
        _ scope: WatchScheduleScope,
        refreshID expectedRefreshID: UUID
    ) {
        guard let store else { return }
        guard let nextScope = scope.next else {
            store.finishRefresh()
            return
        }

        prepareStore(for: nextScope)
        request(
            scope: nextScope,
            offset: 0,
            refreshID: expectedRefreshID
        )
    }

    /// 在发起下一阶段前更新页面上的刷新状态。
    @MainActor
    private func prepareStore(for scope: WatchScheduleScope) {
        if scope == .semester {
            store?.beginSemesterTransfer()
        } else {
            store?.setLoadingScope(scope)
        }
    }

    /// 消费 WCSession 当前持有的最近 Application Context。
    @MainActor
    @discardableResult
    private func consumeLatestApplicationContext(
        from session: WCSession
    ) -> Bool {
        consumeApplicationContext(session.receivedApplicationContext)
    }

    /// 从 Application Context 中读取完整快照并交给 Store 校验。
    @MainActor
    @discardableResult
    private func consumeApplicationContext(
        _ context: [String: Any]
    ) -> Bool {
        // 语言上下文可以独立存在，因此必须在检查课表字段之前安装。
        consumePreferredLanguage(from: context)

        // 相同的完整版本直接复用本地缓存，避免重复解码和页面重新分组。
        if let version = context[Key.scheduleVersion] as? String,
           version == store?.installedScheduleVersion
        {
            return true
        }

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

    /// 判断手机主动推送的轻量上下文是否代表一份尚未完整安装的新课表。
    @MainActor
    private func applicationContextRequiresFullSync(
        _ context: [String: Any]
    ) -> Bool {
        guard let version = context[Key.scheduleVersion] as? String,
              !version.isEmpty
        else {
            return false
        }
        return version != store?.installedScheduleVersion
    }

    /// 从任意 WatchConnectivity 载荷中安装手机指定语言。
    @MainActor
    private func consumePreferredLanguage(from payload: [String: Any]) {
        guard let language = payload[Key.preferredLanguage] as? String else {
            return
        }
        _ = store?.setPreferredLanguage(language)
    }

    /// 标记当前启动请求已收到手机实时通信，并让缓存提示或空状态页自动消失。
    ///
    /// 消息请求回复必须匹配本轮关联的刷新 ID；Application Context 的代理
    /// 回调本身就是实时到达，因此可以不传 ID。磁盘中旧的 Context 由主动
    /// `consumeLatestApplicationContext` 读取，不会经过这里，也不会误判。
    @MainActor
    private func receiveLivePhoneReply(refreshID: UUID? = nil) {
        guard launchAttemptID != nil else { return }
        if let refreshID,
           refreshID != launchAttemptRefreshID
        {
            return
        }
        launchAttemptID = nil
        launchAttemptRefreshID = nil
        store?.receiveLaunchSyncReply()
    }

    /// 判断异步回调是否仍属于最新一轮刷新。
    private func isActiveRefresh(_ expectedRefreshID: UUID) -> Bool {
        expectedRefreshID == refreshID
    }
}
