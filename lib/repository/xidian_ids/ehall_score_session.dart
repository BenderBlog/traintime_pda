// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The score window source.
// Thanks xidian-script and libxdauth!

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 考试成绩 4768574631264620
class ScoreSession extends EhallSession {
  Future<List<Score>> getScore() async {
    List<Score> toReturn = [];

    /// Get all scores here.
    log.i(
      "[ScoreSession] Start getting the score.",
    );
    Map<String, dynamic> querySetting = {
      'name': 'SFYX',
      'value': '1',
      'linkOpt': 'and',
      'builder': 'm_value_equal',
    };

    log.i(
      "[ScoreSession] Ready to login the system.",
    );
    var firstPost = await useApp("4768574631264620");
    log.i(
      "[ScoreSession] First post: $firstPost.",
    );
    await dioEhall.get(firstPost);

    log.i(
      "[ScoreSession] Getting the score data.",
    );
    var getData = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize': 1000,
        'pageNumber': 1,
      },
    ).then((value) => value.data);
    log.i(
      "[ScoreSession] Dealing the score data.",
    );
    if (getData['datas']['xscjcx']["extParams"]["code"] != 1) {
      throw GetScoreFailedException(
        getData['datas']['xscjcx']["extParams"]["msg"],
      );
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      toReturn.add(Score(
        mark: j,
        name: i["XSKCM"], // 课程名
        score: i["ZCJ"], // 总成绩
        semesterCode: i["XNXQDM"], // 学年学期代码
        credit: i["XF"], // 学分
        classStatus: i["KCXZDM_DISPLAY"], // 课程性质，必修，选修等
        classType: i["KCLBDM_DISPLAY"], // 课程类别，公共任选，素质提高等
        scoreStatus: i["CXCKDM_DISPLAY"], // 重修重考等
        scoreTypeCode: int.parse(
          i["DJCJLXDM"],
        ), // 等级成绩类型，01 三级成绩 02 五级成绩 03 两级成绩
        level: i["DJCJMC"], // 等级成绩
        isPassedStr: i["SFJG"], // 是否及格
      ));
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
