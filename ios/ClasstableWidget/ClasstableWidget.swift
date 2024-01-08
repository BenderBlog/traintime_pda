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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), class_table_date: Date().formatted(), class_table_json: "{\"list\":[]}")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        print(data?.string(forKey: "class_table_json") ?? "No data")
        let entry = SimpleEntry(
          date: Date(), 
          class_table_date: data?.string(forKey: "class_table_date") ?? Date().formatted(),
          class_table_json: data?.string(forKey: "class_table_json") ?? "{\"list\":[]}"
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
                ClasstableStruct.self,
                from: Data(entry.class_table_json.utf8)
            ).list
        } catch {
            // Hope never happens.
            print(error.localizedDescription)
            classList = []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // TODO: redesign title text
            if (!classList.isEmpty) {
                if (widgetFamily == .systemSmall || widgetFamily == .systemMedium) {
                    Text("XDYou 今日日程").font(.system(size: 14))
                    EventItem(classList[0])
                    if (classList.count > 1) {
                        EventItem(classList[1])
                    }
                } else if (widgetFamily == .systemLarge) {
                    Text("XDYou 今日日程 还剩\(classList.count)").font(.system(size: 14))
                    ForEach(0..<classList.count, id: \.self) {
                        i in EventItem(classList[i])
                    }
                } else {
                    Text("Unsupported widget family")
                }
                Spacer()
            } else {
                Text("XDYou 今日日程").font(.system(size: 14))
                Text("今日没有安排了")
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
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ClasstableWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ClasstableWidget")
        .description("Show the time arrangement info of today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    ClasstableWidget()
} timeline: {
    SimpleEntry(
        date: Date.now,
        class_table_date: Date().formatted(),
        class_table_json:
            "{\"list\":[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":3,\"end_time\":4},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":7,\"end_time\":8},{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":3,\"end_time\":4},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":7,\"end_time\":8}]}")
    SimpleEntry(
        date: Date.now,
        class_table_date: Date().formatted(),
        class_table_json:
            "{\"list\":[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},{\"name\":\"软件过程与项目管理\",\"teacher\":\"Angaj（印）\",\"place\":\"B-707\",\"start_time\":3,\"end_time\":4},{\"name\":\"软件体系结构\",\"teacher\":\"蔺一帅,李飞\",\"place\":\"A-222\",\"start_time\":7,\"end_time\":8}]}")
    SimpleEntry(
        date: Date.now,
        class_table_date: Date().formatted(),
        class_table_json: "{\"list\":[]}")
    SimpleEntry(
        date: Date.now,
        class_table_date: Date().formatted(),
        class_table_json: "{\"list\":[{\"name\":\"算法分析与设计\",\"teacher\":\"覃桂敏\",\"place\":\"B-706\",\"start_time\":1,\"end_time\":2},]}")
}

// Data struct

struct ClasstableStruct : Codable {
    var list : [ClasstableStructItems]
}

struct ClasstableStructItems : Codable {
    var name : String
    var teacher : String
    var place : String
    var start_time : Int
    var end_time : Int
}

var TimeArray : [String] = [
    "08:30",
    "09:15",
    "09:20",
    "10:05",
    "10:25",
    "11:10",
    "11:15",
    "12:00",
    "14:00",
    "14:45",
    "14:50",
    "15:35",
    "15:55",
    "16:40",
    "16:45",
    "17:30",
    "19:00",
    "19:45",
    "19:55",
    "20:30",
]

// Event view

struct EventItem: View {
    var event:ClasstableStructItems;
    
    internal init(_ event: ClasstableStructItems) {
        self.event = event
    }
    
    @Environment(\.colorScheme) private var colourScheme
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        let eventColour = Color.blue
        HStack {
            RoundedRectangle(cornerRadius: 120).frame(width: 6).padding(.vertical, 6)
            VStack(alignment: .leading) {
                if (widgetFamily == .systemSmall) {
                    Text(event.name)
                        .font(.subheadline.weight(.medium))
                    Text("\(TimeArray[event.start_time]) \(event.place)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else if (widgetFamily == .systemMedium || widgetFamily == .systemLarge) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.subheadline.weight(.medium))
                            Text("\(event.teacher) \(event.place)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(TimeArray[event.start_time])
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(TimeArray[event.end_time * 2 - 1])
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                } else  {
                    Text("Unsupported widget family")
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
        .frame(maxHeight: 48)
        .clipShape(ContainerRelativeShape())
    }
}

struct EventItem_Previews: PreviewProvider {
    static var previews: some View {
        EventItem(ClasstableStructItems(
            name: "形势与政策",
            teacher: "哲学dark师",
            place: "C-666",
            start_time: 7,
            end_time: 8
        )).previewContext(WidgetPreviewContext(family: .systemSmall)).containerBackground(.blue.gradient, for: .widget)
    }
}
