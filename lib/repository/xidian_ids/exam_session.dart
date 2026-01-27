// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The exam source.
// Thanks xidian-script and libxdauth!

import 'dart:io';

import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/semester_info.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 考试安排 4768687067472349
class ExamSession extends EhallSession {
  Future<ExamData> getExamYjspt() async {
    String semester = getSemester();

    String? location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/*default/index.do",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    while (location != null) {
      var response = await dio.get(location);
      log.info("[ExamFile][getExamYjspt] Received location: $location.");
      location = response.headers[HttpHeaders.locationHeader]?[0];
    }

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

  Future<ExamData> getExamEhall() async {
    String? location = await useApp("4768687067472349");
    while (location != null) {
      var response = await dio.get(location);
      log.info("[ExamFile][getExamEhall] Received location: $location.");
      location = response.headers[HttpHeaders.locationHeader]?[0];
    }

    String semester = getSemester();

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
