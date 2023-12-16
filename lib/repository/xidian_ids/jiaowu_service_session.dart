// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class JiaowuServiceSession extends IDSSession {
  Map<String, String> services = {
    "score": "KW.CJCX",
  };

  static String authorization = "";
  Dio get authorizationDio => Dio(
        BaseOptions(
          headers: {
            HttpHeaders.authorizationHeader: authorization,
            //HttpHeaders.cookieHeader: "Authorization=$authorization",
          },
        ),
      )..interceptors.add(alice.getDioInterceptor());

  Future<void> getToken() async {
    String location = await checkAndLogin(
      target: "https://xxcapp.xidian.edu.cn/a_xidian/api/cas-login/index?"
          "redirect=https%3A%2F%2Fxxcapp.xidian.edu.cn%2Fuc%2Fapi%2Foauth%2F"
          "index%3Fappid%3D200190304164516885%26redirect%3Dhttps%253A%252F%252F"
          "ehall.xidian.edu.cn%252Fjwmobile%252Fauth%252Findex%26state%3DSTATE"
          "%26qrcode%3D1&from=wap",
    );

    var response = await dio.get(location);

    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "Jiaowu initSession");
      if (location.contains("ehall.xidian.edu.cn/jwmobile/index#/?token=")) {
        authorization = location.replaceAll(
          RegExp(r'https?:\/\/ehall.xidian.edu.cn\/jwmobile\/index#\/\?token='),
          "",
        );
      }
      response = await dio.get(location);
    }
  }

  Future<void> useService(String type) async {
    if (authorization.isEmpty) {
      await getToken();
    }

    var getData = await authorizationDio.post(
      "https://ehall.xidian.edu.cn/jwmobile/biz/home/updateServiceUsage",
      data: {"key": services[type]},
    ).then((value) => value.data);

    if (getData.toString().isNotEmpty && getData["code"] == 401) {
      await getToken().then((value) async {
        await authorizationDio.post(
          "https://ehall.xidian.edu.cn/jwmobile/biz/home/updateServiceUsage",
          data: {"key": services[type]},
        );
      });
    }
  }

  Future<List<Score>> getScore() async {
    List<Score> toReturn = [];

    developer.log("Getting the score data.", name: "Jiaowu getScore");
    await useService("score");

    var getData = await authorizationDio.post(
      "https://ehall.xidian.edu.cn/jwmobile/biz/v410/score/termScore",
      data: {"termCode": "*"},
    ).then((value) => value.data);

    if (getData["code"] != 200) {
      throw GetScoreFailedException(getData["msg"]);
    }

    int j = 0;
    for (var i in getData['data']['termScoreList']) {
      for (var k in i['scoreList']) {
        toReturn.add(
          Score(
            mark: j,
            name: "${k["courseName"]}",
            scoreStr: k["score"],
            year: k["termCode"],
            credit: double.parse(k["coursePoint"]),
            status: k["majorFlag"],
            examType: k["examType"],
            examProp: k["examProp"],
            isPassed: k["passFlag"],
          ),
        );
        j++;
      }
    }
    return toReturn;
  }
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}
