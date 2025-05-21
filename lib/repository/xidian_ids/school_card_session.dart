// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get your school card money's info, unless you use wechat or alipay...

import 'dart:io';
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart' as developer;
import 'dart:typed_data';
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

  // /*
  Future<Uint8List> getQRCode() async {
    // developer.log(
    //   "try to get QR Code",
    //   name: "SchoolCardSession",
    // );
    final homeUrl =
        "https://v8scan.xidian.edu.cn/home/openHomePage?openid=$openid";
    final homeResp = await dio.get(homeUrl);
    final homeDoc = parse(homeResp.data);

    final aTags = homeDoc.getElementsByTagName('a');
    String? id;
    for (var a in aTags) {
      final href = a.attributes['href'] ?? '';
      if (href.contains('/virtualcard/openVirtualcard') &&
          href.contains('id=')) {
        final uri = Uri.parse(href.replaceAll('&amp;', '&'));
        id = uri.queryParameters['id'];
        if (id != null && id.isNotEmpty) break;
      }
    }
    if (id == null) {
      throw Exception("未找到校园码 id");
    }

    final qrUrl =
        "https://v8scan.xidian.edu.cn/virtualcard/openVirtualcard?openid=$openid&displayflag=1&id=$id";
    final qrResp = await dio.get(qrUrl);
    final qrDoc = parse(qrResp.data);
    final img = qrDoc.getElementById("qrcode");
    if (img == null) {
      throw Exception("二维码图片未找到");
    }
    var src = img.attributes["src"] ?? "";
    // 提取 base64 数据
    var base64Data = src
        .replaceAll("data:image/png;base64,", "")
        .replaceAll("\n", "");
    if (base64Data.isEmpty) {
      throw Exception("二维码数据为空");
    }
    return base64Decode(base64Data);
  }
  // */

  // 获取支付记录
  Future<List<PaidRecord>> getPaidStatus(String begin, String end) async {
    if (isInit.value == SessionState.error ||
        isInit.value == SessionState.none) {
      initSession();
    }
    List<PaidRecord> toReturn = [];
    var response = await dio
        .post(
          "https://v8scan.xidian.edu.cn/selftrade/queryCardSelfTradeList?openid=$openid",
          options: Options(contentType: "application/json; charset=utf-8"),
          data: {
            "beginDate": begin,
            "endDate": end,
            "tradeType": "-1",
            "openid": openid,
          },
        )
        .then((value) => jsonDecode(value.data));
    for (var i in response["resultData"]) {
      toReturn.add(
        PaidRecord(place: i["mername"], date: i["txdate"], money: i["txamt"]),
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

      /// Post formula: fetch money.
      response = await dio.get(
        "https://v8scan.xidian.edu.cn/myaccount/openMyAccount?openid=$openid",
      );
      page = parse(response.data);

      money.value =
          page
              .getElementsByTagName("li")
              .firstOrNull
              ?.children
              .elementAtOrNull(1)
              ?.children
              .elementAtOrNull(1)
              ?.innerHtml ??
          "school_card_status.failed_to_query";
      log.info("[SchoolCardSession][initSession] Money $money");

      isInit.value = SessionState.fetched;
    } catch (e, s) {
      log.error(
        "[SchoolCardSession][initSession] Money failed to fetch.",
        e,
        s,
      );
      errorSession.value = e.toString();
      money.value = "school_card_status.failed_to_fetch";
      isInit.value = SessionState.error;
    }
  }
}
