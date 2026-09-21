// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Live Updates (Android 16 "promoted ongoing" notifications, the "Super
// Island" of Xiaomi and friends) and Live Activities (the iOS Dynamic Island)
// for the class which is going on right now.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/generated/non_ui_i18n.g.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/themes/color_seed.dart';

/// A single class which is shown while it is going on.
///
/// Everything the island needs is decided here, so that both platforms show
/// the same thing: the course, where it is, which periods it takes, how long
/// it still lasts and which class comes next.
class CourseLiveUpdateEvent {
  const CourseLiveUpdateEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.color,
    required this.start,
    required this.end,
    required this.periodText,
    required this.timeText,
    this.shortTitle = "",
    this.location = "",
    this.nextText = "",
    this.upcomingText = "",
    this.periods = 1,
  });

  final int id;

  /// The name of the course.
  final String title;

  /// A very short form of the name, for the places where only a couple of
  /// characters fit: the collapsed island and the status bar chip.
  final String shortTitle;

  /// The classroom and the teacher, in one line.
  final String body;

  /// The colour of the course card, as a 32 bit ARGB value.
  final int color;

  final DateTime start;
  final DateTime end;

  /// "第 3-4 节".
  final String periodText;

  /// "08:30 - 10:05".
  final String timeText;

  /// The classroom on its own, for the "next class" hint.
  final String location;

  /// "下一节 10:25 · B-106", empty when it is the last class of the day.
  final String nextText;

  /// "即将开始", shown while the class has not begun yet.
  ///
  /// The countdown of the notification runs towards the start of the class
  /// before it begins, exactly like it runs towards its end afterwards, so the
  /// island says which of the two it is showing.
  final String upcomingText;

  /// How many class periods the course takes, used to cut the progress bar.
  final int periods;

  CourseLiveUpdateEvent copyWith({String? nextText}) => CourseLiveUpdateEvent(
    id: id,
    title: title,
    body: body,
    color: color,
    start: start,
    end: end,
    periodText: periodText,
    timeText: timeText,
    shortTitle: shortTitle,
    location: location,
    nextText: nextText ?? this.nextText,
    upcomingText: upcomingText,
    periods: periods,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "body": body,
    "color": color,
    "startMillis": start.millisecondsSinceEpoch,
    "endMillis": end.millisecondsSinceEpoch,
    "periodText": periodText,
    "timeText": timeText,
    "shortTitle": shortTitle,
    "nextText": nextText,
    "upcomingText": upcomingText,
    "periods": periods,
  };
}

/// 岛上「提前多久出现」可以选的值（分钟），0 表示上课时才出现。
const kLiveUpdateLeadMinuteOptions = [0, 3, 5, 10, 15, 20, 30];

/// 平台侧的默认提前量：从宿舍走到教室差不多要这么久。
const kDefaultLiveUpdateLeadMinutes = 20;

/// 岛上的课程徽标样式。
///
/// The order is the one of the platform side, so do not shuffle it.
enum CourseLiveUpdateBadgeStyle {
  /// 首字，比如「程」。
  initial("首字"),

  /// 简称，比如「程序」。
  short("简称"),

  /// 方形圆角，配首字。
  square("方形"),

  /// 不要徽标，只留标题。默认用这个，标题里已经有课程名，再放一个同样的
  /// 标记只会让通知显得杂乱。
  none("不显示");

  const CourseLiveUpdateBadgeStyle(this.label);

  final String label;

  static CourseLiveUpdateBadgeStyle fromIndex(Object? index) {
    final value = index is int ? index : none.index;
    return value >= 0 && value < values.length ? values[value] : none;
  }
}

/// Pushes the upcoming classes to the platform, which shows the ongoing one as
/// a Live Update / Live Activity.
class CourseLiveUpdateService {
  CourseLiveUpdateService._();

  static final CourseLiveUpdateService instance = CourseLiveUpdateService._();

  static const MethodChannel _androidChannel = MethodChannel(
    "xdyou/course_live_update",
  );
  static const MethodChannel _appleChannel = MethodChannel(
    "xdyou/live_activity",
  );

  /// Kept apart from the ids of the reminders scheduled by
  /// `flutter_local_notifications`, which live in another bucket.
  static const int _idBase = 2000000000;
  static const int _idRange = 100000000;

  bool? _supported;

  /// Whether the platform turns these notifications into Live Updates.
  Future<bool> isSupported() async {
    final cached = _supported;
    if (cached != null) {
      return cached;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _supported = false;
      return false;
    }

    try {
      _supported = await _channel.invokeMethod<bool>("isSupported") ?? false;
    } on MissingPluginException {
      _supported = false;
    } on PlatformException catch (e) {
      log.warning("[CourseLiveUpdate] Unsupported platform: ${e.message}");
      _supported = false;
    }
    return _supported!;
  }

