/*
Get payment, specifically your owe.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/electricity_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/creative_service_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

var owe = "".obs;

Future<void> update() async {
  try {
    owe.value = "正在获取欠费";
    await PaymentSession().getOwe();
  } on DioException catch (e) {
    developer.log(
      "Network error: $e",
      name: "PaymentSession",
    );
    owe.value = "欠费信息网络故障";
  } catch (e) {
    developer.log(
      "Unknown error: $e",
      name: "PaymentSession",
    );
    owe.value = "欠费程序故障";
  }
}

class PaymentSession extends IDSSession {
  final factorycode = "E003";
  RegExp getTransfer =
      RegExp(r'"http://payment.xidian.edu.cn/NetWorkUI/(.*?)"');
  Future<void> getOwe() async {
    var a = await CreativeServiceSession().getJob();
    developer.log(a.toString(), name: "CreativeTest");
    try {
      /// Get electricity password
      String password = preference.getString(
        preference.Preference.electricityPassword,
      );
      developer.log(
        "Electricity password $password ${password.isEmpty}",
        name: "PaymentSession",
      );
      if (password.isEmpty) {
        password = "123456";
      }

      var nextStop = await checkAndLogin(
        target: "http://payment.xidian.edu.cn/pages/caslogin.jsp",
      ).then((value) => getTransfer.firstMatch(value.data));

      developer.log("getTransfer: ${nextStop![0]!}", name: "PaymentSession");

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
    } catch (e) {
      developer.log(e.toString(), name: "PaymentSession");
      owe.value = "目前欠款无法查询";
    }
  }
}
