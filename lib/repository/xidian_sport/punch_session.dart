import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';

class PunchSession extends SportSession {
  /// Dynamic data.
  Future<PunchDataList> get() async {
    PunchDataList toReturn = PunchDataList();
    if (userId == "") {
      await login();
    }
    var response = await require(
      subWebsite: "stuPunchRecord/findPager",
      body: {
        'userNum': username,
        'sysTermId': await getTermID(),
        'pageSize': "999",
        'pageIndex': "1"
      },
    );
    for (var i in response["data"]) {
      toReturn.allTime++;
      if (i["state"].toString().contains("恭喜你本次打卡成功")) {
        toReturn.valid++;
      }
      toReturn.all.add(PunchData(i["machineName"], i["weekNum"], i["punchDay"],
          i["punchTime"], i["state"]));
    }
    return toReturn;
  }
}
