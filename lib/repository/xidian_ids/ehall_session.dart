/*
E-hall class, which get lots of useful data here.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/user.dart';

class EhallSession extends IDSSession {
  @override
  Future<bool> isLoggedIn() async {
    var response = await dio.get(
      "https://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
  }) async {
    if (await isLoggedIn() == false || forceReLogin == true) {
      await super.login(
        username: username,
        password: password,
        target:
            "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
        onResponse: onResponse,
      );
    }
  }

  Future<String> useApp(String appID) async {
    await loginEhall(
        username: user["idsAccount"]!, password: user["idsPassword"]!);
    var value = await dio.get(
      "https://ehall.xidian.edu.cn/appShow",
      queryParameters: {'appId': appID},
      options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
          headers: {
            "Accept":
                "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
          }),
    );
    return value.headers['location']![0];
  }

  /// 学生个人信息  4585275700341858 Unable to use because of xgxt.xidian.edu.cn (学工系统)
  /// 宿舍学生住宿  4618295887225301
  Future<void> getInformation() async {
    var firstPost = await useApp("4618295887225301");
    await dio.get(firstPost).then((value) => value.data);

    /// Get information here. resultCode==00000 is successful.
    var detailed = await dio.post(
      "https://ehall.xidian.edu.cn/xsfw/sys/xszsapp/commoncall/callQuery/xsjbxxcx-MINE-QUERY.do",
      data: {
        "requestParams": "{\"XSBH\":\"${user["idsAccount"]}\"}",
        "actionType": "MINE",
        "actionName": "xsjbxxcx",
        "dataModelAction": "QUERY",
      },
    ).then((value) => value.data);
    if (detailed["resultCode"] != "00000") {
      throw detailed["msg"];
    } else {
      await addUser("name", detailed["data"][0]["XM"]);
      await addUser("sex", detailed["data"][0]["XBDM_DISPLAY"]);
      await addUser(
          "execution",
          detailed["data"][0]["DZ_SYDM_DISPLAY"]
              .toString()
              .replaceAll("·", ""));
      await addUser("institutes", detailed["data"][0]["DZ_DWDM_DISPLAY"]);
      await addUser("subject", detailed["data"][0]["ZYDM_DISPLAY"]);
      await addUser("dorm", detailed["data"][0]["ZSDZ"]);
    }
  }

  /// 考试成绩 4768574631264620
  Future<void> getScore({
    bool focus = false,
    required void Function(int, String) onResponse,
  }) async {
    if (scores != null && focus == false) {
      onResponse(100, "成绩已获取");
      return;
    }
    List<Score> scoreTable = [];

    /// Get all scores here.
    Map<String, dynamic> querySetting = {
      'name': 'SFYX',
      'value': '1',
      'linkOpt': 'and',
      'builder': 'm_value_equal',
    };
    onResponse(10, "准备获取成绩，正在登录");
    var firstPost = await useApp("4768574631264620");
    await dio.get(firstPost);
    var getData = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize': 1000,
        'pageNumber': 1,
      },
    ).then((value) => value.data);
    onResponse(60, "准备获取成绩，正在处理数据");

    /// Hope this check could work.
    if (getData['datas']['xscjcx']["extParams"]["code"] != 1) {
      throw getData['datas']['xscjcx']["extParams"]["msg"];
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      scoreTable.add(Score(
          mark: j,
          name: i["XSKCM"],
          score: i["ZCJ"] ?? 0.0,
          year: i["XNXQDM"],
          credit: i["XF"],
          status: i["KCXZDM_DISPLAY"],
          classID: i["JXBID"],
          isPassed: i["SFJG"] ?? "-1"));
      j++;
      /* Unable to work.
      if (i["DJCJLXDM"] == "100") {
        try {
          var anotherResponse = await dio.post(
              "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/cxkxkgcxlrcj.do",
              data: {
                "JXBID": scoreTable.last.classID,
                'XH': user["idsAccount"],
                'XNXQDM':scoreTable.last.year,
                'CKLY': "1",
              },
            options: Options(
              headers: {
                "DNT": "1",
                "Referer": firstPost
              },
            )
          );
          //print(anotherResponse.data);
        } on DioError catch (e) {
          //print("WTF:" + e.toString());
          break;
        }
      }*/
    }
    scores = ScoreList(scoreTable: scoreTable);
    onResponse(100, "成绩已获取");
  }

  /// 课程表 4770397878132218
  Future<void> getClasstable({
    bool focus = false,
    required void Function(int, String) onResponse,
  }) async {
    if (classData.isDone == true) {
      onResponse(100, "课表已获取");
      return;
    }

    Map<String, dynamic> qResult = {};

    onResponse(10, "准备获取课表");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory destination =
        Directory("${appDocDir.path}/org.superbart.watermeter");
    if (!destination.existsSync()) {
      await destination.create();
    }
    var file = File("${destination.path}/ClassTable.json");
    bool isExist = file.existsSync();

    onResponse(5, isExist || focus == true ? "读取缓存" : "从网络获取");

    // Try to add some sort of cache support.
    if (!isExist || focus == true) {
      onResponse(10, "进入教务系统");
      await useApp("4770397878132218");

      onResponse(15, "获取学期信息");
      String semesterCode = await dio
          .post(
            "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
          )
          .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);

      onResponse(20, "获取开学日期");
      String termStartDay = await dio.post(
        'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
        data: {
          'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
          'XQ': semesterCode.split('-')[2]
        },
      ).then((value) => value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);

      onResponse(30, "获取课表内容");
      qResult = await dio.post(
        'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
        data: {'XNXQDM': semesterCode},
      ).then((value) => value.data['datas']['xskcb']);
      if (qResult['extParams']['code'] != 1) {
        throw qResult['extParams']['msg'] + "在已安排课程";
      }

      onResponse(40, "缓存课表内容");
      qResult["semesterCode"] = semesterCode;
      qResult["termStartDay"] = termStartDay;

      file.writeAsStringSync(jsonEncode(qResult));
    } else {
      onResponse(40, "读取课表缓存");
      qResult = jsonDecode(file.readAsStringSync());
    }

    onResponse(50, "处理课表内容");

    classData.semesterCode = qResult["semesterCode"];
    classData.termStartDay = qResult["termStartDay"];

    for (var i in qResult["rows"]) {
      classData.onTable.add(ClassDetail(
        name: i["KCM"],
        teacher: i["SKJS"],
        place: i["JASDM"],
      ));
      int index = classData.onTable.length - 1;
      for (var j = 0; j < i["SKZC"].toString().length; ++j) {
        // KSJC 开始(进程?) JSJC 结束
        if (i["SKZC"][j] == "1" && int.parse(i["JSJC"]) <= 10) {
          var startDay = DateTime.parse(classData.termStartDay);
          // If not exist, create the entire week.
          if (classData.classTable[j] == null) {
            classData.classTable[j] = WeekClassInformation(
              startOfTheWeek: startDay.add(Duration(days: 7 * j)),
              classList: List.generate(
                  7, (_) => List.filled(10, null, growable: false)),
            );
          }
          for (var l = int.parse(i["KSJC"]); l <= int.parse(i["JSJC"]); ++l) {
            // SKXQ 上课星期
            classData.classTable[j]!.classList[int.parse(i["SKXQ"]) - 1]
                [l - 1] = index;
          }
        }
      }
    }

    /*
    onResponse(70, "获取未安排内容");
    var notOnTable = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['cxxsllsywpk']);
    if (qResult['extParams']['code'] != 1) {
      throw qResult['extParams']['msg'] + "在未安排课程";
    }
    onResponse(90, "处理未安排内容");
    for (var i in notOnTable["rows"]) {
      classData.notOnTable.add(ClassDetail(
        name: i["KCM"],
        teacher: i["SKJS"],
        place: i["JASDM"],
      ));
    }
    */
    classData.isDone = true;
    onResponse(100, "课表已获取");
  }

  /// 考试安排 4768687067472349
  Future<void> getExamTime() async {
    var firstPost = await useApp("4768687067472349");
    print(firstPost);
    await dio.get(firstPost);

    /// Get semester information.
    /*  Hard to use, I would rather do it by myself.
    var whatever = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/xnxqcx.do",
      data: {"*order": "-PX,-DM"},
    );
    int totalSize = whatever.data["datas"]["xnxqcx"]['totalSize'];
    List<String> semester = [];
    for (var i in whatever.data["datas"]["xnxqcx"]['rows']) {
      semester.add(i["DM"]);
    }
    //print(semester);
    */
    int now = DateTime.now().month;
    String semester = "";
    if (now == 1) {
      semester = "${DateTime.now().year - 1}-${DateTime.now().year}-1";
    } else if (now >= 2 && now <= 7) {
      semester = "${DateTime.now().year - 1}-${DateTime.now().year}-2";
    } else {
      semester = "${DateTime.now().year}-${DateTime.now().year + 1}-1";
    }

    /// cxyxkwapkwdkc 查询已选课未安排考务的课程(正在安排中？)
    /// wdksap 我的考试安排
    /// cxwapdksrw 查询未安排的考试任务
    /// If failed, it is more likely that no exam has arranged.
    var data = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do",
      queryParameters: {"XNXQDM": semester, "*order": "-KSRQ,-KSSJMS"},
    ).then((value) => value.data["datas"]["wdksap"]);
    if (data["extParams"]["msg"] != "查询成功") {
      throw "没有数据，也许没安排考试？";
    }
    print(data);
  }
}

var ses = EhallSession();
