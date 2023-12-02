// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// E-hall class, which get lots of useful data here.
// Thanks xidian-script and libxdauth!

import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class EhallSession extends IDSSession {
  Map<String, String> refererHeader = {
    HttpHeaders.refererHeader: "http://ehall.xidian.edu.cn/new/index_xd.html",
    HttpHeaders.hostHeader: "ehall.xidian.edu.cn",
    HttpHeaders.acceptHeader:
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    HttpHeaders.acceptLanguageHeader:
        'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    HttpHeaders.acceptEncodingHeader: 'identity',
    HttpHeaders.connectionHeader: 'Keep-Alive',
    HttpHeaders.contentTypeHeader:
        "application/x-www-form-urlencoded; charset=UTF-8",
  };

  Dio get dio => super.dio..options = BaseOptions(headers: refererHeader);

  Future<bool> isLoggedIn() async {
    var response = await dio.get(
      "https://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    developer.log("Ehall isLoggedin: ${response.data["hasLogin"]}",
        name: "Ehall isLoggedIn");
    return response.data["hasLogin"];
  }

  Future<String> useApp(String appID) async {
    developer.log("Ready to use the app $appID.", name: "Ehall useApp");
    developer.log("Try to login.", name: "Ehall useApp");
    if (!await isLoggedIn()) {
      await super.checkAndLogin(
        target:
            "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      );
    }
    developer.log("Try to use the $appID.", name: "Ehall useApp");
    var value = await dio.get(
      "https://ehall.xidian.edu.cn/appShow",
      queryParameters: {'appId': appID},
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
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
        "requestParams":
            "{\"XSBH\":\"${preference.getString(preference.Preference.idsAccount)}\"}",
        "actionType": "MINE",
        "actionName": "xsjbxxcx",
        "dataModelAction": "QUERY",
      },
    ).then((value) => value.data);
    developer.log("Storing the user information.",
        name: "Ehall getInformation");
    if (detailed["resultCode"] != "00000") {
      throw GetInformationFailedException(detailed["msg"]);
    } else {
      preference.setString(
        preference.Preference.name,
        detailed["data"][0]["XM"],
      );
      preference.setString(
        preference.Preference.sex,
        detailed["data"][0]["XBDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.execution,
        detailed["data"][0]["DZ_SYDM_DISPLAY"].toString().replaceAll("·", ""),
      );
      preference.setString(
        preference.Preference.institutes,
        detailed["data"][0]["DZ_DWDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.subject,
        detailed["data"][0]["ZYDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.dorm,
        detailed["data"][0]["ZSDZ"],
      );
    }

    developer.log("Get the semester information.",
        name: "Ehall getInformation");
    String get = await useApp("4770397878132218");
    await dio.post(get);
    String semesterCode = await dio
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
        )
        .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    preference.setString(
      preference.Preference.currentSemester,
      semesterCode,
    );

    developer.log("Get the day the semester begin.",
        name: "Ehall getInformation");
    String termStartDay = await dio.post(
      'https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
    ).then((value) => value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);
    preference.setString(
      preference.Preference.currentStartDay,
      termStartDay,
    );
  }
}

class GetInformationFailedException implements Exception {
  final String msg;
  const GetInformationFailedException(this.msg);

  @override
  String toString() => msg;
}
