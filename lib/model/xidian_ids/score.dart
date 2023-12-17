// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

class ScoreStatistics {
  String level;
  int people;
  ScoreStatistics({
    required this.level,
    required this.people,
  });
}

class ScorePlace {
  int? place;
  int? total;
  double? highest;
  double? lowest;
  double? average;
  List<double> get people => List.generate(
      statistics.length, (index) => statistics[index].people.toDouble());
  List<String> get levels =>
      List.generate(statistics.length, (index) => statistics[index].level);
  double get maxOfPeople =>
      List.generate(statistics.length, (index) => statistics[index].people)
          .reduce((v, e) => math.max(v, e))
          .toDouble();
  List<ScoreStatistics> statistics = [];
}

class ComposeDetail {
  String content;
  String ratio;
  String score;
  ComposeDetail({
    required this.content,
    required this.ratio,
    required this.score,
  });
}

class Compose {
  List<ComposeDetail> score = [];
}

class Score {
  int mark; // 编号，用于某种计算，从 0 开始
  String name; // 学科名称
  String scoreStr; // 分数
  String year; // 学年
  double credit; // 学分
  String status; // 修读状态
  String examType; // 考试类型
  String examProp;
  bool isPassed; //是否及格
  Score({
    required this.mark,
    required this.name,
    required this.scoreStr,
    required this.year,
    required this.credit,
    required this.status,
    required this.isPassed,
    required this.examType,
    required this.examProp,
  });

  double get score {
    switch (scoreStr) {
      case "优秀":
        return 95;
      case "免修":
      case "良好":
        return 85;
      case "通过":
      case "中等":
        return 75;
      case "及格":
        return 65;
      case "不通过":
      case "不及格":
        return 0;
      default:
        return double.parse(scoreStr);
    }
  }

  double get gpa {
    if (score >= 95) {
      return 4.0;
    } else if (score >= 90) {
      return 3.9;
    } else if (score >= 84) {
      return 3.8;
    } else if (score >= 80) {
      return 3.6;
    } else if (score >= 76) {
      return 3.4;
    } else if (score >= 73) {
      return 3.2;
    } else if (score >= 70) {
      return 3.0;
    } else if (score >= 67) {
      return 2.7;
    } else if (score >= 64) {
      return 2.4;
    } else if (score >= 62) {
      return 2.2;
    } else if (score >= 60) {
      return 2.0;
    } else {
      return 0.0;
    }
  }
}
