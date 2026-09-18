// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

private enum WidgetInstallStep: Int, CaseIterable {
    case hold
    case edit
    case choose

    var next: Self { Self(rawValue: (rawValue + 1) % Self.allCases.count)! }
    var title: String {
        switch self {
        case .hold: watchLocalizedString("长按表盘")
        case .edit: watchLocalizedString("编辑 → 复杂功能")
        case .choose: watchLocalizedString("选择 XDYou")
        }
    }
    var message: String {
        switch self {
        case .hold: watchLocalizedString("长按表盘空白处\n进入表盘编辑模式")
        case .edit: watchLocalizedString("轻点“编辑”\n滑到“复杂功能”")
        case .choose: watchLocalizedString("轻点一个组件位置\n选择 XDYou 小组件")
        }
    }
}

/// 演示系统添加路径，不尝试跳转或控制表盘编辑器，也不把阅读完成当作已安装。
struct WidgetInstallGuideView: View {
    let playsAnimations: Bool
    let didInteract: () -> Void
    @State private var step = WidgetInstallStep.hold
    @State private var holdProgress: CGFloat = 0
    @State private var manualRevision = 0

    private var playbackID: Int? { playsAnimations ? manualRevision : nil }

    var body: some View {
        WidgetIntroPage(
            title: watchLocalizedString("把课表放到表盘上"),
            message: step.message,
            messageScale: 3.0 / 5.0
        ) {
            GeometryReader { proxy in
                let pictureHeight = max(
                    0,
                    proxy.size.height - WidgetTutorialLayout.previewCaptionHeight
                        - WidgetTutorialLayout.sectionSpacing
                )
                VStack(spacing: WidgetTutorialLayout.sectionSpacing) {
                    WidgetPreviewStage(width: 164, height: 134) {
                        illustration
                    }
                    .frame(width: proxy.size.width, height: pictureHeight)
                    .accessibilityHidden(true)

                    Button(action: nextDemonstration) {
                        HStack(spacing: 4) {
                            Text(verbatim: "\(step.rawValue + 1) · \(step.title)")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Image(systemName: "chevron.right").font(.system(size: 8, weight: .bold))
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.cyan)
                        .frame(width: proxy.size.width, height: WidgetTutorialLayout.previewCaptionHeight)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(watchLocalizedString("下一步添加示意"))
                    .accessibilityValue(step.title)
                    .accessibilityHint(watchLocalizedString("添加后自动更新，轻点组件即可进入概览。"))
                }
                .id(step)
                .transition(.opacity)
            }
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

    @ViewBuilder
    private var illustration: some View {
        switch step {
        case .hold:
            WidgetFacePreview(state: .ongoing)
                .overlay {
                    Circle().trim(from: 0, to: holdProgress)
                        .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 27, height: 27)
                        .rotationEffect(.degrees(-90))
                        .offset(x: 27, y: 17)
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 3)
                        .offset(x: 36, y: 35)
                }
        case .edit:
            WidgetFacePreview(state: .ongoing)
                .scaleEffect(0.88)
                .opacity(0.45)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.cyan, lineWidth: 2)
                        .frame(width: 46, height: 46)
                        .offset(x: -44, y: -31)
                    Text(verbatim: watchLocalizedString("编辑"))
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.18), in: Capsule())
                        .offset(y: 53)
                }
        case .choose:
            VStack(spacing: 8) {
                Text(verbatim: "XDYou")
                    .font(.system(size: WidgetTutorialLayout.textSize, weight: .semibold))
                    .foregroundStyle(.cyan)
                WidgetScreenshotPreview(image: .rectangularScheduleOngoing)
                    .frame(width: 146, height: 62)
                Label(watchLocalizedString("综合课表"), systemImage: "checkmark.circle.fill")
                    .font(.system(size: WidgetTutorialLayout.textSize))
            }
            .frame(width: 164, height: 134)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(.cyan.opacity(0.6), lineWidth: 1))
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
