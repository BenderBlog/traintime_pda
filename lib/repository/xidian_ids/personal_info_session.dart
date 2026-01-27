// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/semester_info.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

class PersonalInfoSession extends EhallSession {
  Future<void> getSemesterInfoYjspt() async {
    String location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    log.info(
      "[PersonalInfoSession][getSemesterInfoYjspt] "
      "Location is $location",
    );
    var response = await dio.get(location);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[PersonalInfoSession][getSemesterInfoYjspt] "
        "Received location: $location.",
      );
      response = await dio.get(location);
    }

    log.info(
      "[PersonalInfoSession][getSemesterInfoYjspt] "
      "Getting the current semester info.",
    );
    var detailed = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/modules/pubWork/getUserInfo.do",
        )
        .then((value) => value.data);
    if (detailed["code"] != "0") {
      throw GetInformationFailedException(detailed["msg"].toString());
    }
    await setCurrentSemester(detailed["data"]["xnxqdm"]);
  }

  Future<String> getDormInfoEhall() async {
    log.info(
      "[ehall_session][getDormInfoEhall] "
      "Ready to get the user information.",
    );

    String location = await super.checkAndLogin(
      target:
          "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do#/wdxx",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );
    log.info(
      "[ehall_session][getDormInfoEhall] "
      "Location is $location",
    );
    var response = await dio.get(
      location,
      options: Options(
        headers: {
          HttpHeaders.refererHeader:
              "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
          HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
        },
      ),
    );
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[ehall_session][useApp] "
        "Received location: $location.",
      );
      response = await dioEhall.get(
        location,
        options: Options(
          headers: {
            HttpHeaders.refererHeader:
                "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
            HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
          },
        ),
      );
    }
    await dioEhall.post(
      "https://xgxt.xidian.edu.cn/xsfw/sys/swpubapp/indexmenu/getAppConfig.do?appId=4585275700341858&appName=jbxxapp",
      options: Options(
        headers: {
          HttpHeaders.refererHeader:
              "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
          HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
        },
      ),
    );

    /// Get information here. resultCode==00000 is successful.
    log.info(
      "[ehall_session][getDormInfoEhall] "
      "Getting the dorm information.",
    );
    var detailed = await dioEhall
        .post(
          "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/modules/infoStudent/getStuBaseInfo.do",
          data:
              "requestParamStr="
              "{\"XSBH\":\"${preference.getString(preference.Preference.idsAccount)}\"}",
          options: Options(
            headers: {
              HttpHeaders.refererHeader:
                  "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
              HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
            },
          ),
        )
        .then((value) => value.data);
    log.info(
      "[ehall_session][getDormInfoEhall] "
      "Storing the user information.",
    );
    if (detailed["returnCode"] != "#E000000000000") {
      throw GetInformationFailedException(detailed["description"]);
    }

    return detailed["data"]["ZSDZ"].toString();
  }

  Future<void> getSemesterInfoEhall() async {
    log.info(
      "[ehall_session][getSemesterInfoEhall] "
      "Get the semester information.",
    );
    String get = await useApp("4770397878132218");
    await dioEhall.post(get);
    String semesterCode = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
        )
        .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    await setCurrentSemester(semesterCode);
  }
}
