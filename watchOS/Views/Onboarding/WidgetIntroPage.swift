// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 内容页共用固定的首行标题和两行底部说明，其间的有限高度全部交给展示区。
struct WidgetIntroPage<Content: View>: View {
    let title: String
    let message: String
    let messageScale: CGFloat
    let messageIsCaption: Bool
    let messageAction: (() -> Void)?
    let content: Content

    init(
        title: String,
        message: String,
        messageScale: CGFloat = 1,
        messageIsCaption: Bool = false,
        messageAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.message = message
        self.messageScale = messageScale
        self.messageIsCaption = messageIsCaption
        self.messageAction = messageAction
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let contentHeight = max(
                0,
                proxy.size.height - WidgetTutorialLayout.titleHeight
                    - messageHeight - 2 * WidgetTutorialLayout.sectionSpacing
            )
            VStack(spacing: WidgetTutorialLayout.sectionSpacing) {
                Text(verbatim: title)
                    .font(.system(size: WidgetTutorialLayout.textSize, weight: .semibold))
                    .lineLimit(1)
                    .frame(width: proxy.size.width, height: WidgetTutorialLayout.titleHeight)
                    .accessibilityAddTraits(.isHeader)

                content.frame(width: proxy.size.width, height: contentHeight)

                footer.frame(width: proxy.size.width, height: messageHeight)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, WidgetTutorialLayout.horizontalInset)
    }

    @ViewBuilder
    private var footer: some View {
        if let messageAction {
            Button(action: messageAction) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    explanation
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(.cyan)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: message))
        } else {
            explanation.foregroundStyle(usesCaptionStyle ? Color.cyan : Color.white.opacity(0.85))
        }
    }

    private var usesCaptionStyle: Bool { messageIsCaption || messageAction != nil }

    private var messageHeight: CGFloat {
        // 字号与文字区同步缩放，腾出的高度交给上方示意图。
        (usesCaptionStyle ? WidgetTutorialLayout.captionMessageHeight : WidgetTutorialLayout.messageHeight) * messageScale
    }

    private var explanation: some View {
        Text(verbatim: message)
            .font(.system(
                size: (usesCaptionStyle ? 10.5 : WidgetTutorialLayout.textSize) * messageScale,
                weight: .regular
            ))
            .lineLimit(2)
            .minimumScaleFactor(usesCaptionStyle ? 0.75 : 1)
    }
}

/// 开场与结束独占整页，复用 App 实操教程的纯黑背景和斜向扫光文字。
struct WidgetOnboardingTransitionPage: View {
    let title: String
    let message: String
    let playsAnimations: Bool
    var continueAction: (() -> Void)? = nil

    var body: some View {
        Group {
            if let continueAction {
                Button(action: continueAction) { content }
                    .buttonStyle(.plain)
            } else {
                content.accessibilityElement(children: .combine)
            }
        }
        .environment(\.watchOnboardingAnimationsPaused, !playsAnimations)
    }

