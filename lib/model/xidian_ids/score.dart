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
  String statusStr; // 课程性质
  String examTypeStr; // 考试类型
  String examPropStr;
  bool isPassed; //是否及格
  Score({
    required this.mark,
    required this.name,
    required this.scoreStr,
    required this.year,
    required this.credit,
    required this.statusStr,
    required this.isPassed,
    required this.examTypeStr,
    required this.examPropStr,
  });

  /// From ehall, score status:
  /// 学院选修（任选）；人文限选；公共任选；辅修
  /// 非标；必修；学院选修；学院限选；学院选修（限选）
  /// 学校任选；学院任选；学校限选
  String get status {
    late String temp;
    switch (statusStr) {
      case "010":
        temp = "学院选修（任选）";
        break;
      case "006":
        temp = "人文限选";
        break;
      case "007":
        temp = "公共任选";
        break;
      case "004":
        temp = "辅修";
        break;
      case "005":
        temp = "非标";
        break;
      case "001":
        temp = "必修";
        break;
      case "002":
        temp = "学院选修";
        break;
      case "013":
        temp = "学院限选";
        break;
      case "009":
        temp = "学院选修（限选）";
        break;
      case "012":
        temp = "学校任选";
        break;
      case "014":
        temp = "学院任选";
        break;
      case "011":
        temp = "学校任选";
        break;
      default:
        temp = statusStr;
    }

    if (temp.contains(RegExp(r'（|）'))) {
      return temp.replaceAll(RegExp(r"选修|（|）"), "");
    }
    return temp;
  }

  String get examType {
    switch (examTypeStr) {
      case "1":
        return "考试";
      case "2":
        return "考察";
      default:
        return examTypeStr;
    }
  }

  String get examProp {
    switch (examPropStr) {
      case "01":
        return "初修";
      case "02":
        return "重修";
      case "03":
        return "复修";
      case "04":
        return "重考";
      default:
        return examPropStr;
    }
  }

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
      case "暂无":
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
