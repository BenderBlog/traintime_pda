// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

class PersonalInfoSession extends EhallSession {
  Future<String> getInformationFromYjspt({bool onlyPhone = false}) async {
    String location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    log.info(
      "[PersonalInfoSession][getInformationFromYjspt] "
      "Location is $location",
    );
    var response = await dio.get(location);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[PersonalInfoSession][getInformationFromYjspt] "
        "Received location: $location.",
      );
      response = await dio.get(location);
    }

    log.info(
      "[PersonalInfoSession][getInformationFromYjspt] "
      "Getting the user information.",
    );
    var detailed = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/modules/pubWork/getUserInfo.do",
        )
        .then((value) => value.data);
    if (onlyPhone == false) {
      if (detailed["code"] != "0") {
        throw GetInformationFailedException(detailed["msg"].toString());
      }
      preference.setString(
        preference.Preference.name,
        detailed["data"]["userName"],
      );
      preference.setString(
        preference.Preference.currentSemester,
        detailed["data"]["xnxqdm"],
      );
    }

    detailed = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/homeAppendPerson/getXsjcxx.do",
          data: {"datas": '{"wdxysysfaxq":"1","concurrency":"main"}'},
          options: Options(
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          ),
        )
        .then((value) => value.data);
    log.info(
      "[PersonalInfoSession][getInformationFromYjspt] "
      "Storing the user information.",
    );
    if (onlyPhone == false) {
      preference.setString(
        preference.Preference.execution,
        "", //detailed["performance"][0]["CONTENT"][4]["CAPTION"],
      );
      preference.setString(
        preference.Preference.institutes,
        "", //detailed["performance"][0]["CONTENT"][2]["CAPTION"],
      );
      preference.setString(
        preference.Preference.subject,
        "", //detailed["performance"][0]["CONTENT"][3]["CAPTION"],
      );
      preference.setString(
        preference.Preference.dorm,
        "", // Did not return, use false data
      );
      log.info(
        "[ehall_session][getInformation] "
        "Get the day the semester begin.",
      );

      log.info(
        "[ehall_session][getInformation] "
        "Get the semester information.",
      );
      String? location = await checkAndLogin(
        target:
            "https://yjspt.xidian.edu.cn/gsapp/"
            "sys/wdkbapp/*default/index.do#/xskcb",
        sliderCaptcha: (String cookieStr) =>
            SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
      );

      while (location != null) {
        var response = await dio.get(location);
        log.info("[getClasstable][getYjspt] Received location: $location.");
        location = response.headers[HttpHeaders.locationHeader]?[0];
      }

      var semesterCode = await dio
          .post(
            "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/kfdxnxqcx.do",
          )
          .then((value) => value.data["datas"]["kfdxnxqcx"]["rows"][0]["WID"]);
      preference.setString(preference.Preference.currentSemester, semesterCode);
    }

    return "02981891206";
  }

  /// 学生个人信息  6635601510182122
  /// Return phone info for electricity. set onlyPhone to avoid update
  /// personal info.
  Future<String> getInformationEhall({bool onlyPhone = false}) async {
    log.info(
      "[ehall_session][getInformation] "
      "Ready to get the user information.",
    );

    String location = await super.checkAndLogin(
      target:
          "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do#/wdxx",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );
    log.info(
      "[ehall_session][useApp] "
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
      "[ehall_session][getInformation] "
      "Getting the user information.",
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
      "[ehall_session][getInformation] "
      "Storing the user information.",
    );
    if (onlyPhone == false) {
      if (detailed["returnCode"] != "#E000000000000") {
        throw GetInformationFailedException(detailed["description"]);
      } else {
        preference.setString(
          preference.Preference.name,
          detailed["data"]["XM"],
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

      log.info(
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
      preference.setString(preference.Preference.currentSemester, semesterCode);
    }

    return detailed["data"]["SJH"] ?? "02981891206";
  }
}
