// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

class SportItems {
  String examName;
  String examunit;
  String actualScore;
  double score;
  String rank = "不合格";

  SportItems({
    required this.examName,
    required this.examunit,
    required this.actualScore,
    required this.score,
    required this.rank,
  });
}

class SportScoreOfYear {
  String year;
  String totalScore;
  String rank;
  String gradeType;
  String moreinfo = "";
  List<SportItems> details = [];

  SportScoreOfYear({
    required this.year,
    required this.totalScore,
    required this.rank,
    required this.gradeType,
  });
}

class SportScore {
  String total = "0.0";
  String rank = "";
  String detail = "";
  List<SportScoreOfYear> list = [];

  bool get isFourYearsComplete => list.length >= 4;
  bool get isQualified => !rank.contains("不");
  String get scoreRankI18nStr =>
      list.length < 4 ? "class_attendance.course_state.unknown" : rank;
}
