// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get payment, specifically your owe.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/electricity_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

var owe = "".obs;

Future<void> update() async {
  try {
    owe.value = "正在获取欠费";
    await PaymentSession().getOwe();
  } on DioException {
    log.info(
      "[PaymentSession][update] "
      "Network error",
    );
    owe.value = "欠费信息网络故障";
  } catch (e, s) {
    log.handle(e, s);
    owe.value = "欠费程序故障";
  }
}

class PaymentSession extends IDSSession {
  final factorycode = "E003";
  RegExp getTransfer =
      RegExp(r'"http://payment.xidian.edu.cn/NetWorkUI/(.*?)"');
  Future<void> getOwe() async {
    try {
      /// Get electricity password
      String password = preference.getString(
        preference.Preference.electricityPassword,
      );
      if (password.isEmpty) {
        password = "123456";
      }

      String location = await checkAndLogin(
        target: "http://payment.xidian.edu.cn/pages/caslogin.jsp",
        sliderCaptcha: (p0) async {},
      );
      var response = await dio.get(location);
      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        log.info(
          "[PaymentSession][getOwe] "
          "Received location: $location.",
        );
        response = await dio.get(location);
      }
      var nextStop = getTransfer.firstMatch(response.data);
      log.info(
        "[PaymentSession][getOwe] "
        "getTransfer: ${nextStop![0]!}.",
      );

      await dio.get(nextStop[0]!.replaceAll('"', ""));

      var (addressid, liveid) = await dio.post(
        "https://payment.xidian.edu.cn/NetWorkUI/checkUserInfo",
        data: {
          "p_Userid": ElectricitySession.electricityAccount(),
          "p_Password": password,
          "factorycode": factorycode,
        },
      ).then(
        (value) {
          var decodeData = jsonDecode(value.data);
          return (
            decodeData["roomList"][0].toString().split('@')[0],
            decodeData["liveid"]
          );
        },
      );

      return await dio.post(
        "https://payment.xidian.edu.cn/NetWorkUI/getOwefeeInfo",
        data: {
          "addressid": addressid,
          "liveid": liveid,
          "factorycode": factorycode,
        },
      ).then((value) {
        var decodeData = jsonDecode(value.data);
        if (decodeData["returncode"] == "ERROR" &&
            decodeData["returnmsg"] == "电费厂家返回xml消息体异常") {
          owe.value = "目前无需清缴欠费";
        } else if (int.parse(decodeData["dueTotal"]) > 0) {
          owe.value = "待清缴${decodeData["dueTotal"]}元欠费";
        } else {
          owe.value = "目前欠款无法查询";
        }
      });
    } catch (e, s) {
      log.handle(e, s);
      owe.value = "目前欠款无法查询";
    }
  }
}
