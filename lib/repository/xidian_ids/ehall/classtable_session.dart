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
        teacher: i["SKJS"],
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
          stop: int.parse(i["JSJC"]),
          day: int.parse(i["SKXQ"]),
          weekList: i["SKZC"].toString(),
          classroom: i["JASDM"],
        ),
      );
      if (i["SKZC"].toString().length > toReturn.semesterLength) {
        toReturn.semesterLength = i["SKZC"].toString().length;
      }
    }

    // Deal with the not arranged data.
    for (var i in qResult["notArranged"]) {
      toReturn.notArranged.add(ClassDetail(
        name: i["KCM"],
        teacher: i["SKJS"],
        code: i["KCH"],
        number: i["KXH"],
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

    developer.log("Caching...", name: "Ehall getClasstable");
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;

    var notOnTable = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['cxxsllsywpk']);

    developer.log(notOnTable.toString(), name: "Ehall getClasstable");
    qResult["notArranged"] = notOnTable["rows"];

    return simplifyData(qResult);
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
