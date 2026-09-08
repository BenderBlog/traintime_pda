// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

enum WidgetTutorialPage: Int, CaseIterable, Identifiable {
    case introduction
    case schedule
    case sizes
    case install
    case completion

    var id: Int { rawValue }
}

/// 标题紧接状态栏；底部说明与分页点分区排列，中间使用剩余视口。
enum WidgetTutorialLayout {
    static let minimumTopInset: CGFloat = 36
    static let horizontalInset: CGFloat = 8
    static let textSize: CGFloat = 17
    static let titleHeight: CGFloat = 26
    static let titleLift: CGFloat = titleHeight / 2
    static let messageHeight: CGFloat = 44
    static let captionMessageHeight: CGFloat = 32
    static let sectionSpacing: CGFloat = 8
    static let previewCaptionHeight: CGFloat = 22
    static let cardReferenceSize = CGSize(width: 164, height: 70)
    static let cardDisplayDuration: Duration = .seconds(3)
    static let messageToIndicatorsSpacing: CGFloat = 10
    static let pageIndicatorHeight: CGFloat = 24
    static let pageIndicatorBottomInset: CGFloat = 6
    static let pageIndicatorLift: CGFloat = 6

    static var bottomInset: CGFloat {
        messageToIndicatorsSpacing + pageIndicatorHeight + pageIndicatorBottomInset
    }
}

/// 三个示例页共用可取消的循环；手动操作通过 `.task(id:)` 重建阅读计时。
/// `prepareCard` 只准备当前卡片的演示，翻页和退出时由宿主任务一并取消。
@MainActor
func runWidgetTutorialPlayback(
    prepareCard: @MainActor () async -> Void = {},
    advanceCard: @MainActor () -> Void
) async {
    while !Task.isCancelled {
        await prepareCard()
        guard !Task.isCancelled else { return }
        do { try await Task.sleep(for: WidgetTutorialLayout.cardDisplayDuration) }
        catch { return }
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: 0.25)) { advanceCard() }
    }
}

/// 阅读型教程独立于实操输入桥；系统分页处理滑动，表冠和辅助功能共用选择入口。
struct WidgetOnboardingView: View {
    let finish: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @State private var page = WidgetTutorialPage.introduction
    @State private var crownPosition = 0.0
    @State private var previewIndex = 0
    @State private var manualPreviewRevision = 0
    @State private var didFinish = false
    @State private var introductionSlideID: UUID?
    @State private var introductionSlideProgress: CGFloat = 0
    @FocusState private var crownFocused: Bool

    // 三种课中形态，以及圆形和长方形的次日状态。
    private static let schedulePreviews: [WidgetTutorialImage] = [
        .circularScheduleOngoing, .cornerScheduleOngoing, .rectangularScheduleOngoing,
        .circularScheduleTomorrow, .rectangularScheduleTomorrow,
    ]

    private var previewImage: WidgetTutorialImage {
        Self.schedulePreviews[previewIndex % Self.schedulePreviews.count]
    }

    private var canAnimate: Bool {
        scenePhase == .active && !reduceMotion && !voiceOverEnabled && introductionSlideID == nil
    }

    private struct PlaybackID: Equatable {
        let page: WidgetTutorialPage?
        let revision: Int
    }

    private var playbackID: PlaybackID {
        PlaybackID(
            page: canAnimate && page == .schedule ? page : nil,
            revision: manualPreviewRevision
        )
    }

