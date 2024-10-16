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
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

var owe = "".obs;
var electricityInfo = "".obs;
var isNotice = true.obs;

Future<void> update() async {
  isNotice.value = true;
  electricityInfo.value = "正在获取";
  owe.value = "正在获取欠费";
  await PaymentSession()
      .loginPayment()
      .then((value) => Future.wait([
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
                electricityInfo.value = "查询故障";
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
          ]))
      .catchError((e, s) {
    log.handle(e, s);
    if (NeedInfoException().toString().contains(e.toString())) {
      electricityInfo.value = "需要在缴费平台完善信息";
    } else if ("NotInitalizedException".contains(e.toString())) {
      electricityInfo.value = e.msg;
    } else if (NoAccountInfoException().toString().contains(e.toString())) {
      electricityInfo.value = "需要填写电费账号";
    } else {
      electricityInfo.value = "程序故障";
    }
    owe.value = "目前欠款无法查询";
    isNotice.value = false;
    return [null];
  });
}

class PaymentSession extends IDSSession {
  final factorycode = "E003";
  RegExp getTransfer = RegExp(
    r'"http://payment.xidian.edu.cn/NetWorkUI/(.*?)"',
  );

  /// The way to get the electricity number.
  /// Refrence here: https://see.xidian.edu.cn/html/news/9179.html
  static String electricityAccount() {
    String rawDormLocation = preference.getString(preference.Preference.dorm);
    if (rawDormLocation.isEmpty) throw NoAccountInfoException;
    if (RegExp(r'^\d+$').hasMatch(rawDormLocation)) return rawDormLocation;
    List<RegExpMatch> nums =
        RegExp(r"[0-9]+").allMatches(rawDormLocation).toList();
    // 校区
    String accountA = "";
    if (rawDormLocation.contains("北校区")) {
      accountA = "1";
    } else {
      accountA = "2";
    }
    // 楼号
    String accountB = "";
    // 区号
    String accountC = "";
    // 房间号
    String accountD = "";
    // 识别码
    String accountE = "";
    int building = -1;

    // 南校区学生公寓的情况
    if (accountA == "2") {
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
      // 南校区19-22#公寓不分区，C段编码默认为01；D段首位编码默认为层号
      if ([19, 20, 21, 22].contains(building)) {
        // 区号
        accountC = "01";
        // 宿舍号
        accountD = nums[2][0]!.toString().padLeft(4, nums[1][0]!.toString());
      }
      // 南校区18#分北楼和南楼两栋，北楼C段为20，南楼C段为10;
      // D段首位编码默认为层号
      if ([18].contains(building)) {
        if (rawDormLocation.contains("南楼")) {
          accountC = "10";
        } else {
          accountC = "20";
        }
        // 宿舍号
        accountD = nums[2][0]!.toString().padLeft(4, nums[1][0]!.toString());
      }
    } else {
      // 北校区公寓的情况
      // 楼号
      accountB = nums[0][0]!.toString().padLeft(3, "0");
      building = int.parse(nums[0][0]!.toString());
      // 识别码
      // 用于解决北校区北院与北校区南院不同户同时具有相同楼号、区号、房间号的冲突情况
      // 当楼号是 4,7,9,12-14,24,47-49,51-53,55# 时，识别码北院为 2 南院为 1；
      // 当楼号是 11# 时，识别码北院为 1 南院为 2；
      // 下文代码仅为判断南北院使用，后续才会对未冲突情况进行识别码的删除
      if ([4, 24, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
        if (rawDormLocation.contains("南院")) {
          accountE = "1";
        } else {
          accountE = "2";
        }
      } else if ([11].contains(building)) {
        if (rawDormLocation.contains("南院")) {
          accountE = "2";
        } else {
          accountE = "1";
        }
      } else {
        // 其余楼号不可能需要使用识别码
        accountE = "";
      }
      // 下面处理区号和宿舍号
      // 北校区 21,24,28,47-49,51-53,55# 的情况
      if ([21, 24, 28, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
        if (accountE != "1") {
          // 当该楼不属于南院时，单元号与层号相同
          // 则 C 段首位编码为 0，第二位按单元编码；D 段按房间号编码，首位补 0
          // 区号
          accountC = nums[1][0]!.toString().padLeft(2, "0");
          // 宿舍号，这样获取保准能用
          accountD = nums[2][0]!.toString().length == 1
              ? nums[3][0]!.toString().padLeft(4, "0")
              : nums[2][0]!.toString().padLeft(4, "0");
        } else {
          // 当该楼属于南院时，有单元划分
          // 则 C 段首位编码为 0，第二位按单元编码；D 段按房间号编码，首位补 0
          // 单元号即区号
          accountC = nums[1][0]!.toString().padLeft(2, "0");
          // 宿舍号
          accountD = nums[3][0]!.toString().padLeft(4, "0");
        }
      }
      // 北校区 4,94-98# 的情况
      if ([4, 94, 95, 96, 97, 98].contains(building)) {
        // C 段首位编码为 0，第二位按层编码；D 段按房间号编码，首位补 0
        // 层号即区号
        accountC = nums[1][0]!.toString().padLeft(2, "0");
        // 宿舍号
        accountD = nums[2][0]!.toString().padLeft(4, "0");
      }
      // 北校区包括 16-17# 公寓在内的其余楼号，一般具有单元划分
      // 则 C 段按单元门编码，前补 0；D 段按房间号编码，前补 0
      if ([16, 17].contains(building) || (accountC == "" && accountD == "")) {
        // 单元号即区号
        accountC = nums[1][0]!.toString().padLeft(2, "0");
        // 宿舍号，这样获取保准能用
        accountD = nums[2][0]!.toString().length == 1
            ? nums[3][0]!.toString().padLeft(4, "0")
            : nums[2][0]!.toString().padLeft(4, "0");
      }
      // 对非冲突房间进行删除识别码操作
      int room = int.parse(accountD.toString());
      if ([4, 24, 49, 51, 55].contains(building)) {
        // 上述楼号的非以下房间不存在南北院电费账号冲突，无需识别码
        if (!([101, 102, 203, 204, 305, 306, 407, 408, 509, 510]
            .contains(room))) {
          accountE = "";
        }
      }
      if ([47, 48, 52, 53].contains(building)) {
        // 上述楼号的非以下房间不存在南北院电费账号冲突，无需识别码
        if (!([101, 102, 103, 104].contains(room))) {
          accountE = "";
        }
      }
    }

    return accountA + accountB + accountC + accountD + accountE;
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

    var value = await dio.post(
      "https://payment.xidian.edu.cn/NetWorkUI/checkUserInfo",
      data: {
        "p_Userid": electricityAccount(),
        "p_Password": password,
        "factorycode": factorycode,
      },
    );
    if ((value.statusCode ?? 0) >= 300 && (value.statusCode ?? 0) < 400) {
      log.info(
        "[PaymentSession][getOwe] "
        "Newbee detected.",
      );
      bool isPostGraduate =
          await PersonalInfoSession().checkWhetherPostgraduate();

      await dio.post(value.headers["location"]![0]).then((value) async {
        await dio.post(
          "https://payment.xidian.edu.cn/NetWorkUI/perfectUserinfo",
          data: {
            "tel": isPostGraduate
                ? await PersonalInfoSession()
                    .getInformationFromYjspt(onlyPhone: true)
                : await PersonalInfoSession()
                    .getInformationEhall(onlyPhone: true),
            "email": "${preference.getString(preference.Preference.idsAccount)}"
                "@stu.mail.xidian.edu.cn",
          },
          options: Options(contentType: Headers.jsonContentType),
        );
      }).then((value) async {
        value = await dio.post(
          "https://payment.xidian.edu.cn/NetWorkUI/checkUserInfo",
          data: {
            "p_Userid": electricityAccount(),
            "p_Password": password,
            "factorycode": factorycode,
          },
        );
      });
    }

    var decodeData = jsonDecode(value.data);
    if (decodeData["returncode"] == "ERROR") {
      throw NotInitalizedException(decodeData["returnmsg"]);
    }
    return (
      decodeData["roomList"][0].toString().split('@')[0],
      decodeData["liveid"].toString(),
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
        } else if (double.parse(decodeData["dueTotal"]) > 0.0) {
          owe.value = "待清缴${decodeData["dueTotal"]}元欠费";
        } else {
          owe.value = "目前欠款无法查询";
        }
      });
}

class NotFoundException implements Exception {}

class NeedInfoException implements Exception {}

class NotInitalizedException implements Exception {
  final String msg;
  const NotInitalizedException(this.msg);
}

class NoAccountInfoException implements Exception {}
