// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WatchConnectivity

/// iPhone 端的 WatchConnectivity 后台队列适配器。
///
/// 实时 `sendMessage` 失败时，手表会改用 `transferUserInfo` 排队发送同一份
/// 轻量课表请求。系统稍后在后台把请求交给 iPhone，本类型为请求补齐关联字段，
/// 再把原生课表管理器生成的回复通过 `transferUserInfo` 排队传回手表。
///
/// 这里不读取 Flutter 状态，也不持有课表数据；回复内容仍由
/// `PhoneWatchConnectivityManager` 根据手机本地完整学期缓存统一生成。
final class PhoneWatchQueuedScheduleTransport {
    private enum Key {
        static let messageType = "messageType"
        static let refreshID = "refreshID"
        static let requestID = "requestID"
    }

    private enum MessageType {
        static let request = "scheduleRequest"
        static let response = "scheduleResponse"
    }

    /// 处理一条系统后台投递的课表请求。
    ///
    /// - Parameters:
    ///   - userInfo: 手表排队发送的请求字典。
    ///   - session: 当前已经激活的 WCSession。
    ///   - makeReply: 复用实时通道的课表回复生成逻辑。
    func handle(
        _ userInfo: [String: Any],
        through session: WCSession,
        makeReply: ([String: Any]) -> [String: Any]?
    ) {
        guard isQueuedScheduleRequest(userInfo),
              let refreshID = nonemptyString(
                userInfo[Key.refreshID]
              ),
              let requestID = nonemptyString(
                userInfo[Key.requestID]
              ),
              var reply = makeReply(userInfo)
        else {
            return
        }

        // refreshID 标识整轮“当天 → 14 天 → 学期”同步；requestID 标识其中
        // 的单个范围或分页请求。手表据此丢弃旧同步和重复的迟到回复。
        reply[Key.messageType] = MessageType.response
        reply[Key.refreshID] = refreshID
        reply[Key.requestID] = requestID
        session.transferUserInfo(reply)
    }

    /// 只接收本协议定义的队列请求，避免误处理其他业务的 UserInfo。
    private func isQueuedScheduleRequest(
        _ userInfo: [String: Any]
    ) -> Bool {
        userInfo[Key.messageType] as? String == MessageType.request
    }

    /// 统一过滤缺失或空白的关联标识。
    private func nonemptyString(_ value: Any?) -> String? {
        guard let value = value as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        return value
    }
}