    private var completionIsActive: Bool {
        page == .completion && scenePhase == .active
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = max(WidgetTutorialLayout.minimumTopInset, proxy.safeAreaInsets.top)
            ZStack {
                Color.black
                pages(in: proxy.size, topInset: topInset)
                    .allowsHitTesting(introductionSlideID == nil)
                    .accessibilityHidden(introductionSlideID != nil)

                if let introductionSlideID {
                    introductionSlide(in: proxy.size, topInset: topInset)
                        .id(introductionSlideID)
                        .transition(.identity)
                        .onAppear { animateIntroductionSlide(id: introductionSlideID) }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .environment(\.colorScheme, .dark)
        .onAppear(perform: reclaimCrownFocus)
        .onChange(of: page) { _, selected in
            crownPosition = Double(selected.rawValue)
            previewIndex = 0
            WatchHaptics.selection()
            reclaimCrownFocus()
        }
        .onChange(of: crownPosition) { _, position in
            guard position.isFinite else { return }
            selectPage(at: Int(position.rounded()))
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                reclaimCrownFocus()
            } else if let introductionSlideID {
                finishIntroductionSlide(id: introductionSlideID)
            }
        }
        .onDisappear {
            if let introductionSlideID {
                finishIntroductionSlide(id: introductionSlideID, restoresFocus: false)
            }
        }
        .task(id: playbackID) {
            guard playbackID.page != nil else { return }
            await runWidgetTutorialPlayback(advanceCard: advancePreview)
        }
        .task(id: completionIsActive) {
            // TabView 会预加载相邻页，因此由真实选中页控制计时，不能依赖 onAppear。
            guard completionIsActive, !didFinish else { return }
            do { try await Task.sleep(for: .seconds(2)) }
            catch { return }
            guard !Task.isCancelled, completionIsActive, !didFinish else { return }
            didFinish = true
            finish()
        }
    }

    private func pages(in viewport: CGSize, topInset: CGFloat) -> some View {
        TabView(selection: $page) {
            introductionPage(in: viewport)
                .tag(WidgetTutorialPage.introduction)

            schedulePage(in: viewport, topInset: topInset)
                .tag(WidgetTutorialPage.schedule)

            contentPage(in: viewport, topInset: topInset) {
                WidgetSizeGuidePage(
                    playsAnimations: canAnimate && page == .sizes,
                    didSelect: reclaimCrownFocus
                )
            }
            .tag(WidgetTutorialPage.sizes)

            contentPage(in: viewport, topInset: topInset) {
                WidgetInstallGuideView(
                    playsAnimations: canAnimate && page == .install,
                    didInteract: reclaimCrownFocus
                )
            }
            .tag(WidgetTutorialPage.install)

            WidgetOnboardingTransitionPage(
                title: watchLocalizedString("教程结束"),
                message: watchLocalizedString("开始愉快的使用吧"),
                playsAnimations: canAnimate && page == .completion
            )
            .frame(width: viewport.width, height: viewport.height)
            .tag(WidgetTutorialPage.completion)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .frame(width: viewport.width, height: viewport.height)
        .id(locale.identifier)
        .focusable()
        .focused($crownFocused)
        .digitalCrownRotation(
            $crownPosition,
            from: 0,
            through: Double(WidgetTutorialPage.allCases.count - 1),
            by: 1,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: false
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selectPage(at: page.rawValue + 1)
            case .decrement: selectPage(at: page.rawValue - 1)
            @unknown default: break
            }
        }
    }

    private func introductionPage(in viewport: CGSize) -> some View {
        WidgetOnboardingTransitionPage(
            title: watchLocalizedString("还有一个更快的方法"),
            message: watchLocalizedString("轻点以继续"),
            playsAnimations: canAnimate && page == .introduction,
            continueAction: startIntroductionSlide
        )
        .frame(width: viewport.width, height: viewport.height)
    }

    private func schedulePage(in viewport: CGSize, topInset: CGFloat) -> some View {
        contentPage(in: viewport, topInset: topInset) {
            WidgetScheduleGuidePage(image: previewImage, cycleImage: cyclePreview)
        }
    }

    /// 首页轻点时明确平移两页，结束后交还系统分页；两处复用完全相同的页面布局。
    private func introductionSlide(in viewport: CGSize, topInset: CGFloat) -> some View {
        HStack(spacing: 0) {
            introductionPage(in: viewport)
            schedulePage(in: viewport, topInset: topInset)
        }
        .frame(width: viewport.width * 2, height: viewport.height)
        .offset(x: -viewport.width * introductionSlideProgress)
        .frame(width: viewport.width, height: viewport.height, alignment: .leading)
        .clipped()
        .background(.black)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func startIntroductionSlide() {
        guard page == .introduction, introductionSlideID == nil, scenePhase == .active else { return }
        guard !reduceMotion else {
            selectPage(at: WidgetTutorialPage.schedule.rawValue)
            return
        }
        introductionSlideProgress = 0
        introductionSlideID = UUID()
        crownFocused = false
    }

    private func animateIntroductionSlide(id: UUID) {
        guard introductionSlideID == id else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { page = .schedule }
        withAnimation(.easeInOut(duration: 0.38), completionCriteria: .removed) {
            introductionSlideProgress = 1
        } completion: {
            finishIntroductionSlide(id: id)
        }
    }

    private func finishIntroductionSlide(id: UUID, restoresFocus: Bool = true) {
        guard introductionSlideID == id else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            page = .schedule
            crownPosition = Double(WidgetTutorialPage.schedule.rawValue)
            introductionSlideID = nil
            introductionSlideProgress = 0
        }
        if restoresFocus { reclaimCrownFocus() }
    }

    private var pageIndicators: some View {
        HStack(spacing: 0) {
            ForEach(WidgetTutorialPage.allCases) { candidate in
                Button { selectPage(at: candidate.rawValue) } label: {
                    Circle()
                        .fill(candidate == page ? Color.cyan : Color.white.opacity(0.28))
                        .frame(width: candidate == page ? 7 : 5, height: candidate == page ? 7 : 5)
                        // 只上移圆点，保留底栏高度和点击区域，不牵动正文位置。
                        .offset(y: -WidgetTutorialLayout.pageIndicatorLift)
                        .frame(width: 24, height: WidgetTutorialLayout.pageIndicatorHeight)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(watchLocalizedFormat(
                    "第 %lld 页，共 %lld 页", Int64(candidate.rawValue + 1), Int64(WidgetTutorialPage.allCases.count)
                ))
                .accessibilityAddTraits(candidate == page ? [.isSelected] : [])
            }
        }
    }

    private func contentPage<Content: View>(
        in viewport: CGSize,
        topInset: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        // 正文与分页点在同一个 Tab 内顺序布局，系统分页的安全区不能把两者叠到一起。
        // 按标题的实际起点分配展示区高度，避免文字偏移后留下多余占位；底栏保持固定。
        let contentTopInset = max(0, topInset - WidgetTutorialLayout.titleLift)
        return VStack(spacing: WidgetTutorialLayout.messageToIndicatorsSpacing) {
            content()
                .frame(
                    width: viewport.width,
                    height: max(0, viewport.height - contentTopInset - WidgetTutorialLayout.bottomInset)
                )
            pageIndicators
                .frame(height: WidgetTutorialLayout.pageIndicatorHeight)
        }
        .padding(.top, contentTopInset)
        .padding(.bottom, WidgetTutorialLayout.pageIndicatorBottomInset)
        .frame(width: viewport.width, height: viewport.height, alignment: .top)
    }

    private func selectPage(at index: Int) {
        guard introductionSlideID == nil,
              let next = WidgetTutorialPage(rawValue: index), next != page else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.24)) {
            page = next
        }
    }

    private func reclaimCrownFocus() {
        guard !voiceOverEnabled, scenePhase == .active, introductionSlideID == nil else { return }
        crownFocused = true
    }

    private func advancePreview() {
        previewIndex = (previewIndex + 1) % Self.schedulePreviews.count
    }

    private func cyclePreview() {
        manualPreviewRevision &+= 1
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            advancePreview()
        }
        reclaimCrownFocus()
    }
}
