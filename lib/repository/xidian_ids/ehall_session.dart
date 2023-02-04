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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/model/user.dart';

class EhallSession extends IDSSession {
  @override
  Future<bool> isLoggedIn() async {
    var response = await dio.get(
      "https://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    developer.log("Ehall isLoggedin: ${response.data["hasLogin"]}",
        name: "Ehall isLoggedIn");
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
  }) async {
    if (await isLoggedIn() == false || forceReLogin == true) {
      developer.log(
          "Ready to log in the ehall. Is force relogin: $forceReLogin.",
          name: "Ehall login");
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
    developer.log("Ready to use the app $appID.", name: "Ehall useApp");
    developer.log("Try to login.", name: "Ehall useApp");
    await loginEhall(
        username: user["idsAccount"]!, password: user["idsPassword"]!);
    developer.log("Try to use the $appID.", name: "Ehall useApp");
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
    developer.log("Transfer address: ${value.headers['location']![0]}.",
        name: "Ehall useApp");
    return value.headers['location']![0];
  }

  /// 学生个人信息  4585275700341858 Unable to use because of xgxt.xidian.edu.cn (学工系统)
  /// 宿舍学生住宿  4618295887225301
  Future<void> getInformation() async {
    developer.log("Ready to get the user information.",
        name: "Ehall getInformation");
    var firstPost = await useApp("4618295887225301");
    await dio.get(firstPost).then((value) => value.data);

    /// Get information here. resultCode==00000 is successful.
    developer.log("Getting the user information.",
        name: "Ehall getInformation");
    var detailed = await dio.post(
      "https://ehall.xidian.edu.cn/xsfw/sys/xszsapp/commoncall/callQuery/xsjbxxcx-MINE-QUERY.do",
      data: {
        "requestParams": "{\"XSBH\":\"${user["idsAccount"]}\"}",
        "actionType": "MINE",
        "actionName": "xsjbxxcx",
        "dataModelAction": "QUERY",
      },
    ).then((value) => value.data);

    /// Get information here. resultCode==00000 is successful.
    developer.log("Storing the user information.",
        name: "Ehall getInformation");
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

  /// 考试安排 4768687067472349
  @protected
  Future<void> getExamTime() async {
    var firstPost = await useApp("4768687067472349");
    // print(firstPost);
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
    // print(data);
  }
}

var ses = EhallSession();