    private var content: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 18) {
                WatchOnboardingSweepingLightText(
                    text: title,
                    font: .system(size: WidgetTutorialLayout.textSize, weight: .semibold),
                    baseOpacity: 1
                )
                .accessibilityAddTraits(.isHeader)
                WatchOnboardingSweepingLightText(
                    text: message,
                    font: .system(size: WidgetTutorialLayout.textSize, weight: .medium),
                    baseOpacity: 0.76
                )
            }
            .padding(.horizontal, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

struct WidgetScheduleGuidePage: View {
    let image: WidgetTutorialImage
    let cycleImage: () -> Void

    var body: some View {
        WidgetIntroPage(
            title: watchLocalizedString("抬腕，就知道下一节"),
            message: watchLocalizedString("课中看时间和进度\n课后显示下一节课")
        ) {
            WidgetRotatingPreview(image: image, cycleImage: cycleImage)
        }
    }
}

/// 图片区域整体可点，说明只占一行，把余下高度交给原比例的组件截图。
private struct WidgetRotatingPreview: View {
    let image: WidgetTutorialImage
    let cycleImage: () -> Void

    var body: some View {
        Button(action: cycleImage) {
            GeometryReader { proxy in
                let pictureHeight = max(
                    0,
                    proxy.size.height - WidgetTutorialLayout.previewCaptionHeight
                        - WidgetTutorialLayout.sectionSpacing
                )
                VStack(spacing: WidgetTutorialLayout.sectionSpacing) {
                    WidgetTutorialCardPreview(image: image)
                        .frame(width: proxy.size.width, height: pictureHeight)

                    HStack(spacing: 4) {
                        Text(verbatim: [image.family.title, image.state.title].joined(separator: " · "))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Image(systemName: "chevron.right").font(.system(size: 8, weight: .bold))
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.cyan)
                    .frame(width: proxy.size.width, height: WidgetTutorialLayout.previewCaptionHeight)
                }
                // 图片与形态/状态标签作为一组过渡，避免切换时文字先于图片变化。
                .id(image)
                .transition(.opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(watchLocalizedString("切换组件示例"))
        .accessibilityValue(Text(verbatim: image.accessibilitySummary))
        .accessibilityHint(watchLocalizedString("轻点图片查看其他组件和状态。"))
    }
}

struct WidgetSizeGuidePage: View {
    let playsAnimations: Bool
    let didSelect: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var family = WidgetPreviewFamily.circular
    @State private var exampleIndex = 0
    @State private var manualRevision = 0

    // 自动推进保持同一任务；手动选择或播放条件变化才重置阅读计时。
    private var playbackID: Int? { playsAnimations ? manualRevision : nil }

    private var example: WidgetTutorialImage {
        family.examples[min(exampleIndex, family.examples.count - 1)]
    }

    var body: some View {
        WidgetIntroPage(
            title: watchLocalizedString("选择适合你的表盘"),
            message: [example.caption, example.guideDescription].joined(separator: "\n"),
            messageIsCaption: true,
            messageAction: family.examples.count > 1 ? cycleExample : nil
        ) {
            GeometryReader { proxy in
                let selectorHeight: CGFloat = 32
                let pictureHeight = max(0, proxy.size.height - selectorHeight - WidgetTutorialLayout.sectionSpacing)
                VStack(spacing: WidgetTutorialLayout.sectionSpacing) {
                    if family.examples.count > 1 {
                        Button(action: cycleExample) {
                            selectedExample
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(width: proxy.size.width, height: pictureHeight)
                        .accessibilityLabel(watchLocalizedString("切换组件示例"))
                        .accessibilityValue(Text(verbatim: example.accessibilitySummary))
                        .accessibilityHint(watchLocalizedString("轻点图片查看其他组件和状态。"))
                    } else {
                        selectedExample
                            .frame(width: proxy.size.width, height: pictureHeight)
                    }
                    familySelector.frame(width: proxy.size.width, height: selectorHeight)
                }
            }
        }
        .task(id: playbackID) {
            guard playsAnimations else { return }
            await runWidgetTutorialPlayback(advanceCard: advanceExample)
        }
    }

    private var familySelector: some View {
        HStack(spacing: 6) {
            ForEach(WidgetPreviewFamily.allCases) { candidate in
                Button {
                    manualRevision &+= 1
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                        family = candidate
                        exampleIndex = 0
                    }
                    didSelect()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: candidate.symbol)
                            .font(.system(size: 13, weight: .medium))
                        Text(verbatim: candidate.title)
                            .font(.system(size: 9, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(family == candidate ? Color.cyan : Color.white.opacity(0.72))
                    .background(family == candidate ? Color.cyan.opacity(0.15) : Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(candidate.title)
                .accessibilityHint(candidate.message)
                .accessibilityAddTraits(family == candidate ? [.isSelected] : [])
            }
        }
    }

    private var selectedExample: some View {
        WidgetTutorialCardPreview(image: example)
            .id(example)
            .transition(.opacity)
    }

    private func cycleExample() {
        manualRevision &+= 1
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
            advanceExample()
        }
        didSelect()
    }

    private func advanceExample() {
        exampleIndex = (exampleIndex + 1) % family.examples.count
    }
}
