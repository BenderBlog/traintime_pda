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
import OSLog

private let widgetGroupId = "group.xyz.superbart.xdyou"
private let classTableFile = "ClassTable.json"
private let examFile = "ExamFile.json"
private let physicsExperimentFile = "PhysicsExperiment.json"
private let otherExperimentFile = "OtherExperiment.json"
private let swiftFile = "WeekSwift.txt"
private let format = "yyyy-MM-dd HH:mm:ss"
private let myDateFormatter = DateFormatter()
let logger = Logger(
  subsystem: "xyz.superbart.xdyou",
  category: "ClassTableWidget"
)

struct StartDayFetchError : Error {}

enum ArrangementType : String {
    case course = "课\n程"
    case exam = "考\n试"
    case experiment = "实\n验"
}

enum ErrorType : Int {
   case none
   case course
   case exam
   case experiment
   case others
}

struct SimpleEntry: TimelineEntry {
    var date : Date
    var currentWeek : Int
    let arrangement : [TimeLineStructItems]
    var errorType : ErrorType
    var error : String?
}

struct TimeLineStructItems {
    var type : ArrangementType
    var name : String
    var teacher : String
    var place : String
    var start_time : Date
    var end_time : Date
    var colorIndex : Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            currentWeek: -1,
            arrangement: [],
            errorType: .none,
            error: nil
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
        
        // Fetch the current day, and calculate tomorrow if system allow and user query it
        var day = Date()
        var currentWeekToStore = -1
        let calendar = Calendar.current
        if #available(iOSApplicationExtension 17.0, *), IsTomorrowManager.value {
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
        // Initalize json decoder and date formatter
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Get content from widget group id
        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: widgetGroupId
        )!
        
        // Deal with ClassTable data
        do {
            // Read data
            logger.info("Getting courses data...")
            let fileURL = containerURL.appendingPathComponent(classTableFile)
            let jsonData = try Data(contentsOf: fileURL)
            let classData : ClassTableData = try decoder.decode(ClassTableData.self, from: jsonData)
            
            // Fetch start day
            guard var startDay = dateFormatter.date(from: classData.termStartDay) else {
                throw StartDayFetchError()
            }
            logger.info("Term start day is \(startDay)")
            
            // Add start day with swift
            var weekSwift : Int = 0
            do {
                let swiftData = try String(
                    contentsOf: containerURL.appendingPathComponent(swiftFile),
                    encoding: .utf8
                )
                weekSwift = Int(swiftData) ?? 0
            } catch {
                logger.warning("Could not fetch week swift, set to 0 by default. Error detail: \(String(describing: error))")
            }
            logger.info("Week swift is \(weekSwift)")

            var dateComponent = DateComponents()
            dateComponent.day = 7 * weekSwift
            startDay = Calendar.current.date(byAdding: dateComponent, to: startDay)!

            // Current week and others
            let components = calendar.dateComponents([.day], from: startDay, to: day)
            var delta = components.day!
            if delta < 0 {
                delta = -7
            }
            let currentWeek : Int = delta / 7
            // Caution: .weekday starts from Sunday!
            var dayInWeek : Int = calendar.component(.weekday, from: day)
            if dayInWeek == 1 {
                dayInWeek = 7
            } else {
                dayInWeek -= 1
            }
            logger.info("Start day is \(String(describing: startDay)), currentWeek is \(currentWeek) and dayOfWeek is \(dayInWeek)")
            
            if currentWeek >= 0 && currentWeek < classData.semesterLength {
                currentWeekToStore = currentWeek
                for i in classData.timeArrangement {
                    if i.week_list.count > currentWeek && i.week_list[currentWeek] && i.day == dayInWeek {
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
            logger.error("Fetch courses error: \(String(describing: error))")
            let entries = [
                SimpleEntry(
                    date: Date(),
                    currentWeek: currentWeekToStore,
                    arrangement: [],
                    errorType: .course,
                    error: String(describing: error)
                )
            ]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        
        // Deal with exam data
        do {
            // Read data
            logger.info("Getting exam data...")
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
                        place: String(i.seat ?? ""),
                        start_time: i.startTime,
                        end_time: i.endTime,
                        colorIndex: examData.subject.firstIndex(where: {$0 === i}) ?? 0
                    ))
                }
            }
        } catch {
            logger.error("Fetch exam error: \(String(describing: error))")
            let entries = [
                SimpleEntry(
                    date: Date(),
                    currentWeek: currentWeekToStore,
                    arrangement: [],
                    errorType: .exam,
                    error: String(describing: error)
                )
            ]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        
        // Deal with other experiment data
        do {
            // Read data
            logger.info("Getting other experiment data...")
            let fileURL = containerURL.appendingPathComponent(otherExperimentFile)
            if let jsonData = try? Data(contentsOf: fileURL) {
                let experimentData : [ExperimentData] = try decoder.decode([ExperimentData].self, from: jsonData)
                
                let components = calendar.dateComponents([.day,.month,.year], from: day)
                let day = components.day
                let month = components.month
                let year = components.year
                
                for i in experimentData {
                    for timeRange in i.timeRanges {
                        let thisDay = calendar.dateComponents([.day,.month,.year], from: timeRange.0)
                        if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                            arrangement.append(TimeLineStructItems(
                                type: .experiment,
                                name: i.name,
                                teacher: i.teacher,
                                place: i.classroom,
                                start_time: timeRange.0,
                                end_time: timeRange.1,
                                colorIndex: experimentData.firstIndex(where: {$0 === i}) ?? 0
                            ))
                        }
                    }
                }
            } else {
                logger.warning("No other experiment data file, will ignore it")
            }
        } catch {
            logger.error("Fetch other experiment error: \(String(describing: error))")
            let entries = [
                SimpleEntry(
                    date: Date(),
                    currentWeek: currentWeekToStore,
                    arrangement: [],
                    errorType: .experiment,
                    error: String(describing: error)
                )
            ]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return

        }
        
        // Deal with physics experiment data
        do {
            // Read data
            logger.info("Getting physics experiment data...")
            let fileURL = containerURL.appendingPathComponent(physicsExperimentFile)
            if let jsonData = try? Data(contentsOf: fileURL) {
                let experimentData : [ExperimentData] = try decoder.decode([ExperimentData].self, from: jsonData)
                
                let components = calendar.dateComponents([.day,.month,.year], from: day)
                let day = components.day
                let month = components.month
                let year = components.year
                
                for i in experimentData {
                    for timeRange in i.timeRanges {
                        let thisDay = calendar.dateComponents([.day,.month,.year], from: timeRange.0)
                        if thisDay.year == year && thisDay.month == month && thisDay.day == day {
                            arrangement.append(TimeLineStructItems(
                                type: .experiment,
                                name: i.name,
                                teacher: i.teacher,
                                place: i.classroom,
                                start_time: timeRange.0,
                                end_time: timeRange.1,
                                colorIndex: experimentData.firstIndex(where: {$0 === i}) ?? 0
                            ))
                        }
                    }
                }
            } else {
                logger.warning("No physics experiment data file, will ignore it")
            }
        } catch {
            logger.error("Fetch physics experiment error: \(String(describing: error))")
            let entries = [
                SimpleEntry(
                    date: Date(),
                    currentWeek: currentWeekToStore,
                    arrangement: [],
                    errorType: .experiment,
                    error: String(describing: error)
                )
            ]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return

        }
        
        // Order
        arrangement.sort(by: {$0.start_time < $1.start_time})
        logger.info("Successfully fetcn arrangement data, it have \(arrangement.count) item(s)")
        
        // Generate timelines
        var entryDates : Set<Date> = []
        var entries: [SimpleEntry] = []
        for todayItem in arrangement {
            entryDates.insert(todayItem.start_time)
            entryDates.insert(todayItem.end_time)
        }
        if #available(iOSApplicationExtension 17.0, *), IsTomorrowManager.value == true {
            logger.info("User wants tomorrow's arrangements")
            entries.append(SimpleEntry(
                date: Date(),
                currentWeek: currentWeekToStore,
                arrangement: arrangement,
                errorType: .none,
                error: nil
            ))
        } else if arrangement.isEmpty {
            logger.info("Arrangement data have no items")
            entries.append(SimpleEntry(
                date: Date(),
                currentWeek: currentWeekToStore,
                arrangement: arrangement,
                errorType: .none,
                error: nil

            ))
        } else {
            logger.info("User wants today's arrangements, will remove occured arrangements")
            for entryDate in entryDates {
                entries.append(SimpleEntry(
                    date: entryDate,
                    currentWeek: currentWeekToStore,
                    arrangement: arrangement.filter{
                        element in return element.end_time > entryDate
                    },
                    errorType: .none,
                    error: nil
                ))
                print("\(entries)")
            }
        }
        
        logger.info("Updating timeline")
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}



