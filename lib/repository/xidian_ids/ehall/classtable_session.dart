// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The class table window source.
// Thanks xidian-script and libxdauth!

import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall/ehall_session.dart';

/// 课程表 4770397878132218
class ClassTableFile extends EhallSession {
  ClassTableData simplifyData(Map<String, dynamic> qResult) {
    ClassTableData toReturn = ClassTableData();

    toReturn.semesterCode = qResult["semesterCode"];
    toReturn.termStartDay = qResult["termStartDay"];

    developer.log("${toReturn.semesterCode} ${toReturn.termStartDay}",
        name: "Ehall getClasstable");

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
          index: toReturn.classDetail.indexOf(toDeal),
          start: int.parse(i["KSJC"]),
          teacher: i["SKJS"],
          stop: int.parse(i["JSJC"]),
          day: int.parse(i["SKXQ"]),
          weekList: i["SKZC"].toString(),
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

  Future<ClassTableData> getFromWeb() async {
    Map<String, dynamic> qResult = {};
    developer.log("Login the system.", name: "Ehall getClasstable");
    String get = await useApp("4770397878132218");
    await dio.post(get);

    developer.log("Fetch the semester information.",
        name: "Ehall getClasstable");
    String semesterCode = await dio
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

    developer.log("Fetch the day the semester begin.",
        name: "Ehall getClasstable");
    String termStartDay = await dio.post(
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
    }
    developer.log(
        "Will get $semesterCode which start at $termStartDay, fetching...",
        name: "Ehall getClasstable");

    qResult = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['xskcb']);
    if (qResult['extParams']['code'] != 1) {
      developer.log(qResult['extParams']['msg'], name: "Ehall getClasstable");
      developer.log(
        " ${qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")}",
        name: "Ehall getClasstable",
      );
      if (qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
        developer.log("Classtable not released.", name: "Ehall getClasstable");
        return ClassTableData(
          semesterCode: semesterCode,
          termStartDay: termStartDay,
        );
      } else {
        throw Exception("${qResult['extParams']['msg']}");
      }
    }

    developer.log("Preliminary storage...", name: "Ehall getClasstable");
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;

    var notOnTable = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['cxxsllsywpk']);

    developer.log(notOnTable.toString(), name: "Ehall getClasstable");
    qResult["notArranged"] = notOnTable["rows"];

    ClassTableData preliminaryData = simplifyData(qResult);

    /// Deal with the class change.
    developer.log("Deal with the class change...", name: "Ehall getClasstable");

    qResult = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xsdkkc.do',
      data: {
        'XNXQDM': semesterCode,
        //'SKZC': "6",
        '*order': "-SQSJ",
      },
    ).then((value) => value.data['datas']['xsdkkc']);
    if (qResult['extParams']['code'] != 1) {
      developer.log(qResult['extParams']['msg'], name: "Ehall getClasstable");
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

    if (int.parse(qResult["totalSize"].toString()) > 0) {
      for (var i in qResult["rows"]) {
        preliminaryData.classChanges.add(
          ClassChange(
            type: type(i["TKLXDM"]),
            classCode: i["KCH"],
            classNumber: i["KXH"],
            className: i["KCM"],
            originalAffectedWeeks: i["SKZC"],
            newAffectedWeeks: i["XSKZC"],
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

    developer.log(
      "Dealing class change with ${preliminaryData.classChanges.length} info(s).",
      name: "Ehall getClasstable",
    );

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
      developer.log(
        "Class change related to class detail index $indexClassDetailList.",
        name: "Ehall getClasstable",
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

      /// Give a value to the
      int timeArrangementIndex = indexOriginalTimeArrangementList.first;

      /// Third, search for the time arrangements, seek for the truth.
      developer.log(
        "Class change related to time arrangement index $indexOriginalTimeArrangementList",
        name: "Ehall getClasstable",
      );

      if (e.type == ChangeType.change) {
        developer.log(
          "Class change.",
          name: "Ehall getClasstable",
        );
        developer.log(
          "Teacher changed? ${e.isTeacherChanged}.",
          name: "Ehall getClasstable",
        );
        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          /// Seek for the change entry. Delete the classes moved away.
          developer.log(
            "Original weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
            name: "Ehall getClasstable",
          );
          for (int i in e.originalAffectedWeeksList) {
            developer.log(
              "$i ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i] == '1'}",
              name: "Ehall getClasstable",
            );
            if (preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                    .weekList[i] ==
                '1') {
              preliminaryData
                      .timeArrangement[indexOriginalTimeArrangement].weekList =
                  preliminaryData
                      .timeArrangement[indexOriginalTimeArrangement].weekList
                      .replaceRange(i, i + 1, '0');
              timeArrangementIndex = preliminaryData
                  .timeArrangement[indexOriginalTimeArrangement].index;
            }
          }
          developer.log(
            "New weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}. ",
            name: "Ehall getClasstable",
          );
        }

        developer.log(
          "New week: ${e.newAffectedWeeks} day: ${e.newWeek} startToStop: ${e.newClassRange} timeArrangementIndex: $timeArrangementIndex.",
          name: "Ehall getClasstable",
        );

        /// Add classes.
        preliminaryData.timeArrangement.add(
          TimeArrangement(
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
        developer.log(
          "Class patch.",
          name: "Ehall getClasstable",
        );

        /// Add classes.
        preliminaryData.timeArrangement.add(
          TimeArrangement(
            index: timeArrangementIndex,
            weekList: e.newAffectedWeeks!,
            day: e.newWeek!,
            start: e.newClassRange[0],
            stop: e.newClassRange[1],
            classroom: e.newClassroom ?? e.originalClassroom,
            teacher: e.isTeacherChanged ? e.newTeacher : e.originalTeacher,
          ),
        );
      } else {
        developer.log(
          "Class stop.",
          name: "Ehall getClasstable",
        );

        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          developer.log(
            "Original weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
            name: "Ehall getClasstable",
          );
          for (int i in e.originalAffectedWeeksList) {
            developer.log(
              "$i ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i] == '1'}",
              name: "Ehall getClasstable",
            );
            if (preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                    .weekList[i] ==
                '1') {
              preliminaryData
                      .timeArrangement[indexOriginalTimeArrangement].weekList =
                  preliminaryData
                      .timeArrangement[indexOriginalTimeArrangement].weekList
                      .replaceRange(i, i + 1, '0');
            }
          }
          developer.log(
            "New weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}.",
            name: "Ehall getClasstable",
          );
        }
      }
    }

    return preliminaryData;
  }

  Future<ClassTableData> get({
    bool isForce = false,
  }) async {
    developer.log("Check whether the classtable has fetched.",
        name: "Ehall getClasstable");

    developer.log("Start fetching the classtable.",
        name: "Ehall getClasstable");
    Directory appDocDir = await getApplicationSupportDirectory();
    if (!await appDocDir.exists()) {
      await appDocDir.create();
    }
    developer.log("Path at ${appDocDir.path}.", name: "Ehall getClasstable");
    var file = File("${appDocDir.path}/ClassTable.json");
    bool isExist = file.existsSync();
    developer.log("File exist: $isExist.", name: "Ehall getClasstable");

    developer.log(
        isExist &&
                isForce == false &&
                DateTime.now().difference(file.lastModifiedSync()).inDays <= 3
            ? "Cache"
            : "Fetch from internet.",
        name: "Ehall getClasstable");

    if (isExist &&
        isForce == false &&
        DateTime.now().difference(file.lastModifiedSync()).inDays <= 2) {
      return ClassTableData.fromJson(jsonDecode(file.readAsStringSync()));
    } else {
      try {
        var toUse = await getFromWeb();
        file.writeAsStringSync(jsonEncode(toUse.toJson()));
        return toUse;
      } catch (e) {
        if (isExist) {
          return ClassTableData.fromJson(jsonDecode(file.readAsStringSync()));
        } else {
          rethrow;
        }
      }
    }
  }
}
