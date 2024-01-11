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

struct Provider: TimelineProvider {
    let myDateFormatter = DateFormatter()
    
    func placeholder(in context: Context) -> SimpleEntry {
        myDateFormatter.dateFormat = "yyyy-MM-dd"
        return SimpleEntry(
            date: Date(),
            class_table_date: myDateFormatter.string(from: Date()),
            class_table_json: "[]"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        myDateFormatter.dateFormat = "yyyy-MM-dd"

        let data = UserDefaults.init(suiteName: widgetGroupId)
        let entry = SimpleEntry(
          date: Date(), 
          class_table_date: data?.string(forKey: "class_table_date") ?? myDateFormatter.string(from: Date()),
          class_table_json: data?.string(forKey: "class_table_json") ?? "[]"
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
    var date: Date
    
    let class_table_date: String
    let class_table_json: String
}

struct ClasstableWidgetEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)
    let classList:[ClasstableStructItems]
    
    @Environment(\.widgetFamily) var widgetFamily
    
    init(entry: Provider.Entry) {
        self.entry = entry
        let decoder = JSONDecoder()
        do {
            classList = try decoder.decode(
                [ClasstableStructItems].self,
                from: Data(entry.class_table_json.utf8)
            )
        } catch {
            // Hope never happens.
            print(error.localizedDescription)
            classList = []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (!classList.isEmpty) {
                // TODO: redesign title text
                HStack {
                    Text("\(entry.class_table_date)日程").font(.system(size: 14))
                    Spacer()
                    if (widgetFamily != .systemSmall) {
                        Text("还剩\(classList.count)项").font(.system(size: 14))
                    }
                }

                
                if (widgetFamily == .systemSmall || widgetFamily == .systemMedium) {
                    EventItem(classList[0], color: colors[0])
                    if (classList.count > 1) {
                        EventItem(classList[1], color: colors[1])
                    }
                } else {
                    ForEach(0..<classList.count, id: \.self) {
                        i in EventItem(classList[i], color: colors[i % colors.count])
                    }
                }
                
                Spacer()
            } else {
                Text("\(entry.class_table_date) 日程").font(.system(size: 14))
                Text("目前没有安排了")
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
}

// Data struct

struct ClasstableStructItems : Codable {
    var name : String
    var teacher : String
    var place : String
    var start_time : String
    var end_time : String
}

// Event view

struct EventItem: View {
    var event : ClasstableStructItems;
    var color : Color;
    
    internal init(_ event: ClasstableStructItems, color: Color) {
        self.event = event
        self.color = color
    }
    
    @Environment(\.colorScheme) private var colourScheme
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        let eventColour = color
        HStack {
            RoundedRectangle(cornerRadius: 120).frame(width: 6).padding(.vertical, 6)
            VStack(alignment: .leading) {
                if (widgetFamily == .systemSmall) {
                    Text(event.name)
                        .font(.subheadline.weight(.medium))
                    Text("\(event.start_time) \(event.place)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.subheadline.weight(.medium))
                            Text("\(event.teacher) \(event.place)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(event.start_time)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(event.end_time)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            Spacer(minLength: .zero)
        }
        .foregroundColor(eventColour)
        .blendMode(colourScheme == .light ? .plusDarker : .plusLighter)
        .padding(.horizontal, 8)
        .background {
            eventColour.opacity(0.125)
                .blendMode(colourScheme == .light ? .normal : .hardLight)
        }
        .frame(maxHeight: 42)
        .clipShape(ContainerRelativeShape())
    }
}
/*
struct EventItem_Previews: PreviewProvider {
    static var previews: some View {
        EventItem(ClasstableStructItems(
            name: "形势与政策",
            teacher: "哲学dark师",
            place: "C-666",
            start_time: "11:45",
            end_time: "19:19"
        )).previewContext(WidgetPreviewContext(family: .systemSmall)).containerBackground(.blue.gradient, for: .widget)
    }
}
*/

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

