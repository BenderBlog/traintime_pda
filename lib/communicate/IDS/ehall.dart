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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:watermeter/communicate/IDS/ids.dart';
import 'package:watermeter/communicate/general.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/dataStruct/ids/score.dart';

class EhallSession extends IDSSession {

  @override
  Future<bool> isLoggedIn() async {
    var response = await dio.get(
      "https://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    //print(response.data);
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    bool forceReLogin = false
  }) async {
    if (await isLoggedIn() == false || forceReLogin == true){
      //print("IsnotLogin");
      await super.login(
        username: username,
        password: password,
        target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html"
      );
    }
  }

  Future<String> useApp(String appID) async {
    await loginEhall(username: user["idsAccount"]!, password: user["idsPassword"]!);
    var value = await dio.get(
        "https://ehall.xidian.edu.cn/appShow",
        queryParameters: {'appId': appID},
        options: Options(
            followRedirects: false,
            validateStatus: (status) { return status! < 500; },
            headers: {
              "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            }
        )
    );
    //print("登陆完了${value.headers["set-cookie"]}");
    //print(value.headers);
    return value.headers['location']![0];
  }

  /// 学生个人信息  4585275700341858
  Future<void> getInformation () async {
    var firstPost = await useApp("4585275700341858");
    await dio.get(firstPost).then((value)=>value.data);
    /// Get information here.
    /// Check returnCode, #E000000000000 is successful.
    /*
    var information = await dio.post(
      "https://ehall.xidian.edu.cn/xsfw/sys/swpubapp/userinfo/getConfigUserInfo.do?USERID=${user["idsAccount"]}",
    ).then((value) => value.data["data"]);
    //print("$information");
    */
    var detailed = await dio.post(
      "https://ehall.xidian.edu.cn/xsfw/sys/jbxxapp/modules/infoStudent/getStuBatchInfo.do",
      data: {"requestParamStr": "\{\"XSBH\":${user["idsAccount"]}\}"},
    ).then((value) => value.data["data"]);
    await addUser("name",detailed["XM"]);
    await addUser("sex", detailed["XBDM_DISPLAY"]);
    await addUser("execution", detailed["BZ5_DISPLAY"]);
    await addUser("institutes", detailed["DZ_DWDM_DISPLAY"]);
    await addUser("subject", detailed["ZYDM_DISPLAY"]);
    await addUser("dorm", detailed["ZSDZ"]);
  }


  /// 考试成绩 4768574631264620
  Future<void> getScore () async {
    List<Score> scoreTable = [];
    Map<String,dynamic> querySetting =
      {
        'name': 'SFYX',
        'value': '1',
        'linkOpt': 'and',
        'builder': 'm_value_equal',
      };
    var firstPost = await useApp("4768574631264620");
    var whatever  = await dio.get(firstPost);
    var getData = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize':1000,
        'pageNumber': 1,
      },
    );
    //print("获取到成绩了");
    int j = 0;
    for (var i in getData.data['datas']['xscjcx']['rows']){
      scoreTable.add(Score(
          mark: j,
          name: i["XSKCM"],
          score: i["ZCJ"],
          year: i["XNXQDM"],
          credit: i["XF"],
          status: i["KCXZDM_DISPLAY"],
          classID: i["JXBID"],
          isPassed: i["SFJG"]
      ));
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
    //print(scoreTable.length);
  }

  /// 课程表 4770397878132218
  Future<void> getClasstable () async {
    await useApp("4770397878132218");
    String semesterCode = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
    ).then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    //print(semesterCode);
    String termStartDay = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
    ).then((value)=>value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);
    //print(termStartDay);
    var qResult = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['xskcb']);
    /// qResult['extParams']['code'] == 1 ? qResult['rows'] : qResult['extParams']['msg']);
    //print(qResult);

    var notOnTable = await dio.post(
      "httpss://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['cxxsllsywpk']);
    //print(notOnTable);

  }

  /// 考试安排 4768687067472349
  Future<void> getExamTime () async {
    var firstPost = await useApp("4768687067472349");
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
      semester = "${DateTime.now().year-1}-${DateTime.now().year}-1";
    } else if (now >= 2 && now <= 7) {
      semester = "${DateTime.now().year-1}-${DateTime.now().year}-2";
    } else {
      semester = "${DateTime.now().year}-${DateTime.now().year+1}-1";
    }
    //print(semester);
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程
    /// wdksap 我的考试安排
    /// cxwapdksrw 查询未安排的考试任务
    /// If failed, it is more likely that no exam has arranged.
    var data = await dio.post(
      "httpss://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do",
      queryParameters: {
        "XNXQDM":semester,
        "*order":"-KSRQ,-KSSJMS"
      },
    );
    //print(data);
  }
}

class NotLoginException implements Exception {}

var ses = EhallSession();