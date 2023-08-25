// Copyright 2023 BenderBlog Rodriguez.
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
  double score; // 分数
  String year; // 学年
  double credit; // 学分
  String status; // 修读状态
  String type; // 课程类别
  // DJCJLXDM 01 三级成绩 02 五级成绩
  int how; // 评分方式
  String? level; // 等级
  String? classID; // 教学班序列号
  String? courseID;
  String? scoreStructure; //成绩构成
  String? scoreDetail; //分项成绩
  String isPassed; //是否及格
  Score({
    required this.mark,
    required this.name,
    required this.score,
    required this.year,
    required this.credit,
    required this.status,
    required this.isPassed,
    required this.how,
    required this.type,
    this.level,
    this.classID,
    this.courseID,
    this.scoreStructure,
    this.scoreDetail,
  });

  double get gpa {
    switch (how) {
      case 1:
        if (level == "优秀") {
          return 4.0;
        } else if (level == "通过") {
          return 3.2;
        } else {
          return 0.0;
        }
      case 2:
        if (level == "优秀") {
          return 4.0;
        } else if (level == "良好") {
          return 3.8;
        } else if (level == "中等") {
          return 3.2;
        } else if (level == "及格") {
          return 2.4;
        } else {
          return 0.0;
        }
      default:
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
}
