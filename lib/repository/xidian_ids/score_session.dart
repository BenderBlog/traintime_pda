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
import 'package:watermeter/model/user.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 考试成绩 4768574631264620
class ScoreFile extends EhallSession {
  /// [JXBID] 教学班ID
  /// [XNXQDM] 学年学期代码
  /// This function gets the composement of the score.
  // ignore: non_constant_identifier_names
  Future<Compose> getDetail(String JXBID, String XNXQDM) async {
    Compose toReturn = Compose();
    var response = await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/cxkckgcxlrcj.do",
        data: {
          "JXBID": JXBID,
          'XH': user["idsAccount"],
          'XNXQDM': XNXQDM,
          'CKLY': 1
        }).then((value) => value.data);

    if (response["datas"]["cxkckgcxlrcj"]["rows"][0]["GCXKHLRCJGS"] != null) {
      List<String> formula = response["datas"]["cxkckgcxlrcj"]["rows"][0]
              ["GCXKHLRCJGS"]
          .toString()
          .split(RegExp(r'( \+ |\*| = )'));
      List<String> detailList = response["datas"]["cxkckgcxlrcj"]["rows"][0]
              ["KCGCXKHLRCJ"]
          .toString()
          .split(RegExp(r','));
      Map<String, String> detail = {
        for (var v in detailList) v.split(':')[0]: v.split(':')[1]
      };
      int i = 0;
      while (i < formula.length) {
        if (formula[i] == "总评成绩") {
          i++;
          continue;
        }
        toReturn.score.add(ComposeDetail(
            content: formula[i],
            ratio: "${double.parse(formula[i + 1]) * 100}%",
            score: detail[formula[i]] ?? '未登记'));
        i += 2;
      }
    }

    return toReturn;
  }

  /// [KCH] 学科ID
  /// [XNXQDM] 学年学期代码
  /// This function gets the place of your score in class.
  // ignore: non_constant_identifier_names
  Future<ScorePlace> getPlaceInGrade(String KCH, String XNXQDM) async {
    ScorePlace data = ScorePlace();

    /// Place in the class.
    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbxspmcx.do",
        data: {
          'XH': user["idsAccount"],
          'JXBID': '*',
          'XNXQDM': XNXQDM,
          'KCH': KCH,
          'TJLX': "02"
        }).then((value) {
      data.place = int.parse(value.data["datas"]["jxbxspmcx"]["rows"][0]["PM"]);
      data.total =
          int.parse(value.data["datas"]["jxbxspmcx"]["rows"][0]["ZRS"]);
    });

    /// Highest, lowest, average score of the grade.
    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbcjtjcx.do",
        data: {
          "JXBID": '*',
          'XNXQDM': XNXQDM,
          'KCH': KCH,
          'TJLX': "02"
        }).then((value) {
      data.highest =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["ZGF"]);
      data.lowest =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["ZDF"]);
      data.average =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["PJF"]);
    });

    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbcjfbcx.do",
        data: {
          "JXBID": '*',
          'XNXQDM': XNXQDM,
          'KCH': KCH,
          'TJLX': "02",
          '*order': '+DJDM',
        }).then((value) {
      for (var i in value.data["datas"]["jxbcjfbcx"]["rows"]) {
        data.statistics.add(
            ScoreStatistics(level: i["DJDM"], people: int.parse(i["DJSL"])));
      }
    });

    return data;
  }

  /// [JXBID] 教学班ID
  /// [XNXQDM] 学年学期代码
  /// This function gets the place of your score in class.
  // ignore: non_constant_identifier_names
  Future<ScorePlace> getPlaceInClass(String JXBID, String XNXQDM) async {
    ScorePlace data = ScorePlace();

    /// Place in the class.
    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbxspmcx.do",
        data: {
          'XH': user["idsAccount"],
          'JXBID': JXBID,
          'XNXQDM': XNXQDM,
          'TJLX': "01"
        }).then((value) {
      data.place = int.parse(value.data["datas"]["jxbxspmcx"]["rows"][0]["PM"]);
      data.total =
          int.parse(value.data["datas"]["jxbxspmcx"]["rows"][0]["ZRS"]);
    });

    /// Highest, lowest, average score of the grade.
    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbcjtjcx.do",
        data: {
          "JXBID": JXBID,
          'XNXQDM': XNXQDM,
          'TJLX': "01",
        }).then((value) {
      data.highest =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["ZGF"]);
      data.lowest =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["ZDF"]);
      data.average =
          double.parse(value.data["datas"]["jxbcjtjcx"]["rows"][0]["PJF"]);
    });

    await dio.post(
        "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/jxbcjfbcx.do",
        data: {
          "JXBID": JXBID,
          'XNXQDM': XNXQDM,
          'TJLX': "01",
          '*order': '+DJDM',
        }).then((value) {
      for (var i in value.data["datas"]["jxbcjfbcx"]["rows"]) {
        data.statistics.add(
            ScoreStatistics(level: i["DJDM"], people: int.parse(i["DJSL"])));
      }
    });

    return data;
  }

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
      throw GetScoreFailedException(
          getData['datas']['xscjcx']["extParams"]["msg"]);
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
          courseID: i["KCH"],
          isPassed: i["SFJG"] ?? "-1"));
      j++;
    }
    return toReturn;
  }
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}
