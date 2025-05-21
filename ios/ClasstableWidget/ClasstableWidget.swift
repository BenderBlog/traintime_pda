// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  ClasstableWidget.swift
//  ClasstableWidget
//
//  Created by BenderBlog Rodriguez on 2024/1/6.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.xyz.superbart.xdyou"
private let classTableFile = "ClassTable.json"
private let examFile = "ExamFile.json"
private let experimentFile = "Experiment.json"
private let swiftFile = "WeekSwift.txt"
private let format = "yyyy-MM-dd HH:mm:ss"
private let myDateFormatter = DateFormatter()

struct StartDayFetchError : Error {}

enum ArrangementType : String {
    case course = "课\n程"
    case exam = "考\n试"
    case experiment = "实\n验"
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            currentWeek: -1,
            arrangement: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot")
        getTimeline(in: context, completion: { (timeLine) in
            completion(timeLine.entries.first!)
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var arrangement : [TimeLineStructItems] = []
        
        var day = Date()
        var currentWeekToStore = -1
        let calendar = Calendar.current
        if #available(iOSApplicationExtension 17.0, *), IsTomorrowManager.value {
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
        let decoder = JSONDecoder()
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
            let components = calendar.dateComponents([.day], from: startDay!, to: day)
            var delta = components.day!
            if delta < 0 {
                delta = -7
            }
            let currentWeek : Int = delta / 7
            var index : Int = calendar.component(.weekday, from: day)
            if index == 1 {
                index = 7
            } else {
                index -= 1
            }
            
            print("startDay: \(String(describing: startDay)) currentWeek: \(currentWeek) index: \(index)")
            if currentWeek >= 0 && currentWeek < classData.semesterLength {
                currentWeekToStore = currentWeek
                for i in classData.timeArrangement {
                    if i.week_list.count > currentWeek && i.week_list[currentWeek] && i.day == index {
                        let startData = TimeInt[(i.start - 1) * 2]
                        let stopData = TimeInt[(i.stop - 1) * 2 + 1]
                        arrangement.append(TimeLineStructItems(
                            type: .course,
                            name: classData.getClassName(t: i),
                            teacher: i.teacher ?? "未知老师",
                            place: i.classroom ?? "未安排教室",
                            start_time: calendar.date(
                                bySettingHour: startData.0,
                                minute: startData.1,
                                second: 0,
                                of: day
                            )!,
                            end_time: calendar.date(
                                bySettingHour: stopData.0,
                                minute: stopData.1,
                                second: 0,
                                of: day
                            )!,
                            colorIndex: i.index
                        ))
                    }
                }
            }
        } catch {
            print("classtable error: \(String(describing: error))")
        }
        
        // Deal with exam data
        do {
            // Read data
            let fileURL = containerURL.appendingPathComponent(examFile)
            let jsonData = try Data(contentsOf: fileURL)
            let examData : ExamData = try decoder.decode(ExamData.self, from: jsonData)
            
            let components = calendar.dateComponents([.day,.month,.year], from: day)
            let day = components.day
            let month = components.month
            let year = components.year
            
            for i in examData.subject {
                let thisDay = calendar.dateComponents([.day,.month,.year],from: i.startTime)
                if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                    arrangement.append(TimeLineStructItems(
                        type: .exam,
                        name: i.subject,
                        teacher: i.place,
                        place: String(i.seat),
                        start_time: i.startTime,
                        end_time: i.endTime,
                        colorIndex: examData.subject.firstIndex(where: {$0 === i}) ?? 0
                    ))
                }
            }
        } catch {
            print("exam error: \(String(describing: error))")
        }
        
        // Deal with experiment data
        do {
            // Read data
            let fileURL = containerURL.appendingPathComponent(experimentFile)
            let jsonData = try Data(contentsOf: fileURL)
            let experimentData : [ExperimentData] = try decoder.decode([ExperimentData].self, from: jsonData)
            
            let components = calendar.dateComponents([.day,.month,.year], from: day)
            let day = components.day
            let month = components.month
            let year = components.year
            
            // Today data
            for i in experimentData {
                let thisDay = calendar.dateComponents([.day,.month,.year],from: i.startTime)
                if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                    arrangement.append(TimeLineStructItems(
                        type: .experiment,
                        name: i.name,
                        teacher: i.teacher,
                        place: i.classroom,
                        start_time: i.startTime,
                        end_time: i.endTime,
                        colorIndex: experimentData.firstIndex(where: {$0 === i}) ?? 0
                    ))
                }
            }
        } catch {
            print("experiment error: \(String(describing: error))")
        }
        
        // Order
        arrangement.sort(by: {$0.start_time < $1.start_time})

        print("arrangement: \(arrangement.count)")
        
        var entryDates : Set<Date?> = []
        var entries: [SimpleEntry] = []
        for todayItem in arrangement {
            entryDates.insert(todayItem.start_time)
            entryDates.insert(todayItem.end_time)
        }
        if #available(iOSApplicationExtension 17.0, *), IsTomorrowManager.value == true {
            print("isTomorrow")
            entries.append(SimpleEntry(
                date: Date(),
                currentWeek: currentWeekToStore,
                arrangement: arrangement
            ))
        } else if arrangement.isEmpty {
            print("Noitem")
            entries.append(SimpleEntry(
                date: Date(),
                currentWeek: currentWeekToStore,
                arrangement: arrangement
            ))
        } else {
            print("isToday")
            for entryDate in entryDates {
                if (entryDate == nil) {
                    continue
                }
                print("\(String(describing: entryDate?.formatted()))")
                var toShow : [TimeLineStructItems] = []
                for arr in arrangement {
                    print("\(arr.end_time.formatted()) \(arr.end_time > entryDate!)")
                    if arr.end_time > entryDate! {
                        toShow.append(arr)
                    }
                }
                entries.append(SimpleEntry(
                    date: entryDate!,
                    currentWeek: currentWeekToStore,
                    arrangement: toShow
                ))
                print("\(entries)")
            }
        }
        
        print("Updating timeline")
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date : Date
    var currentWeek : Int
    let arrangement : [TimeLineStructItems]
}

