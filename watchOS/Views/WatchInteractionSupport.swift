// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
import WatchKit

/// 手表端统一的轻量触觉反馈入口。
///
/// 只在用户完成明确操作或跨越一个导航刻度时播放，避免表冠连续转动期间
/// 高频触发导致触觉含义变得模糊。
@MainActor
enum WatchHaptics {
    static func selection() {
        WKInterfaceDevice.current().play(.click)
    }

    /// 到达边界时使用与课程列表表冠刻度一致的短点击触觉。
    static func boundary(_ amount: Int) {
        _ = amount
        WKInterfaceDevice.current().play(.click)
    }

    static func navigation(_ amount: Int) {
        // Core Haptics 不对普通 watchOS App target 开放；使用课程列表同款
        // 短点击组成双脉冲。边界为单击、翻页为双击，同时避开 `.start`
        // 等会附带明显系统提示音的反馈类型。
        _ = amount
        let device = WKInterfaceDevice.current()
        device.play(.click)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            device.play(.click)
        }
    }

    static func refreshStarted() {
        WKInterfaceDevice.current().play(.click)
    }

    static func success() {
        WKInterfaceDevice.current().play(.click)
    }
}

/// 一次表冠输入更新的语义结果。
///
/// 页面只需要关心方向、是否开始了新一轮旋转、以及是否发生反转；原始
/// 时间戳和上一次方向统一由 `WatchCrownTurnSession` 管理。
struct WatchCrownTurnUpdate {
    let direction: Int
    let startsNewSession: Bool
    let reversesDirection: Bool
}

/// 日视图和周视图共用的表冠连续旋转状态机。
///
/// 该类型不计算位移，也不播放触觉；它只提供两项基础能力：
///
/// 1. 超过 0.35 秒没有输入时开始新一轮；
/// 2. 识别同一轮旋转中的方向反转。
///
/// 具体的卡片滚动、页面位移和吸附阈值由各视图自行决定。
struct WatchCrownTurnSession {
    private static let inactivityTimeout: TimeInterval = 0.35

    private var lastEventTime = 0.0
    private var direction = 0

    /// 接收一次非零表冠变化，并返回本次输入对应的会话语义。
    mutating func register(
        delta: Double,
        now: TimeInterval = Date.timeIntervalSinceReferenceDate
    ) -> WatchCrownTurnUpdate? {
        guard abs(delta) > .ulpOfOne else { return nil }

        let startsNewSession = lastEventTime == 0
            || now - lastEventTime > Self.inactivityTimeout
        let newDirection = delta > 0 ? 1 : -1
        let reversesDirection = !startsNewSession
            && direction != 0
            && newDirection != direction

        lastEventTime = now
        direction = newDirection

        return WatchCrownTurnUpdate(
            direction: newDirection,
            startsNewSession: startsNewSession,
            reversesDirection: reversesDirection
        )
    }

    /// 主动结束当前表冠会话。
    ///
    /// 吸附完成后清空旧时间和方向，下一个刻度会作为新会话处理。
    mutating func reset() {
        lastEventTime = 0
        direction = 0
    }
}
