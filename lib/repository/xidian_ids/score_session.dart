/*
The score window source.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 考试成绩 4768574631264620
class ScoreFile extends EhallSession {
  Future<List<Score>> get() async {
    List<Score> toReturn = [];

    /// Get information here. resultCode==00000 is successful.
    developer.log("Check whether the score has fetched in this session.",
        name: "Ehall getScore");

    /// Get all scores here.
    developer.log("Start getting the score.", name: "Ehall getScore");
    Map<String, dynamic> querySetting = {
      'name': 'SFYX',
      'value': '1',
      'linkOpt': 'and',
      'builder': 'm_value_equal',
    };

    developer.log("Ready to login the system.", name: "Ehall getScore");
    var firstPost = await useApp("4768574631264620");
    await dio.get(firstPost);

    developer.log("Getting the score data.", name: "Ehall getScore");
    var getData = await dio.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize': 1000,
        'pageNumber': 1,
      },
    ).then((value) => value.data);
    developer.log("Dealing the score data.", name: "Ehall getScore");
    if (getData['datas']['xscjcx']["extParams"]["code"] != 1) {
      throw getData['datas']['xscjcx']["extParams"]["msg"];
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      toReturn.add(Score(
          mark: j,
          name: "${i["XSKCM"]}",
          score: i["ZCJ"] ?? 0.0,
          year: i["XNXQDM"],
          credit: i["XF"],
          status: i["KCXZDM_DISPLAY"],
          how: int.parse(i["DJCJLXDM"]),
          level: i["DJCJLXDM"] == "01" || i["DJCJLXDM"] == "02"
              ? i["DJCJMC"]
              : null,
          classID: i["JXBID"],
          isPassed: i["SFJG"] ?? "-1"));
      j++;
      /* //Unable to work.
      if (i["DJCJLXDM"] == "100") {
        try {
          var anotherResponse = await dio.post(
              "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/cxkxkgcxlrcj.do",
              data: {
                "JXBID": scoreTable.last.classID,
                'XH': user["idsAccount"],
                'XNXQDM':scoreTable.last.year,
                'CKLY': "1",
              },
            options: Options(
              headers: {
                "DNT": "1",
                "Referer": firstPost
              },
            )
          );
          //print(anotherResponse.data);
        } on DioError catch (e) {
          //print("WTF:" + e.toString());
          break;
        }
      }*/
    }
    return toReturn;
  }
}
