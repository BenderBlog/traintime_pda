// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get your school card money's info, unless you use wechat or alipay...

import 'dart:io';
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Rx<SessionState> isInit = SessionState.none.obs;
RxString money = "".obs;
RxString errorSession = "".obs;

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
    if (isInit.value == SessionState.error ||
        isInit.value == SessionState.none) {
      initSession();
    }
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

  @override
  Future<void> initSession() async {
    log.info(
      "[SchoolCardSession][initSession] "
      "Current State: ${isInit.value}",
    );
    if (isInit.value == SessionState.fetching) {
      return;
    }
    try {
      isInit.value = SessionState.fetching;
      log.info(
        "[SchoolCardSession][initSession] "
        "Fetching...",
      );
      var response = await dio.get(
        "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
      );
      while (response.headers[HttpHeaders.locationHeader] != null) {
        String location = response.headers[HttpHeaders.locationHeader]![0];
        log.info(
          "[SchoolCardSession][initSession] "
          "Received location: $location.",
        );
        response = await dio.get(location);
      }
      var page = parse(response.data);

      var getOpenId = page.getElementsByTagName('input');

      for (var i in getOpenId) {
        if (i.id == "openid" && i.attributes["type"] == "hidden") {
          openid = i.attributes["value"]!;
          break;
        }
      }

      page.getElementsByTagName('a').forEach((element) {
        if (element.attributes["href"]?.contains("openVirtualcard") ?? false) {
          virtualCardUrl += element.attributes["href"]!;
        }
        if (element.attributes["href"]?.contains("openMyAccount") ?? false) {
          personalCenter += element.attributes["href"]!;
        }
      });

      /// Post formula: fetch money.
      String text = "";
      for (var i in page.getElementsByTagName("span")) {
        if (i.attributes["name"] == "showbalanceid") {
          text = i.innerHtml;
          break;
        }
      }
      log.info("[SchoolCardSession] remains on the surface: $text");

      if (text.contains("余额未结转")) {
        var element = page.getElementById("hidebalanceid");
        if (element != null) {
          text = element.innerHtml;
        }
      } else if (text.contains(RegExp(r'[0-9]'))) {
        text = text.substring(4);
      }
      log.info("[SchoolCardSession] remains: $text");

      if (text.isEmpty) {
        text = "school_card_status.failed_to_query";
      } else if (text.contains("school_card_status.failed_to_query")) {
        money.value = "school_card_status.failed_to_query";
      } else {
        money.value = text;
      }
      isInit.value = SessionState.fetched;
    } catch (e) {
      errorSession.value = e.toString();
      money.value = "school_card_status.failed_to_fetch";
      isInit.value = SessionState.error;
    }
  }
}
