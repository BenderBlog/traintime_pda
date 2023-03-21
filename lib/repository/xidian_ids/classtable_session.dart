/*
The class table window source.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 课程表 4770397878132218
class ClassTableFile extends EhallSession {
  Future<Map<String, dynamic>> getFromWeb() async {
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

    developer.log("Fetch the day the semester begin.",
        name: "Ehall getClasstable");
    String termStartDay = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
    ).then((value) => value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);

    developer.log(
        "Will get $semesterCode which start at $termStartDay, fetching...",
        name: "Ehall getClasstable");

    qResult = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['xskcb']);
    if (qResult['extParams']['code'] != 1) {
      throw qResult['extParams']['msg'] + "在已安排课程";
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

    return qResult;
  }

  Future<Map<String, dynamic>> get({
    bool isForce = false,
  }) async {
    developer.log("Check whether the classtable has fetched.",
        name: "Ehall getClasstable");

    developer.log("Start fetching the classtable.",
        name: "Ehall getClasstable");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory destination =
        Directory("${appDocDir.path}/org.superbart.watermeter");
    if (!destination.existsSync()) {
      await destination.create();
    }
    var file = File("${destination.path}/ClassTable.json");
    bool isExist = file.existsSync();

    developer.log(
        isExist &&
                isForce == false &&
                DateTime.now().difference(file.lastModifiedSync()).inDays <= 3
            ? "Cache"
            : "Fetch from internet.",
        name: "Ehall getClasstable");

    if (isExist &&
        isForce == false &&
        DateTime.now().difference(file.lastModifiedSync()).inDays <= 3) {
      return jsonDecode(file.readAsStringSync());
    } else {
      try {
        var qResult = await getFromWeb();
        file.writeAsStringSync(jsonEncode(qResult));
        return qResult;
      } catch (e) {
        if (isExist) {
          return jsonDecode(file.readAsStringSync());
        } else {
          rethrow;
        }
      }
    }
  }
}
