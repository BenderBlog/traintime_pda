// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class CreativeServiceSession extends IDSSession {
  static const url = "https://scjspt.xidian.edu.cn";
  static var authorization = "";
  Future<void> initSession() async {
    var response = await checkAndLogin(
      target: "$url/login/ids",
    );
    String urlReceived = "${response.realUri}";

    RegExp ticketExp = RegExp(r'ST\S+');
    String ticket = ticketExp.firstMatch(urlReceived)![0]!;
    developer.log("Received: $ticket.", name: "CreativeServiceSession");
    bool isLogin = await dio
        .post(
      "$url/api/v1/auth/ids",
      data: {
        "ticket": ticket,
      },
      options: Options(
        contentType: ContentType.json.toString(),
      ),
    )
        .then(
      (value) {
        if (value.data["code"] == 200) {
          authorization = value.headers.value("Authorization")!;
        }
        return value.data["code"] == 200;
      },
    );

    developer.log(
      "Received: \n${isLogin}\n",
      name: "CreativeServiceSession",
    );

    if (isLogin) {
      await dio
          .post(
            "$url/api/v1/job/query",
            data: {
              "where": [{}],
              "order": "created_at desc",
              "size": 20
            },
            options: Options(
              contentType: ContentType.json.toString(),
              headers: {
                "Authorization": authorization,
              },
            ),
          )
          .then(
            (value) => authorization = value.headers.value("Authorization")!,
          );
    } else {
      return;
    }
  }
}
