/*
The class table model.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

class ClassDetail {
  String name; // 名称
  String? teacher; // 老师
  String? place; // 地方
  String? code; // 课程序号
  String? number; // 班级序号

  ClassDetail({
    required this.name,
    this.teacher,
    this.place,
    this.code,
    this.number,
  });

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassDetail &&
      other.runtimeType == runtimeType &&
      name == other.name;

  @override
  String toString() {
    if (place != null) {
      return "${name.length <= 15 ? name : "${name.substring(0, 14)}..."}\n$place";
    } else {
      return name;
    }
  }
}

class TimeArrangement {
  int index; // 课程索引
  // 返回的是 0 和 1 组成的数组，0 代表这周没课程，1 代表这周有课
  String weekList; // 上课周次
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  late int step; // 上课长度
  TimeArrangement({
    required this.index,
    required this.weekList,
    required this.day,
    required this.start,
    required this.stop,
  }) {
    step = stop - start;
  }
}

class ClassTable {
  List<ClassDetail> classDetail = <ClassDetail>[];
  List<TimeArrangement> timeArrangement = <TimeArrangement>[];
  String semesterCode = "";
  String termStartDay = "";
  int semesterLength = 0;

  void update(Map<String, dynamic> qResult) {
    semesterCode = qResult["semesterCode"];
    termStartDay = qResult["termStartDay"];
    semesterLength = 0;
    for (var i in qResult["rows"]) {
      var toDeal = ClassDetail(
        name: i["KCM"],
        teacher: i["SKJS"],
        place: i["JASDM"],
        code: i["KCH"],
        number: i["KXH"],
      );
      if (!classDetail.contains(toDeal)) {
        classDetail.add(toDeal);
      }
      timeArrangement.add(
        TimeArrangement(
          index: classDetail.indexOf(toDeal),
          start: int.parse(i["KSJC"]),
          stop: int.parse(i["JSJC"]),
          day: int.parse(i["SKXQ"]),
          weekList: i["SKZC"].toString(),
        ),
      );
      if (i["SKZC"].toString().length > semesterLength) {
        semesterLength = i["SKZC"].toString().length;
      }
    }

    // Uncomment to see the conflict.
    /*
    classData.classDetail.add(ClassDetail(
      name: "测试连课",
      teacher: "SPRT",
      place: "Flutter",
    ));
    classData.timeArrangement.addAll([
      TimeArrangement(
        index: classData.classDetail.length - 1,
        start: 2,
        stop: 8,
        day: 2,
        weekList: "1111111111111111111111",
      ),
      TimeArrangement(
        index: classData.classDetail.length - 1,
        start: 4,
        stop: 8,
        day: 6,
        weekList: "1111111111111111111111",
      ),
    ]);
    */
  }
}
