// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreState extends ChangeNotifier {
  /// Hack on notifyListeners, do not fire when the widget is disposed.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Score fetch state.
  ScoreFetchState state = ScoreFetchState.fetching;

  /// Score data
  bool isCache = false;
  DateTime fetchDate = DateTime.now();
  List<Score> scoreData = [];
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};

  /// Error and stacktrace for fatal error
  Object? error;
  StackTrace? stackTrace;

  /// Hintkey for cache result
  String? hintKey;

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

  /// A Score Session
  late final ScoreSession session;

  /// Init
  ScoreState(BuildContext context) {
    session = ScoreSession();
    refreshingState(context);
  }

  /// Refresh the score page's state.
  Future<void> refreshingState(
    BuildContext context, {
    bool isForce = false,
  }) async {
    /// Set to fetching mode.
    if (scoreData.isNotEmpty) {
      state = ScoreFetchState.fetchingWithData;
    } else {
      state = ScoreFetchState.fetching;
    }
    notifyListeners();

    try {
      /// Fetch the data.
      FetchResult<List<Score>> scoreDataFetchResult = await session.getScore();

      /// Reset data.
      isCache = false;
      scoreData.clear();
      semester.clear();
      statuses.clear();
      unPassedSet.clear();

      /// Error status changed.
      error = null;
      stackTrace = null;
      hintKey = null;

      /// State reset in here.
      isSelected.clear();
      _isSelectMod = false;
      _chosenSemester = "";
      _chosenStatus = "";
      _search = "";

      fetchDate = scoreDataFetchResult.fetchTime;
      scoreData.addAll(scoreDataFetchResult.data);
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

      if (scoreDataFetchResult.isCache) {
        hintKey = scoreDataFetchResult.hintKey;
        isCache = true;
        state = ScoreFetchState.readyCache;
        return;
      }

      state = ScoreFetchState.readyFresh;
    } catch (e, s) {
      log.error("[ScorePageState] Error on fetching score info.", e, s);
      state = ScoreFetchState.error;
      error = e;
      stackTrace = s;
    } finally {
      log.info("[ScorePageState] Finish fetching. state: $state");
      if (context.mounted) {
        if (isCache) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "score.cache_message"),
          );
        }
      }
      notifyListeners();
    }
  }

  /// Fetch score detail info
  Future<List<ComposeDetail>> getScoreComposeInfo(Score scoreData) =>
      session.getDetail(
        scoreData.classID,
        scoreData.semesterCode,
        needRelogin: isCache,
      );

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

  String bottomInfo(BuildContext context) => FlutterI18n.translate(
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
    Map<String, int> notCoreClassCount = {};

    for (var i in scoreData) {
      if (i.classStatus.contains(notCoreClassType)) {
        if (notCoreClassCount[i.classStatus] == null) {
          notCoreClassCount[i.classStatus] = 1;
        } else {
          notCoreClassCount[i.classStatus] =
              notCoreClassCount[i.classStatus]! + 1;
        }
      }
    }

    String toReturn = notCoreClassCount.keys
        .map(
          (k) =>
              "${k.replaceAll(RegExp(notCoreClassType), "")}"
              "${notCoreClassCount[k]}分",
        )
        .join("；");
    return toReturn.isEmpty ? "score.none" : toReturn;
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
