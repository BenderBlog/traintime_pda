//
//  ClasstableWidget.swift
//  ClasstableWidget
//
//  Created by sprt on 2024/1/6.
//  SPDX-License-Identifier: MPL-2.0
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "xyz.superbart.xdyou"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), class_table_date: Date(), class_table_json: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), class_table_date: Date(), class_table_json: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: Date(), class_table_date: entryDate, class_table_json: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let class_table_date: Date
    let class_table_json: String
}

struct ClasstableWidgetEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)
    
    init(entry: Provider.Entry) {
      self.entry = entry
      // TODO: Decode json
    }

    var body: some View {
        VStack {
            Text("今日日程")
            Text("Time:\(entry.class_table_date,style: .time)")
            
            Text(entry.class_table_json)
        }
    }
}

struct ClasstableWidget: Widget {
    let kind: String = "ClasstableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ClasstableWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ClasstableWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ClasstableWidget")
        .description("Show the time arrangement info of today.")
    }
}

#Preview(as: .systemSmall) {
    ClasstableWidget()
} timeline: {
    SimpleEntry(
        date: Date.now,
        class_table_date: Date(),
        class_table_json:
            "{\"list\":[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":3,\"end_time\":4},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":3,\"end_time\":4},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":7,\"end_time\":8},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":7,\"end_time\":8}]}")
}
