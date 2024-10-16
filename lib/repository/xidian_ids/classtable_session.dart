// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The class table window source.
// Thanks xidian-script and libxdauth!

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 课程表 4770397878132218
class ClassTableFile extends EhallSession {
  static const schoolClassName = "ClassTable.json";
  static const userDefinedClassName = "UserClass.json";
  static const partnerClassName = "darling.erc.json";

  ClassTableData simplifyData(Map<String, dynamic> qResult) {
    ClassTableData toReturn = ClassTableData();

    toReturn.semesterCode = qResult["semesterCode"];
    toReturn.termStartDay = qResult["termStartDay"];

    log.info(
      "[getClasstable][simplifyData] "
      "${toReturn.semesterCode} ${toReturn.termStartDay}",
    );

    for (var i in qResult["rows"]) {
      var toDeal = ClassDetail(
        name: i["KCM"],
        code: i["KCH"],
        number: i["KXH"],
      );
      if (!toReturn.classDetail.contains(toDeal)) {
        toReturn.classDetail.add(toDeal);
      }
      toReturn.timeArrangement.add(
        TimeArrangement(
          source: Source.school,
          index: toReturn.classDetail.indexOf(toDeal),
          start: int.parse(i["KSJC"]),
          teacher: i["SKJS"],
          stop: int.parse(i["JSJC"]),
          day: int.parse(i["SKXQ"]),
          weekList: List<bool>.generate(
            i["SKZC"].toString().length,
            (index) => i["SKZC"].toString()[index] == "1",
          ),
          classroom: i["JASMC"],
        ),
      );
      if (i["SKZC"].toString().length > toReturn.semesterLength) {
        toReturn.semesterLength = i["SKZC"].toString().length;
      }
    }

    // Deal with the not arranged data.
    for (var i in qResult["notArranged"]) {
      toReturn.notArranged.add(NotArrangementClassDetail(
        name: i["KCM"],
        code: i["KCH"],
        number: i["KXH"],
        teacher: i["SKJS"],
      ));
    }

    return toReturn;
  }

