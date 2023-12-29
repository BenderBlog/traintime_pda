// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Super class contains Score, Exam and empty classroom.

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/network_session.dart';

import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
        ..interceptors.add(alice.getDioInterceptor());

  Future<void> getToken() async {
    String location = await checkAndLogin(
      target: "https://xxcapp.xidian.edu.cn/a_xidian/api/cas-login/index?"
          "redirect=https%3A%2F%2Fxxcapp.xidian.edu.cn%2Fuc%2Fapi%2Foauth%2F"
          "index%3Fappid%3D200190304164516885%26redirect%3Dhttps%253A%252F%252F"
          "ehall.xidian.edu.cn%252Fjwmobile%252Fauth%252Findex%26state%3DSTATE"
          "%26qrcode%3D1&from=wap",
    );

    var response = await dio.get(location);

    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "Jiaowu initSession");
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
  Future<List<Score>> getScore() async {
    List<Score> toReturn = [];

    developer.log("Getting the score data.", name: "Jiaowu getScore");
    await useService("score");

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
            status: k["majorFlag"],
            examType: k["examType"],
            examProp: k["examProp"],
            isPassed: k["passFlag"],
          ),
        );
        j++;
      }
    }
    return toReturn;
  }

  /// Default fetch the current semester's exam.
  Future<(List<Subject>, List<ToBeArranged>)> getExam() async {
    developer.log("Getting the exam data.", name: "Jiaowu getExam");
    await useService("exam");

    /// Choose the first period...
    developer.log("Seek for the semesters.", name: "Jiaowu getExam");
    String semester = await authorizationDio
        .get("https://ehall.xidian.edu.cn/jwmobile/biz/v410/examTask/termList")
        .then((value) {
      for (var i in value.data["data"]) {
        if (i["currentFlag"] == true) return i["termCode"];
      }
      return preference.getString(preference.Preference.currentSemester);
    });

    /// If failed, it is more likely that no exam has arranged.
    developer.log("My exam arrangemet $semester", name: "Jiaowu getExam");

    /*
    List<Subject> examData = await authorizationDio
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
        (index) => Subject(
          subject: data[index]["courseName"],
          type: data[index]["batchName"].toString().contains("期末考试")
              ? "期末考试"
              : data[index]["batchName"].toString().contains("期中考试")
                  ? "期中考试"
                  : data[index]["batchName"],
          time: data[index]["timeNote"],
          place: data[index]["classroomName"],
          seat: int.parse(data[index]["seatNo"]),
        ),
      );
    });
    */

    var data = jsonDecode('''{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "MI204011",
      "courseName": "半导体器件物理（II）",
      "examStart": "2024-01-12 00:00:00",
      "timeStart": "15:40",
      "timeEnd": "17:40",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-318",
      "classroomName": "A-318",
      "seatNo": "26",
      "timeNote": "2024-01-12 15:40-17:40(星期五)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "MI024003",
      "courseName": "数字信号处理",
      "examStart": "2024-01-09 00:00:00",
      "timeStart": "18:40",
      "timeEnd": "20:40",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-217",
      "classroomName": "A-217",
      "seatNo": "29",
      "timeNote": "2024-01-09 18:40-20:40(星期二)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7e96d9d438ee4c6da363a250a03540d9",
      "batchName": "2023-2024学年第一学期 结课考试",
      "courseNo": "MI205003",
      "courseName": "计算机原理与系统设计",
      "examStart": "2024-01-05 00:00:00",
      "timeStart": "15:40",
      "timeEnd": "17:40",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-223",
      "classroomName": "A-223",
      "seatNo": "6",
      "timeNote": "2024-01-05 15:40-17:40(星期五)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7e96d9d438ee4c6da363a250a03540d9",
      "batchName": "2023-2024学年第一学期 结课考试",
      "courseNo": "MI204010",
      "courseName": "半导体器件物理（I）（双语）",
      "examStart": "2023-12-29 00:00:00",
      "timeStart": "18::4",
      "timeEnd": "-20:4",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-217",
      "classroomName": "A-217",
      "seatNo": "34",
      "timeNote": "2023-12-29 18::40-20:40(星期五)",
      "examTaskStatus": "1"
    }
  ]
}''')["data"];
    List<Subject> examData = List<Subject>.generate(
      data.length,
      (index) => Subject(
        subject: data[index]["courseName"],
        type: data[index]["batchName"].toString().contains("期末考试")
            ? "期末考试"
            : data[index]["batchName"].toString().contains("期中考试")
                ? "期中考试"
                : data[index]["batchName"].toString().contains("结课考试")
                    ? "结课考试"
                    : data[index]["batchName"],
        time: data[index]["timeNote"],
        place: data[index]["classroomName"],
        seat: int.parse(data[index]["seatNo"]),
      ),
    );
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

    return (examData, toBeArrangedData);
  }

  /// Fetch the buildings for empty classroom.
  Future<List<EmptyClassroomPlace>> getBuildingList() async {
    List<EmptyClassroomPlace> toReturn = [];
    developer.log(
      "Getting the empty classroom.",
      name: "Jiaowu getBuildingList",
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
