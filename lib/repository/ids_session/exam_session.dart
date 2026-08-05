// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The exam source.
// Thanks xidian-script and libxdauth!

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/user_role.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/ids_session/ehall_session.dart';
import 'package:watermeter/repository/ids_session/ids_session.dart';

/// 考试安排 4768687067472349
class ExamSession extends EhallSession {
  static const _examDataCacheName = "exam.json";
  static const _examDataGroupFileName = "ExamFile.json";
  static final File _examDataCache = File(
    "${supportPath.path}/$_examDataCacheName",
  );

  bool get isCacheExist => _examDataCache.existsSync();

  void deleteCache() {
    if (_examDataCache.existsSync()) {
      _examDataCache.deleteSync();
    }
  }

  Future<void> updateCacheAndGroup(ExamData data) async {
    await _examDataCache.writeAsString(jsonEncode(data.toJson()));
    if (Platform.isIOS) {
      final api = SaveToGroupIdSwiftApi();
      try {
        bool result = await api.saveToGroupId(
          FileToGroupID(
            appid: pref.appId,
            fileName: _examDataGroupFileName,
            data: jsonEncode(data.toJson()),
          ),
        );
        log.info(
          "[ExamSession][updateCacheAndGroup] "
          "ios Save to public place status: $result.",
        );
      } catch (e, s) {
        log.handle(e, s);
      }
    }
  }

  (DateTime, ExamData)? getCache() {
    try {
      ExamData toReturn = ExamData.fromJson(
        jsonDecode(_examDataCache.readAsStringSync()),
      );
      DateTime fetchTime = _examDataCache.lastModifiedSync();
      return (fetchTime, toReturn);
    } catch (e, s) {
      log.handle(e, s);
      return null;
    }
  }

  Future<FetchResult<ExamData>> getScoreInfo(
    String semester,
    UserRole role,
  ) async {
    try {
      ExamData data = role == UserRole.postgraduate
          ? await _getExamYjspt(semester)
          : await _getExamEhall(semester);
      DateTime fetchTime = DateTime.now();
      await updateCacheAndGroup(data);
      return FetchResult.fresh(fetchTime: fetchTime, data: data);
    } catch (e, s) {
      log.handle(e, s, "[getScoreInfo] Have issue");
      (DateTime, ExamData)? cache = getCache();
      if (cache != null) {
        return FetchResult.cache(
          fetchTime: cache.$1,
          data: cache.$2,
          hintKey: _cacheHintFromError(e),
        );
      }
      rethrow;
    }
  }

  String _cacheHintFromError(Object error) {
    if (error is PasswordWrongException) {
      return "exam.cache_hint_password_wrong";
    }
    if (error is LoginFailedException) {
      return "exam.cache_hint_login_failed";
    }
    if (error is DioException) {
      return "exam.cache_hint_network_failed";
    }
    return "exam.cache_hint_unknown_error";
  }

  Future<ExamData> _getExamYjspt(String semester) async {
    final location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/*default/index.do",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(),
    );

    await followIDSRedirects(initialLocation: location, client: dio);

    /// wdksap 我的考试安排
    log.info("[ExamFile][getExamYjspt] My exam arrangemet $semester");
    var data = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/wdksxxcx.do",
          queryParameters: {
            "querySetting":
                '''[
          {"name":"XNXQDM","caption":"学年学期代码","builder":"equal","linkOpt":"AND","value":"$semester"},
          {"name":"SFFBKSAP","caption":"是否发布考试安排","builder":"equal","linkOpt":"AND","value":"1"},
          {"name":"XH","caption":"学号","builder":"equal","linkOpt":"AND","value":"${pref.getString(pref.Preference.idsAccount)}"},
          {"name":"KSAPWID","caption":"考试安排WID","builder":"notEqual","linkOpt":"AND","value":null}]''',
            "pageSize": 1000,
            "pageNumber": 1,
          },
        )
        .then((value) => value.data["datas"]["wdksxxcx"]["rows"]);

    List<Subject> subject = [];

    if (data != null) {
      for (var i in data) {
        subject.add(
          Subject.generate(
            subject: i["KCMC"],
            typeStr: i["KSLXDM_DISPLAY"],
            time: i["KSSJMS"],
            place: i["JASMC"],
            seat: null,
          ),
        );
      }
    }

    return ExamData(subject: subject, toBeArranged: []);
  }

  Future<ExamData> _getExamEhall(String semester) async {
    final location = await useApp("4768687067472349");
    await followIDSRedirects(initialLocation: location, client: dio);

    /// wdksap 我的考试安排
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程(正在安排中，不抓)
    /// If failed, it is more likely that no exam has arranged.
    log.info(
      "[ExamFile][getExam] "
      "My exam arrangemet $semester",
    );
    List<Subject> subject = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys"
          "/studentWdksapApp/modules/wdksap/wdksap.do",
          queryParameters: {"XNXQDM": semester, "*order": "-KSRQ,-KSSJMS"},
        )
        .then((value) {
          if (value.data["code"] != "0" ||
              value.data["datas"]["wdksap"]["rows"] == null) {
            if (value.data["datas"]["wdksap"]["extParams"]["msg"] != null) {
              throw GetExamFailedException(
                "未安排考试信息获取失败："
                "${value.data["datas"]["wdksap"]["extParams"]["msg"]}",
              );
            }
            throw const GetExamFailedException("考试信息获取失败：无法解析数据");
          }
          var data = value.data["datas"]["wdksap"]["rows"];

          /// Deal with disqualified in advance
          return List<Subject>.generate(
            data.length,
            (index) => Subject.generate(
              subject: data[index]["KCM"],
              typeStr: data[index]["KSMC"] ?? "未知类型考试",
              time: data[index]["KSSJMS"] ?? "未知考试时间",
              place: data[index]["JASMC"] ?? "尚无安排",
              seat: data[index]["ZWH"] ?? '未知座位',
            ),
          );
        });

    List<ToBeArranged> toBeArrangedData = await dioEhall
        .post(
          "https://ehall.xidian.edu.cn/jwapp/sys"
          "/studentWdksapApp/modules/wdksap/cxyxkwapkwdkc.do",
          queryParameters: {"XNXQDM": semester},
        )
        .then((value) {
          if (value.data["code"] != "0" ||
              value.data["datas"]["cxyxkwapkwdkc"]["rows"] == null) {
            if (value.data["datas"]["cxyxkwapkwdkc"]["extParams"]["msg"] !=
                null) {
              throw GetExamFailedException(
                "未安排考试信息获取失败："
                "${value.data["datas"]["cxyxkwapkwdkc"]["extParams"]["msg"]}",
              );
            }
            throw const GetExamFailedException("未安排考试信息获取失败：无法解析数据");
          }
          var data = value.data["datas"]["cxyxkwapkwdkc"]["rows"];
          return List<ToBeArranged>.generate(
            data.length,
            (index) => ToBeArranged(
              subject: data[index]["KCM"],
              id: data[index]["KCH"],
            ),
          );
        });

    return ExamData(subject: subject, toBeArranged: toBeArrangedData);
  }
}

class GetExamFailedException implements Exception {
  final String msg;
  const GetExamFailedException(this.msg);

  @override
  String toString() => msg;
}