  Future<ClassTableData> getYjspt() async {
    Map<String, dynamic> qResult = {};

    const semesterCodeURL =
        "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/kfdxnxqcx.do";
    const classInfoURL =
        "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/xspkjgcx.do";
    const notArrangedInfoURL =
        "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/xswsckbkc.do";

    log.info("[getClasstable][getYjspt] Login the system.");
    String? location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp/"
          "sys/wdkbapp/*default/index.do#/xskcb",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    while (location != null) {
      var response = await dio.get(location);
      log.info("[getClasstable][getYjspt] Received location: $location.");
      location = response.headers[HttpHeaders.locationHeader]?[0];
    }

    /// AKA xnxqdm as [startyear][period] eg 20242 as
    var semesterCode = await dio
        .post(semesterCodeURL)
        .then((value) => value.data["datas"]["kfdxnxqcx"]["rows"][0]["WID"]);

    DateTime now = DateTime.now();
    var currentWeek = await dio.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/queryRcap.do',
      data: {'day': Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")},
    ).then((value) => value.data);
    currentWeek = RegExp(r'[0-9]+').firstMatch(currentWeek["xnxq"])![0]!;
    log.info(
      "[getClasstable][getYjspt] Current week is $currentWeek, fetching...",
    );
    int weekDay = now.weekday - 1;
    String termStartDay = Jiffy.parseFromDateTime(now)
        .add(weeks: 1 - int.parse(currentWeek), days: -weekDay)
        .format(pattern: "yyyy-MM-dd");

    Map<String, dynamic> data = await dio.post(classInfoURL, data: {
      "XNXQDM": semesterCode,
    }).then((response) => response.data);

    if (data['code'] != "0") {
      log.warning(
        "[getClasstable][getEhall] "
        "extParams: ${data['extParams']['msg']} isNotPublish: "
        "${data['extParams']['msg'].toString().contains("查询学年学期的课程未发布")}",
      );
      if (data['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
        log.warning(
          "[getClasstable][getEhall] "
          "extParams: ${data['extParams']['msg']} isNotPublish: "
          "Classtable not released.",
        );
        return ClassTableData(
          semesterCode: semesterCode,
          termStartDay: termStartDay, // indicate no class occured...
        );
      } else {
        throw Exception("${data['extParams']['msg']}");
      }
    }

    qResult["rows"] = data["datas"]["xspkjgcx"]["rows"];

    var notOnTable = await dio.post(
      notArrangedInfoURL,
      data: {
        'XNXQDM': semesterCode,
        'XH': preference.getString(preference.Preference.idsAccount),
      },
    ).then((value) => value.data['datas']['xswsckbkc']);
    qResult["notArranged"] = notOnTable["rows"];

    ClassTableData toReturn = ClassTableData();
    toReturn.semesterCode = semesterCode;
    toReturn.termStartDay = termStartDay;

    log.info(
      "[getClasstable][getYjspt] "
      "${toReturn.semesterCode} ${toReturn.termStartDay}",
    );

    for (var i in qResult["rows"]) {
      var toDeal = ClassDetail(
        name: i["KCMC"],
        code: i["KCDM"],
      );
      if (!toReturn.classDetail.contains(toDeal)) {
        toReturn.classDetail.add(toDeal);
      }

      toReturn.timeArrangement.add(
        TimeArrangement(
          source: Source.school,
          index: toReturn.classDetail.indexOf(toDeal),
          start: i["KSJCDM"],
          teacher: i["JSXM"],
          stop: i["JSJCDM"],
          day: int.parse(i["XQ"].toString()),
          weekList: List<bool>.generate(
            i["ZCBH"].toString().length,
            (index) => i["ZCBH"].toString()[index] == "1",
          ),
          classroom: i["JASMC"],
        ),
      );

      if (i["ZCBH"].toString().length > toReturn.semesterLength) {
        toReturn.semesterLength = i["ZCBH"].toString().length;
      }
    }

    // Post deal here
    List<TimeArrangement> newStuff = [];
    int getCourseId(TimeArrangement i) =>
        "${i.weekList}-${i.day}-${i.classroom}".hashCode;

    for (var i = 0; i < toReturn.classDetail.length; ++i) {
      List<TimeArrangement> data =
          List<TimeArrangement>.from(toReturn.timeArrangement)
            ..removeWhere((item) => item.index != i);
      List<int> entries = [];
      //Map<int, List<TimeArrangement>> toAdd = {};

      for (var j in data) {
        int id = getCourseId(j);
        if (!entries.any((k) => k == id)) entries.add(id);
      }

      for (var j in entries) {
        List<TimeArrangement> result = List<TimeArrangement>.from(data)
          ..removeWhere((item) => getCourseId(item) != j)
          ..sort((a, b) => a.start - b.start);

        List<int> arrangements = {
          for (var i in result) ...[i.start, i.stop]
        }.toList()
          ..sort();

        /// May be bug here, since I do not secure that
        /// [arrangements] is continus, may like [1,2,4,5]...
        newStuff.add(TimeArrangement(
          source: Source.school,
          index: i,
          classroom: result.first.classroom,
          teacher: result.first.teacher,
          weekList: result.first.weekList,
          day: result.first.day,
          start: arrangements.first,
          stop: arrangements.last,
        ));
      }
    }
    toReturn.timeArrangement = newStuff;

    for (var i in qResult["notArranged"]) {
      toReturn.notArranged.add(NotArrangementClassDetail(
        name: i["KCMC"],
        code: i["KCDM"],
      ));
    }

    return toReturn;
  }

  Future<ClassTableData> getEhall() async {
    Map<String, dynamic> qResult = {};
    log.info("[getClasstable][getEhall] Login the system.");
    String get = await useApp("4770397878132218");
    log.info("[getClasstable][getEhall] Location: $get");
    await dioEhall.post(get);

    log.info(
      "[getClasstable][getEhall] "
      "Fetch the semester information.",
    );
    String semesterCode = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
        )
        .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    if (preference.getString(preference.Preference.currentSemester) !=
        semesterCode) {
      preference.setString(
        preference.Preference.currentSemester,
        semesterCode,
      );
    }

    log.info(
      "[getClasstable][getEhall] "
      "Fetch the day the semester begin.",
    );
    String termStartDay = await dioEhall.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
    ).then((value) => value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);
    if (preference.getString(preference.Preference.currentStartDay) !=
        termStartDay) {
      preference.setString(
        preference.Preference.currentStartDay,
        termStartDay,
      );

      /// New semenster, user defined class is useless.
      var userClassFile = File("${supportPath.path}/$userDefinedClassName");
      if (userClassFile.existsSync()) userClassFile.deleteSync();
    }
    log.info(
      "[getClasstable][getEhall] "
      "Will get $semesterCode which start at $termStartDay.",
    );

