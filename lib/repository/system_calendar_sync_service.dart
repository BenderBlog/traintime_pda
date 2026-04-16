// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

const String exportedClassTableCalendarPrefix = 'PDA Class Arrangement';

/// Build a stable calendar name for exported classtable events.
String buildExportedClassTableCalendarName(String semesterCode) =>
    semesterCode.isEmpty
        ? exportedClassTableCalendarPrefix
        : '$exportedClassTableCalendarPrefix $semesterCode';

/// Build a stable snapshot used to decide whether auto sync is needed.
String buildSystemCalendarSnapshot({
  required ClassTableData classTableData,
  required List<Subject> subjects,
  required List<ExperimentData> experiments,
}) => jsonEncode({
  'classTableData': classTableData.toJson(),
  'subjects': subjects.map((item) => item.toJson()).toList(),
  'experiments': experiments.map((item) => item.toJson()).toList(),
});

List<Event> buildCalendarEvents({
  required ClassTableData classTableData,
  required List<Subject> subjects,
  required List<ExperimentData> experiments,
}) {
  List<Event> events = [];

  tz.initializeTimeZones();
  Location currentLocation = getLocation('Asia/Shanghai');

  if (classTableData.termStartDay.isNotEmpty) {
    DateTime startDay = DateTime.parse(classTableData.termStartDay);

    for (var i in classTableData.timeArrangement) {
      int j = i.weekList.indexWhere((element) => element);

      if (j == -1) continue;

      List<(int, int)> ranges = [];
      int start = -1;

      for (j; j < i.weekList.length; j++) {
        if (i.weekList[j] && start == -1) {
          start = j;
        } else if (!i.weekList[j] && start != -1) {
          ranges.add((start, j - 1));
          start = -1;
        }
      }

      if (start != -1) {
        ranges.add((start, j - 1));
      }

      String title =
          '${classTableData.getClassDetail(i).name}@${i.classroom ?? "待定"}';
      String description =
          '课程名称：${classTableData.getClassDetail(i).name} - 老师：${i.teacher ?? "未知"}';
      String? location = i.classroom ?? '待定';

      List<String> startTime = timeList[(i.start - 1) * 2].split(':');
      List<String> stopTime = timeList[(i.stop - 1) * 2 + 1].split(':');

      DayOfWeek getDayOfWeek(int day) {
        switch (day) {
          case 1:
            return DayOfWeek.Monday;
          case 2:
            return DayOfWeek.Tuesday;
          case 3:
            return DayOfWeek.Wednesday;
          case 4:
            return DayOfWeek.Thursday;
          case 5:
            return DayOfWeek.Friday;
          case 6:
            return DayOfWeek.Saturday;
          case 7:
            return DayOfWeek.Sunday;
          default:
            return DayOfWeek.Sunday;
        }
      }

      for (var range in ranges) {
        DateTime firstDay = startDay.add(
          Duration(days: range.$1 * 7 + i.day - 1),
        );

        DateTime startTimeToUse = firstDay.add(
          Duration(
            hours: int.parse(startTime[0]),
            minutes: int.parse(startTime[1]),
          ),
        );
        DateTime stopTimeToUse = firstDay.add(
          Duration(
            hours: int.parse(stopTime[0]),
            minutes: int.parse(stopTime[1]),
          ),
        );

        RecurrenceRule rrule = RecurrenceRule(
          RecurrenceFrequency.Weekly,
          daysOfWeek: [getDayOfWeek(i.day)],
          endDate: firstDay.add(Duration(days: (range.$2 - range.$1) * 7 + 1)),
        );

        events.add(
          Event(
            null,
            title: title,
            description: description,
            recurrenceRule: rrule,
            start: TZDateTime.from(startTimeToUse, currentLocation),
            end: TZDateTime.from(stopTimeToUse, currentLocation),
            location: location,
          ),
        );
      }
    }
  }

  for (var i in subjects) {
    String title =
        '${i.subject} ${i.typeStr}@${i.place} ${i.seat != null ? "-${i.seat}" : ""}';
    String description = '考试信息：${i.subject} - ${i.typeStr}';
    String location = '${i.place} ${i.seat != null ? "-${i.seat}" : ""}';

    events.add(
      Event(
        null,
        title: title,
        description: description,
        start: TZDateTime.from(i.startTime!, currentLocation),
        end: TZDateTime.from(i.stopTime!, currentLocation),
        location: location,
      ),
    );
  }

  for (var experiment in experiments) {
    for (var j in experiment.timeRanges) {
      events.add(
        Event(
          null,
          title: '${experiment.name}@${experiment.classroom}',
          description: '实验名称：${experiment.name} - 老师：${experiment.teacher}',
          start: TZDateTime.from(j.$1, currentLocation),
          end: TZDateTime.from(j.$2, currentLocation),
          location: experiment.classroom,
        ),
      );
    }
  }

  return events;
}

