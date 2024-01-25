// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The class table window source.
// Thanks xidian-script and libxdauth!

import 'dart:io';
import 'dart:convert';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 课程表 4770397878132218
class ClassTableFile extends EhallSession {
  static const schoolClassName = "ClassTable.json";
  static const userDefinedClassName = "UserClass.json";

  ClassTableData simplifyData(Map<String, dynamic> qResult) {
    ClassTableData toReturn = ClassTableData();

    toReturn.semesterCode = qResult["semesterCode"];
    toReturn.termStartDay = qResult["termStartDay"];

    log.i(
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

  (UserDefinedClassData, File) getUserDefinedData() {
    var file = File("${supportPath.path}/$userDefinedClassName");
    bool isExist = file.existsSync();
    log.i(
      "[getClasstable][getUserDefinedData] "
      "File exist: $isExist.",
    );

    if (!isExist) {
      file.writeAsStringSync(jsonEncode(UserDefinedClassData.empty()));
    }

    UserDefinedClassData storedData =
        UserDefinedClassData.fromJson(jsonDecode(file.readAsStringSync()));

    return (storedData, file);
  }

  /// TODO: Write update user defined data function...

  void deleteUserDefinedData(TimeArrangement t) {
    (UserDefinedClassData, File) data = getUserDefinedData();

    data.$1.timeArrangement.remove(t);
    data.$1.userDefinedDetail.removeAt(t.index);
    data.$2.writeAsStringSync(jsonEncode(data.$1.toJson()));
  }

  void saveUserDefinedData(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) {
    (UserDefinedClassData, File) data = getUserDefinedData();

    data.$1.userDefinedDetail.add(classDetail);
    timeArrangement.index = data.$1.userDefinedDetail.length - 1;
    data.$1.timeArrangement.add(timeArrangement);

    data.$2.writeAsStringSync(jsonEncode(data.$1.toJson()));
  }

  Future<ClassTableData> getFromWeb() async {
    Map<String, dynamic> qResult = {};
    log.i("[getClasstable][getFromWeb] Login the system.");
    String get = await useApp("4770397878132218");
    log.i("[getClasstable][getFromWeb] Location: $get");
    await dioEhall.post(get);

    log.i(
      "[getClasstable][getFromWeb] "
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

    log.i(
      "[getClasstable][getFromWeb] "
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
    log.i(
      "[getClasstable][getFromWeb] "
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
      log.w(
        "[getClasstable][getFromWeb] "
        "extParams: ${qResult['extParams']['msg']} isNotPublish: "
        "${qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")}",
      );
      if (qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
        log.w(
          "[getClasstable][getFromWeb] "
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

    log.i(
      "[getClasstable][getFromWeb] "
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

    log.i(
      "[getClasstable][getFromWeb] $notOnTable",
    );
    qResult["notArranged"] = notOnTable["rows"];

    ClassTableData preliminaryData = simplifyData(qResult);

    /// Deal with the class change.
    log.i(
      "[getClasstable][getFromWeb] "
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
      log.w(
        "[getClasstable][getFromWeb] ${qResult['extParams']['msg']}",
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

    log.i(
      "[getClasstable][getFromWeb] "
      "Dealing class change with ${preliminaryData.classChanges.length} info(s).",
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
      log.i(
        "[getClasstable][getFromWeb] "
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
      log.i(
        "[getClasstable][getFromWeb] "
        "Class change related to time arrangement index $indexOriginalTimeArrangementList.",
      );

      if (e.type == ChangeType.change) {
        /// Give a value to the
        int timeArrangementIndex = indexOriginalTimeArrangementList.first;

        log.i(
          "[getClasstable][getFromWeb] "
          "Class change. Teacher changed? ${e.isTeacherChanged}.",
        );
        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          /// Seek for the change entry. Delete the classes moved away.
          log.i(
            "[getClasstable][getFromWeb] "
            "Original weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
          );
          for (int i in e.originalAffectedWeeksList) {
            log.i(
              "[getClasstable][getFromWeb] "
              "$i ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i]}",
            );
            if (preliminaryData
                .timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
              preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                  .weekList[i] = false;
              timeArrangementIndex = preliminaryData
                  .timeArrangement[indexOriginalTimeArrangement].index;
            }
          }

          log.i(
            "[getClasstable][getFromWeb] "
            "New weeklist ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}.",
          );
        }

        log.i(
          "[getClasstable][getFromWeb] "
          "New week: ${e.newAffectedWeeks}, "
          "day: ${e.newWeek}, "
          "startToStop: ${e.newClassRange}, "
          "timeArrangementIndex: $timeArrangementIndex.",
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
        log.i(
          "[getClasstable][getFromWeb] "
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
        log.i(
          "[getClasstable][getFromWeb] "
          "Class stop.",
        );

        for (int indexOriginalTimeArrangement
            in indexOriginalTimeArrangementList) {
          log.i(
            "[getClasstable][getFromWeb] "
            "Original weeklist "
            "${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList} "
            "with originalAffectedWeeksList ${e.originalAffectedWeeksList}.",
          );
          for (int i in e.originalAffectedWeeksList) {
            log.i(
              "[getClasstable][getFromWeb] "
              "$i ${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList[i]}",
            );
            if (preliminaryData
                .timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
              preliminaryData.timeArrangement[indexOriginalTimeArrangement]
                  .weekList[i] = false;
            }
          }
          log.i(
            "[getClasstable][getFromWeb] "
            "New weeklist "
            "${preliminaryData.timeArrangement[indexOriginalTimeArrangement].weekList}.",
          );
        }
      }
    }

    return preliminaryData;
  }

  Future<ClassTableData> get({
    bool isForce = false,
    bool isUserDefinedChanged = false,
  }) async {
    log.i(
      "[getClasstable][get] "
      "Start fetching the classtable.",
    );

    var file = File("${supportPath.path}/$schoolClassName");
    bool isExist = file.existsSync();
    bool isNotNeedRefreshCache = isExist &&
        isForce == false &&
        DateTime.now().difference(file.lastModifiedSync()).inDays <= 2;

    log.i(
      "[getClasstable][get] "
      "Cache file exist: $isExist."
      "Is not need refresh cache: $isNotNeedRefreshCache\n"
      "Is user class changed: $isUserDefinedChanged",
    );

    if (isNotNeedRefreshCache || isUserDefinedChanged) {
      ClassTableData data =
          ClassTableData.fromJson(jsonDecode(file.readAsStringSync()));
      var userClass = getUserDefinedData();
      data.userDefinedDetail = userClass.$1.userDefinedDetail;
      data.timeArrangement.addAll(userClass.$1.timeArrangement);
      return data;
    } else {
      try {
        var toUse = await getFromWeb();
        file.writeAsStringSync(jsonEncode(toUse.toJson()));
        var userClass = getUserDefinedData();
        toUse.userDefinedDetail = userClass.$1.userDefinedDetail;
        toUse.timeArrangement.addAll(userClass.$1.timeArrangement);
        return toUse;
      } catch (e, s) {
        log.w(
          "[getClasstable][get] "
          "Fetch error with exception.",
          error: e,
          stackTrace: s,
        );
        if (isExist) {
          return ClassTableData.fromJson(jsonDecode(file.readAsStringSync()));
        } else {
          rethrow;
        }
      }
    }
  }
}
