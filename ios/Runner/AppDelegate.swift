import ActivityKit
import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        let api = ApiImplementation()
        SaveToGroupIdSwiftApiSetup.setUp(binaryMessenger: engineBridge.applicationRegistrar.messenger(), api: api)

        CourseLiveActivityChannel.register(messenger: engineBridge.applicationRegistrar.messenger())
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
}

/// The state of the class which is going on.
///
/// The very same declaration is compiled into the widget extension as well,
/// ActivityKit matches the two by name.
@available(iOS 16.2, *)
struct CourseActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var name: String
        /// A very short form of the name, for the collapsed island.
        var shortTitle: String
        /// The classroom and the teacher.
        var location: String
        /// "第 3-4 节"
        var periodText: String
        /// "08:30 - 10:05"
        var timeText: String
        /// "下一节 10:25 · B-106"
        var nextText: String
        /// "即将开始", shown while the class has not begun yet.
        var upcomingText: String
        /// How many class periods the lesson takes.
        var periods: Int
        var startDate: Date
        var endDate: Date
        /// The colour of the course card, in the `#RRGGBB` form.
        var colorHex: String
    }

    var courseId: String
}

/// Bridge between the Dart side and the Live Activity of the ongoing class.
enum CourseLiveActivityChannel {
    private static let name = "xdyou/live_activity"

    /// How early the activity of a class may be started.
    ///
    /// iOS has no way of starting an activity at a given moment on its own: the
    /// app can only do it while it runs, so the class which comes next is put on
    /// the island as soon as the app is opened within this window, and the widget
    /// itself counts down to the beginning of the class. Android has alarms, so
    /// it shows its island a fixed number of minutes before the class instead.
    @available(iOS 16.2, *)
    private static let lookAhead: TimeInterval = 4 * 60 * 60

    static func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            guard #available(iOS 16.2, *) else {
                switch call.method {
                case "isSupported":
                    result(false)
                case "schedule":
                    result(0)
                default:
                    result(nil)
                }
                return
            }

            switch call.method {
            case "isSupported":
                result(ActivityAuthorizationInfo().areActivitiesEnabled)

            case "schedule":
                let arguments = call.arguments as? [String: Any]
                let events = arguments?["events"] as? [[String: Any]] ?? []
                result(schedule(events: events))

            case "cancelAll":
                cancelAll()
                result(nil)

            case "showPreview":
                let arguments = call.arguments as? [String: Any]
                let event = arguments?["event"] as? [String: Any]
                result(showPreview(event: event))

            case "stopPreview":
                stopPreview()
                result(nil)

            case "diagnostics":
                result(diagnostics())

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Shows a made up class right away, to try the island out without waiting
    /// for a real lesson.
    @available(iOS 16.2, *)
    private static func showPreview(event: [String: Any]?) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }
        guard let planned = plannedCourse(from: event ?? [:]) else {
            return false
        }

        for activity in Activity<CourseActivityAttributes>.activities
        where activity.attributes.courseId != previewCourseId {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }

        let content = ActivityContent(
            state: planned.state,
            staleDate: planned.state.endDate
        )
        if let existing = Activity<CourseActivityAttributes>.activities
            .first(where: { $0.attributes.courseId == previewCourseId }) {
            Task { await existing.update(content) }
            return true
        }

        do {
            _ = try Activity.request(
                attributes: CourseActivityAttributes(courseId: previewCourseId),
                content: content,
                pushType: nil
            )
            return true
        } catch {
            NSLog("[CourseLiveActivity] Unable to start the preview: \(error)")
            return false
        }
    }

    @available(iOS 16.2, *)
    private static func stopPreview() {
        for activity in Activity<CourseActivityAttributes>.activities
        where activity.attributes.courseId == previewCourseId {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }
    }

    /// What the platform knows about the Live Activities of the app.
    @available(iOS 16.2, *)
    private static func diagnostics() -> [String: Any] {
        [
            "supported": true,
            "activitiesEnabled": ActivityAuthorizationInfo().areActivitiesEnabled,
            "activities": Activity<CourseActivityAttributes>.activities.count,
        ]
    }

    @available(iOS 16.2, *)
    private static let previewCourseId = "preview"

    /// Starts (or refreshes) the Live Activity of the class which is going on,
    /// or of the one which starts next. iOS has no way of starting an activity
    /// at a given time on its own, so the app decides while it runs.
    @available(iOS 16.2, *)
    private static func schedule(events: [[String: Any]]) -> Int {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return 0
        }

        let now = Date()
        let upcoming = events
            .compactMap(plannedCourse(from:))
            .filter { $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }

        guard let next = upcoming.first,
              next.startDate.timeIntervalSince(now) <= lookAhead else {
            cancelAll()
            return 0
        }

        let content = ActivityContent(state: next.state, staleDate: next.endDate)

        for activity in Activity<CourseActivityAttributes>.activities
        where activity.attributes.courseId != next.id {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }

        if let existing = Activity<CourseActivityAttributes>.activities
            .first(where: { $0.attributes.courseId == next.id }) {
            Task { await existing.update(content) }
            return 1
        }

        do {
            _ = try Activity.request(
                attributes: CourseActivityAttributes(courseId: next.id),
                content: content,
                pushType: nil
            )
            return 1
        } catch {
            NSLog("[CourseLiveActivity] Unable to start the activity: \(error)")
            return 0
        }
    }

    @available(iOS 16.2, *)
    static func cancelAll() {
        for activity in Activity<CourseActivityAttributes>.activities {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }
    }

    @available(iOS 16.2, *)
    private struct PlannedCourse {
        let id: String
        let state: CourseActivityAttributes.ContentState

        var startDate: Date { state.startDate }
        var endDate: Date { state.endDate }
    }

    @available(iOS 16.2, *)
    private static func plannedCourse(from raw: [String: Any]) -> PlannedCourse? {
        guard let startMillis = raw["startMillis"] as? NSNumber,
              let endMillis = raw["endMillis"] as? NSNumber else {
            return nil
        }

        let start = Date(timeIntervalSince1970: startMillis.doubleValue / 1000.0)
        let end = Date(timeIntervalSince1970: endMillis.doubleValue / 1000.0)
        guard end > start else {
            return nil
        }

        return PlannedCourse(
            id: (raw["id"] as? NSNumber)?.stringValue ?? "\(start.timeIntervalSince1970)",
            state: CourseActivityAttributes.ContentState(
                name: raw["title"] as? String ?? "",
                shortTitle: raw["shortTitle"] as? String ?? "",
                location: raw["body"] as? String ?? "",
                periodText: raw["periodText"] as? String ?? "",
                timeText: raw["timeText"] as? String ?? "",
                nextText: raw["nextText"] as? String ?? "",
                upcomingText: raw["upcomingText"] as? String ?? "",
                periods: max((raw["periods"] as? NSNumber)?.intValue ?? 1, 1),
                startDate: start,
                endDate: end,
                colorHex: hexString(from: raw["color"] as? NSNumber)
            )
        )
    }

    /// The app sends the colour as a 32 bit ARGB value.
    @available(iOS 16.2, *)
    private static func hexString(from color: NSNumber?) -> String {
        guard let color = color else {
            return "#4A6CF7"
        }
        let argb = UInt32(bitPattern: color.int32Value)
        return String(
            format: "#%02X%02X%02X",
            (argb >> 16) & 0xFF,
            (argb >> 8) & 0xFF,
            argb & 0xFF
        )
    }
}
