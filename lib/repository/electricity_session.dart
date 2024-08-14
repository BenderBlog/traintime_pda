// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Get electricity usage data.

import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

var isNotice = true.obs;
var electricityInfo = "".obs;

Future<void> update() async {
  try {
    isNotice.value = true;
    electricityInfo.value = "正在获取";
    await ElectricitySession().updateInformation();
    isNotice.value = false;
  } on NotSchoolNetworkException {
    electricityInfo.value = "非校园网";
    isNotice.value = false;
  } on DioException catch (e, s) {
    log.w(
      "[electricity_session][update] "
      "Network Error.",
      error: e,
      stackTrace: s,
    );
    electricityInfo.value = "网络故障";
    isNotice.value = false;
  } on NotFoundException {
    electricityInfo.value = "查询失败";
    isNotice.value = false;
  } catch (e, s) {
    log.w(
      "[electricity_session][update] "
      "Exception: ",
      error: e,
      stackTrace: s,
    );
    electricityInfo.value = "程序故障";
    isNotice.value = false;
  }
}

class ElectricitySession extends NetworkSession {
  final base = "http://10.168.55.50:8088";

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

  Future<void> updateInformation() async {
    if (await NetworkSession.isInSchool == false) {
      throw NotSchoolNetworkException();
    }

    /// Get electricity password
    String password = preference.getString(
      preference.Preference.electricityPassword,
    );
    if (password.isEmpty) {
      password = "123456";
    }

    /// ASP session id.
    await dio.get("$base/searchWap/Login.aspx");
    var account = electricityAccount();

    /// Login function.
    await dio
        .post(
          "$base/ajaxpro/SearchWap_Login,App_Web_fghipt60.ashx",
          data: {
            "webName": account,
            "webPass": password,
          },
          options: Options(
            contentType: ContentType.json.toString(),
            headers: {
              "AjaxPro-Method": "getLoginInput",
              'Origin': base,
            },
          ),
        )
        .then((value) => value.data.toString());

    /// Get data.
    var page = await dio
        .get("$base/searchWap/webFrm/met.aspx")
        .then((value) => value.data);

    //int building = int.parse(account.substring(1, 4));
    RegExp name = RegExp(r"表名称：.*");
    RegExp data = RegExp(r"剩余量：.*");

    List<RegExpMatch> nameArray = name.allMatches(page).toList();
    List<RegExpMatch> dataArray = data.allMatches(page).toList();

    /* 
    List<RegExpMatch> nums = RegExp(r"[0-9]+")
      .allMatches(preference.getString(preference.Preference.dorm))
      .toList();
    int building = int.parse(nums[0][0]!.toString());
    for (int i = 0; i < nameArray.length; ++i) {
      if ((building >= 1 && building <= 4 && nameArray[i][0]!.contains("派诺")) ||
          (building >= 5 &&
              building <= 10 &&
              nameArray[i][0]!.contains("科德")) ||
          (building >= 11 && nameArray[i][0]!.contains("电表"))) {
        electricityInfo.value = dataArray[i][0]!.substring(4);
        return;
      }
    }
    */
    /// by ZCWzy
    for (int i = nameArray.length - 1; i >= 0; --i) {
      if (nameArray[i][0]!.contains("电表")) {
        electricityInfo.value = dataArray[i][0]!.replaceAll("剩余量：", "");
        log.d(
          "[electricity_session][update] "
          "electricity value: ${electricityInfo.value}.",
        );
        return;
      }
    }

    throw NotFoundException();
  }
}

class NotFoundException implements Exception {}
