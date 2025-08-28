// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/themes/color_seed.dart';

/// Use a inheritedWidget to share the ClassTableWidgetState
class ClassTableState extends InheritedWidget {
  final ClassTableWidgetState controllers;
  final BuildContext parentContext;
  final BoxConstraints constraints;

  const ClassTableState({
    super.key,
    required super.child,
    required this.parentContext,
    required this.controllers,
    required this.constraints,
  });

  static ClassTableState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassTableState>();
  }

  @override
  bool updateShouldNotify(covariant ClassTableState oldWidget) {
    controllers.chosenWeek = oldWidget.controllers.chosenWeek;
    controllers.partnerClass = oldWidget.controllers.partnerClass;
    controllers.partnerSubjects = oldWidget.controllers.partnerSubjects;
    controllers.partnerExperiment = oldWidget.controllers.partnerExperiment;
    controllers.partnerName = oldWidget.controllers.partnerName;
    controllers.isPartner = oldWidget.controllers.isPartner;
    return true;
  }
}

/// The controllers and shared datas of the class table.
class ClassTableWidgetState with ChangeNotifier {
  ///****************************///
  /// Following are static data. ///
  /// ***************************///

  /// The controller...
  final ClassTableController classTableController = Get.find();
  final ExamController examController = Get.find();
  final ExperimentController experimentController = Get.find();

  /// The length of the semester, the amount of the class table.
  int get semesterLength => classTableController.classTableData.semesterLength;

  /// The semester code.
  String get semesterCode => classTableController.classTableData.semesterCode;

  /// The offset append to start day of the week.
  final int offset = preference.getInt(preference.Preference.swift);

  ///*****************************///
  /// Following are dynamic data. ///
  /// ****************************///

  /// Partner class info (if there is)
  ClassTableData? partnerClass;
  List<Subject>? partnerSubjects;
  List<ExperimentData>? partnerExperiment;
  String? partnerName;

  /// Render partner code.
  bool _isPartner = false;

  set isPartner(bool isPartner) {
    if (isPartner &&
        (partnerClass == null ||
            partnerSubjects == null ||
            partnerExperiment == null)) {
      return;
    }
    _isPartner = isPartner;
    notifyListeners();
  }

  bool get isPartner => _isPartner;

  bool get havePartner =>
      partnerClass != null &&
      partnerSubjects != null &&
      partnerExperiment != null;

  /// Current showing week.
  int _chosenWeek = 0;

  /// Change chosen week.
  set chosenWeek(int chosenWeek) {
    if (chosenWeek != _chosenWeek) {
      _chosenWeek = chosenWeek;
    }
    notifyListeners();
  }

  int get chosenWeek => _chosenWeek;

  /// The class details.
  List<ClassDetail> get classDetail => isPartner
      ? partnerClass!.classDetail
      : classTableController.classTableData.classDetail;

  /// The classes without time arrangements.
  List<NotArrangementClassDetail> get notArranged => isPartner
      ? partnerClass!.notArranged
      : classTableController.classTableData.notArranged;

  /// The time arrangements of the class details, use with [classDetail].
  List<TimeArrangement> get timeArrangement => isPartner
      ? partnerClass!.timeArrangement
      : classTableController.classTableData.timeArrangement;

  /// The class change data.
  List<ClassChange> get classChange => isPartner
      ? partnerClass!.classChanges
      : classTableController.classTableData.classChanges;

  /// The day the semester start, used to calculate the first day of the week.
  DateTime get startDay =>
      DateTime.parse(classTableController.classTableData.termStartDay);

  /// The currentWeek.
  final int currentWeek;

  /// The exam list.
  List<Subject> get subjects =>
      isPartner ? partnerSubjects! : examController.data.subject;

  /// The experiment list.
  List<ExperimentData> get experiments =>
      isPartner ? partnerExperiment! : experimentController.data;

  /// Get class detail by prividing index of timearrangement
  ClassDetail getClassDetail(int index) =>
      (isPartner ? partnerClass! : classTableController.classTableData)
          .getClassDetail(timeArrangement[index]);

