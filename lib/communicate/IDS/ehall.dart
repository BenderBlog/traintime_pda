/*
E-hall class, which get lots of useful data here.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:watermeter/communicate/IDS/ids.dart';

class EhallSession extends IDSSession {

  @override
  Future<bool> isLoggedIn() async {
    var response = await dio.get(
      "http://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    print(response.data);
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    bool forceReLogin = false
  }) async {
    if (await isLoggedIn() == false || forceReLogin == true){
      print("IsnotLogin");
      await super.login(
        username: username,
        password: password,
        target: "http://ehall.xidian.edu.cn/login?service=http://ehall.xidian.edu.cn/new/index.html"
      );
    }
  }

  Future<String> useApp(String appID) async => await dio.get(
      "http://ehall.xidian.edu.cn/appShow",
      queryParameters: {'appId': appID},
      options: Options(
        followRedirects: false,
        validateStatus: (status) { return status! < 500; },
        headers: {
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        }
      )
    ).then((value) => value.headers['location']![0]);

  /// 学生个人信息  4585275700341858
  Future<void> getInformation () async {
    var firstPost = await useApp("4585275700341858");
    var post = await dio.get(firstPost).then((value)=>value.data);
    /// Get student ID.
    BeautifulSoup getStuID = BeautifulSoup(post);
    String stepForward = getStuID.find("script").toString();
    int indexOfID = stepForward.indexOf("\"USERID\":\"");
    String ID = stepForward.substring(indexOfID, indexOfID+22).substring(10,21);
    /// Get information here.
    /// Check returnCode, #E000000000000 is successful.
    /*
    var information = await _dio.post(
      "http://ehall.xidian.edu.cn/xsfw/sys/swpubapp/userinfo/getConfigUserInfo.do?USERID=$ID",
    ).then((value) => value.data["data"]);
    print("初步信息：\n学号 ${information[0]}\n姓名 ${information[1]}\n学院 ${information[2]}");
    */
    var detailed = await dio.post(
      "http://ehall.xidian.edu.cn/xsfw/sys/jbxxapp/modules/infoStudent/getStuBatchInfo.do",
      data: {"requestParamStr": "\{\"XSBH\":$ID\}"},
    );
    print(detailed.data["data"]);
  }


  /// 考试成绩 4768574631264620
  Future<void> getScore () async {
    Map<String,dynamic> querySetting =
      {
        'name': 'SFYX',
        'value': '1',
        'linkOpt': 'and',
        'builder': 'm_value_equal'
      };
    var firstPost = await useApp("4768574631264620");
    await dio.get(firstPost);
    var getData = await dio.post(
      "http://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize':1000,
        'pageNumber': 1,
      },
    );
    print(getData);
  }

  /// 课程表 4770397878132218
  Future<void> getClasstable () async {
    var firstPost = await useApp("4770397878132218");
    await dio.get(firstPost);
    String semesterCode = await dio.post(
      "http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
      options: Options(
        headers: {'Accept': 'application/json, text/javascript, */*; q=0.01'}
      )
    ).then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    print(semesterCode);
    String termStartDay = await dio.post(
      'http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
      options: Options(
        headers: {'Accept': 'application/json, text/javascript, */*; q=0.01'}
      ),
    ).then((value)=>value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);
    print(termStartDay);
    var qResult = await dio.post(
      'http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {'XNXQDM': semesterCode},
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json, text/javascript, */*; q=0.01'
        }
      )
    ).then((value) => value.data['datas']['xskcb']);
    print(qResult['extParams']['code'] == 1 ? qResult['rows'] : qResult['extParams']['msg']);
  }

  /// 考试安排 4768687067472349
  Future<void> getExamTime () async {
    var firstPost = await useApp("4768687067472349");
    await dio.get(firstPost);
    /// Get semester information.
    /*  Hard to use, I would rather do it by myself.
    var whatever = await dio.post(
      "http://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/xnxqcx.do",
      data: {"*order": "-PX,-DM"},
    );
    int totalSize = whatever.data["datas"]["xnxqcx"]['totalSize'];
    List<String> semester = [];
    for (var i in whatever.data["datas"]["xnxqcx"]['rows']) {
      semester.add(i["DM"]);
    }
    print(semester);
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
    print(semester);
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程
    /// wdksap 我的考试安排
    /// cxwapdksrw 查询未安排的考试任务
    /// If failed, it is more likely that no exam have arranged.
    var data = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do",
      queryParameters: {
        "XNXQDM":semester,
        "*order":"-KSRQ,-KSSJMS"
      },
    );
    print(data);
  }
}

class NotLoginException implements Exception {}

var ses = EhallSession();