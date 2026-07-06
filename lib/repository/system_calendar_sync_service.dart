// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:convert';

import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:intl/intl.dart';
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

/// Lightweight draft used to build events before pushing them to the system
/// calendar or serialising to iCalendar format.
///
/// The plugin's [Event] class is read-only and can only be obtained from the
/// platform.  This draft captures all the fields we need for both write and
/// iCal-export paths.
class CalendarEventDraft {
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final RecurrenceRule? recurrenceRule;

  const CalendarEventDraft({
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.location,
    this.recurrenceRule,
  });
}

List<CalendarEventDraft> buildCalendarEvents({
  required ClassTableData classTableData,
  required List<Subject> subjects,
  required List<ExperimentData> experiments,
}) {
  List<CalendarEventDraft> events = [];

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
            return DayOfWeek.monday;
          case 2:
            return DayOfWeek.tuesday;
          case 3:
            return DayOfWeek.wednesday;
          case 4:
            return DayOfWeek.thursday;
          case 5:
            return DayOfWeek.friday;
          case 6:
            return DayOfWeek.saturday;
          case 7:
            return DayOfWeek.sunday;
          default:
            return DayOfWeek.sunday;
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

        RecurrenceRule rrule = WeeklyRecurrence(
          daysOfWeek: [getDayOfWeek(i.day)],
          end: UntilEnd(
            firstDay.add(Duration(days: (range.$2 - range.$1) * 7 + 1)),
          ),
        );

        events.add(
          CalendarEventDraft(
            title: title,
            description: description,
            recurrenceRule: rrule,
            startDate: startTimeToUse,
            endDate: stopTimeToUse,
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
      CalendarEventDraft(
        title: title,
        description: description,
        startDate: i.startTime!,
        endDate: i.stopTime!,
        location: location,
      ),
    );
  }

  for (var experiment in experiments) {
    for (var j in experiment.timeRanges) {
      events.add(
        CalendarEventDraft(
          title: '${experiment.name}@${experiment.classroom}',
          description: '实验名称：${experiment.name} - 老师：${experiment.teacher}',
          startDate: j.$1,
          endDate: j.$2,
          location: experiment.classroom,
        ),
      );
    }
  }

  return events;
}

String buildICalendarString(List<CalendarEventDraft> events) {
  String toReturn = 'BEGIN:VCALENDAR\n'
      'CALSCALE:GREGORIAN\n'
      'BEGIN:VTIMEZONE\n'
      'TZID:Asia/Shanghai\n'
      'X-LIC-LOCATION:Asia/Shanghai\n'
      'BEGIN:STANDARD\n'
      'TZOFFSETFROM:+0800\n'
      'TZOFFSETTO:+0800\n'
      'TZNAME:CST\n'
      'DTSTART:19700101T000000\n'
      'END:STANDARD\n'
      'END:VTIMEZONE\n';

  for (var i in events) {
    String vevent = 'BEGIN:VEVENT\n';

    vevent +=
        'DTSTAMP:${DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now())}\n';
    vevent += 'SUMMARY:${i.title}\n';
    vevent += 'DESCRIPTION:${i.description ?? "待定"}\n';

    vevent +=
        'DTSTART;TZID=Asia/Shanghai:'
        '${DateFormat('yyyyMMddTHHmmss').format(i.startDate)}\n';
    vevent +=
        'DTEND;TZID=Asia/Shanghai:'
        '${DateFormat('yyyyMMddTHHmmss').format(i.endDate)}\n';
    if (i.location != null) {
      vevent += 'LOCATION:${i.location}\n';
    }

    if (i.recurrenceRule is WeeklyRecurrence) {
      final weekly = i.recurrenceRule! as WeeklyRecurrence;
      final day = weekly.daysOfWeek?.firstOrNull;
      final endDate = (weekly.end is UntilEnd)
          ? (weekly.end as UntilEnd).until
          : null;
      if (day != null && endDate != null) {
        vevent +=
            'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=${day.toRruleDay()};'
            'UNTIL=${DateFormat('yyyyMMdd').format(endDate)}\n';
      }
    }
    toReturn += '${vevent}END:VEVENT\n';
  }

  return '${toReturn}END:VCALENDAR\n';
}

class SystemCalendarSyncService {
  final DeviceCalendar deviceCalendar = DeviceCalendar();

  ClassTableController get classTableController => ClassTableController.i;
  ExamController get examController => ExamController.i;
  PhysicsExperimentController get physicsExperimentController =>
      PhysicsExperimentController.i;
  OtherExperimentController get otherExperimentController =>
      OtherExperimentController.i;

  String get currentSemesterCode =>
      classTableController.classTableComputedSignal.value.semesterCode;

  String get savedCalendarId =>
      preference.getString(preference.Preference.systemCalendarId);

  String get savedCalendarSemesterCode =>
      preference.getString(preference.Preference.systemCalendarSemesterCode);

  String get calendarName =>
      buildExportedClassTableCalendarName(currentSemesterCode);

  List<ExperimentData> get experiments => [
    ...physicsExperimentController.physicsExperiments.value,
    ...otherExperimentController.otherExperiments.value,
  ];

  List<CalendarEventDraft> get events => buildCalendarEvents(
    classTableData: classTableController.classTableComputedSignal.value,
    subjects: examController.subjects.value,
    experiments: experiments,
  );

  String get snapshot => buildSystemCalendarSnapshot(
    classTableData: classTableController.classTableComputedSignal.value,
    subjects: examController.subjects.value,
    experiments: experiments,
  );

  bool get hasCalendarBinding => savedCalendarId.isNotEmpty;

  bool get isBoundCalendarForCurrentSemester =>
      savedCalendarSemesterCode.isNotEmpty &&
      savedCalendarSemesterCode == currentSemesterCode;