  /// Bridge function to add/del/edit user defined class
  /// Only main classtable support it!
  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) => classTableController
      .addUserDefinedClass(classDetail, timeArrangement)
      .then((value) => notifyListeners());

  Future<void> editUserDefinedClass(
    TimeArrangement oldTimeArrangment,
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) => classTableController
      .editUserDefinedClass(oldTimeArrangment, classDetail, timeArrangement)
      .then((value) => notifyListeners());

  Future<void> deleteUserDefinedClass(TimeArrangement timeArrangement) =>
      classTableController
          .deleteUserDefinedClass(timeArrangement)
          .then((value) => notifyListeners());

  /// Decode Partner String info
  (String, ClassTableData, List<Subject>, List<ExperimentData>, bool)
  decodePartnerClass(String source) {
    final data = jsonDecode(source);
    var yearNotEqual =
        semesterCode
            .substring(0, 4)
            .compareTo(
              data["classtable"]["semesterCode"].toString().substring(0, 4),
            ) !=
        0;
    var lastNotEqual =
        semesterCode
            .substring(semesterCode.length - 1)
            .compareTo(
              data["classtable"]["semesterCode"].toString().substring(
                data["classtable"]["semesterCode"].length - 1,
              ),
            ) !=
        0;
    if (yearNotEqual || lastNotEqual) {
      throw NotSameSemesterException(
        msg:
            "Not the same semester. This semester: $semesterCode. "
            "Input source: ${data["classtable"]["semesterCode"]}."
            "This partner classtable is going to be deleted.",
      );
    }
    return (
      data["name"] ?? "Sweetie",
      ClassTableData.fromJson(data["classtable"]),
      List.generate(
        data["exam"].length,
        (i) => Subject.fromJson(data["exam"][i]),
      ),
      List.generate(
        data["experiment"].length,
        (i) => ExperimentData.fromJson(data["experiment"][i]),
      ),
      true,
    );
  }

  /// Update partner class info
  void updatePartnerClass() {
    var file = File("${supportPath.path}/${ClassTableFile.partnerClassName}");
    if (!file.existsSync()) throw Exception("File not found.");
    final data = decodePartnerClass(file.readAsStringSync());
    partnerName = data.$1;
    partnerClass = data.$2;
    partnerSubjects = data.$3;
    partnerExperiment = data.$4;

    notifyListeners();
  }

  /// Delete partner class info
  void deletePartnerClass() {
    var file = File("${supportPath.path}/${ClassTableFile.partnerClassName}");
    if (!file.existsSync()) {
      throw Exception("File not found.");
    }
    file.deleteSync();
    partnerClass = null;
    partnerSubjects = null;
    partnerExperiment = null;
    notifyListeners();
  }

  List<Event> get events {
    List<Event> events = [];

    // UTC+8 timezone defination, hard-coded since our school is in here...
    tz.initializeTimeZones();
    Location currentLocation = getLocation("Asia/Shanghai");

    // @hgh: i here means each single course assignment
    for (var i in timeArrangement) {
      // @hgh: j here means each week for a single course assignment
      // @hgh: find the first week that has class
      int j = i.weekList.indexWhere((element) => element);

      // @benderblog: basically not happens, but if not arranged, just skip it.
      if (j == -1) continue;

      // @benderblog: rewrite, using ai generated algorithm to get the ranges of "true".
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

      // @ai: Handle the case where the array ends with a sequence of true values.
      if (start != -1) {
        ranges.add((start, j - 1));
      }

      String title =
          "${getClassDetail(timeArrangement.indexOf(i)).name}@${i.classroom ?? "待定"}";
      String description =
          "课程名称：${getClassDetail(timeArrangement.indexOf(i)).name} - 老师：${i.teacher ?? "未知"}";
      String? location = i.classroom ?? "待定";

      List<String> startTime = time[(i.start - 1) * 2].split(":");
      List<String> stopTime = time[(i.stop - 1) * 2 + 1].split(":");

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

      // @benderblog: start dealing with
      for (var range in ranges) {
        // @hgh: initialize the first day(or, first recurrence) of the class
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

    // Add exam data and experiment data here.
    for (var i in subjects) {
      String title =
          "${i.subject} ${i.typeStr}@${i.place} ${i.seat != null ? "-${i.seat}" : ""}";
      String description = "考试信息：${i.subject} - ${i.typeStr}";
      String location = "${i.place} ${i.seat != null ? "-${i.seat}" : ""}";

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

    for (var i in experiments) {
      events.add(
        Event(
          null,
          title: "${i.name}@${i.classroom}}",
          start: TZDateTime.from(i.time.first, currentLocation),
          end: TZDateTime.from(i.time.last, currentLocation),
          location: i.classroom,
        ),
      );
    }
    return events;
  }

  /// Generate icalendar file string.
  String get iCalenderStr {
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
      String vevent = "BEGIN:VEVENT\n";

      vevent +=
          "DTSTAMP:"
          "${DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now())}\n";
      vevent += "SUMMARY:${i.title ?? "待定"}\n";
      vevent += "DESCRIPTION:${i.description ?? "待定"}\n";

      /// Minus 8 hours to match the "UTC time"
      vevent +=
          "DTSTART;TZID=Asia/Shanghai:"
          "${DateFormat('yyyyMMddTHHmmss').format(DateTime.fromMicrosecondsSinceEpoch(i.start!.microsecondsSinceEpoch))}\n";
      vevent +=
          "DTEND;TZID=Asia/Shanghai:"
          "${DateFormat('yyyyMMddTHHmmss').format(DateTime.fromMicrosecondsSinceEpoch(i.end!.microsecondsSinceEpoch))}\n";
      if (i.location != null) {
        vevent += "LOCATION:${i.location}\n";
      }

      if (i.recurrenceRule != null) {
        String getWeekStr(DayOfWeek day) {
          switch (day) {
            case DayOfWeek.Monday:
              return "MO";
            case DayOfWeek.Tuesday:
              return "TU";
            case DayOfWeek.Wednesday:
              return "WE";
            case DayOfWeek.Thursday:
              return "TH";
            case DayOfWeek.Friday:
              return "FR";
            case DayOfWeek.Saturday:
              return "SA";
            case DayOfWeek.Sunday:
              return "SU";
          }
        }

        vevent +=
            "RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=${getWeekStr(i.recurrenceRule!.daysOfWeek!.first)};"
            "UNTIL=${DateFormat('yyyyMMdd').format(i.recurrenceRule!.endDate!)}\n";
      }
      toReturn += "${vevent}END:VEVENT\n";
    }

    return "${toReturn}END:VCALENDAR";
  }

  /// Output to System Calendar
  Future<bool> outputToCalendar(Future<void> Function() showDialog) async {
    // Fetch calendar permission
    final DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();
    Result<bool> hasPermitted = await deviceCalendarPlugin.hasPermissions();
    if (hasPermitted.data != true) {
      await showDialog();
      hasPermitted = await deviceCalendarPlugin.requestPermissions();
      if (hasPermitted.data != true) {
        log.info(
          "[Classtable][outputToCalendar] "
          "Gain permission failed: "
          "${hasPermitted.errors.map((e) => e.errorMessage).join(",")}",
        );
        return false;
      }
    }

    // Generate a new calendar
    (bool, String) calendarIdData = await DeviceCalendarPlugin()
        .createCalendar(
          "PDA Class Arrangement $semesterCode "
          "created at ${DateTime.now().millisecondsSinceEpoch}",
        )
        .then((data) {
          if (!data.isSuccess) {
            log.info(
              "[Classtable][outputToCalendar] "
              "Generate new calendar failed: "
              "${hasPermitted.errors.map((e) => e.errorMessage).join(",")}",
            );
            return (false, "");
          } else {
            return (true, data.data!);
          }
        });

    if (!calendarIdData.$1) {
      return false;
    }
    String calendarId = calendarIdData.$2;

    for (var i in events) {
      var toPush = i..calendarId = calendarId;
      Result<String>? addEventResult = await deviceCalendarPlugin
          .createOrUpdateEvent(toPush);
      // If got error, return with false.
      if (addEventResult == null ||
          addEventResult.data == null ||
          addEventResult.data!.isEmpty) {
        log.info(
          "[Classtable][outputToCalendar] "
          "Add failed: "
          "${hasPermitted.errors.map((e) => e.errorMessage).join(",")}",
        );
        return false;
      }
    }

    return true;
  }

  /// Generate shared class data.
  /// Elliot Ray Classtable (Format)
  String ercStr(String name) => jsonEncode({
    "name": name,
    "classtable": classTableController.classTableData,
    "exam": examController.data.subject,
    "experiment": experimentController.data,
  });

  /// Update classtable infos
  Future<void> updateClasstable(BuildContext context) async {
    log.info("Updating time arrangement data...");
    return await Future.wait([
      classTableController.updateClassTable(isForce: true),
      examController.get(),
      experimentController.get(),
    ]).then((value) => value.first);
  }

  ClassTableWidgetState({required this.currentWeek, this.partnerClass}) {
    if (currentWeek < 0) {
      _chosenWeek = 0;
    } else if (currentWeek >= semesterLength) {
      _chosenWeek = semesterLength - 1;
    } else {
      _chosenWeek = currentWeek;
    }
    try {
      updatePartnerClass();
    } on NotSameSemesterException {
      deletePartnerClass();
    } on Exception {
      log.info("No partner classtable present...");
    }
  }

  bool _checkIsOverlapping(
    double eStart1,
    double eEnd1,
    double eStart2,
    double eEnd2,
  ) =>
      (eStart1 >= eStart2 && eStart1 < eEnd2) ||
      (eEnd1 > eStart2 && eEnd1 <= eEnd2) ||
      (eStart2 >= eStart1 && eStart2 < eEnd1) ||
      (eEnd2 > eStart1 && eEnd2 <= eEnd1);

  /// [weekIndex] start from 0 while [dayIndex] start from 1
  List<ClassOrgainzedData> getArrangement({
    required int weekIndex,
    required int dayIndex,
  }) {
    /// Fetch all class in this range.
    List<ClassOrgainzedData> events = [];

    for (final i in timeArrangement) {
      if (i.weekList.length > weekIndex &&
          i.weekList[weekIndex] &&
          i.day == dayIndex) {
        events.add(
          ClassOrgainzedData.fromTimeArrangement(
            i,
            colorList[i.index % colorList.length],
            getClassDetail(timeArrangement.indexOf(i)).name,
          ),
        );
      }
    }

    for (final i in subjects) {
      if (i.startTime == null ||
          i.stopTime == null ||
          i.startTime!.isBefore(startDay)) {
        continue;
      }

      int diff = i.startTime!.difference(startDay).inDays;

      if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
        events.add(
          ClassOrgainzedData.fromSubject(
            colorList[subjects.indexOf(i) % colorList.length],
            i,
          ),
        );
      }
    }

    for (final i in experiments) {
      int diff = i.time[0].difference(startDay).inDays;

      if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
        events.add(
          ClassOrgainzedData.fromExperiment(
            colorList[experiments.indexOf(i) % colorList.length],
            i,
          ),
        );
      }
    }

    /// Sort it with the ascending order of start time.
    events.sort((a, b) => a.start.compareTo(b.start));

    /// The arrangement to use
    List<ClassOrgainzedData> arrangedEvents = [];

    for (final event in events) {
      final startTime = event.start;
      final endTime = event.stop;

      var eventIndex = -1;
      final arrangeEventLen = arrangedEvents.length;

      for (var i = 0; i < arrangeEventLen; i++) {
        final arrangedEventStart = arrangedEvents[i].start;
        final arrangedEventEnd = arrangedEvents[i].stop;

        if (_checkIsOverlapping(
          arrangedEventStart,
          arrangedEventEnd,
          startTime,
          endTime,
        )) {
          eventIndex = i;
          break;
        }
      }

      if (eventIndex == -1) {
        arrangedEvents.add(event);
      } else {
        final arrangedEventData = arrangedEvents[eventIndex];

        final arrangedEventStart = arrangedEventData.start;
        final arrangedEventEnd = arrangedEventData.stop;

        final startDuration = math.min(startTime, arrangedEventStart);
        final endDuration = math.max(endTime, arrangedEventEnd);

        bool shouldNew =
            (event.stop - event.start) >=
            (arrangedEventData.stop - arrangedEventData.start);

        final top = startDuration;
        // TODO: check whether it is good.
        final bottom = endDuration;

        final newEvent = ClassOrgainzedData(
          start: top,
          stop: bottom,
          data: [...arrangedEventData.data, ...event.data],
          color: shouldNew ? event.color : arrangedEventData.color,
          name: shouldNew ? event.name : arrangedEventData.name,
          place: shouldNew ? event.place : arrangedEventData.place,
        );

        arrangedEvents[eventIndex] = newEvent;
      }
    }

    return arrangedEvents;
  }
}
