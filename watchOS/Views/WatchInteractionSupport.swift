// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation
#if canImport(WatchKit)
import SwiftUI
import WatchKit
#endif

/// 创建一个可取消的界面自动收起任务。
///
/// 缓存提示和新手引导完成提示共用这一入口，避免各自在根视图里重复维护
/// `Task.sleep`、取消检查和主线程回调。调用方仍负责保存并取消返回的任务。
@MainActor
func makeWatchAutoDismissTask(
    after seconds: TimeInterval,
    action: @escaping @MainActor () -> Void
) -> Task<Void, Never> {
    Task { @MainActor in
        let nanoseconds = UInt64(max(0, seconds) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)
        guard !Task.isCancelled else { return }
        action()
    }
}

/// 按住 0.3 秒后持续发出渐强、加速的短脉冲，三秒时结束。
struct WatchHoldFeedbackPulse: Equatable {
    private static let holdSeconds = 3.0
    private static let startDelaySeconds = 0.3
    static let holdDuration: Duration = .seconds(holdSeconds)
    static let startDelay: Duration = .seconds(startDelaySeconds)

    // 即使相邻两次强度相同，也要让 sensoryFeedback 识别为新的脉冲。
    let sequence: Int
    private let strengthLevel: Int
    let interval: Duration

    init(sequence: Int, elapsed: Duration) {
        self.sequence = sequence
        let components = elapsed.components
        let elapsedSeconds = Double(components.seconds)
            + Double(components.attoseconds) / 1_000_000_000_000_000_000
        let progress = min(1, max(0,
            (elapsedSeconds - Self.startDelaySeconds)
                / (Self.holdSeconds - Self.startDelaySeconds)
        ))
        // 固定 13 档强度，避免每次按压都创建不同浮点强度的反馈对象。
        strengthLevel = Int((progress * 12).rounded())
        // 留出至少 120ms，避免过密触发使系统打断前一次触觉。
        interval = .seconds(0.28 - 0.16 * progress)
    }
}

/// 模式按钮与欢迎页共用三秒长按计时；调用方负责按压有效性和任务取消。
@MainActor
func makeWatchHoldFeedbackTask(
    isActive: @escaping @MainActor () -> Bool,
    onPulse: @escaping @MainActor (WatchHoldFeedbackPulse) -> Void,
    onComplete: @escaping @MainActor () -> Void
) -> Task<Void, Never> {
    let clock = ContinuousClock()
    let startedAt = clock.now
    let completionAt = startedAt.advanced(by: WatchHoldFeedbackPulse.holdDuration)
    return Task { @MainActor in
        do {
            try await clock.sleep(until: startedAt.advanced(by: WatchHoldFeedbackPulse.startDelay))
            var sequence = 0
            while true {
                guard !Task.isCancelled, isActive() else { return }
                let now = clock.now
                guard now < completionAt else { break }
                let pulse = WatchHoldFeedbackPulse(
                    sequence: sequence,
                    elapsed: startedAt.duration(to: now)
                )
                onPulse(pulse)
                sequence &+= 1
                // 只按实际经过时间推进，不补发卡顿期间错过的脉冲，完成时刻固定为三秒。
                try await clock.sleep(until: min(now.advanced(by: pulse.interval), completionAt))
            }
        } catch {
            return
        }
        guard !Task.isCancelled, isActive() else { return }
        onComplete()
    }
}

#if canImport(WatchKit)
extension WatchHoldFeedbackPulse {
    var feedback: SensoryFeedback {
        let intensity = 0.25 + 0.75 * Double(strengthLevel) / 12
        switch strengthLevel {
        case 0..<4: return .impact(weight: .light, intensity: intensity)
        case 4..<8: return .impact(weight: .medium, intensity: intensity)
        default: return .impact(weight: .heavy, intensity: intensity)
        }
    }
}
#endif

/// 手表端统一的轻量触觉反馈入口。
///
/// 只在用户完成明确操作或跨越一个导航刻度时播放，避免表冠连续转动期间
/// 高频触发导致触觉含义变得模糊。
#if canImport(WatchKit)
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

    /// 新手引导正确操作使用系统“成功”双段触觉，语义与支付成功一致。
    static func onboardingSuccess() {
        WKInterfaceDevice.current().play(.success)
    }

    /// 操作种类、方向轴或点击位置不符时使用系统失败反馈。
    static func onboardingError() {
        WKInterfaceDevice.current().play(.failure)
    }
}
#endif

