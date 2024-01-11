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
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        if (widgetFamily != .systemMedium) {
            ZStack {
                ProgressView(value: (Double(entry.score) / 100.0))
                    .progressViewStyle(.circular)
                    .tint(colorScheme == .dark ? .purple : .blue)
                
                VStack {
                    Image(systemName: "figure.run")
                    if #available(iOS 16, *) {
                        if (widgetFamily == .accessoryCircular) {
                            Text(entry.success == -1 && entry.score == -1 ? "-- " : "\(entry.success)")
                        } else {
                            Divider().hidden()
                            if (entry.success == -1 && entry.score == -1) {
                                Text("--")
                            } else {
                                Text("\(entry.success) 次")
                                Text("\(entry.score) 分")
                            }
                        }
                    } else {
                        Divider().hidden()
                        if (entry.success == -1 && entry.score == -1) {
                            Text("--")
                        } else {
                            Text("\(entry.success) 次")
                            Text("\(entry.score) 分")
                        }
                    }
                }
            }
        } else {
            HStack {
                ZStack {
                    ProgressView(value: (Double(entry.score) / 100.0))
                        .progressViewStyle(.circular)
                        .tint(colorScheme == .dark ? .purple : .blue)
                    VStack {
                        Image(systemName: "figure.run")
                        if (entry.success == -1 && entry.score == -1) {
                            Text("--")
                        } else {
                            Text("\(entry.success) 次")
                            Text("\(entry.score) 分")
                        }
                    }
                }.frame(width: 96, height: 96)
                Spacer()
                if (entry.lastInfoTime != nil) {
                    VStack (alignment: .leading){
                        Text("上次记录").font(.body)
                        Divider().hidden()
                        HStack {
                            Image(systemName: "clock").font(.footnote)
                            Text("\(entry.lastInfoTime!)").font(.footnote)
                        }.padding(.bottom,4)
                        HStack {
                            Image(systemName: "location").font(.footnote)
                            Text("\(entry.lastInfoPlace!)").font(.footnote)
                        }.padding(.bottom,4)
                        HStack {
                            Image(systemName: "info.circle").font(.footnote)
                            VStack {
                                Text("\(entry.lastInfoDescription!)").font(.footnote)
                            }
                        }
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
    @Environment(\.colorScheme) var colorScheme
    var body: some WidgetConfiguration {
        var supportFamilies : [WidgetFamily] = [.systemSmall, .systemMedium]
        if #available(iOS 16, *) {
            supportFamilies.append(.accessoryCircular)
        }
        return StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SportWidgetEntryView(entry: entry)
                    .containerBackground(Color("WidgetBackground"), for: .widget)
            } else {
                SportWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color("WidgetBackground"))
            }
        }
        .configurationDisplayName("体育刷脸部件")
        .description("查询刷脸成功次数和得分")
        .supportedFamilies(supportFamilies)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
#Preview(as: .systemSmall) {
    SportWidget()
} timeline: {
    SimpleEntry(date: Date(), success:-1, score:-1, lastInfoTime: nil, lastInfoPlace: nil, lastInfoDescription: nil)
    SimpleEntry(date: Date(), success:0, score:0, lastInfoTime: nil, lastInfoPlace: nil, lastInfoDescription: nil)
    SimpleEntry(date: Date(), success:50, score:100, lastInfoTime: "2024-01-02 19:35:40", lastInfoPlace: "北操场", lastInfoDescription: "打卡成功")
    SimpleEntry(date: Date(), success:30, score:60, lastInfoTime: "2024-01-02 19:35:40", lastInfoPlace: "北篮球场入口东-1", lastInfoDescription: "恭喜你本次打卡成功，本次打卡时间为：75分钟")
}