  MethodChannel get _channel =>
      Platform.isAndroid ? _androidChannel : _appleChannel;

  /// Replaces the schedule of the platform with the classes of the next
  /// [daysToSchedule] days.
  Future<void> scheduleFromCourseData({required int daysToSchedule}) async {
    if (!await isSupported()) {
      return;
    }

    try {
      final events = collectEvents(daysToSchedule: daysToSchedule);
      if (events.isEmpty) {
        await cancelAll();
        return;
      }

      final scheduled = await _channel.invokeMethod<int>("schedule", {
        "events": [for (final event in events) event.toMap()],
      });
      log.info(
        "[CourseLiveUpdate] Scheduled $scheduled of ${events.length} classes",
      );
    } catch (e, stackTrace) {
      log.error("[CourseLiveUpdate] Failed to schedule", e, stackTrace);
    }
  }

  /// Drops every pending Live Update, the ongoing one included.
  Future<void> cancelAll() async {
    if (!await isSupported()) {
      return;
    }

    try {
      await _channel.invokeMethod("cancelAll");
    } catch (e, stackTrace) {
      log.error("[CourseLiveUpdate] Failed to cancel", e, stackTrace);
    }
  }

  /// 换一种课程徽标。
  ///
  /// The badge is drawn by the platform, so the choice is kept there instead of
  /// in the preferences of the app: it has to be readable while the app is not
  /// running. 它只在 Android 上有意义。
  Future<void> setBadgeStyle(CourseLiveUpdateBadgeStyle style) async {
    if (!Platform.isAndroid || !await isSupported()) {
      return;
    }

    try {
      await _androidChannel.invokeMethod("setBadgeStyle", {
        "style": style.index,
      });
    } catch (e) {
      log.warning("[CourseLiveUpdate] Unable to set the badge: $e");
    }
  }

  /// 上课前多久把课放上岛（分钟，0 表示上课时才出现）。
  ///
  /// The alarms which put a class on the island are set by the platform, so the
  /// choice is kept there as well. 新的设置要在下次排程时才生效。
  Future<void> setLeadMinutes(int minutes) async {
    if (!Platform.isAndroid || !await isSupported()) {
      return;
    }

    try {
      await _androidChannel.invokeMethod("setLeadMinutes", {
        "minutes": minutes.clamp(0, 60),
      });
    } catch (e) {
      log.warning("[CourseLiveUpdate] Unable to set the lead time: $e");
    }
  }

  /// 上课时是否把课放到岛上。
  ///
  /// 它和「课前提醒」是两件事:提醒是响一下就走的通知,岛是上课期间一直挂着的状态,
  /// 所以两边各有自己的开关。关掉时把岛上那条也收走。
  Future<void> setEnabled(bool enabled) async {
    if (!Platform.isAndroid || !await isSupported()) {
      return;
    }

    try {
      await _androidChannel.invokeMethod("setEnabled", {"enabled": enabled});
    } catch (e) {
      log.warning("[CourseLiveUpdate] Unable to set the switch: $e");
    }
  }

  /// 岛是否开着(默认开着)。只有 Android 有这个概念。
  Future<bool> isEnabled() async {
    if (!Platform.isAndroid || !await isSupported()) {
      return false;
    }

    final values = await diagnostics();
    return values["enabled"] as bool? ?? true;
  }

  /// Shows a class right away, for trying the island out without waiting for
  /// the lesson.
  ///
  /// Pass the real [start] and [end] of the class to see exactly what the
  /// island will look like during it; leave them out to squeeze the class into
  /// [minutes] minutes, which is handy for watching the progress bar move.
  /// Either way it is not part of the schedule and does not touch the pending
  /// alarms.
  Future<bool> showPreview({
    required String title,
    required String body,
    required int minutes,
    String periodText = "",
    String nextText = "",
    DateTime? start,
    DateTime? end,
    int periods = 2,
    int color = 0xFF4A6CF7,
  }) async {
    if (!await isSupported()) {
      return false;
    }

    try {
      final now = DateTime.now();
      final previewStart = start ?? now.subtract(const Duration(minutes: 1));
      final previewEnd =
          end ?? previewStart.add(Duration(minutes: minutes.clamp(2, 240)));
      final event = CourseLiveUpdateEvent(
        id: 0,
        title: title,
        shortTitle: _shortName(title),
        body: body,
        color: color,
        start: previewStart,
        end: previewEnd,
        periodText: periodText,
        timeText: "${_formatTime(previewStart)} - ${_formatTime(previewEnd)}",
        nextText: nextText,
        upcomingText: NonUII18n.translate(
          CourseReminderService().getCurrentLocale(),
          "course_live_update.upcoming_start",
        ),
        periods: periods,
      );

      final shown = await _channel.invokeMethod<bool>("showPreview", {
        "event": event.toMap(),
      });
      return shown ?? false;
    } catch (e, stackTrace) {
      log.error("[CourseLiveUpdate] Failed to show the preview", e, stackTrace);
      return false;
    }
  }