/// 拖出按钮后，本轮触摸始终取消；手指移回也不能重启长按或补发点击。
/// 状态机不保存计时任务，页面离开时由调用方取消任务并 reset。
struct WatchPressSession {
    private(set) var isActive = false
    private(set) var isCancelled = false

    mutating func begin() -> Bool {
        guard !isActive, !isCancelled else { return false }
        isActive = true
        return true
    }

    mutating func cancel() {
        isActive = false
        isCancelled = true
    }

    mutating func finish(didTriggerLongPress: Bool) -> Bool {
        let shouldTap = isActive && !isCancelled && !didTriggerLongPress
        reset()
        return shouldTap
    }

    mutating func reset() {
        isActive = false
        isCancelled = false
    }
}

/// 系统 idle 与触摸兜底共用一次性完成门。步骤切换或手势取消会推进代次，
/// 因而旧回调即使已排入主线程，也不能完成新步骤。
struct WatchInputCompletionGate {
    private(set) var generation = 0
    private var completedGeneration: Int?

    var hasCompletedTouch: Bool { completedGeneration == generation }

    mutating func begin() {
        generation &+= 1
    }

    mutating func completeTouch(for expectedGeneration: Int) -> Bool {
        guard expectedGeneration == generation, !hasCompletedTouch else { return false }
        completedGeneration = generation
        return true
    }
}

/// 日、周、月分页共用的表冠停止协调器。
///
/// watchOS 正常会在停止旋转后发送 `onIdle`，但实体表在焦点切换或系统
/// ScrollView 参与时偶尔会漏发。协调器同时维护两种互斥计时：
///
/// - 每个有效刻度重置 360ms 兜底；
/// - 收到 `onIdle` 后改用 90ms 短确认窗。
///
/// 新刻度、页面吸附或视图退出都会调用 `cancel()`，因此同一页面永远只有
/// 一个待执行任务。
@MainActor
final class CalendarCrownIdleCoordinator {
    private static let fallbackDelay: UInt64 = 360_000_000
    private static let idleConfirmationDelay: UInt64 = 90_000_000
    private var task: Task<Void, Never>?

    /// 安装实体表漏发 `onIdle` 时使用的较长兜底计时。
    func scheduleFallback(
        action: @escaping @MainActor () -> Void
    ) {
        schedule(afterNanoseconds: Self.fallbackDelay, action: action)
    }

    /// 系统已报告空闲时，用短窗口确认期间没有新刻度。
    func scheduleIdleConfirmation(
        action: @escaping @MainActor () -> Void
    ) {
        schedule(
            afterNanoseconds: Self.idleConfirmationDelay,
            action: action
        )
    }

    /// 取消旧任务后安装唯一的新停止检测任务。
    private func schedule(
        afterNanoseconds: UInt64,
        action: @escaping @MainActor () -> Void
    ) {
        cancel()
        task = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: afterNanoseconds)
            guard !Task.isCancelled else { return }
            self?.task = nil
            action()
        }
    }

    /// 新输入和页面生命周期变化共用的取消入口。
    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
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

/// 日、周、月视图共用的表冠连续旋转状态机。
///
/// 该类型不计算位移，也不播放触觉；它只提供两项基础能力：
///
/// 1. 超过 0.35 秒没有输入时开始新一轮；
/// 2. 识别同一轮旋转中的方向反转。
///
/// 具体的卡片滚动、页面位移和吸附阈值由各视图自行决定。
struct WatchCrownTurnSession {
    private static let inactivityTimeout: TimeInterval = 0.35

    private var lastEventTime: TimeInterval?
    private var direction = 0

    /// 接收一次非零表冠变化，并返回本次输入对应的会话语义。
    mutating func register(
        delta: Double,
        now: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> WatchCrownTurnUpdate? {
        guard delta.isFinite, now.isFinite, abs(delta) > .ulpOfOne else { return nil }

        // 使用单调时钟，手机校时不会把两次独立旋转合并为同一轮。
        let startsNewSession = lastEventTime.map {
            now < $0 || now - $0 > Self.inactivityTimeout
        } ?? true
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
        lastEventTime = nil
        direction = 0
    }
}
