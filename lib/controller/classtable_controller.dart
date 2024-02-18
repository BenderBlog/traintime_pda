// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';

enum ClassTableState {
  fetching,
  fetched,
  error,
  none,
}

class ClassTableController extends GetxController {
  // Classtable state
  String? error;
  ClassTableState state = ClassTableState.none;

  // Classtable Data
  late File classTableFile;
  late File userDefinedFile;
  late ClassTableData classTableData;
  late UserDefinedClassData userDefinedClassData;

  // The start day of the semester.
  DateTime startDay = DateTime.parse("2022-01-22");

  // Get ClassDetail name info
  ClassDetail getClassDetail(TimeArrangement timeArrangementIndex) =>
      classTableData.getClassDetail(timeArrangementIndex);

  bool isTomorrow(DateTime updateTime) =>
      updateTime.hour * 60 + updateTime.minute > 21 * 60 + 25;

  int getCurrentWeek(DateTime now) {
    // Get the current index.
    int delta = Jiffy.parseFromDateTime(now)
        .diff(Jiffy.parseFromDateTime(startDay), unit: Unit.day)
        .toInt();
    if (delta < 0) delta = -7;
    return delta ~/ 7;
  }

  /// Get all of [timeToQuery]'s arrangement in classtable
  List<HomeArrangement> getArrangementOfDay(DateTime timeToQuery) {
    Jiffy updateTime = Jiffy.parseFromDateTime(timeToQuery);
    int currentWeek = getCurrentWeek(timeToQuery);
    Set<HomeArrangement> getArrangement = {};
    if (currentWeek >= 0 && currentWeek < classTableData.semesterLength) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > currentWeek &&
            i.weekList[currentWeek] &&
            i.day == updateTime.dateTime.weekday) {
          getArrangement.add(HomeArrangement(
            name: getClassDetail(i).name,
            teacher: i.teacher ?? "未知",
            place: i.classroom ?? "未知",
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.start - 1) * 2].split(':')[0]),
              int.parse(time[(i.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          ));
        }
      }
    }

    return getArrangement.toList();
  }

  @override
  void onInit() {
    super.onInit();
    log.i(
      "[ClassTableController][onInit] "
      "Init classtable file.",
    );
    classTableFile = File(
      "${supportPath.path}/${ClassTableFile.schoolClassName}",
    );
    bool classTableFileisExist = classTableFile.existsSync();
    if (classTableFileisExist) {
      log.i(
        "[ClassTableController][onInit] "
        "Init from cache.",
      );
      classTableData = ClassTableData.fromJson(jsonDecode(
        classTableFile.readAsStringSync(),
      ));
      state = ClassTableState.fetched;
    } else {
      log.i(
        "[ClassTableController][onInit] "
        "Init from empty.",
      );
      classTableData = ClassTableData();
    }

    log.i(
      "[ClassTableController][onInit] "
      "Init user defined file.",
    );
    userDefinedFile = File(
      "${supportPath.path}/${ClassTableFile.userDefinedClassName}",
    );
    bool userDefinedFileIsExist = userDefinedFile.existsSync();
    if (!userDefinedFileIsExist) {
      userDefinedFile.writeAsStringSync(
        jsonEncode(UserDefinedClassData.empty()),
      );
    }
    userDefinedClassData = UserDefinedClassData.fromJson(
      jsonDecode(userDefinedFile.readAsStringSync()),
    );
  }

  @override
  void onReady() async {
    await updateClassTable();
  }

  /// TODO: Write update user defined data function...

  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) async {
    userDefinedClassData.userDefinedDetail.add(classDetail);
    timeArrangement.index = userDefinedClassData.userDefinedDetail.length - 1;
    userDefinedClassData.timeArrangement.add(timeArrangement);
    userDefinedFile.writeAsStringSync(jsonEncode(
      userDefinedClassData.toJson(),
    ));
    await updateClassTable(isUserDefinedChanged: true);
  }

  Future<void> deleteUserDefinedClass(
    TimeArrangement timeArrangement,
  ) async {
    if (timeArrangement.source != Source.user) return;
    userDefinedClassData.timeArrangement.remove(timeArrangement);
    userDefinedClassData.userDefinedDetail.removeAt(timeArrangement.index);
    userDefinedFile.writeAsStringSync(jsonEncode(
      userDefinedClassData.toJson(),
    ));
    await updateClassTable(isUserDefinedChanged: true);
  }

  void updateCurrent() {
    if (state != ClassTableState.fetched) return;

    /// Get the start day of the semester. Append offset
    startDay = DateTime.parse(classTableData.termStartDay).add(
        Duration(days: 7 * preference.getInt(preference.Preference.swift)));

    log.i(
      "[ClassTableController][addUserDefinedClass] "
      "startDay: $startDay.",
    );

    update();
  }

  Future<void> updateClassTable({
    bool isForce = false,
    bool isUserDefinedChanged = false,
  }) async {
    state = ClassTableState.fetching;
    error = null;
    try {
      log.i(
        "[ClassTableController][updateClassTable] "
        "Start fetching the classtable.",
      );

      bool classTableFileIsExist = classTableFile.existsSync();
      bool isNotNeedRefreshCache = classTableFileIsExist &&
          !isForce &&
          DateTime.now().difference(classTableFile.lastModifiedSync()).inDays <=
              2;

      log.i(
        "[ClassTableController][updateClassTable]"
        "Cache file exist: $classTableFileIsExist.\n"
        "Is not need refresh cache: $isNotNeedRefreshCache\n"
        "Is user class changed: $isUserDefinedChanged",
      );

      if (isNotNeedRefreshCache || isUserDefinedChanged) {
        classTableData = ClassTableData.fromJson(jsonDecode(
          classTableFile.readAsStringSync(),
        ));
        classTableData.userDefinedDetail =
            userDefinedClassData.userDefinedDetail;
        classTableData.timeArrangement
            .addAll(userDefinedClassData.timeArrangement);
      } else {
        try {
          var toUse = await ClassTableFile().get();
          classTableFile.writeAsStringSync(jsonEncode(toUse.toJson()));
          toUse.userDefinedDetail = userDefinedClassData.userDefinedDetail;
          toUse.timeArrangement.addAll(userDefinedClassData.timeArrangement);
          classTableData = toUse;
        } catch (e, s) {
          log.w(
            "[ClassTableController][updateClassTable] "
            "Fetch error with exception.",
            error: e,
            stackTrace: s,
          );
          if (classTableFileIsExist) {
            classTableData = ClassTableData.fromJson(jsonDecode(
              classTableFile.readAsStringSync(),
            ));
            classTableData.userDefinedDetail =
                userDefinedClassData.userDefinedDetail;
            classTableData.timeArrangement
                .addAll(userDefinedClassData.timeArrangement);
          } else {
            rethrow;
          }
        }
      }

      /// If ios, store the file to groupid public place
      /// in order to refresh the widget...
      if (Platform.isIOS) {
        final api = SaveToGroupIdSwiftApi();
        try {
          bool data = await api.saveToGroupId(FileToGroupID(
            appid: preference.appId,
            fileName: "ClassTable.json",
            data: jsonEncode(classTableData.toJson()),
          ));
          log.i(
            "[ClassTableController][updateClassTable] "
            "ios ClassTable.json save to public place status: $data.",
          );
        } catch (e, s) {
          log.w(
            "[ClassTableController][updateClassTable] "
            "ios ClassTable.json save to public place failed with error: ",
            error: e,
            stackTrace: s,
          );
        }
        try {
          bool data = await api.saveToGroupId(FileToGroupID(
            appid: preference.appId,
            fileName: "WeekSwift.txt",
            data: preference.getInt(preference.Preference.swift).toString(),
          ));
          log.i(
            "[ClassTableController][updateClassTable] "
            "ios WeekSwift.txt save to public place status: $data.",
          );
        } catch (e, s) {
          log.w(
            "[ClassTableController][updateClassTable] "
            "ios WeekSwift.txt save to public place failed with error: ",
            error: e,
            stackTrace: s,
          );
        }
        HomeWidget.updateWidget(iOSName: "ClasstableWidget");
      }

      state = ClassTableState.fetched;
      updateCurrent();
      update();
    } catch (e, s) {
      log.w(
        "[ClassTableController][updateClassTable] "
        "updateClassTable failed",
        error: e,
        stackTrace: s,
      );
      state = ClassTableState.error;
      error = e.toString();
    }
  }
}
