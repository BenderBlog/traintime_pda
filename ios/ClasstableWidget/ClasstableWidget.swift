//
//  ClasstableWidget.swift
//  ClasstableWidget
//
//  Created by BenderBlog Rodriguez on 2024/1/6.
//  SPDX-License-Identifier: MPL-2.0
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.xyz.superbart.xdyou"
private let classTableFile = "ClassTable.json"
private let examFile = "ExamFile.json"
private let swiftFile = "WeekSwift.txt"
private let format = "yyyy-MM-dd HH:mm:ss"
private let myDateFormatter = DateFormatter()

struct StartDayFetchError : Error {}

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
        var todayArr : [TimeLineStructItems] = []
        var tomorrowArr : [TimeLineStructItems] = []
        
        let today = Date()
        let decoder = JSONDecoder()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: widgetGroupId
        )!
        
        // Deal with ClassTable data
        do {
            // Read data
            print("getting classtable data")
            let fileURL = containerURL.appendingPathComponent(classTableFile)
            let jsonData = try Data(contentsOf: fileURL)
            let classData : ClassTableData = try decoder.decode(ClassTableData.self, from: jsonData)
            
            // Fetch start day
            var startDay : Date? = dateFormatter.date(from: classData.termStartDay)
            if startDay == nil {
                throw StartDayFetchError()
            }
            
            // With swift
            var classSwift : Int = 0
            do {
                let swiftData = try String(
                    contentsOf: containerURL.appendingPathComponent(swiftFile),
                    encoding: .utf8
                )
                classSwift = Int(swiftData) ?? 0
            } catch {
                print(String(describing: error))
            }
            print("swift: \(classSwift)")

            var dateComponent = DateComponents()
            dateComponent.day = 7 * classSwift
            startDay = Calendar.current.date(byAdding: dateComponent, to: startDay!)

            // Current week and others
            let components = calendar.dateComponents([.day], from: startDay!, to: today)
            var delta = components.day!
            if delta < 0 {
                delta = -7
            }
            var currentWeek : Int = delta / 7
            var index : Int = calendar.component(.weekday, from: today)
            if index == 1 {
                index = 7
            } else {
                index -= 1
            }
            print("startDay: \(String(describing: startDay)) currentWeek: \(currentWeek) index: \(index)")
            
            // Classes in today
            if currentWeek >= 0 && currentWeek < classData.semesterLength {
                for i in classData.timeArrangement {
                    if i.week_list.count > currentWeek && i.week_list[currentWeek] && i.day == index {
                        let startData = TimeInt[(i.start - 1) * 2]
                        let stopData = TimeInt[(i.start - 1) * 2]
                        todayArr.append(TimeLineStructItems(
                            name: classData.getClassName(
                                timeArrangementIndex: i.index
                            ),
                            teacher: i.teacher ?? "未知老师",
                            place: i.classroom ?? "未安排教室",
                            start_time: calendar.date(
                                bySettingHour: startData.0,
                                minute: startData.1,
                                second: 0,
                                of: today
                            )!,
                            end_time: calendar.date(
                                bySettingHour: stopData.0,
                                minute: stopData.1,
                                second: 0,
                                of: today
                            )!
                        ))
                    }
                }
            }
            
            // Tomorrow class
            index += 1
            if index > 7 {
                index = 1
                currentWeek += 1
            }
            print("(tomorrow) startDay: \(String(describing: startDay)) currentWeek: \(currentWeek) index: \(index)")
            if currentWeek >= 0 && currentWeek < classData.semesterLength {
                for i in classData.timeArrangement {
                    if i.week_list.count > currentWeek && i.week_list[currentWeek] && i.day == index {
                        let startData = TimeInt[(i.start - 1) * 2]
                        let stopData = TimeInt[(i.start - 1) * 2]
                        tomorrowArr.append(TimeLineStructItems(
                            name: classData.getClassName(
                                timeArrangementIndex: i.index
                            ),
                            teacher: i.teacher ?? "未知老师",
                            place: i.classroom ?? "未安排教室",
                            start_time: calendar.date(
                                bySettingHour: startData.0,
                                minute: startData.1,
                                second: 0,
                                of: today
                            )!,
                            end_time: calendar.date(
                                bySettingHour: stopData.0,
                                minute: stopData.1,
                                second: 0,
                                of: today
                            )!
                        ))
                    }
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        // Deal with exam data
        do {
            // Read data
            let fileURL = containerURL.appendingPathComponent(examFile)
            let jsonData = try Data(contentsOf: fileURL)
            let examData : ExamData = try decoder.decode(ExamData.self, from: jsonData)
            
            var components = calendar.dateComponents([.day,.month,.year], from: today)
            var day = components.day
            var month = components.month
            var year = components.year
            
            // Today data
            for i in examData.subject {
                let thisDay = calendar.dateComponents([.day,.month,.year],from: i.startTime)
                if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                    todayArr.append(TimeLineStructItems(
                        name: i.subject,
                        teacher: "考试",
                        place: "\(i.place) \(i.seat)",
                        start_time: i.startTime,
                        end_time: i.endTime
                    ))
                }
            }
            
            // Tomorrow data
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            components = calendar.dateComponents([.day,.month,.year], from: tomorrow)
            day = components.day
            month = components.month
            year = components.year
            for i in examData.subject {
                let thisDay = calendar.dateComponents([.day,.month,.year],from: i.startTime)
                if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                    tomorrowArr.append(TimeLineStructItems(
                        name: i.subject,
                        teacher: "考试",
                        place: "\(i.place) \(i.seat)",
                        start_time: i.startTime,
                        end_time: i.endTime
                    ))
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        // Order
        todayArr.sort(by: {$0.start_time > $1.start_time})
        tomorrowArr.sort(by: {$0.start_time > $1.start_time})

        print("todayArr: \(todayArr.count) tomorrowArr:\(tomorrowArr.count)")
        
        var entryDates : Set<Date?> = []
        var entries: [SimpleEntry] = []
        for todayItem in todayArr {
            entryDates.insert(todayItem.start_time)
            entryDates.insert(todayItem.end_time)
        }
        for entryDate in entryDates {
            if (entryDate == nil) {
                continue
            }
            var toShow : [TimeLineStructItems] = []
            for arr in todayArr {
                if arr.end_time > entryDate! {
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
    var start_time : Date
    var end_time : Date
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

