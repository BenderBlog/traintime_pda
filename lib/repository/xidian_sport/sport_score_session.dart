import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';

class SportScoreSession extends SportSession {
  /// "Static" Data.
  Future<SportScore> getSportScore() async {
    SportScore toReturn = SportScore();
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
    return toReturn;
  }
}
