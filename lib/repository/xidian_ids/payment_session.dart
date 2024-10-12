// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get payment, specifically your owe.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

var owe = "".obs;
var electricityInfo = "".obs;
var isNotice = true.obs;

Future<void> update() async {
  try {
    await PaymentSession().loginPayment().then((value) => Future.wait([
          Future(() async {
            try {
              isNotice.value = true;
              electricityInfo.value = "正在获取";
              await PaymentSession().getElectricity(value);
              isNotice.value = false;
            } on DioException catch (e, s) {
              log.handle(e, s);
              electricityInfo.value = "网络故障";
              isNotice.value = false;
            } on NotFoundException {
              electricityInfo.value = "查询失败";
              isNotice.value = false;
            } catch (e, s) {
              log.handle(e, s);
              electricityInfo.value = "程序故障";
              isNotice.value = false;
            }
          }),
          Future(() async {
            try {
              owe.value = "正在获取欠费";
              await PaymentSession().getOwe(value);
            } on DioException {
              log.info(
                "[PaymentSession][update] "
                "Network error",
              );
              owe.value = "欠费信息网络故障";
            } catch (e, s) {
              log.handle(e, s);
              owe.value = "目前欠款无法查询";
            }
          })
        ]));
  } catch (e, s) {
    log.handle(e, s);
    electricityInfo.value = "程序故障";
    owe.value = "目前欠款无法查询";
    isNotice.value = false;
    return;
  }
}

class PaymentSession extends IDSSession {
  final factorycode = "E003";
  RegExp getTransfer = RegExp(
    r'"http://payment.xidian.edu.cn/NetWorkUI/(.*?)"',
  );

  /// The way to get the electricity number.
  /// Refrence here: https://see.xidian.edu.cn/html/news/9179.html
  static String electricityAccount() {
    List<RegExpMatch> nums = RegExp(r"[0-9]+")
        .allMatches(preference.getString(preference.Preference.dorm))
        .toList();
    // 校区，默认南校区
    String accountA = "2";
    // 楼号
    String accountB = "";
    // 区号
    String accountC = "";
    // 房间号
    String accountD = "";
    int building = -1;

    // 楼号
    accountB = nums[0][0]!.toString().padLeft(3, "0");
    building = int.parse(nums[0][0]!.toString());
    // 南校区1～4#公寓的房间分区编号，则C段首位按区编码，第二位按层编码；D段首位编码为0
    if ([1, 2, 3, 4].contains(building)) {
      // 层号
      accountC += nums[1][0]!.toString();
      // 区号
      accountC = nums[2][0]!.toString() + accountC;
      // 宿舍号
      accountD = nums[3][0]!.toString().padLeft(4, "0");
    }
    // 南校区5、8、9、10、11、12、14#公寓的房间分区编号
    // 则C段首位编码为0，第二位按区编码；D段首位编码同区号
    if ([5, 8, 9, 10, 11, 12, 14].contains(building)) {
      // 区号
      accountC = nums[2][0]!.toString().padLeft(2, "0");
      // 宿舍号
      accountD = nums[3][0]!.toString().padLeft(4, nums[2][0]!);
    }
    // 南校区6、7#公寓不分区，C段编码默认为00；D段首位编码默认为0
    if ([6, 7].contains(building)) {
      accountC = "00";
      accountD = nums[2][0]!.toString().padLeft(4, "0");
    }
    // 南校区13、15#公寓不分区，C段编码默认为01；D段首位编码默认为1
    if ([13, 15].contains(building)) {
      accountC = "01";
      accountD = nums[2][0]!.toString().padLeft(4, "1");
    }

    return accountA + accountB + accountC + accountD;
  }

  /// Password, addressid, liveid
  Future<(String, String)> loginPayment() async {
    /// Get electricity password
    String password = preference.getString(
      preference.Preference.electricityPassword,
    );
    if (password.isEmpty) {
      password = "123456";
    }

    String location = await checkAndLogin(
      target: "http://payment.xidian.edu.cn/pages/caslogin.jsp",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
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

    return dio.post(
      "https://payment.xidian.edu.cn/NetWorkUI/checkUserInfo",
      data: {
        "p_Userid": electricityAccount(),
        "p_Password": password,
        "factorycode": factorycode,
      },
    ).then(
      (value) {
        var decodeData = jsonDecode(value.data);
        return (
          decodeData["roomList"][0].toString().split('@')[0],
          decodeData["liveid"].toString(),
        );
      },
    );
  }

  Future<void> getElectricity((String, String) fetched) => dio.post(
        "https://payment.xidian.edu.cn/NetWorkUI/checkPayelec",
        data: {
          "addressid": fetched.$1,
          "liveid": fetched.$2,
          'payAmt': 'leftwingpopulism',
          "factorycode": factorycode,
        },
      ).then((value) {
        var decodeData = jsonDecode(value.data);
        if (decodeData["returnmsg"] == "连接超时") {
          double balance = double.parse(
              decodeData["rtmeterInfo"]["Result"]["Meter"]["RemainQty"]);
          electricityInfo.value = balance.toString();
        } else {
          throw NotFoundException();
        }
      });

  Future<void> getOwe((String, String) fetched) => dio.post(
        "https://payment.xidian.edu.cn/NetWorkUI/getOwefeeInfo",
        data: {
          "addressid": fetched.$1,
          "liveid": fetched.$2,
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
}

class NotFoundException implements Exception {}