String buildICalendarString(List<Event> events) {
  String toReturn = '''BEGIN:VCALENDAR
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:Asia/Shanghai
X-LIC-LOCATION:Asia/Shanghai
BEGIN:STANDARD
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
TZNAME:CST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE
''';

  for (var i in events) {
    String vevent = 'BEGIN:VEVENT\n';

    vevent +=
        'DTSTAMP:${DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now())}\n';
    vevent += 'SUMMARY:${i.title ?? "待定"}\n';
    vevent += 'DESCRIPTION:${i.description ?? "待定"}\n';

    vevent +=
        'DTSTART;TZID=Asia/Shanghai:'
        '${DateFormat('yyyyMMddTHHmmss').format(DateTime.fromMicrosecondsSinceEpoch(i.start!.microsecondsSinceEpoch))}\n';
    vevent +=
        'DTEND;TZID=Asia/Shanghai:'
        '${DateFormat('yyyyMMddTHHmmss').format(DateTime.fromMicrosecondsSinceEpoch(i.end!.microsecondsSinceEpoch))}\n';
    if (i.location != null) {
      vevent += 'LOCATION:${i.location}\n';
    }

    if (i.recurrenceRule != null) {
      String getWeekStr(DayOfWeek day) {
        switch (day) {
          case DayOfWeek.Monday:
            return 'MO';
          case DayOfWeek.Tuesday:
            return 'TU';
          case DayOfWeek.Wednesday:
            return 'WE';
          case DayOfWeek.Thursday:
            return 'TH';
          case DayOfWeek.Friday:
            return 'FR';
          case DayOfWeek.Saturday:
            return 'SA';
          case DayOfWeek.Sunday:
            return 'SU';
        }
      }

      vevent +=
          'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=${getWeekStr(i.recurrenceRule!.daysOfWeek!.first)};'
          'UNTIL=${DateFormat('yyyyMMdd').format(i.recurrenceRule!.endDate!)}\n';
    }
    toReturn += '${vevent}END:VEVENT\n';
  }

  return '${toReturn}END:VCALENDAR';
}

class SystemCalendarSyncService {
  final DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

  ClassTableController get classTableController => ClassTableController.i;
  ExamController get examController => ExamController.i;
  PhysicsExperimentController get physicsExperimentController =>
      PhysicsExperimentController.i;
  OtherExperimentController get otherExperimentController =>
      OtherExperimentController.i;

  String get calendarName => buildExportedClassTableCalendarName(
    classTableController.classTableComputedSignal.value.semesterCode,
  );

  List<ExperimentData> get experiments => [
    ...physicsExperimentController.physicsExperiments.value,
    ...otherExperimentController.otherExperiments.value,
  ];

  List<Event> get events => buildCalendarEvents(
    classTableData: classTableController.classTableComputedSignal.value,
    subjects: examController.subjects.value,
    experiments: experiments,
  );

  String get snapshot => buildSystemCalendarSnapshot(
    classTableData: classTableController.classTableComputedSignal.value,
    subjects: examController.subjects.value,
    experiments: experiments,
  );

  bool get canAutoSync =>
      preference.getString(preference.Preference.systemCalendarId).isNotEmpty &&
      preference.getString(preference.Preference.systemCalendarSnapshot) !=
          snapshot &&
      classTableController.hasValidClassInfo.value;

  Future<bool> _ensureCalendarPermission({
    required bool requestPermissionsIfNeeded,
    Future<void> Function()? showDialog,
  }) async {
    Result<bool> hasPermitted = await deviceCalendarPlugin.hasPermissions();
    if (hasPermitted.data == true) {
      return true;
    }

    if (!requestPermissionsIfNeeded) {
      return false;
    }

    if (showDialog != null) {
      await showDialog();
    }
    hasPermitted = await deviceCalendarPlugin.requestPermissions();
    return hasPermitted.data == true;
  }

  Future<void> _saveCalendarBinding(String calendarId) async {
    await preference.setString(
      preference.Preference.systemCalendarId,
      calendarId,
    );
  }

  Future<void> _saveCalendarSyncState(String calendarId) async {
    await _saveCalendarBinding(calendarId);
    await preference.setString(
      preference.Preference.systemCalendarSnapshot,
      snapshot,
    );
  }

  Future<void> _clearCalendarBinding() async {
    await preference.remove(preference.Preference.systemCalendarId);
  }

  bool _isLegacyCalendarName(String name) {
    return name.startsWith('$calendarName created at ') ||
        name.startsWith(exportedClassTableCalendarPrefix);
  }

  Future<List<Calendar>?> _retrieveWritableCalendars() async {
    final calendarResult = await deviceCalendarPlugin.retrieveCalendars();
    if (!calendarResult.isSuccess || calendarResult.data == null) {
      log.info(
        '[SystemCalendarSyncService][_retrieveWritableCalendars] '
        'Retrieve calendars failed.',
      );
      return null;
    }

    return calendarResult.data!
        .where((calendar) => calendar.isReadOnly != true)
        .toList();
  }

