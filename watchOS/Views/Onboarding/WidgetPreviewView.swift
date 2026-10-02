// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 与用户提供的截图对应；教学图片不请求课表、不写缓存，也不参与真实组件刷新。
enum WidgetPreviewState: Int, CaseIterable {
    case ongoing
    case tomorrow
    case nextClass

    var time: String { self == .ongoing ? endTime : startTime }
    var startTime: String {
        switch self {
        case .ongoing: "20:00"
        case .tomorrow: "08:30"
        case .nextClass: "10:25"
        }
    }
    var endTime: String {
        switch self {
        case .ongoing: "21:15"
        case .tomorrow: "10:05"
        case .nextClass: "12:00"
        }
    }
    var location: String {
        switch self {
        case .ongoing: "B-312"
        case .tomorrow: "B-442"
        case .nextClass: "A-602"
        }
    }
    var teacher: String {
        switch self {
        case .ongoing: "宋浩"
        case .tomorrow: "苏玉龙"
        case .nextClass: "相萌，董雪"
        }
    }
    var courseName: String {
        switch self {
        case .ongoing: watchLocalizedString("高等数学")
        case .tomorrow: watchLocalizedString("工程概论 (IV)")
        case .nextClass: watchLocalizedString("光电成像原理")
        }
    }
    var title: String {
        switch self {
        case .ongoing: watchLocalizedString("正在上课")
        case .tomorrow: watchLocalizedString("今日已下课")
        case .nextClass: watchLocalizedString("下一节课")
        }
    }
    var heading: String {
        switch self {
        case .ongoing: watchLocalizedString("下课")
        case .tomorrow: watchLocalizedFormat("明天%@", watchLocalizedString("上课"))
        case .nextClass: watchLocalizedString("上课")
        }
    }
    var accessibilitySummary: String {
        [heading, time, location].joined(separator: "，")
    }
}

/// 教程所展示的组件用途，与截图文件名解耦，供说明和辅助功能共用。
enum WidgetPreviewRole {
    case combined, name, timeAndPlace, overview

    var title: String {
        switch self {
        case .combined: watchLocalizedString("综合课表")
        case .name: watchLocalizedString("课程名称")
        case .timeAndPlace: watchLocalizedString("时间地点")
        case .overview: watchLocalizedString("日程概览")
        }
    }
}

/// 每种形态只列出已经提供截图的示例；表角只有课中综合课表这一张。
enum WidgetPreviewFamily: Int, CaseIterable, Identifiable {
    case circular, corner, rectangular

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .circular: watchLocalizedString("圆形")
        case .corner: watchLocalizedString("表角")
        case .rectangular: watchLocalizedString("长方形")
        }
    }
    var symbol: String {
        switch self {
        case .circular: "circle"
        case .corner: "arrow.up.left"
        case .rectangular: "rectangle"
        }
    }
    var message: String {
        switch self {
        case .circular: watchLocalizedString("圆形：快速查看时间与地点。")
        case .corner: watchLocalizedString("表角：沿表盘边缘查看课程与进度。")
        case .rectangular: watchLocalizedString("长方形：课程、时间、地点与教师更完整。")
        }
    }
    var examples: [WidgetTutorialImage] {
        switch self {
        case .circular:
            [.circularScheduleNext, .circularNameNext,
             .circularScheduleOngoing, .circularScheduleTomorrow,
             .circularNameOngoing, .circularNameTomorrow,
             .circularTimeOngoing, .circularTimeTomorrow,
             .circularOverviewOngoing, .circularOverviewTomorrow]
        case .corner:
            [.cornerScheduleOngoing]
        case .rectangular:
            [.rectangularScheduleNext, .rectangularScheduleOngoing, .rectangularScheduleTomorrow]
        }
    }
}

/// 资源名集中管理。保留截图原色，避免图片随教程按钮的强调色被重新着色。
enum WidgetTutorialImage: String {
    case circularScheduleNext = "WidgetGuideCircularScheduleNext"
    case circularNameNext = "WidgetGuideCircularNameNext"
    case rectangularScheduleNext = "WidgetGuideRectangularScheduleNext"
    case circularScheduleOngoing = "WidgetGuideCircularScheduleOngoing"
    case circularScheduleTomorrow = "WidgetGuideCircularScheduleTomorrow"
    case circularNameOngoing = "WidgetGuideCircularNameOngoing"
    case circularNameTomorrow = "WidgetGuideCircularNameTomorrow"
    case circularTimeOngoing = "WidgetGuideCircularTimeOngoing"
    case circularTimeTomorrow = "WidgetGuideCircularTimeTomorrow"
    case circularOverviewOngoing = "WidgetGuideCircularOverviewOngoing"
    case circularOverviewTomorrow = "WidgetGuideCircularOverviewTomorrow"
    case rectangularScheduleOngoing = "WidgetGuideRectangularScheduleOngoing"
    case rectangularScheduleTomorrow = "WidgetGuideRectangularScheduleTomorrow"
    case cornerScheduleOngoing = "WidgetGuideCornerScheduleOngoing"
    case faceCircularOngoing = "WidgetGuideFaceCircularOngoing"
    case faceRectangularOngoing = "WidgetGuideFaceRectangularOngoing"

