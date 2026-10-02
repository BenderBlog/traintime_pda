// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

private enum WidgetInstallStep: Int, CaseIterable {
    case hold
    case edit
    case slot
    case app
    case widget

    var next: Self { Self(rawValue: (rawValue + 1) % Self.allCases.count)! }
    var title: String {
        switch self {
        case .hold: watchLocalizedString("长按表盘")
        case .edit: watchLocalizedString("轻点编辑")
        case .slot: watchLocalizedString("选择组件位置")
        case .app: watchLocalizedString("选择 XDYou")
        case .widget: watchLocalizedString("选择综合课表")
        }
    }
    var message: String {
        switch self {
        case .hold: watchLocalizedString("长按表盘空白处\n进入表盘选择界面")
        case .edit: watchLocalizedString("在表盘选择界面\n轻点下方“编辑”")
        case .slot: watchLocalizedString("滑到“复杂功能”\n轻点想放课表的位置")
        case .app: watchLocalizedString("在应用列表中找到\n并轻点 XDYou")
        case .widget: watchLocalizedString("选择“综合课表”\n返回表盘，轻点进入概览")
        }
    }

    var imageName: String {
        switch self {
        case .hold: "WidgetGuideInstallHold"
        case .edit: "WidgetGuideInstallEdit"
        case .slot: "WidgetGuideInstallSlot"
        case .app: "WidgetGuideInstallApp"
        case .widget: "WidgetGuideInstallWidget"
        }
    }

    /// 与原始截图裁切矩形保持相同比例，提示坐标始终跟随图片缩放。
    var imageSize: CGSize {
        switch self {
        case .hold: CGSize(width: 1004, height: 1196)
        case .edit: CGSize(width: 642, height: 347)
        case .slot: CGSize(width: 842, height: 375)
        case .app: CGSize(width: 924, height: 263)
        case .widget: CGSize(width: 930, height: 580)
        }
    }

    var touchPoint: UnitPoint {
        switch self {
        case .hold: UnitPoint(x: 0.70, y: 0.43)
        case .edit: UnitPoint(x: 0.52, y: 0.69)
        case .slot: UnitPoint(x: 0.87, y: 0.84)
        case .app: UnitPoint(x: 0.82, y: 0.52)
        case .widget: UnitPoint(x: 0.46, y: 0.86)
        }
    }
}

/// 用实拍截图演示系统添加路径；原图只做裁切，操作示范叠加在真实控件上。
struct WidgetInstallGuideView: View {
    let playsAnimations: Bool
    let didInteract: () -> Void
    @State private var step = WidgetInstallStep.hold
    @State private var holdProgress: CGFloat = 0
    @State private var manualRevision = 0

    private var playbackID: Int? { playsAnimations ? manualRevision : nil }

    var body: some View {
        WidgetIntroPage(
            title: watchLocalizedFormat(
                "%lld/%lld · %@", Int64(step.rawValue + 1),
                Int64(WidgetInstallStep.allCases.count), step.title
            ),
            message: step.message,
            messageScale: 0.7
        ) {
            Button(action: nextDemonstration) {
                illustration
                    .id(step)
                    .transition(.opacity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(watchLocalizedString("下一步添加示意"))
            .accessibilityValue(Text(verbatim: [step.title, step.message].joined(separator: "，")))
            .accessibilityHint(watchLocalizedString("添加后自动更新，轻点组件即可进入概览。"))
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .task(id: playbackID) {
            guard playsAnimations else {
                holdProgress = 1
                return
            }
            await runWidgetTutorialPlayback(
                prepareCard: prepareDemonstration,
                advanceCard: { step = step.next }
            )
        }
    }

    /// 环形示意先提交空进度再绘制填充；取消后不能启动离屏动画。
    private func prepareDemonstration() async {
        guard step == .hold else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { holdProgress = 0 }
        await Task.yield()
        guard !Task.isCancelled else { return }
        withAnimation(.linear(duration: 1.3)) { holdProgress = 1 }
    }

    private var illustration: some View {
        let width: CGFloat = 184
        let height = width * step.imageSize.height / step.imageSize.width

        return WidgetPreviewStage(width: width, height: height) {
            Image(step.imageName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(
                    cornerRadius: step == .hold ? width * 0.32 : 8,
                    style: .continuous
                ))
                .overlay {
                    PhaseAnimator(playsAnimations ? [false, true] : [false]) { phase in
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 23, height: 23)
                                .scaleEffect(step == .hold ? 1 : (phase ? 1.2 : 0.8))
                            if step == .hold {
                                Circle().trim(from: 0, to: holdProgress)
                                    .stroke(.cyan, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                    .frame(width: 23, height: 23)
                                    .rotationEffect(.degrees(-90))
                            }
                            Image(systemName: step == .hold ? "hand.point.up.left.fill" : "hand.tap.fill")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.8), radius: 1)
                                .offset(x: 5, y: 9)
                        }
                        .position(x: width * step.touchPoint.x, y: height * step.touchPoint.y)
                    } animation: { _ in
                        .easeInOut(duration: 0.85)
                    }
                    .allowsHitTesting(false)
                }
                .accessibilityHidden(true)
        }
    }

    private func nextDemonstration() {
        manualRevision &+= 1
        withAnimation(playsAnimations ? .easeInOut(duration: 0.25) : nil) {
            step = step.next
        }
        didInteract()
    }
}
