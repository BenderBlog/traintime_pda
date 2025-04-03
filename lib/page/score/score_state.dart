// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/score/score_statics.dart';

class ScoreState extends InheritedWidget {
  /// Static data.
  final List<Score> scoreTable;
  final Set<String> semester;
  final Set<String> statuses;
  final Set<String> unPassedSet;

  /// Parent's Buildcontext.
  final BuildContext context;

  /// Changeable state.
  final ScoreWidgetState controllers;

  /// Exclude these from counting avgs
  /// 1. CET-4 and CET-6
  /// 2. Teacher have not finish uploading scores
  /// 3. Have score below 60 but passed.
  /// 4. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains("国家英语四级") ||
      eval.name.contains("国家英语六级") ||
      !eval.isFinish ||
      (!eval.isPassed! && !unPassedSet.contains(eval.name)) ||
      (eval.scoreStatus != "初修" && !eval.isPassed!));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
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
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalScore += (isGPA ? scoreTable[i].gpa : scoreTable[i].score!) *
            scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (controllers.chosenSemester != "") {
      whatever.removeWhere(
        (element) => element.semesterCode != controllers.chosenSemester,
      );
    }
    if (controllers.chosenStatus != "") {
      whatever.removeWhere(
        (element) => element.classStatus != controllers.chosenStatus,
      );
    }
    whatever.removeWhere(
      (element) =>
          !element.name.toLowerCase().contains(
            controllers.search.toLowerCase(),
          ),
    );
    return whatever;
  }

  List<Score> get getSelectedScoreList => List.from(scoreTable)
    ..removeWhere((element) => !controllers.isSelected[element.mark]);

  List<Score> get selectedScoreList {
    List<Score> whatever = List.from(getSelectedScoreList);
    if (controllers.chosenSemesterInScoreChoice != "") {
      whatever.removeWhere(
        (element) =>
            element.semesterCode != controllers.chosenSemesterInScoreChoice,
      );
    }
    if (controllers.chosenStatusInScoreChoice != "") {
      whatever.removeWhere(
        (element) =>
            element.classStatus != controllers.chosenStatusInScoreChoice,
      );
    }
    whatever.removeWhere(
      (element) => !element.name.contains(controllers.searchInScoreChoice),
    );
    return whatever;
  }

  String get unPassed => unPassedSet.isEmpty ? "" : unPassedSet.join(",");

  String bottomInfo(context) =>
      FlutterI18n.translate(context, "score.summary", translationParams: {
        "chosen": getSelectedScoreList.length.toString(),
        "credit": evalCredit(false).toStringAsFixed(2),
        "avg": evalAvg(false).toStringAsFixed(2),
        "gpa": evalAvg(false, isGPA: true).toStringAsFixed(2)
      });

  double get notCoreClass {
    double toReturn = 0.0;
    for (var i in scoreTable) {
      if (i.classStatus.contains(notCoreClassType) &&
          i.isFinish &&
          i.isPassed!) {
        toReturn += i.credit;
      }
    }
    return toReturn;
  }

  factory ScoreState.init({
    required List<Score> scoreTable,
    required Widget child,
    required BuildContext context,
  }) {
    Set<String> semester = {for (var i in scoreTable) i.semesterCode};
    Set<String> statuses = {for (var i in scoreTable) i.classStatus};
    Set<String> unPassedSet = {
      for (var i in scoreTable)
        if (i.isFinish && !i.isPassed!) i.name
    };
    return ScoreState._(
      scoreTable: scoreTable,
      controllers: ScoreWidgetState(
        isSelected: List<bool>.generate(
          scoreTable.length,
          (int index) {
            for (var i in courseIgnore) {
              if (scoreTable[index].name.contains(i)) return false;
            }
            for (var i in typesIgnore) {
              if (scoreTable[index].classType.contains(i)) return false;
            }
            return true;
          },
        ),
        chosenSemester: "",
      ),
      semester: semester,
      statuses: statuses,
      unPassedSet: unPassedSet,
      context: context,
      child: child,
    );
  }

  const ScoreState._({
    required super.child,
    required this.scoreTable,
    required this.controllers,
    required this.semester,
    required this.statuses,
    required this.unPassedSet,
    required this.context,
  });

  void setScoreChoiceMod() {
    controllers.isSelectMod = !controllers.isSelectMod;
    controllers.notifyListeners();
  }

  void setScoreChoiceFromIndex(int index) {
    controllers.isSelected[index] = !controllers.isSelected[index];
    controllers.notifyListeners();
  }

  void setScoreChoiceState(ChoiceState state) {
    for (var stuff in toShow) {
      if (state == ChoiceState.all) {
        controllers.isSelected[stuff.mark] = true;
      } else if (state == ChoiceState.none) {
        controllers.isSelected[stuff.mark] = false;
      } else {
        bool toBeGiven = true;
        for (var i in courseIgnore) {
          if (stuff.name.contains(i)) toBeGiven = false;
        }
        for (var i in typesIgnore) {
          if (stuff.classType.contains(i)) toBeGiven = false;
        }
        controllers.isSelected[stuff.mark] = toBeGiven;
      }
    }
    controllers.notifyListeners();
  }

  set search(String text) {
    controllers.search = text;
    controllers.notifyListeners();
  }

  set chosenSemester(String str) {
    controllers.chosenSemester = str;
    controllers.notifyListeners();
  }

  set chosenStatus(String str) {
    controllers.chosenStatus = str;
    controllers.notifyListeners();
  }

  set searchInScoreChoice(String text) {
    controllers.searchInScoreChoice = text;
    controllers.notifyListeners();
  }

  set chosenSemesterInScoreChoice(String str) {
    controllers.chosenSemesterInScoreChoice = str;
    controllers.notifyListeners();
  }

  set chosenStatusInScoreChoice(String str) {
    controllers.chosenStatusInScoreChoice = str;
    controllers.notifyListeners();
  }

  static ScoreState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScoreState>();
  }

  @override
  bool updateShouldNotify(covariant ScoreState oldWidget) {
    ScoreWidgetState newState = controllers;
    ScoreWidgetState oldState = oldWidget.controllers;

    return (!listEquals(oldState.isSelected, newState.isSelected) ||
        oldState.chosenSemester != newState.chosenSemester ||
        oldState.chosenStatus != newState.chosenStatus ||
        oldState.chosenSemesterInScoreChoice !=
            newState.chosenSemesterInScoreChoice ||
        oldState.chosenStatusInScoreChoice !=
            newState.chosenStatusInScoreChoice ||
        oldState.search != newState.search ||
        oldState.searchInScoreChoice != newState.chosenSemesterInScoreChoice);
  }
}

class ScoreWidgetState extends ChangeNotifier {
  /// Is score is selected to count.
  List<bool> isSelected;

  /// Is select mod?
  bool isSelectMod = false;

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Empty means all semester, especially in score choice window.
  String chosenSemesterInScoreChoice = "";

  /// Empty means all status, especially in score choice window.
  String chosenStatusInScoreChoice = "";

  /// Search parameter
  String search = "";
  String searchInScoreChoice = "";

  ScoreWidgetState({
    required this.isSelected,
    required this.chosenSemester,
  });

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
