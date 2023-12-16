// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

class ScoreController extends GetxController {
  RxBool isGet = false.obs;
  RxBool isError = false.obs;
  String? error;
  late String currentSemester;
  late List<Score> scoreTable;
  late List<bool> isSelected;

  RxBool isSelectMod = false.obs;
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};

  static final courseIgnore = [
    '军事',
    '形势与政策',
    '创业基础',
    '新生',
    '写作与沟通',
    '学科导论',
    '心理',
    '物理实验',
    '工程概论',
    '达标测试',
    '大学生职业发展',
    '国家英语四级',
    '劳动教育',
    '思想政治理论实践课',
    '就业指导',
  ];

  static final statusIgnore = [
    '学院选修（任选）',
    '非标',
    '公共任选',
  ];

  static const notFinish = "(成绩没登完)";
  static const notFirstTime = "(非初修)";
  static const notCoreClassType = "公共任选";

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Empty means all semester, especially in score choice window.
  String chosenSemesterInScoreChoice = "";

  /// Empty means all status, especially in score choice window.
  String chosenStatusInScoreChoice = "";

  /// Exclude these from counting avgs
  /// 1. CET-4 and CET-6
  /// 2. Teacher have not finish uploading scores
  /// 3. Have score below 60 but passed.
  /// 4. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains("国家英语四级") ||
      eval.name.contains("国家英语六级") ||
      eval.name.contains(notFinish) ||
      (eval.score < 60 && !unPassedSet.contains(eval.name)) ||
      (eval.name.contains(notFirstTime) && eval.score < 60));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  /// [isGPA] true for the GPA, false for the avgScore
  double evalAvg(bool isAll, {bool isGPA = false}) {
    double totalScore = 0.0;
    double totalCredit = evalCredit(isAll);
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalScore += (isGPA ? scoreTable[i].gpa : scoreTable[i].score) *
            scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (chosenSemester != "") {
      whatever.removeWhere((element) => element.year != chosenSemester);
    }
    if (chosenStatus != "") {
      whatever.removeWhere((element) => element.status != chosenStatus);
    }
    return whatever;
  }

  List<Score> get getSelectedScoreList => List.from(scoreTable)
    ..removeWhere((element) => !isSelected[element.mark]);

  List<Score> get selectedScoreList {
    List<Score> whatever = List.from(getSelectedScoreList);
    if (chosenSemesterInScoreChoice != "") {
      whatever.removeWhere(
          (element) => element.year != chosenSemesterInScoreChoice);
    }
    if (chosenStatusInScoreChoice != "") {
      whatever.removeWhere(
          (element) => element.status != chosenStatusInScoreChoice);
    }
    return whatever;
  }

  String get unPassed => unPassedSet.isEmpty ? "没有" : unPassedSet.join(",");

  String get bottomInfo =>
      "目前选中科目 ${getSelectedScoreList.length}  总计学分 ${evalCredit(false).toStringAsFixed(2)}\n"
      "均分 ${evalAvg(false).toStringAsFixed(2)}  "
      "GPA ${evalAvg(false, isGPA: true).toStringAsFixed(2)}  ";

  double get notCoreClass {
    double toReturn = 0.0;
    for (var i in scoreTable) {
      if (i.status.contains(notCoreClassType) && i.score >= 60) {
        toReturn += i.credit;
      }
    }
    return toReturn;
  }

  void setScoreChoiceState(int index) {
    isSelected[index] = !isSelected[index];
    update();
  }

  @override
  void onInit() {
    currentSemester =
        preference.getString(preference.Preference.currentSemester);
    print(currentSemester);
    super.onInit();
  }

  @override
  void onReady() async {
    get();
    update();
  }

  void resetChoice() {
    isSelected = List<bool>.generate(scoreTable.length, (int index) {
      for (var i in courseIgnore) {
        if (scoreTable[index].name.contains(i)) return false;
      }
      for (var i in statusIgnore) {
        if (scoreTable[index].status.contains(i)) return false;
      }
      return true;
    });
  }

  Future<void> get() async {
    isGet.value = false;
    isError.value = false;
    try {
      /// Init scorefile
      scoreTable = await JiaowuServiceSession().getScore();
      resetChoice();
      semester = {for (var i in scoreTable) i.year};
      statuses = {for (var i in scoreTable) i.status};
      unPassedSet.addAll({
        for (var i in scoreTable)
          if (i.score < 60) i.name
      });

      isGet.value = true;
      chosenSemester = currentSemester;
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
      isError.value = true;
    } on GetScoreFailedException catch (e) {
      developer.log("没有获取到成绩：$e", name: "ScoreSession");
      error = "没有获取到成绩：$e";
      isError.value = true;
    } catch (e) {
      developer.log("未知故障：$e", name: "ScoreSession");
      error = e.toString();
      isError.value = true;
    }
    update();
  }
}
