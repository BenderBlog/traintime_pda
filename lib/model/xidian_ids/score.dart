// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'score.g.dart';

@JsonSerializable(explicitToJson: true)
class Score {
  int mark; // 编号，用于某种计算，从 0 开始
  String name; // 学科名称
  double? score; // 分数
  String semesterCode; // 学年
  double credit; // 学分
  String classStatus; // 课程性质，必修，选修等，
  String classType; // 课程类别
  // DJCJLXDM 01 三级成绩 02 五级成绩 03 两级成绩
  String scoreStatus; // 修读类型类型，重修重考等
  int scoreTypeCode; // 评分方式
  String? level; // 等级
  String? isPassedStr; //是否及格，null 没出分，1 通过 0 没有
  String? classID; // 教学班序列号

  Score({
    required this.mark,
    required this.name,
    required this.score,
    required this.semesterCode,
    required this.credit,
    required this.classStatus,
    required this.isPassedStr,
    required this.scoreTypeCode,
    required this.classType,
    required this.scoreStatus,
    this.level,
    this.classID,
  });

  bool? get isPassed {
    if (isPassedStr == null) return null;
    return isPassedStr == "1";
  }

  String get scoreStr {
    if (score != null) {
      switch (scoreTypeCode) {
        case 1:
        case 3:
        case 2:
          return level.toString();
        default:
          return score!.toInt().toString();
      }
    } else if (isPassedStr == null) {
      return "暂无";
    } else if (isPassedStr!.contains('0')) {
      return "未及格";
    } else {
      return "及格";
    }
  }

  bool get isFinish => isPassed != null && score != null;

  double get gpa {
    if (!isFinish) {
      return 0.0;
    }
    switch (scoreTypeCode) {
      case 1:
      case 3:
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
        if (score! >= 95) {
          return 4.0;
        } else if (score! >= 90) {
          return 3.9;
        } else if (score! >= 84) {
          return 3.8;
        } else if (score! >= 80) {
          return 3.6;
        } else if (score! >= 76) {
          return 3.4;
        } else if (score! >= 73) {
          return 3.2;
        } else if (score! >= 70) {
          return 3.0;
        } else if (score! >= 67) {
          return 2.7;
        } else if (score! >= 64) {
          return 2.4;
        } else if (score! >= 62) {
          return 2.2;
        } else if (score! >= 60) {
          return 2.0;
        } else {
          return 0.0;
        }
    }
  }

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreToJson(this);
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
