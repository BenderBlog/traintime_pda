// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/ids_session/ids_session.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';

class SemesterSession extends IDSSession {
  Future<String> getSemesterInfoYjspt() async {
    final location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(),
    );

    log.info(
      "[PersonalInfoSession][getSemesterInfoYjspt] "
      "Location is $location",
    );
    await followIDSRedirects(initialLocation: location, client: dio);

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
    return detailed["data"]["xnxqdm"];
  }

  Future<String> getSemesterInfoEhall() async {
    log.info(
      "[ehall_session][getSemesterInfoEhall] "
      "Get the semester information.",
    );

    await checkAndLogin(
      target: "https://ehall.xidian.edu.cn/appShow?appId=4770397878132218",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(),
    ).then((location) async {
      await followIDSRedirects(initialLocation: location, client: dio);
    });

    String semesterCode = await dio
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
        )
        .then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    return semesterCode;
  }
}

class GetInformationFailedException implements Exception {
  final String msg;
  const GetInformationFailedException(this.msg);

  @override
  String toString() => msg;
}