  Future<Calendar?> _findBoundCalendar(List<Calendar> calendars) async {
    String savedCalendarId = preference.getString(
      preference.Preference.systemCalendarId,
    );
    if (savedCalendarId.isEmpty) {
      return null;
    }

    for (var calendar in calendars) {
      if (calendar.id == savedCalendarId) {
        return calendar;
      }
    }

    await _clearCalendarBinding();
    return null;
  }

  /// Find the exported calendar by saved id or compatible old naming rules.
  Future<Calendar?> _findExportedCalendar({
    required bool allowLegacyLookup,
  }) async {
    final calendars = await _retrieveWritableCalendars();
    if (calendars == null) {
      return null;
    }

    final boundCalendar = await _findBoundCalendar(calendars);
    if (boundCalendar != null || !allowLegacyLookup) {
      return boundCalendar;
    }

    for (var calendar in calendars) {
      if (calendar.name == calendarName &&
          calendar.id != null &&
          calendar.id!.isNotEmpty) {
        await _saveCalendarBinding(calendar.id!);
        return calendar;
      }
    }

    for (var calendar in calendars) {
      if (_isLegacyCalendarName(calendar.name ?? '') &&
          calendar.id != null &&
          calendar.id!.isNotEmpty) {
        await _saveCalendarBinding(calendar.id!);
        return calendar;
      }
    }

    return null;
  }

  Future<String?> _createExportedCalendar() async {
    Result<String> calendarIdData = await deviceCalendarPlugin.createCalendar(
      calendarName,
    );
    if (!calendarIdData.isSuccess ||
        calendarIdData.data == null ||
        calendarIdData.data!.isEmpty) {
      log.info(
        '[SystemCalendarSyncService][_createExportedCalendar] '
        'Create calendar failed.',
      );
      return null;
    }

    return calendarIdData.data!;
  }

  Future<String?> _prepareCalendar({required bool onlyIfCalendarExists}) async {
    Calendar? exportedCalendar = await _findExportedCalendar(
      allowLegacyLookup: !onlyIfCalendarExists,
    );

    if (exportedCalendar == null) {
      if (onlyIfCalendarExists) {
        return null;
      }
      return await _createExportedCalendar();
    }

    if (exportedCalendar.id == null || exportedCalendar.id!.isEmpty) {
      log.info(
        '[SystemCalendarSyncService][_prepareCalendar] '
        'Exported calendar has empty id.',
      );
      return null;
    }

    Result<bool> deleteResult = await deviceCalendarPlugin.deleteCalendar(
      exportedCalendar.id!,
    );
    if (deleteResult.data != true) {
      log.info(
        '[SystemCalendarSyncService][_prepareCalendar] '
        'Delete old exported calendar failed.',
      );
      return null;
    }

    await _clearCalendarBinding();
    return await _createExportedCalendar();
  }

  Future<bool> _writeEventsToCalendar(String calendarId) async {
    for (var i in events) {
      final toPush = i..calendarId = calendarId;
      Result<String>? addEventResult = await deviceCalendarPlugin
          .createOrUpdateEvent(toPush);
      if (addEventResult == null ||
          addEventResult.data == null ||
          addEventResult.data!.isEmpty) {
        log.info(
          '[SystemCalendarSyncService][_writeEventsToCalendar] '
          'Write event failed.',
        );
        return false;
      }
    }

    return true;
  }

  Future<bool> syncSystemCalendar({
    required bool requestPermissionsIfNeeded,
    required bool onlyIfCalendarExists,
    Future<void> Function()? showDialog,
  }) async {
    try {
      bool hasPermitted = await _ensureCalendarPermission(
        requestPermissionsIfNeeded: requestPermissionsIfNeeded,
        showDialog: showDialog,
      );
      if (!hasPermitted) {
        log.info(
          '[SystemCalendarSyncService][syncSystemCalendar] '
          'Calendar permission denied.',
        );
        return false;
      }

      String? calendarId = await _prepareCalendar(
        onlyIfCalendarExists: onlyIfCalendarExists,
      );
      if (calendarId == null || calendarId.isEmpty) {
        return false;
      }

      bool didWrite = await _writeEventsToCalendar(calendarId);
      if (didWrite) {
        await _saveCalendarSyncState(calendarId);
      }
      return didWrite;
    } catch (e, s) {
      log.handle(e, s);
      return false;
    }
  }
}

/// Auto sync only when the exported payload changed and the bound calendar
/// still exists.
Future<void> maybeAutoSyncSystemCalendar() async {
  try {
    final service = SystemCalendarSyncService();
    if (!service.canAutoSync) {
      return;
    }

    await service.syncSystemCalendar(
      requestPermissionsIfNeeded: false,
      onlyIfCalendarExists: true,
    );
  } catch (e, s) {
    log.handle(e, s);
  }
}