struct ClasstableWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

        
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    @ViewBuilder
    private func errorContentView() -> some View {
        let errorMessage = switch entry.errorType {
        case .course:
            NSLocalizedString("error_course", comment: "Failed to load course data.")
        case .exam:
            NSLocalizedString("error_exam", comment: "Failed to load exam data.")
        case .experiment:
            NSLocalizedString("error_experiment", comment: "Failed to load experiment data.")
        case .others:
            NSLocalizedString("error_other", comment: "An unexpected error occurred.")
        case .none:
            ""
        }
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        colorScheme == .dark ? .white :
                            Color(hexString: "#314e7a")
                    )
                Text(errorMessage)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundStyle(
                        colorScheme == .dark ? .white :
                            Color(hexString: "#314e7a")
                    )
            }
            Text(entry.error ?? "No message about this error.")
                    .foregroundStyle(
                        colorScheme == .dark ? .white :
                            Color(hexString: "#314e7a")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }.padding()
        
    }
    
    
    private func normalContentView() -> some View {
                
        // Calculate the date arrangements will show
        var day = Date()
        let calendar = Calendar.current
        
        if #available(iOS 17.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *), IsTomorrowManager.value {
            logger.info("Will show tomorrow's arrangments")
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
        // Generate title screen
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
        }.padding()
    }

    
    var body: some View {
        Group {
            if entry.errorType != .none {
                errorContentView()
            } else {
                normalContentView()
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
                    .background(Color("WidgetBackground"))
            }
        }
        .contentMarginsDisabled()
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
        arrangement: [],
        errorType: .others,
        error: "Testing error"
    )
    SimpleEntry(
        date: Date.now,
        currentWeek: -1,
        arrangement: [],
        errorType: .none,
        error: nil
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
        )],
        errorType: .none,
        error: nil

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
        ],
        errorType: .none,
        error: nil
    )
}