// Data struct
struct TimeLineStructItems {
    var type : ArrangementType
    var name : String
    var teacher : String
    var place : String
    var start_time : Date
    var end_time : Date
    var colorIndex : Int
}

struct ClasstableWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        var day = Date()
        let calendar = Calendar.current
        //let array = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
        if #available(iOS 17.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *), IsTomorrowManager.value {
            print("isTomorrow")
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        var title = NSLocalizedString("title", comment: "Title of the widget")
        if (widgetFamily != .systemSmall) {
            title = "XDYou ".appending(title)
        }
        
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("date_formatter", comment: "Date format pattern")
        
        // Week of the semester
        let weekOfSemester = String(
            format:NSLocalizedString("week_of_semester", comment: "Show week of the semester"),
            entry.currentWeek + 1,
        )
        
        return VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(
                            colorScheme == .dark ? .white :
                            Color(hexString: "#314e7a")
                        )
                    Text(
                        "\(dateFormatter.string(from: day))" +
                        " \(entry.currentWeek >= 0 ? "\(weekOfSemester)" : "")"
                    ).font(.system(size: 10))
                     .foregroundStyle(Color(hexString: "#abbed1"))
                }
                if #available(iOS 17.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *) {
                    Spacer()
                    Button(intent: IsTomorrowIntent()) {
                        Image(
                            systemName: IsTomorrowManager.value ?
                                        "chevron.backward" :
                                        "chevron.forward"
                        )
                    }.buttonStyle(.plain)
                }
            }
            if (!entry.arrangement.isEmpty) {
                if (widgetFamily == .systemSmall || widgetFamily == .systemMedium) {
                    EventItem(entry.arrangement[0])
                    if (entry.arrangement.count > 1) {
                        EventItem(entry.arrangement[1])
                    }
                } else {
                    ForEach(0..<entry.arrangement.count, id: \.self) {
                        i in EventItem(entry.arrangement[i])
                    }
                }

                Spacer()
            } else {
                let text = Text(NSLocalizedString("no_arrangement", comment: "No arrangment")).foregroundStyle(Color(hexString: "#abbed1"))
                let icon = Image(systemName: "tray").foregroundStyle(Color(hexString: "#abbed1"))
                if (widgetFamily == .systemSmall) {
                    text.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if (widgetFamily == .systemMedium) {
                    HStack{
                        icon.font(.largeTitle)
                        text
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    VStack{
                        icon.font(.system(size: 72))
                        Divider().opacity(0)
                        text
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
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
        .configurationDisplayName(NSLocalizedString("widget_title", comment: "Widget Title"))
        .description(NSLocalizedString("widget_description", comment: "Widget Description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
#Preview(as: .systemLarge) {
    ClasstableWidget()
} timeline: {
    SimpleEntry(
        date: Date.now,
        currentWeek: -1,
        arrangement: []
    )
    SimpleEntry(
        date: Date.now,
        currentWeek: 10,
        arrangement : [TimeLineStructItems(
            type: .course,
            name: "英语课",
            teacher: "机器人",
            place: "不知道",
            start_time: Date.now,
            end_time: Date.now,
            colorIndex: 1
        )]
    )
    SimpleEntry(
        date: Date.now,
        currentWeek: 10,
        arrangement : [
            TimeLineStructItems(
                type: .course,
                name: "英语课",
                teacher: "机器人",
                place: "不知道",
                start_time: Date.now,
                end_time: Date.now,
                colorIndex: 1
            ),
            TimeLineStructItems(
                type: .course,
                name: "英语课",
                teacher: "机器人",
                place: "不知道",
                start_time: Date.now,
                end_time: Date.now,
                colorIndex: 2
            )
        ]
    )
}
