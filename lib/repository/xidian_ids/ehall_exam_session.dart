// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The exam source.
// Thanks xidian-script and libxdauth!

import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';

/// 考试安排 4768687067472349
class ExamSession extends EhallSession {
  Future<ExamData> getExam() async {
    var firstPost = await useApp("4768687067472349");
    await dioEhall.get(firstPost);

    String semester =
        preference.getString(preference.Preference.currentSemester);

    /// wdksap 我的考试安排
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程(正在安排中，不抓)
    /// If failed, it is more likely that no exam has arranged.
    log.i(
      "[ExamFile][getExam] "
      "My exam arrangemet $semester",
    );
    List<Subject> subject = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys"
      "/studentWdksapApp/modules/wdksap/wdksap.do",
      queryParameters: {"XNXQDM": semester, "*order": "-KSRQ,-KSSJMS"},
    ).then((value) {
      if (value.data["code"] != "0" ||
          value.data["datas"]["wdksap"]["rows"] == null) {
        if (value.data["datas"]["wdksap"]["extParams"]["msg"] != null) {
          throw GetExamFailedException(
            "未安排考试信息获取失败："
            "${value.data["datas"]["wdksap"]["extParams"]["msg"]}",
          );
        }
        throw const GetExamFailedException(
          "考试信息获取失败：无法解析数据",
        );
      }
      var data = value.data["datas"]["wdksap"]["rows"];
      return List<Subject>.generate(
        data.length,
        (index) => Subject.generate(
          subject: data[index]["KCM"],
          typeStr: data[index]["KSMC"] ?? "未知类型考试",
          time: data[index]["KSSJMS"] ?? "未知考试时间",
          place: data[index]["JASMC"] ?? "尚无安排",
          seat: int.parse(data[index]["ZWH"] ?? '-1'),
        ),
      );
    });

    List<ToBeArranged> toBeArrangedData = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys"
      "/studentWdksapApp/modules/wdksap/cxyxkwapkwdkc.do",
      queryParameters: {"XNXQDM": semester},
    ).then((value) {
      if (value.data["code"] != "0" ||
          value.data["datas"]["cxyxkwapkwdkc"]["rows"] == null) {
        if (value.data["datas"]["cxyxkwapkwdkc"]["extParams"]["msg"] != null) {
          throw GetExamFailedException(
            "未安排考试信息获取失败："
            "${value.data["datas"]["cxyxkwapkwdkc"]["extParams"]["msg"]}",
          );
        }
        throw const GetExamFailedException(
          "未安排考试信息获取失败：无法解析数据",
        );
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

    return ExamData(
      subject: subject,
      toBeArranged: toBeArrangedData,
    );
  }
}

class GetExamFailedException implements Exception {
  final String msg;
  const GetExamFailedException(this.msg);

  @override
  String toString() => msg;
}
