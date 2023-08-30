// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get your school card money's info, unless you use wechat or alipay...

import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class SchoolCardSession extends IDSSession {
  static String openid = "";
  static String virtualCardUrl = "";
  static String personalCenter = "";

  /*
  Future<Uint8List> getQRCode() async {
    developer.log(
      "try to get QR Code",
      name: "SchoolCardSession",
    );
    var response = await dio
        .get("https://v8scan.xidian.edu.cn/$virtualCardUrl")
        .then((value) => BeautifulSoup(value.data));
    return base64Decode(
      response
              .find(
                'img',
                id: "qrcode",
              )
              ?.attributes["src"]
              ?.replaceAll(
                "data:image/png;base64,",
                "",
              )
              .replaceAll(
                "\n",
                "",
              ) ??
          "",
    );
  }*/

  Future<List<PaidRecord>> getPaidStatus(String begin, String end) async {
    List<PaidRecord> toReturn = [];
    var response = await dio.post(
      "https://v8scan.xidian.edu.cn/selftrade/queryCardSelfTradeList?openid=$openid",
      options: Options(contentType: "application/json; charset=utf-8"),
      data: {
        "beginDate": begin,
        "endDate": end,
        "tradeType": "-1",
        "openid": openid,
      },
    ).then((value) => jsonDecode(value.data));
    for (var i in response["resultData"]) {
      toReturn.add(
        PaidRecord(
          place: i["mername"],
          date: i["txdate"],
          money: i["txamt"],
        ),
      );
    }
    return toReturn;
  }

  Future<String> getMoney() async {
    developer.log("Received: $virtualCardUrl.", name: "SchoolCardSession");
    developer.log("Received: $personalCenter.", name: "SchoolCardSession");
    var response =
        await dio.get("https://v8scan.xidian.edu.cn/$personalCenter");
    while (response.headers[HttpHeaders.locationHeader] != null) {
      String location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "SchoolCardSession");
      response = await dio.get(location);
    }

    return BeautifulSoup(response.data)
            .ul
            ?.children[0]
            .findAll('p')[1]
            .innerHtml ??
        "查询失败";
  }

  Future<void> initSession() async {
    var response = await dio.get(
      "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
    );
    while (response.headers[HttpHeaders.locationHeader] != null) {
      String location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "SchoolCardSession");
      response = await dio.get(location);
    }
    var page = BeautifulSoup(response.data);

    openid = page.find(
          'input',
          attrs: {"id": "openid", "type": "hidden"},
        )?["value"] ??
        "";

    page.findAll('a').forEach((element) {
      if (element["href"]?.contains("openVirtualcard") ?? false) {
        virtualCardUrl += element["href"]!;
      }
      if (element["href"]?.contains("openMyAccount") ?? false) {
        personalCenter += element["href"]!;
      }
    });
  }
}