  /// Takes the preview off the island again.
  Future<void> stopPreview() async {
    if (!await isSupported()) {
      return;
    }

    try {
      await _channel.invokeMethod("stopPreview");
    } catch (e, stackTrace) {
      log.error("[CourseLiveUpdate] Failed to stop the preview", e, stackTrace);
    }
  }

  /// 让岛上正在显示的那节课按现在的外观重发一次。
  ///
  /// The notification is built by the platform and only one class fits on the
  /// island, so this is how a change of the look (the badge, for instance)
  /// reaches what is already there, instead of a second notification. 它只在
  /// Android 上有意义,那边的通知由原生画;iOS 的活动界面是 Widget 自己随
  /// 时间重绘的,没有「重发一次」这回事。
  /// Returns whether there was a class on the island.
  Future<bool> refreshCurrent() async {
    if (!Platform.isAndroid || !await isSupported()) {
      return false;
    }

    try {
      return await _androidChannel.invokeMethod<bool>("refreshCurrent") ??
          false;
    } catch (e) {
      log.warning("[CourseLiveUpdate] Unable to refresh the island: $e");
      return false;
    }
  }

  /// What the platform reports about the island, for the debug page.
  Future<Map<String, dynamic>> diagnostics() async {
    if (!await isSupported()) {
      return {"supported": false};
    }

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        "diagnostics",
      );
      return result ?? {"supported": true};
    } catch (e) {
      log.warning("[CourseLiveUpdate] No diagnostics: $e");
      return {"supported": true};
    }
  }

  /// Opens the notification settings of the app, where the live updates can be
  /// turned on.
  Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod("openNotificationSettings");
    } catch (e) {
      log.warning("[CourseLiveUpdate] Unable to open the settings: $e");
    }
  }

  /// The classes of the next [daysToSchedule] days, taken from the same
  /// sources as the course reminders.
  List<CourseLiveUpdateEvent> collectEvents({required int daysToSchedule}) {
    final now = DateTime.now();
    final until = now.add(Duration(days: daysToSchedule));
    final locale = CourseReminderService().getCurrentLocale();
    final events = <CourseLiveUpdateEvent>[];

    final controller = ClassTableController.i;
    final data = controller.classTableComputedSignal.value;

    if (data.termStartDay.isNotEmpty) {
      final semesterStart = DateTime.parse(data.termStartDay);

      var startWeek = controller.getCurrentWeek(now);
      if (startWeek < 0) {
        startWeek = 0;
      }
      var endWeek = controller.getCurrentWeek(until);
      if (endWeek >= data.semesterLength) {
        endWeek = data.semesterLength - 1;
      }

      for (var week = startWeek; week <= endWeek; week++) {
        for (final arrangement in data.timeArrangement) {
          if (week >= arrangement.weekList.length ||
              !arrangement.weekList[week]) {
            continue;
          }

          final day = semesterStart.add(
            Duration(days: week * 7 + arrangement.day - 1),
          );
          final start = _atTimeOfDay(
            day,
            timeList[(arrangement.start - 1) * 2],
          );
          final end = _atTimeOfDay(
            day,
            timeList[(arrangement.stop - 1) * 2 + 1],
          );
          if (!end.isAfter(now) || start.isAfter(until)) {
            continue;
          }

          events.add(
            _buildEvent(
              locale: locale,
              name: data.getClassDetail(arrangement).name,
              classroom: arrangement.classroom,
              teacher: arrangement.teacher,
              start: start,
              end: end,
              startPeriod: arrangement.start,
              stopPeriod: arrangement.stop,
              colorIndex: arrangement.index,
            ),
          );
        }
      }
    }

    for (final customClass in CustomClassController.i.customClasses) {
      for (final range in customClass.timeRanges) {
        if (!range.endTime.isAfter(now) || range.startTime.isAfter(until)) {
          continue;
        }

        events.add(
          _buildEvent(
            locale: locale,
            name: customClass.name,
            classroom: customClass.classroom,
            teacher: customClass.teacher,
            start: range.startTime,
            end: range.endTime,
            startPeriod: _periodOf(range.startTime),
            stopPeriod: _periodOf(range.endTime),
            colorIndex: customClass.name.hashCode,
          ),
        );
      }
    }

    events.sort((a, b) => a.start.compareTo(b.start));

    /// A hint about the class which follows, so that the break can be planned
    /// from the island alone.
    return [
      for (var index = 0; index < events.length; index++)
        _withNextClass(events, index, locale),
    ];
  }

  CourseLiveUpdateEvent _withNextClass(
    List<CourseLiveUpdateEvent> events,
    int index,
    String locale,
  ) {
    final event = events[index];
    if (index + 1 >= events.length) {
      return event;
    }

    final next = events[index + 1];
    final sameDay =
        next.start.year == event.end.year &&
        next.start.month == event.end.month &&
        next.start.day == event.end.day;
    if (!sameDay) {
      return event;
    }

    return event.copyWith(
      nextText: NonUII18n.translate(
        locale,
        "course_live_update.next_class",
        translateParams: {
          "time": _formatTime(next.start),
          "location": next.location.isEmpty
              ? NonUII18n.translate(locale, "course_live_update.no_location")
              : next.location,
        },
      ),
    );
  }

  CourseLiveUpdateEvent _buildEvent({
    required String locale,
    required String name,
    required String? classroom,
    required String? teacher,
    required DateTime start,
    required DateTime end,
    required int startPeriod,
    required int stopPeriod,
    required int colorIndex,
  }) {
    final location = classroom?.trim() ?? "";
    final teacherName = teacher?.trim() ?? "";

    return CourseLiveUpdateEvent(
      id: _eventId(name, start),
      title: name,
      shortTitle: _shortName(name),
      body: [
        if (location.isNotEmpty) location,
        if (teacherName.isNotEmpty) teacherName,
      ].join(" · "),
      color: colorList[colorIndex.abs() % colorList.length].toARGB32(),
      start: start,
      end: end,
      periodText: startPeriod == stopPeriod
          ? NonUII18n.translate(
              locale,
              "course_live_update.period_single",
              translateParams: {"start": "$startPeriod"},
            )
          : NonUII18n.translate(
              locale,
              "course_live_update.period",
              translateParams: {"start": "$startPeriod", "stop": "$stopPeriod"},
            ),
      timeText: "${_formatTime(start)} - ${_formatTime(end)}",
      location: location,
      upcomingText: NonUII18n.translate(
        locale,
        "course_live_update.upcoming_start",
      ),
      periods: (stopPeriod - startPeriod + 1).clamp(1, 20),
    );
  }

  /// A very short form of the course name.
  ///
  /// The collapsed island has room for a couple of characters only, and the
  /// status bar chip truncates whatever it is given. Cutting the name here
  /// keeps it readable: the "(II)" kind of suffix goes first, then the name is
  /// cut to four characters (or to one word, for names without Chinese).
  static String _shortName(String name) {
    var value = name.trim();
    if (value.isEmpty) {
      return "";
    }

    value = value.replaceFirst(RegExp(r"[(（][^)）]*[)）]\s*$"), "").trim();
    if (value.isEmpty) {
      value = name.trim();
    }

    if (RegExp(r"[\u4e00-\u9fff]").hasMatch(value)) {
      final runes = value.runes.toList();
      return runes.length <= 4 ? value : String.fromCharCodes(runes.take(4));
    }

    final word = value.split(RegExp(r"\s+")).first;
    return word.length <= 10 ? word : word.substring(0, 10);
  }

  /// A stable id for a class, so that updating it keeps the same notification.
  int _eventId(String name, DateTime start) {
    const int fnvOffsetBasis = 0x811C9DC5;
    const int fnvPrime = 0x01000193;

    int hash = fnvOffsetBasis;
    for (final codeUnit in "$name|${start.toIso8601String()}".codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }

    return _idBase + (hash % _idRange);
  }

  DateTime _atTimeOfDay(DateTime day, String hourMinute) {
    final minutes = _minutesOf(hourMinute);
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }

  int _minutesOf(String hourMinute) {
    final parts = hourMinute.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// The period a moment belongs to, by the start of the periods.
  int _periodOf(DateTime time) {
    final minutes = time.hour * 60 + time.minute;

    var period = 1;
    for (var index = 0; index < timeList.length ~/ 2; index++) {
      if (minutes >= _minutesOf(timeList[index * 2])) {
        period = index + 1;
      }
    }
    return period;
  }

  String _formatTime(DateTime time) =>
      "${time.hour.toString().padLeft(2, "0")}:"
      "${time.minute.toString().padLeft(2, "0")}";
}
