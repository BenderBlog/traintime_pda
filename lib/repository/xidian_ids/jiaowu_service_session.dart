// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Super class contains Score, Exam and empty classroom.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/network_session.dart';

import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class JiaowuServiceSession extends IDSSession {
  Map<String, String> services = {
    "score": "KW.CJCX",
    "exam": "KW.KSAPCX",
    "classroom": "PK.KXJSCX",
  };

  static String authorization = "";
  Dio get authorizationDio => Dio(BaseOptions(headers: {
        HttpHeaders.authorizationHeader: authorization,
      }))
        ..interceptors.add(aliceDioAdapter);

  Future<void> getToken() async {
    String location = await checkAndLogin(
      target: "https://xxcapp.xidian.edu.cn/a_xidian/api/cas-login/index?"
          "redirect=https%3A%2F%2Fxxcapp.xidian.edu.cn%2Fuc%2Fapi%2Foauth%2F"
          "index%3Fappid%3D200190304164516885%26redirect%3Dhttps%253A%252F%252F"
          "ehall.xidian.edu.cn%252Fjwmobile%252Fauth%252Findex%26state%3DSTATE"
          "%26qrcode%3D1&from=wap",
      sliderCaptcha: (p0) async {},
    );

    var response = await dio.get(location);

    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.i(
        "[JiaowuServiceSession][getToken] "
        "Received location: $location.",
      );
      if (location.contains("ehall.xidian.edu.cn/jwmobile/index#/?token=")) {
        authorization = location.replaceAll(
          RegExp(r'https?:\/\/ehall.xidian.edu.cn\/jwmobile\/index#\/\?token='),
          "",
        );
      }
      response = await dio.get(location);
    }
  }

  Future<void> useService(String type) async {
    if (authorization.isEmpty) {
      await getToken();
    }

    var getData = await authorizationDio.post(
      "https://ehall.xidian.edu.cn/jwmobile/biz/home/updateServiceUsage",
      data: {"key": services[type]},
    ).then((value) => value.data);

    if (getData.toString().isNotEmpty && getData["code"] == 401) {
      await getToken().then((value) async {
        await authorizationDio.post(
          "https://ehall.xidian.edu.cn/jwmobile/biz/home/updateServiceUsage",
          data: {"key": services[type]},
        );
      });
    }
  }

  /// All score list.
  /*
  Future<List<Score>> getScore() async {
    List<Score> toReturn = [];

    log.i(
      "[JiaowuServiceSession][getScore] "
      "Getting the score data.",
    );

    var getData = await authorizationDio.post(
      "https://ehall.xidian.edu.cn/jwmobile/biz/v410/score/termScore",
      data: {"termCode": "*"},
    ).then((value) => value.data);

    if (getData["code"] != 200) {
      throw GetScoreFailedException(getData["msg"]);
    }

    int j = 0;
    for (var i in getData['data']['termScoreList']) {
      for (var k in i['scoreList']) {
        toReturn.add(
          Score(
            mark: j,
            name: "${k["courseName"]}",
            scoreStr: k["score"] ?? "暂无",
            year: k["termCode"],
            credit: double.parse(k["coursePoint"]),
            statusStr: k["majorFlag"],
            examTypeStr: k["examType"],
            examPropStr: k["examProp"],
            isPassed: k["passFlag"],
          ),
        );
        j++;
      }
    }
    return toReturn;
  }
  */

  /// Default fetch the current semester's exam.
  /*
  Future<ExamData> getExam() async {
    log.i(
      "[JiaowuServiceSession][getExam] "
      "Getting the exam data.",
    );
    await useService("exam");

    /// Choose the first period...
    log.i(
      "[JiaowuServiceSession][getExam] "
      "Seek for the semesters.",
    );
    String semester = await authorizationDio
        .get("https://ehall.xidian.edu.cn/jwmobile/biz/v410/examTask/termList")
        .then((value) {
      for (var i in value.data["data"]) {
        if (i["currentFlag"] == true) return i["termCode"];
      }
      return preference.getString(preference.Preference.currentSemester);
    });

    /// If failed, it is more likely that no exam has arranged.
    log.i(
      "[JiaowuServiceSession][getExam] "
      "My exam arrangemet $semester.",
    );

    List<Subject> subject = await authorizationDio
        .get(
      "https://ehall.xidian.edu.cn/jwmobile/biz/v410/examTask/listStuExamPlan"
      "?termCode=$semester",
    )
        .then((value) {
      if (value.data["code"] != 200) {
        throw GetExamFailedException(value.data["msg"]);
      }

      var data = value.data["data"];

      return List<Subject>.generate(
        data.length,
        (index) => Subject.generate(
          subject: data[index]["courseName"],
          typeStr: data[index]["batchName"] ?? "未知类型考试",
          time: data[index]["timeNote"] ?? "未知考试时间",
          place: data[index]["classroomName"] ?? "尚无安排",
          seat: int.parse(data[index]["seatNo"] ?? '-1'),
        ),
      );
    });

    List<ToBeArranged> toBeArrangedData = await authorizationDio
        .get(
      "https://ehall.xidian.edu.cn/jwmobile/biz/v410/examTask/listStuExamUnPlan"
      "?termCode=$semester",
    )
        .then((value) {
      if (value.data["code"] != 200) {
        throw GetExamFailedException(value.data["msg"]);
      }

      var data = value.data["data"];
      return List<ToBeArranged>.generate(
        data.length,
        (index) => ToBeArranged(
          subject: data[index]["courseName"],
          id: data[index]["courseNo"],
        ),
      );
    });

    return ExamData(
      subject: subject,
      toBeArranged: toBeArrangedData,
    );
  }
  */

  /// Fetch the buildings for empty classroom.
  Future<List<EmptyClassroomPlace>> getBuildingList() async {
    List<EmptyClassroomPlace> toReturn = [];
    log.i(
      "[JiaowuServiceSession][getBuildingList] "
      "Getting the empty classroom.",
    );
    await useService("exam");

    var data = await authorizationDio
        .get(
          "https://ehall.xidian.edu.cn/jwmobile/biz/v410/spareClassroom/listBuilding?"
          "pageNumber=1&campusNo=all&pageSize=50",
        )
        .then((value) => value.data["data"]["rows"]);
    for (var i in data) {
      toReturn.add(EmptyClassroomPlace(
        code: i["buildingNo"],
        name: i["buildingName"],
      ));
    }

    return toReturn;
  }

  /// The function of search the buildings inside buildingCode.
  /// params:
  ///   [buildingCode]: the code defined in [getBuildingList].
  ///   [date]: A date string with [yyyy-mm-dd] pattern.
  /// Must be executed after [getBuildingList]!
  Future<List<EmptyClassroomData>> searchEmptyClassroomData({
    required String buildingCode,
    required String date,
  }) async {
    List<EmptyClassroomData> toReturn = [];
    await authorizationDio.get(
        "https://ehall.xidian.edu.cn/jwmobile/biz/v410/spareClassroom/listUsedStatus",
        queryParameters: {
          "pageNumber": 1,
          "pageSize": 999,
          "buildingNo": buildingCode,
          "date": date,
          "periodOfTime": "00",
        }).then((value) {
      for (var i in value.data["data"]["rows"]) {
        toReturn.add(
          EmptyClassroomData(
            name: i["classroomName"],
            isUsed1To2: i["morning"][0]["used"] || i["morning"][1]["used"],
            isUsed3To4: i["morning"][2]["used"] || i["morning"][3]["used"],
            isUsed5To6: i["afternoon"][0]["used"] || i["afternoon"][1]["used"],
            isUsed7To8: i["afternoon"][2]["used"] || i["afternoon"][3]["used"],
            isUsed9To10: i["night"][0]["used"] || i["night"][1]["used"],
          ),
        );
      }
    });
    return toReturn;
  }
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}

class GetExamFailedException implements Exception {
  final String msg;
  const GetExamFailedException(this.msg);

  @override
  String toString() => msg;
}
