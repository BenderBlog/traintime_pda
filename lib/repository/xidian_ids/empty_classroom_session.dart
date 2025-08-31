// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 空闲教室查询 4768402106681759
class EmptyClassroomSession extends EhallSession {
  String baseUrl = "https://ehall.xidian.edu.cn/jwapp/sys/kxjas/modules/kxjas";
  String target =
      "https://ehall.xidian.edu.cn/jwapp/sys/kxjas/*default/index.do";

  Map<String, String> buildingSetting(String jxldm) => {
    "name": "JXLDM",
    "caption": "教学楼代码",
    "builder": "equal",
    "linkOpt": "AND",
    "value": jxldm,
  };

  Map<String, String> semesterSetting(String xnxqdm) => {
    "name": "XNXQDM",
    "value": xnxqdm,
    "linkOpt": "AND",
    "builder": "equal",
  };

  Map<String, dynamic> weekCountSetting(weekCount) => {
    "name": "ZC",
    "value": weekCount,
    "linkOpt": "AND",
    "builder": "equal",
  };

  Map<String, dynamic> weekDaySetting(weekDay) => {
    "name": "ZC",
    "value": weekDay,
    "linkOpt": "AND",
    "builder": "equal",
  };

  List<Map<String, String>> classroomSetting(String mcOrdm) => [
    {
      "name": "JASDM",
      "caption": "教室代码",
      "builder": "include",
      "linkOpt": "AND",
      "value": mcOrdm,
    },
    {
      "name": "JASMC",
      "caption": "教室名称",
      "builder": "include",
      "linkOpt": "OR",
      "value": mcOrdm,
    },
  ];

  /// This is the first function we need to execute
  Future<List<EmptyClassroomPlace>> getBuildingList() async {
    List<EmptyClassroomPlace> toReturn = [];
    developer.log("Ready to login the system.", name: "Ehall emptyClassroom");
    var firstPost = await useApp("4768402106681759");
    await dio.get(firstPost);
    var data = await dio
        .post("$baseUrl/jxlcx.do", data: {"*order": "+XXXQDM,+PX,+JXLDM"})
        .then((value) => value.data["datas"]["jxlcx"]["rows"]);
    for (var i in data) {
      toReturn.add(EmptyClassroomPlace(code: i["JXLDM"], name: i["JXLJC"]));
    }
    return toReturn;
  }

  /// The function of search the buildings inside buildingCode.
  /// params:
  ///   [buildingCode]: the code defined in [getBuildingList].
  ///   [date]: A date string with [yyyy-mm-dd] pattern.
  ///   [semesterRange]: A year range in string. e.g. [2022-2023]
  ///   [semesterPart]: The part in the semester. Only allow 1 and 2
  Future<List<EmptyClassroomData>> searchData({
    required String buildingCode,
    required String date,
    required String semesterRange,
    required String semesterPart,
  }) async {
    (dynamic, dynamic) dateData = await dio
        .post(
          "$baseUrl/rqzhzcjc.do",
          data: {"RQ": date, "XN": semesterRange, "XQ": semesterPart},
        )
        .then(
          (value) => (
            value.data["datas"]["rqzhzcjc"]["ZC"],
            value.data["datas"]["rqzhzcjc"]["XQJ"],
          ),
        );

    List<EmptyClassroomData> toReturn = [];

    await dio
        .post(
          "$baseUrl/cxjsqk.do",
          data: {
            "XNXQDM": "$semesterRange-$semesterPart",
            "ZC": dateData.$1,
            "XQ": dateData.$2,
            "querySetting": jsonEncode([
              buildingSetting(buildingCode),
              semesterSetting("$semesterRange-$semesterPart"),
              weekCountSetting(dateData.$1),
              weekDaySetting(dateData.$2),
            ]),
            '*order': "+LC,+JASMC",
            'pageSize': 999,
            'pageNumber': 1,
          },
        )
        .then((value) {
          for (var i in value.data["datas"]["cxjsqk"]["rows"]) {
            toReturn.add(
              EmptyClassroomData(
                name: i["JASMC"]
                    .toString()
                    .replaceAll(RegExp(r'[(（]'), "\n")
                    .replaceAll(RegExp(r'[)）]'), ""),
                isUsed: List.generate(
                  10,
                  (index) => i["JC${index + 1}"].toString().contains("1_"),
                  growable: false,
                ),
              ),
            );
          }
        });
    return toReturn;
  }
}
