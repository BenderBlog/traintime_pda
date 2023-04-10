import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';

var sportScore = SportScore().obs;

Future<void> getScore() async {
  sportScore.value.situation = "正在获取";
  developer.log("开始获取打卡信息", name: "GetPunchSession");
  SportScore toReturn = SportScore();
  try {
    if (userId == "") {
      await login();
    }
    var response = await require(
      subWebsite: "measure/getStuTotalScore",
      body: {"userId": userId},
    );
    for (var i in response["data"]) {
      if (i.keys.contains("graduationStatus")) {
        toReturn.total = i["totalScore"];
        toReturn.detail = i["gradeType"];
      } else {
        SportScoreOfYear toAdd = SportScoreOfYear(
            year: i["year"],
            totalScore: i["totalScore"],
            rank: i["rank"],
            gradeType: i["gradeType"]);
        var anotherResponse = await require(
          subWebsite: "measure/getStuScoreDetail",
          body: {"meaScoreId": i["meaScoreId"]},
        );
        for (var i in anotherResponse["data"]) {
          toAdd.details.add(SportItems(
              examName: i["examName"],
              examunit: i["examunit"],
              actualScore: i["actualScore"] ?? "0",
              score: i["score"] ?? 0.0,
              rank: i["rank"] ?? "不及格"));
        }
        toReturn.list.add(toAdd);
      }
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
    sportScore.value = toReturn;
  }
}
