//
//  ClasstableWidget.swift
//  ClasstableWidget
//
//  Created by BenderBlog Rodriguez on 2024/1/6.
//  SPDX-License-Identifier: MPL-2.0
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.xdyou"
private let format = "yyyy-MM-dd HH:mm:ss"
private let myDateFormatter = DateFormatter()

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            currentArrangement: [],
            tomorrowArrangement: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot")
        getTimeline(in: context, completion: { (timeLine) in
            completion(timeLine.entries.first!)
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("gettingTimeline")
        let data = UserDefaults.init(suiteName: widgetGroupId)
        var todayArr : [TimeLineStructItems] = []
        var tomorrowArr : [TimeLineStructItems] = []
        do {
            let decoder = JSONDecoder()
            todayArr.append(
                contentsOf: try decoder.decode(
                    [TimeLineStructItems].self,
                    from: Data(data?.string(forKey: "today_data")?.utf8 ?? "[]".utf8)
                )
            )
            tomorrowArr.append(
                contentsOf: try decoder.decode(
                    [TimeLineStructItems].self,
                    from: Data(data?.string(forKey: "tomorrow_data")?.utf8 ?? "[]".utf8)
                )
            )
        } catch {
            print(error.localizedDescription)
        }

        var entryDates : Set<Date?> = []
        var entries: [SimpleEntry] = []
        for todayItem in todayArr {
            entryDates.insert(todayItem.startTime)
            entryDates.insert(todayItem.endTime)
        }
        for entryDate in entryDates {
            if (entryDate == nil) {
                continue
            }
            var toShow : [TimeLineStructItems] = []
            for arr in todayArr {
                if (arr.endTime == nil){
                    continue
                }
                if arr.endTime! > entryDate! {
                    toShow.append(arr)
                }
            }
            entries.append(SimpleEntry(
                date: entryDate!,
                currentArrangement: toShow,
                tomorrowArrangement: tomorrowArr
            ))
            print("\(entries)")
        }
        if entries.isEmpty {
            entries.append(SimpleEntry(
                date: Date(),
                currentArrangement: [],
                tomorrowArrangement: []
            ))
        }
        print("Updating timeline")
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let currentArrangement : [TimeLineStructItems]
    let tomorrowArrangement : [TimeLineStructItems]
}

// Data struct
struct TimeLineStructItems : Codable {
    var name : String
    var teacher : String
    var place : String
    var start_time : String
    var end_time : String
    
    var startTime : Date? {
        get {
            myDateFormatter.dateFormat = format
            return myDateFormatter.date(from: start_time)
        }
    }
    
    var endTime : Date? {
        get {
            myDateFormatter.dateFormat = format
            return myDateFormatter.date(from: end_time)
        }
    }
}



struct ClasstableWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        return VStack(alignment: .leading) {
            if (!entry.currentArrangement.isEmpty) {
                // TODO: redesign title text
                HStack {
                    Text("日程信息").font(.system(size: 14))
                    if (widgetFamily != .systemSmall) {
                        Spacer()
                        Text("还剩\(entry.currentArrangement.count)项").font(.system(size: 14))
                    }
                }

                
                if (widgetFamily == .systemSmall || widgetFamily == .systemMedium) {
                    EventItem(entry.currentArrangement[0], color: colors[0])
                    if (entry.currentArrangement.count > 1) {
                        EventItem(entry.currentArrangement[1], color: colors[1])
                    }
                } else {
                    ForEach(0..<entry.currentArrangement.count, id: \.self) {
                        i in EventItem(entry.currentArrangement[i], color: colors[i % colors.count])
                    }
                }
                
                Spacer()
            } else {
                Text("今日日程").font(.system(size: 14))
                Text("目前没有安排了\n明日有\(entry.tomorrowArrangement.count)项日程")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

struct ClasstableWidget: Widget {
    let kind: String = "ClasstableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ClasstableWidgetEntryView(entry: entry)
                    .containerBackground(Color("WidgetBackground"), for: .widget)
            } else {
                ClasstableWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color("WidgetBackground"))
            }
        }
        .configurationDisplayName("课程表组件")
        .description("展示今日课程信息")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/*
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
#Preview(as: .systemSmall) {
    ClasstableWidget()
} timeline: {
    SimpleEntry(
        date: Date.now,
        class_table_date: "2023-12-31",
        class_table_json:
            "[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":\"08:30\",\"end_time\":\"10:05\"},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":\"10:25\",\"end_time\":\"12:00\"},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":\"15:55\",\"end_time\":\"17:30\"},{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":\"08:30\",\"end_time\":\"10:05\"},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":\"10:25\",\"end_time\":\"12:00\"},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":\"15:55\",\"end_time\":\"17:30\"}]")
    SimpleEntry(
        date: Date.now,
        class_table_date: "2023-12-31",
        class_table_json:
            "[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":\"08:30\",\"end_time\":\"10:05\"},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":\"10:25\",\"end_time\":\"12:00\"},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":\"15:55\",\"end_time\":\"17:30\"}]")
    SimpleEntry(
        date: Date.now,
        class_table_date: "2023-12-31",
        class_table_json: "[]")
    SimpleEntry(
        date: Date.now,
        class_table_date: "2023-12-31",
        class_table_json: "[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":\"08:45\",\"end_time\":\"10:05\"},]")

}*/



// Colors
var colors: [Color] = [
    Color(.blue),
    //Color(.teal),
    Color(.green),
    Color(.yellow),
    Color(.orange),
    Color(.red),
    //Color(.pink),
    Color(.purple),
    //Color(.indigo),
]

