// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreState extends ChangeNotifier {
  /// Score fetch state.
  ScoreFetchState state = ScoreFetchState.fetching;

  /// Score data
  List<Score> scoreData = [];
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};

  /// Error string
  String? error;

  /// Is score is selected to count.
  List<bool> isSelected = [];

  /// Is select mod?
  bool _isSelectMod = false;

  /// Empty means all semester.
  String _chosenSemester = "";

  /// Empty means all status.
  String _chosenStatus = "";

  /// Search parameter
  String _search = "";

  /// Init
  ScoreState(BuildContext context) {
    refreshingState(context);
  }

  /// Refresh the score page's state.
  Future<void> refreshingState(
    BuildContext context, {
    bool isForce = false,
  }) async {
    /// Set to fetching mode.
    state = ScoreFetchState.fetching;
    notifyListeners();

    /// Reset data.
    scoreData.clear();
    semester.clear();
    statuses.clear();
    unPassedSet.clear();

    /// Error status changed.
    error = null;

    /// State reset in here.
    isSelected.clear();
    _isSelectMod = false;
    _chosenSemester = "";
    _chosenStatus = "";
    _search = "";
    try {
      ScoreSession session = ScoreSession();

      /// Fetch the data.
      scoreData = await session.getScore(force: isForce);
      semester = {for (var i in scoreData) i.semesterCode};
      statuses = {for (var i in scoreData) i.classStatus};
      unPassedSet = {
        for (var i in scoreData)
          if (i.isFinish && !i.isPassed!) i.name,
      };

      /// Fresh the state.
      isSelected = List<bool>.generate(scoreData.length, (int index) {
        for (var i in courseIgnore) {
          if (scoreData[index].name.contains(i)) return false;
        }
        for (var i in typesIgnore) {
          if (scoreData[index].classType.contains(i)) return false;
        }
        return true;
      });
      state = ScoreFetchState.ok;
    } catch (e, s) {
      log.error("[ScorePageState] Error on fetching score info.", e, s);
      state = ScoreFetchState.error;
      error = e.toString();
    } finally {
      log.info("[ScorePageState] Finish fetching. state: $state");
      if (context.mounted) {
        if (ScoreSession.isScoreListCacheUsed) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "score.cache_message"),
          );
        }
      }
      notifyListeners();
    }
  }

  /// Exclude these from counting avgs
  /// 1. CET-4 and CET-6
  /// 2. Teacher have not finish uploading scores
  /// 3. Have score below 60 but passed.
  /// 4. Not first time learning this, but still failed.
  bool _evalCount(Score eval) =>
      !(eval.name.contains("国家英语四级") ||
          eval.name.contains("国家英语六级") ||
          !eval.isFinish ||
          (!eval.isPassed! && !unPassedSet.contains(eval.name)) ||
          (eval.scoreStatus != "初修" && !eval.isPassed!));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreData[i])) {
        totalCredit += scoreData[i].credit;
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
          _evalCount(scoreData[i])) {
        totalScore +=
            (isGPA ? scoreData[i].gpa : scoreData[i].score!) *
            scoreData[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreData);
    if (_chosenSemester != "") {
      whatever.removeWhere(
        (element) => element.semesterCode != _chosenSemester,
      );
    }
    if (_chosenStatus != "") {
      whatever.removeWhere((element) => element.classStatus != _chosenStatus);
    }
    whatever.removeWhere(
      (element) => !element.name.toLowerCase().contains(_search.toLowerCase()),
    );
    return whatever;
  }

  List<Score> get getSelectedScoreList =>
      List.from(scoreData)..removeWhere((element) => !isSelected[element.mark]);

  String get unPassed => unPassedSet.isEmpty ? "" : unPassedSet.join(",");

  String bottomInfo(context) => FlutterI18n.translate(
    context,
    "score.summary",
    translationParams: {
      "chosen": getSelectedScoreList.length.toString(),
      "credit": evalCredit(false).toStringAsFixed(2),
      "avg": evalAvg(false).toStringAsFixed(2),
      "gpa": evalAvg(false, isGPA: true).toStringAsFixed(2),
    },
  );

  double get notCoreClass {
    double toReturn = 0.0;
    for (var i in scoreData) {
      if (i.classStatus.contains(notCoreClassType) &&
          i.isFinish &&
          i.isPassed!) {
        toReturn += i.credit;
      }
    }
    return toReturn;
  }

  String get notCoreClassTypeList {
    List<String> list = List<String>.from(statuses)
      ..removeWhere((str) => !str.contains(notCoreClassType));
    String toReturn = list
        .map((str) => str.replaceAll(RegExp(notCoreClassType), ""))
        .join("、");
    // TODO: Use i18n for None
    return toReturn.isEmpty ? "None" : toReturn;
  }

  set isSelectMode(bool value) {
    _isSelectMod = value;
    notifyListeners();
  }

  bool get isSelectMode => _isSelectMod;

  set chosenSemester(String toSet) {
    _chosenSemester = toSet;
    notifyListeners();
  }

  String get chosenSemester => _chosenSemester;

  set chosenStatus(String toSet) {
    _chosenStatus = toSet;
    notifyListeners();
  }

  String get chosenStatus => _chosenStatus;

  set search(String toSet) {
    _search = toSet;
    notifyListeners();
  }

  String get search => _search;

  void setScoreChoiceFromIndex(int index) {
    isSelected[index] = !isSelected[index];
    notifyListeners();
  }

  void setScoreChoiceState(ChoiceState state) {
    for (var stuff in toShow) {
      if (state == ChoiceState.all) {
        isSelected[stuff.mark] = true;
      } else if (state == ChoiceState.none) {
        isSelected[stuff.mark] = false;
      } else {
        bool toBeGiven = true;
        for (var i in courseIgnore) {
          if (stuff.name.contains(i)) toBeGiven = false;
        }
        for (var i in typesIgnore) {
          if (stuff.classType.contains(i)) toBeGiven = false;
        }
        isSelected[stuff.mark] = toBeGiven;
      }
    }
    notifyListeners();
  }
}
