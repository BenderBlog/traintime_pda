//
//  SportWidget.swift
//  SportWidget
//
//  Created by BenderBlog Rodriguez on 2024/1/11.
//  SPDX-License-Identifier: MPL-2.0
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.xdyou"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), success:0, score:0, lastInfoTime: nil, lastInfoPlace: nil, lastInfoDescription: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        
        let entry = SimpleEntry(
            date: Date(),
            success: data?.integer(forKey: "success_punch") ?? -1,
            score: data?.integer(forKey: "score_punch") ?? -1,
            lastInfoTime: data?.string(forKey: "last_info_time"),
            lastInfoPlace: data?.string(forKey: "last_info_place"),
            lastInfoDescription: data?.string(forKey: "last_info_description")
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date : Date
    let success : Int
    let score : Int
    let lastInfoTime : String?
    let lastInfoPlace : String?
    let lastInfoDescription : String?
}

struct SportWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        if (widgetFamily != .systemMedium) {
            ZStack {
                ProgressView(value: (Double(entry.score) / 100.0))
                    .progressViewStyle(.circular)
                    .tint(.purple)
                
                if (entry.success == -1 && entry.score == -1) {
                    Text("--")
                } else if (widgetFamily != .accessoryCircular) {
                    VStack {
                        Text("\(entry.success) 次")
                        Text("\(entry.score) 分")
                    }
                } else {
                    Text("\(entry.success)")
                }
            }
        } else {
            HStack {
                ZStack {
                    ProgressView(value: (Double(entry.score) / 100.0))
                        .progressViewStyle(.circular)
                        .tint(.purple)
                    
                    if (entry.success == -1 && entry.score == -1) {
                        Text("--")
                    } else if (widgetFamily != .accessoryCircular) {
                        VStack {
                            Text("\(entry.success) 次")
                            Text("\(entry.score) 分")
                        }
                    } else {
                        Text("\(entry.success)")
                    }
                }
                Spacer()
                if (entry.lastInfoTime != nil) {
                    VStack (alignment: .leading){
                        Text("上次记录")
                        Text("\(entry.lastInfoTime!)")
                        Text("位置：\(entry.lastInfoPlace!)")
                        Text("信息：\(entry.lastInfoDescription!)")
                    }.padding()
                } else if (entry.success == -1 && entry.score == -1) {
                    Text("获取刷脸信息失败").padding()
                } else {
                    Text("快去打卡吧").padding()
                }
            }
        }
    }
}

struct SportWidget: Widget {
    let kind: String = "SportWidget"
    var body: some WidgetConfiguration {
        var supportFamilies : [WidgetFamily] = [.systemSmall, .systemMedium]
        if #available(iOS 16, *) {
            supportFamilies.append(.accessoryCircular)
        }
        return StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SportWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SportWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("体育刷脸部件")
        .description("查询刷脸成功次数和得分")
        .supportedFamilies(supportFamilies)
    }
}

#Preview(as: .systemSmall) {
    SportWidget()
} timeline: {
    SimpleEntry(date: Date(), success:-1, score:-1, lastInfoTime: nil, lastInfoPlace: nil, lastInfoDescription: nil)
    SimpleEntry(date: Date(), success:0, score:0, lastInfoTime: nil, lastInfoPlace: nil, lastInfoDescription: nil)
    SimpleEntry(date: Date(), success:50, score:100, lastInfoTime: "2024-01-02 19:35", lastInfoPlace: "北操场", lastInfoDescription: "打卡成功")
    SimpleEntry(date: Date(), success:30, score:60, lastInfoTime: "2024-01-02 19:35", lastInfoPlace: "北篮球场", lastInfoDescription: "未到30分钟")
}