    qResult = await dioEhall.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {
        'XNXQDM': semesterCode,
        'XH': preference.getString(preference.Preference.idsAccount),
      },
    ).then((value) => value.data['datas']['xskcb']);
    if (qResult['extParams']['code'] != 1) {
      log.warning(
        "[getClasstable][getEhall] "
        "extParams: ${qResult['extParams']['msg']} isNotPublish: "
        "${qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")}",
      );
      if (qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
        log.warning(
          "[getClasstable][getEhall] "
          "extParams: ${qResult['extParams']['msg']} isNotPublish: "
          "Classtable not released.",
        );
        return ClassTableData(
          semesterCode: semesterCode,
          termStartDay: termStartDay,
        );
      } else {
        throw Exception("${qResult['extParams']['msg']}");
      }
    }

    log.info(
      "[getClasstable][getEhall] "
      "Preliminary storage...",
    );
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;

    var notOnTable = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {
        'XNXQDM': semesterCode,
        'XH': preference.getString(preference.Preference.idsAccount),
      },
    ).then((value) => value.data['datas']['cxxsllsywpk']);

    log.info(
      "[getClasstable][getEhall] $notOnTable",
    );
    qResult["notArranged"] = notOnTable["rows"];

    ClassTableData preliminaryData = simplifyData(qResult);

    /// Deal with the class change.
    log.info(
      "[getClasstable][getEhall] "
      "Deal with the class change...",
    );

    qResult = await dioEhall.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xsdkkc.do',
      data: {
        'XNXQDM': semesterCode,
        //'SKZC': "6",
        '*order': "-SQSJ",
      },
    ).then((value) => value.data['datas']['xsdkkc']);
    if (qResult['extParams']['code'] != 1) {
      log.warning(
        "[getClasstable][getEhall] ${qResult['extParams']['msg']}",
      );
    }

    // ignore: non_constant_identifier_names
    ChangeType type(String TKLXDM) {
      if (TKLXDM == '01') {
        return ChangeType.change; //调课
      } else if (TKLXDM == '02') {
        return ChangeType.stop; //停课
      } else {
        return ChangeType.patch; //补课
      }
    }

    // Merge change info

    if (int.parse(qResult["totalSize"].toString()) > 0) {
      for (var i in qResult["rows"]) {
        preliminaryData.classChanges.add(
          ClassChange(
            type: type(i["TKLXDM"]),
            classCode: i["KCH"],
            classNumber: i["KXH"],
            className: i["KCM"],
            originalAffectedWeeks: i["SKZC"] == null
                ? null
                : List<bool>.generate(
                    i["SKZC"].toString().length,
                    (index) => i["SKZC"].toString()[index] == "1",
                  ),
            newAffectedWeeks: i["XSKZC"] == null
                ? null
                : List<bool>.generate(
                    i["XSKZC"].toString().length,
                    (index) => i["XSKZC"].toString()[index] == "1",
                  ),
            originalTeacherData: i["YSKJS"],
            newTeacherData: i["XSKJS"],
            originalClassRange: [
              int.parse(i["KSJC"]?.toString() ?? "-1"),
              int.parse(i["JSJC"]?.toString() ?? "-1"),
            ],
            newClassRange: [
              int.parse(i["XKSJC"]?.toString() ?? "-1"),
              int.parse(i["XJSJC"]?.toString() ?? "-1"),
            ],
            originalWeek: i["SKXQ"],
            newWeek: i["XSKXQ"],
            originalClassroom: i["JASMC"],
            newClassroom: i["XJASMC"],
          ),
        );
      }
    }

    log.info(
      "[getClasstable][getEhall] "
      "Dealing class change with ${preliminaryData.classChanges.length} info(s).",
    );

    List<ClassChange> cache = [];

    for (var e in preliminaryData.classChanges) {
      /// First, search for the classes.
      /// Due to the unstability of the api, a list is introduced.
      List<int> indexClassDetailList = [];
      for (int i = 0; i < preliminaryData.classDetail.length; ++i) {
        if (preliminaryData.classDetail[i].code == e.classCode) {
          indexClassDetailList.add(i);
        }
      }

      /// Second, find the all time arrangement related to the class.
      log.info(
        "[getClasstable][getEhall] "
        "Class change related to class detail index $indexClassDetailList.",
      );
      List<int> indexOriginalTimeArrangementList = [];
      for (var currentClassIndex in indexClassDetailList) {
        for (int i = 0; i < preliminaryData.timeArrangement.length; ++i) {
          if (preliminaryData.timeArrangement[i].index == currentClassIndex &&
              preliminaryData.timeArrangement[i].day == e.originalWeek &&
              preliminaryData.timeArrangement[i].start ==
                  e.originalClassRange[0] &&
              preliminaryData.timeArrangement[i].stop ==
                  e.originalClassRange[1]) {
            indexOriginalTimeArrangementList.add(i);
          }
        }
      }

      /// Third, search for the time arrangements, seek for the truth.
      log.info(
        "[getClasstable][getEhall] "
        "Class change related to time arrangement index $indexOriginalTimeArrangementList.",
      );

      if (e.type == ChangeType.change) {
        /// Give a value to the
        int timeArrangementIndex = indexOriginalTimeArrangementList.first;

        log.info(
          "[getClasstable][getEhall] "
          "Class change. Teacher changed? ${e.isTeacherChanged}. timeArrangementIndex is $timeArrangementIndex",
        );
        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          /// Seek for the change entry. Delete the classes moved waay.
          log.info(
            "[getClasstable][getEhall] "
            "Original weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
          );
          for (int i in e.originalAffectedWeeksList) {
            log.info(
              "[getClasstable][getEhall] "
              "Week $i, status ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i]}.",
            );
            if (preliminaryData
                .timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
              preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                  .weekList[i] = false;
              timeArrangementIndex = preliminaryData
                  .timeArrangement[indexOriginalTimeArrangement].index;
            }
          }

          log.info(
            "[getClasstable][getEhall] "
            "New weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}.",
          );
        }

        if (timeArrangementIndex == indexOriginalTimeArrangementList.first) {
          cache.add(e);
          timeArrangementIndex = preliminaryData
              .timeArrangement[indexOriginalTimeArrangementList.first].index;
        }

        log.info(
          "[getClasstable][getEhall] "
          "New week: ${e.newAffectedWeeks}, "
          "day: ${e.newWeek}, "
          "startToStop: ${e.newClassRange}, "
          "timeArrangementIndex: $timeArrangementIndex.",
        );

        bool flag = false;
        ClassChange? toRemove;
        log.info("[getClasstable][getEhall] cache length = ${cache.length}");
        for (var f in cache) {
          //log.info("[getClasstable][getFromWeb]"
          //    "${f.className} ${f.classCode} ${f.originalClassRange} ${f.originalAffectedWeeksList} ${f.originalWeek}");
          //log.info("[getClasstable][getFromWeb]"
          //    "${e.className} ${e.classCode} ${e.newClassRange} ${e.newAffectedWeeksList} ${e.newWeek}");
          //log.info("[getClasstable][getFromWeb]"
          //    "${f.className == e.className} ${f.classCode == e.classCode} ${listEquals(f.originalClassRange, e.newClassRange)} ${listEquals(f.originalAffectedWeeksList, e.newAffectedWeeksList)} ${f.originalWeek == e.newWeek}");
          if (f.className == e.className &&
              f.classCode == e.classCode &&
              listEquals(f.originalClassRange, e.newClassRange) &&
              listEquals(f.originalAffectedWeeksList, e.newAffectedWeeksList) &&
              f.originalWeek == e.newWeek) {
            flag = true;
            toRemove = f;
            break;
          }
        }

        if (flag) {
          cache.remove(toRemove);
          log.info(
            "[getClasstable][getEhall] "
            "Cannot be added",
          );
          continue;
        }

        log.info(
          "[getClasstable][getEhall] "
          "Can be added",
        );

        /// Add classes.
        preliminaryData.timeArrangement.add(
          TimeArrangement(
            source: Source.school,
            index: timeArrangementIndex,
            weekList: e.newAffectedWeeks!,
            day: e.newWeek!,
            start: e.newClassRange[0],
            stop: e.newClassRange[1],
            classroom: e.newClassroom ?? e.originalClassroom,
            teacher: e.isTeacherChanged ? e.newTeacher : e.originalTeacher,
          ),
        );
      } else if (e.type == ChangeType.patch) {
        log.info(
          "[getClasstable][getEhall] "
          "Class patch.",
        );

        /// Add classes.
        preliminaryData.timeArrangement.add(
          TimeArrangement(
            source: Source.school,
            index: indexClassDetailList.first,
            weekList: e.newAffectedWeeks!,
            day: e.newWeek!,
            start: e.newClassRange[0],
            stop: e.newClassRange[1],
            classroom: e.newClassroom ?? e.originalClassroom,
            teacher: e.isTeacherChanged ? e.newTeacher : e.originalTeacher,
          ),
        );
      } else {
        log.info(
          "[getClasstable][getEhall] "
          "Class stop.",
        );

        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          log.info(
            "[getClasstable][getEhall] "
            "Original weeklist "
            "${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
          );
          for (int i in e.originalAffectedWeeksList) {
            log.info(
              "[getClasstable][getEhall] "
              "$i ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i]}",
            );
            if (preliminaryData
                .timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
              preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                  .weekList[i] = false;
            }
          }
          log.info(
            "[getClasstable][getEhall] "
            "New weeklist "
            "${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}.",
          );
        }
      }
    }

    return preliminaryData;
  }
}

class NotSameSemesterException implements Exception {
  final String msg;
  NotSameSemesterException({required this.msg});
}
