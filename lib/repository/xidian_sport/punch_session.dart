import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/user.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';

var punchData = PunchDataList().obs;

Future<void> getPunch() async {
  punchData.value.situation = "正在获取";
  PunchDataList toReturn = PunchDataList();
  try {
    if (userId == "") {
      await login();
    }
    var response = await require(
      subWebsite: "stuPunchRecord/findPager",
      body: {
        'userNum': user["idsAccount"],
        'sysTermId': await getTermID(),
        'pageSize': 999,
        'pageIndex': 1
      },
    );
    for (var i in response["data"]) {
      toReturn.allTime++;
      if (i["state"].toString().contains("恭喜你本次打卡成功")) {
        toReturn.valid++;
      }
      toReturn.all.add(PunchData(
        i["machineName"],
        i["weekNum"],
        i["punchDay"],
        i["punchTime"],
        i["state"],
      ));
    }
  } on NoPasswordException {
    toReturn.situation = "无密码信息";
  } on LoginFailedException catch (e) {
    developer.log("登录失败：$e", name: "GetPunchSession");
    toReturn.situation = "登录失败";
  } on SemesterFailedException catch (e) {
    developer.log("未获取学期值：$e", name: "GetPunchSession");
    toReturn.situation = "未获取学期值";
  } on DioError catch (e) {
    developer.log("网络故障：$e", name: "GetPunchSession");
    toReturn.situation = "网络故障";
  } catch (e) {
    developer.log("未知故障：$e", name: "GetPunchSession");
    toReturn.situation = "未知故障";
  } finally {
    punchData.value = toReturn;
  }
}
