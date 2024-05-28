// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// E-hall class, which get lots of useful data here.
// Thanks xidian-script and libxdauth!

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class EhallSession extends IDSSession {
  static final _ehallLock = Lock();

  /// This header shall only be used in the ehall related stuff...
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

  Dio get dioEhall => super.dio..options = BaseOptions(headers: refererHeader);

  Future<bool> isLoggedIn() async {
    var response = await dioEhall.get(
      "https://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    log.i(
      "[ehall_session][isLoggedIn] "
      "Ehall isLoggedin: ${response.data["hasLogin"]}",
    );
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    required void Function(int, String) onResponse,
  }) async {
    String location = await super.login(
      target:
          "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      username: username,
      password: password,
      sliderCaptcha: sliderCaptcha,
      onResponse: onResponse,
    );
    var response = await dio.get(location);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.i(
        "[ehall_session][loginEhall] "
        "Received location: $location",
      );
      response = await dioEhall.get(location);
    }
    return;
  }

  Future<String> useApp(String appID) async {
    return await _ehallLock.synchronized(() async {
      log.i(
        "[ehall_session][useApp] "
        "Ready to use the app $appID. Try to Login.",
      );
      if (!await isLoggedIn()) {
        String location = await super.checkAndLogin(
          target: "https://ehall.xidian.edu.cn/login?"
              "service=https://ehall.xidian.edu.cn/new/index.html",
          sliderCaptcha: (p0) async {},
        );
        var response = await dio.get(location);
        while (response.headers[HttpHeaders.locationHeader] != null) {
          location = response.headers[HttpHeaders.locationHeader]![0];
          log.i(
            "[ehall_session][useApp] "
            "Received location: $location.",
          );
          response = await dioEhall.get(location);
        }
      }
      log.i(
        "[ehall_session][useApp] "
        "Try to use the $appID.",
      );
      var value = await dioEhall.get(
        "https://ehall.xidian.edu.cn/appShow?appId=$appID",
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      log.i(
        "[ehall_session][useApp] "
        "Transfer address: ${value.headers['location']![0]}.",
      );
      return value.headers['location']![0];
    });
  }

  /// 学生个人信息  6635601510182122
  Future<void> getInformation() async {
    log.i(
      "[ehall_session][getInformation] "
      "Ready to get the user information.",
    );

    String location = await super.checkAndLogin(
      target:
          "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do#/wdxx",
      sliderCaptcha: (p0) async {},
    );
    log.i("[ehall_session][useApp] "
        "Location is $location");
    var response = await dio.get(
      location,
      options: Options(headers: {
        HttpHeaders.refererHeader:
            "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
        HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
      }),
    );
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.i(
        "[ehall_session][useApp] "
        "Received location: $location.",
      );
      response = await dioEhall.get(
        location,
        options: Options(headers: {
          HttpHeaders.refererHeader:
              "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
          HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
        }),
      );
    }
    await dioEhall.post(
      "https://xgxt.xidian.edu.cn/xsfw/sys/swpubapp/indexmenu/getAppConfig.do?appId=4585275700341858&appName=jbxxapp",
      options: Options(headers: {
        HttpHeaders.refererHeader:
            "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
        HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
      }),
    );

    /// Get information here. resultCode==00000 is successful.
    log.i(
      "[ehall_session][getInformation] "
      "Getting the user information.",
    );
    var detailed = await dioEhall
        .post(
            "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/modules/infoStudent/getStuBaseInfo.do",
            data: "requestParamStr="
                "{\"XSBH\":\"${preference.getString(preference.Preference.idsAccount)}\"}",
            options: Options(headers: {
              HttpHeaders.refererHeader:
                  "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
              HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
            }))
        .then(
          (value) => value.data,
        );
    log.i(
      "[ehall_session][getInformation] "
      "Storing the user information.",
    );
    if (detailed["returnCode"] != "#E000000000000") {
      throw GetInformationFailedException(detailed["description"]);
    } else {
      preference.setString(
        preference.Preference.name,
        detailed["data"]["CZZXM"],
      );
      preference.setString(
        preference.Preference.sex,
        detailed["data"]["XBDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.execution,
        detailed["data"]["SYDM_DISPLAY"].toString().replaceAll("·", ""),
      );
      preference.setString(
        preference.Preference.institutes,
        detailed["data"]["DWDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.subject,
        detailed["data"]["ZYDM_DISPLAY"],
      );
      preference.setString(
        preference.Preference.dorm,
        detailed["data"]["ZSDZ"],
      );
    }

    log.i(
      "[ehall_session][getInformation] "
      "Get the semester information.",
    );
    String get = await useApp("4770397878132218");
    await dioEhall.post(get);
    String semesterCode = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
        )
        .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    preference.setString(
      preference.Preference.currentSemester,
      semesterCode,
    );

    log.i(
      "[ehall_session][getInformation] "
      "Get the day the semester begin.",
    );
    String termStartDay = await dioEhall.post(
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
