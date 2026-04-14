// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The score window source.
// Thanks xidian-script and libxdauth!

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

String _cacheHintFromError(Object error) {
  if (error is PasswordWrongException) {
    return "score.cache_hint_password_wrong";
  }
  if (error is LoginFailedException) {
    return "score.cache_hint_login_failed";
  }
  if (error is DioException) {
    return "score.cache_hint_network_failed";
  }
  return "score.cache_hint_unknown_error";
}

/// 考试成绩 4768574631264620
class ScoreSession extends EhallSession {
  static const scoreListCacheName = "scores.json";
  static File file = File("${supportPath.path}/$scoreListCacheName");

  static bool get isCacheExist => file.existsSync();

  /// Must be called after [getScore]!
  /// If bug, just return dummy data.
  Future<List<ComposeDetail>> getDetail(
    String? JXBID,
    String semesterCode, {
    bool needRelogin = false,
  }) async {
    if (JXBID == null) {
      return [ComposeDetail(content: "教学班编号", ratio: "未知", score: "无法查询")];
    }

    try {
      List<ComposeDetail> toReturn = [];

      if (needRelogin) {
        log.info("[ScoreSession][getDetail] Cache detected, need login.");

        var firstPost = await useApp("4768574631264620");
        log.info("[ScoreSession] First post: $firstPost.");
        await dioEhall.get(firstPost);
      }

      var response = await dio
          .post(
            "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/cxkckgcxlrcj.do",
            data: {
              "JXBID": JXBID,
              'XH': pref.getString(pref.Preference.idsAccount),
              'XNXQDM': semesterCode,
              'CKLY': 1,
            },
          )
          .then((value) => value.data);

      if (response["datas"]["cxkckgcxlrcj"]["rows"][0]["GCXKHLRCJGS"] != null) {
        List<String> formula =
            response["datas"]["cxkckgcxlrcj"]["rows"][0]["GCXKHLRCJGS"]
                .toString()
                .split(RegExp(r'( \+ |\*| = )'));
        List<String> detailList =
            response["datas"]["cxkckgcxlrcj"]["rows"][0]["KCGCXKHLRCJ"]
                .toString()
                .split(RegExp(r','));
        Map<String, String> detail = {
          for (var v in detailList) v.split(':')[0]: v.split(':')[1],
        };
        int i = 0;
        while (i < formula.length) {
          if (formula[i] == "总评成绩") {
            i++;
            continue;
          }
          toReturn.add(
            ComposeDetail(
              content: formula[i],
              ratio: "${double.parse(formula[i + 1]) * 100}%",
              score: detail[formula[i]] ?? '未登记',
            ),
          );
          i += 2;
        }
      }

      return toReturn;
    } catch (e, s) {
      log.info("[ScoreSession][getDetail] Fetch detail error: $e $s.");

      return [ComposeDetail(content: "", ratio: "获取详情失败", score: "")];
    }
  }

  void dumpScoreListCache(List<Score> scores) {
    file.writeAsStringSync(jsonEncode(scores));
    log.info(
      "[ScoreWindow][dumpScoreListCache] "
      "Dumped scoreList to ${supportPath.path}/$scoreListCacheName.",
    );
  }

