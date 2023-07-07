/*
Get electricity usage data.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script!
*/

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart';

var electricityInfo = "".obs;

Future<void> update() async {
  try {
    electricityInfo.value = "正在获取";
    await ElectricitySession().updateInformation();
  } on NotSchoolNetworkException {
    electricityInfo.value = "目前不是校园网";
  } on DioException catch (e) {
    developer.log(
      "Network error: $e",
      name: "ElectricSession",
    );
    electricityInfo.value = "网络故障";
  } on NotFoundException {
    electricityInfo.value = "未找到电表数据";
  } catch (e) {
    developer.log(
      "Unknown error: $e",
      name: "ElectricSession",
    );
    electricityInfo.value = "程序故障";
  }
}

class ElectricitySession extends NetworkSession {
  final base = "http://10.168.55.50:8088";

  /// The way to get the electricity number.
  /// Refrence here: https://see.xidian.edu.cn/html/news/9179.html
  static String electricityAccount() {
    RegExp numsExp = RegExp(r"[0-9]+");
    List<RegExpMatch> nums = numsExp
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

  Future<void> updateInformation() async {
    if (await isInSchool() == false) {
      throw NotSchoolNetworkException();
    }

    /// ASP session id.
    var sessionId = await dio
        .get("$base/searchWap/Login.aspx")
        .then((value) => value.headers.map["Set-Cookie"]![0]);
    sessionId = sessionId.substring(0, 42);

    developer.log(
      "The electricity session id is: $sessionId.",
      name: "ElectricSession",
    );

    var account = electricityAccount();

    /// Login function.
    await dio
        .post(
          "$base/ajaxpro/SearchWap_Login,App_Web_fghipt60.ashx",
          data: {
            "webName": account,
            "webPass": preference.getString(
              preference.Preference.electricityPassword,
            ),
          },
          options: Options(headers: {
            "AjaxPro-Method": "getLoginInput",
            "Cookie": sessionId,
            'Origin': "$base/ajaxpro/SearchWap_Login,App_Web_fghipt60.ashx",
          }),
        )
        .then((value) => value.data.toString());

    /// Get data.
    var page = await dio
        .get("$base/searchWap/webFrm/met.aspx",
            options: Options(headers: {"Cookie": sessionId}))
        .then((value) => value.data);

    //int building = int.parse(account.substring(1, 4));
    RegExp name = RegExp(r"表名称：.*");
    RegExp data = RegExp(r"剩余量：.*");

    List<RegExpMatch> nameArray = name.allMatches(page).toList();
    List<RegExpMatch> dataArray = data.allMatches(page).toList();

    //by ZCWzy
    for (int i = nameArray.length - 1; i >= 0; --i) {
      if (nameArray[i][0]!.contains("电表")) {
        electricityInfo.value = "${dataArray[i][0]!} 度";
        developer.log(
          electricityInfo.value,
          name: "ElectricSession",
        );
        return;
      }
    }

    throw NotFoundException();
  }
}

class NotFoundException implements Exception {}