  bool get didSemesterChangeSinceLastBinding =>
      savedCalendarSemesterCode.isNotEmpty &&
      currentSemesterCode.isNotEmpty &&
      savedCalendarSemesterCode != currentSemesterCode;

  bool get canAutoSync =>
      hasCalendarBinding &&
      (didSemesterChangeSinceLastBinding ||
          preference.getString(preference.Preference.systemCalendarSnapshot) !=
              snapshot) &&
      classTableController.hasValidClassInfo.value;

  Future<bool> _ensureCalendarPermission({
    required bool requestPermissionsIfNeeded,
    Future<void> Function()? showDialog,
  }) async {
    CalendarPermissionStatus status = await deviceCalendar.hasPermissions();
    if (status == CalendarPermissionStatus.granted) {
      return true;
    }

    if (!requestPermissionsIfNeeded) {
      return false;
    }

    if (showDialog != null) {
      await showDialog();
    }
    status = await deviceCalendar.requestPermissions();
    return status == CalendarPermissionStatus.granted;
  }

  Future<void> _saveCalendarBinding(String calendarId) async {
    await preference.setString(
      preference.Preference.systemCalendarId,
      calendarId,
    );
    await preference.setString(
      preference.Preference.systemCalendarSemesterCode,
      currentSemesterCode,
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
    await preference.remove(preference.Preference.systemCalendarSemesterCode);
  }

  Future<List<Calendar>?> _retrieveWritableCalendars() async {
    try {
      final calendars = await deviceCalendar.listCalendars();
      return calendars.where((calendar) => !calendar.readOnly).toList();
    } catch (e, s) {
      log.info(
        '[SystemCalendarSyncService][_retrieveWritableCalendars] '
        'Retrieve calendars failed: $e',
      );
      log.handle(e, s);
      return null;
    }
  }

  Future<Calendar?> _findBoundCalendar(List<Calendar> calendars) async {
    if (!hasCalendarBinding) {
      return null;
    }

    for (var calendar in calendars) {
      if (calendar.id != savedCalendarId) {
        continue;
      }

      if (isBoundCalendarForCurrentSemester) {
        return calendar;
      }

      // Migrate older bindings that do not persist the semester code yet.
      if (savedCalendarSemesterCode.isEmpty &&
          calendar.name == calendarName &&
          calendar.id.isNotEmpty) {
        await _saveCalendarBinding(calendar.id);
        return calendar;
      }

      log.info(
        '[SystemCalendarSyncService][_findBoundCalendar] '
        'Skip maintaining bound calendar from semester '
        '$savedCalendarSemesterCode while current semester is '
        '$currentSemesterCode.',
      );
      return null;
    }

    await _clearCalendarBinding();
    return null;
  }

  /// Find the exported calendar by saved id or the current fixed name.
  Future<Calendar?> _findExportedCalendar() async {
    final calendars = await _retrieveWritableCalendars();
    if (calendars == null) {
      return null;
    }

    final hadCalendarBinding = hasCalendarBinding;
    final boundCalendar = await _findBoundCalendar(calendars);
    if (boundCalendar != null) {
      return boundCalendar;
    }
    // Treat a missing bound calendar as an explicit user opt-out, so auto sync
    // does not resurrect the export by falling back to name lookup.
    if (hadCalendarBinding && !hasCalendarBinding) {
      return null;
    }

    for (var calendar in calendars) {
      if (calendar.name == calendarName && calendar.id.isNotEmpty) {
        await _saveCalendarBinding(calendar.id);
        return calendar;
      }
    }

    return null;
  }

  Future<String?> _createExportedCalendar() async {
    try {
      final calendarId = await deviceCalendar.createCalendar(
        name: calendarName,
      );
      if (calendarId.isEmpty) {
        log.info(
          '[SystemCalendarSyncService][_createExportedCalendar] '
          'Create calendar returned empty id.',
        );
        return null;
      }
      return calendarId;
    } catch (e, s) {
      log.info(
        '[SystemCalendarSyncService][_createExportedCalendar] '
        'Create calendar failed: $e',
      );
      log.handle(e, s);
      return null;
    }
  }

  Future<String?> _prepareCalendar({required bool onlyIfCalendarExists}) async {
    Calendar? exportedCalendar = await _findExportedCalendar();
    bool shouldCreateCurrentSemesterCalendar =
        !onlyIfCalendarExists || didSemesterChangeSinceLastBinding;

    if (exportedCalendar == null) {
      if (!shouldCreateCurrentSemesterCalendar) {
        return null;
      }
      return await _createExportedCalendar();
    }

    if (exportedCalendar.id.isEmpty) {
      log.info(
        '[SystemCalendarSyncService][_prepareCalendar] '
        'Exported calendar has empty id.',
      );
      return null;
    }

    try {
      await deviceCalendar.deleteCalendar(exportedCalendar.id);
    } catch (e, s) {
      log.info(
        '[SystemCalendarSyncService][_prepareCalendar] '
        'Delete old exported calendar failed: $e',
      );
      log.handle(e, s);
      return null;
    }

    await _clearCalendarBinding();
    return await _createExportedCalendar();
  }

  Future<bool> _writeEventsToCalendar(String calendarId) async {
    for (var i in events) {
      try {
        await deviceCalendar.createEvent(
          calendarId: calendarId,
          title: i.title,
          startDate: i.startDate,
          endDate: i.endDate,
          description: i.description,
          location: i.location,
          recurrenceRule: i.recurrenceRule,
        );
      } catch (e, s) {
        log.info(
          '[SystemCalendarSyncService][_writeEventsToCalendar] '
          'Write event failed: $e',
        );
        log.handle(e, s);
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