  Future<List<Score>> getScoreFromYjspt() async {
    List<Score> toReturn = [];

    log.info("[ScoreSession][getScoreFromYjspt] Ready to login the system.");
    String? location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp/sys/wdcjapp/*default/index.do",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    while (location != null) {
      var response = await dio.get(location);
      log.info("[ExamFile][getScoreFromYjspt] Received location: $location.");
      location = response.headers[HttpHeaders.locationHeader]?[0];
    }

    log.info("[ScoreSession][getScoreFromYjspt] Getting the score data.");
    var getData = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdcjapp/modules/wdcj/xscjcx.do",
          data: {"querySetting": [], 'pageSize': 1000, 'pageNumber': 1},
        )
        .then((value) => value.data);

    log.info("[ScoreSession][getScoreFromYjspt] Dealing the score data.");
    if (getData["datas"]["xscjcx"]["extParams"]["code"] != 1) {
      throw GetScoreFailedException(
        getData['datas']['xscjcx']["extParams"]["msg"],
      );
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      toReturn.add(
        Score(
          mark: j,
          name: "${i["KCMC"]}",
          score: i["DYBFZCJ"],
          semesterCode: i["XNXQDM_DISPLAY"],
          credit: i["XF"],
          classStatus: i["KCLBMC"],
          scoreTypeCode: int.parse(i["CJFZDM"]),
          level: i["CJFZDM"] != "0" ? i["CJXSZ"] : null,
          isPassedStr: i["SFJG"].toString(),
          classID: i["KCDM"],
          classType: i['KCLBMC'],
          scoreStatus: i["KSXZDM_DISPLAY"],
        ),
      );
      j++;
    }
    return toReturn;
  }

  Future<List<Score>> getScoreFromEhall() async {
    List<Score> toReturn = [];

    /// Otherwise get fresh score data.
    Map<String, dynamic> querySetting = {
      'name': 'SFYX',
      'value': '1',
      'linkOpt': 'and',
      'builder': 'm_value_equal',
    };
    log.info(
      "[ScoreSession][getScoreFromEhall] "
      "Ready to log into the system.",
    );
    var firstPost = await useApp("4768574631264620");
    log.info("[ScoreSession] First post: $firstPost.");
    await dioEhall.get(firstPost);

    log.info(
      "[ScoreSession][getScoreFromEhall] "
      "Getting score data.",
    );
    var getData = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
          data: {
            "*json": 1,
            "querySetting": json.encode(querySetting),
            "*order": '+XNXQDM,KCH,KXH',
            'pageSize': 1000,
            'pageNumber': 1,
          },
        )
        .then((value) => value.data);
    log.info(
      "[ScoreSession][getScoreFromEhall] "
      "Dealing with the score data.",
    );
    if (getData['datas']['xscjcx']["extParams"]["code"] != 1) {
      throw GetScoreFailedException(
        getData['datas']['xscjcx']["extParams"]["msg"],
      );
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      toReturn.add(
        Score(
          mark: j,
          name: i["XSKCM"], // 课程名
          score: i["ZCJ"], // 总成绩
          semesterCode: i["XNXQDM"], // 学年学期代码
          credit: i["XF"], // 学分
          classStatus: i["XGXKLBDM_DISPLAY"].toString().isEmpty
              ? i["KCXZDM_DISPLAY"]
              : "选修 ${i["XGXKLBDM_DISPLAY"]}", // 课程性质，必修，选修等
          classType: i["KCLBDM_DISPLAY"], // 课程类别，公共任选，素质提高等
          scoreStatus: i["CXCKDM_DISPLAY"], // 重修重考等
          scoreTypeCode: int.parse(
            i["DJCJLXDM"],
          ), // 等级成绩类型，01 三级成绩 02 五级成绩 03 两级成绩
          level: i["DJCJMC"], // 等级成绩
          isPassedStr: i["SFJG"], // 是否及格
          classID: i["JXBID"], // 教学班 ID
        ),
      );
      j++;
    }
    return toReturn;
  }

  Future<FetchResult<List<Score>>> getScore() async {
    List<Score> toReturn = [];
    List<Score> cache = [];

    /// Try retrieving cached scores first.
    log.info(
      "[ScoreSession][getScore] "
      "Path at ${supportPath.path}/$scoreListCacheName.",
    );
    if (file.existsSync()) {
      log.info(
        "[ScoreSession][getScore] "
        "Cache file found.",
      );
      cache = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .map((s) => Score.fromJson(s as Map<String, dynamic>))
          .toList();
    } else {
      log.info(
        "[ScoreSession][getScore] "
        "Cache file non-existent.",
      );
    }

    /// Otherwise get fresh score data.
    log.info(
      "[ScoreSession][getScore] "
      "Start getting score data.",
    );

    try {
      toReturn = pref.getBool(pref.Preference.role)
          ? await getScoreFromYjspt()
          : await getScoreFromEhall();
      DateTime fetchTime = DateTime.now();
      dumpScoreListCache(toReturn);
      log.info(
        "[ScoreSession][getScore] "
        "Cached the score data.",
      );
      return FetchResult.fresh(fetchTime: fetchTime, data: toReturn);
    } catch (e, s) {
      log.handle(e, s, "[ScoreSession][getScore] Have issue");
      if (cache.isNotEmpty) {
        return FetchResult.cache(
          fetchTime: file.lastModifiedSync(),
          data: cache,
          hintKey: _cacheHintFromError(e),
        );
      } else {
        rethrow;
      }
    }
  }
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}