    var state: WidgetPreviewState {
        switch self {
        case .circularScheduleNext, .circularNameNext, .rectangularScheduleNext: .nextClass
        case .circularScheduleTomorrow, .circularNameTomorrow,
             .circularTimeTomorrow, .circularOverviewTomorrow,
             .rectangularScheduleTomorrow: .tomorrow
        default: .ongoing
        }
    }
    var family: WidgetPreviewFamily {
        switch self {
        case .cornerScheduleOngoing: .corner
        case .rectangularScheduleNext, .rectangularScheduleOngoing, .rectangularScheduleTomorrow,
             .faceRectangularOngoing: .rectangular
        default: .circular
        }
    }
    var role: WidgetPreviewRole {
        switch self {
        case .circularNameNext, .circularNameOngoing, .circularNameTomorrow: .name
        case .circularTimeOngoing, .circularTimeTomorrow: .timeAndPlace
        case .circularOverviewOngoing, .circularOverviewTomorrow: .overview
        default: .combined
        }
    }
    var caption: String { [role.title, state.title].joined(separator: " · ") }

    var guideDescription: String {
        switch role {
        case .combined:
            switch family {
            case .corner: watchLocalizedString("沿表盘边缘看课程与进度")
            case .rectangular: watchLocalizedString("课程、时间、地点与教师")
            case .circular: timeAndPlaceDescription
            }
        case .name:
            watchLocalizedString("当前或下一节课的名称")
        case .timeAndPlace:
            timeAndPlaceDescription
        case .overview:
            watchLocalizedString("今日剩余安排与结束状态")
        }
    }

    private var timeAndPlaceDescription: String {
        watchLocalizedString(state == .ongoing ? "下课时间、地点与进度" : "下次上课的时间与地点")
    }

    var accessibilitySummary: String {
        var details = [family.title, role.title, state.title]
        switch role {
        case .name:
            details.append(state.courseName)
        case .overview:
            if state == .ongoing {
                details.append(watchLocalizedFormat("今日还剩 %lld 项", Int64(1)))
            } else {
                details.append(watchLocalizedFormat("明天%@", state.time))
            }
        case .combined, .timeAndPlace:
            if role == .combined { details.append(state.courseName) }
            if family == .rectangular {
                details += [watchLocalizedString("上课"), state.startTime,
                            watchLocalizedString("下课"), state.endTime,
                            state.location, state.teacher]
            } else if family == .corner {
                details += [watchLocalizedString("课程进度"), state.location]
            } else {
                details.append(state.accessibilitySummary)
            }
        }
        return details.joined(separator: "，")
    }
}

struct WidgetScreenshotPreview: View {
    let image: WidgetTutorialImage

    var body: some View {
        Image(image.rawValue)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .accessibilityLabel(Text(verbatim: image.accessibilitySummary))
    }
}

/// 各种形态的组件截图共用长方形画布，等高缩放并保留原图比例。
struct WidgetTutorialCardPreview: View {
    let image: WidgetTutorialImage

    var body: some View {
        WidgetPreviewStage(
            width: WidgetTutorialLayout.cardReferenceSize.width,
            height: WidgetTutorialLayout.cardReferenceSize.height
        ) {
            WidgetScreenshotPreview(image: image)
        }
    }
}

/// 在有限教学视口内等比缩放，保持截图中各行文字、图标和进度条的原始比例。
struct WidgetPreviewStage<Content: View>: View {
    let referenceSize: CGSize
    let content: Content

    init(width: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) {
        referenceSize = CGSize(width: width, height: height)
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = max(0.01, min(
                proxy.size.width / referenceSize.width,
                proxy.size.height / referenceSize.height
            ))
            content
                .frame(width: referenceSize.width, height: referenceSize.height)
                .scaleEffect(scale)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }
}
