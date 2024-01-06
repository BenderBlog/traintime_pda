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

    List<Subject> examData = await authorizationDio
        .get(
      "https://ehall.xidian.edu.cn/jwmobile/biz/v410/examTask/listStuExamPlan"
      "?termCode=$semester",
    )
        .then((value) {
      if (value.data["code"] != 200) {
        throw GetExamFailedException(value.data["msg"]);
      }

      var data = jsonDecode('''{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "ME006002",
      "courseName": "图学基础与计算机绘图",
      "examStart": "2024-01-17 00:00:00",
      "timeStart": "15:40",
      "timeEnd": "17:40",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-227",
      "classroomName": "A-227",
      "seatNo": "36",
      "timeNote": "2024-01-17 15:40-17:40(星期三)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "AM006001",
      "courseName": "军事理论",
      "examStart": "2024-01-17 00:00:00",
      "timeStart": "09:00",
      "timeEnd": "11:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-403",
      "classroomName": "A-403",
      "seatNo": "45",
      "timeNote": "2024-01-17 09:00-11:00(星期三)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "MC006001",
      "courseName": "思想道德与法治",
      "examStart": "2024-01-15 00:00:00",
      "timeStart": "13:00",
      "timeEnd": "15:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "B",
      "buildingName": null,
      "classroomNo": "B-203",
      "classroomName": "B-203",
      "seatNo": "6",
      "timeNote": "2024-01-15 13:00-15:00(星期一)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "CS006001X",
      "courseName": "计算机导论与程序设计",
      "examStart": "2024-01-12 00:00:00",
      "timeStart": "15:40",
      "timeEnd": "17:40",
      "campusNo": null,
      "campusName": null,
      "buildingNo": null,
      "buildingName": null,
      "classroomNo": null,
      "classroomName": null,
      "seatNo": null,
      "timeNote": "2024-01-12 15:40-17:40(星期五)",
      "examTaskStatus": "0"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "FL006001",
      "courseName": "大学英语(Ⅰ)",
      "examStart": "2024-01-12 00:00:00",
      "timeStart": "09:00",
      "timeEnd": "11:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-402",
      "classroomName": "A-402",
      "seatNo": "19",
      "timeNote": "2024-01-12 09:00-11:00(星期五)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "7406b04551fa4dc4a05826e2a67257e2",
      "batchName": "2023-2024学年第一学期 期末考试",
      "courseNo": "MS006041",
      "courseName": "高等数学A(Ⅰ)",
      "examStart": "2024-01-10 00:00:00",
      "timeStart": "13:00",
      "timeEnd": "15:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-604",
      "classroomName": "A-604",
      "seatNo": "27",
      "timeNote": "2024-01-10 13:00-15:00(星期三)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "0c4b52aa211e4b268bcf0cb3c0c17804",
      "batchName": "2023-2024学年第一学期 期中考试",
      "courseNo": "MS006041",
      "courseName": "高等数学A(Ⅰ)",
      "examStart": "2023-11-07 00:00:00",
      "timeStart": "13:00",
      "timeEnd": "15:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-602",
      "classroomName": "A-602",
      "seatNo": "30",
      "timeNote": "2023-11-07 13:00-15:00(星期二)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "4ed08ce9c1d94267b788f6da656cb5eb",
      "batchName": "2023-2024学年新生入学能力测试",
      "courseNo": "RXKS00WL01",
      "courseName": "物理(入学考试)",
      "examStart": "2023-09-03 00:00:00",
      "timeStart": "19:00",
      "timeEnd": "20:30",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-604",
      "classroomName": "A-604",
      "seatNo": "45",
      "timeNote": "2023-09-03 19:00-20:30(星期日)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "4ed08ce9c1d94267b788f6da656cb5eb",
      "batchName": "2023-2024学年新生入学能力测试",
      "courseNo": "RXKS00SX01",
      "courseName": "数学(入学考试)",
      "examStart": "2023-09-03 00:00:00",
      "timeStart": "16:00",
      "timeEnd": "17:30",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-604",
      "classroomName": "A-604",
      "seatNo": "45",
      "timeNote": "2023-09-03 16:00-17:30(星期日)",
      "examTaskStatus": "1"
    },
    {
      "batchId": "4ed08ce9c1d94267b788f6da656cb5eb",
      "batchName": "2023-2024学年新生入学能力测试",
      "courseNo": "RXKS00YY01",
      "courseName": "英语(入学考试)",
      "examStart": "2023-09-03 00:00:00",
      "timeStart": "13:00",
      "timeEnd": "15:00",
      "campusNo": "S",
      "campusName": null,
      "buildingNo": "A",
      "buildingName": null,
      "classroomNo": "A-604",
      "classroomName": "A-604",
      "seatNo": "45",
      "timeNote": "2023-09-03 13:00-15:00(星期日)",
      "examTaskStatus": "1"
    }
  ]
}''')["data"];

      return List<Subject>.generate(
        data.length,
        (index) => Subject(
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
