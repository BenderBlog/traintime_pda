// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class SportClassItem {
  static final RegExp _termDealer = RegExp(
    r'^(?<year_start>\d{4})-(?<year_end>\d{4})(.*)(?<term>\d{1})',
  );
  static final RegExp _timeDealer = RegExp(
    r'^星期(?<week>.{1})(?<start>\d{1})(?<stop>\d{1})',
  );

  final String termToShow;
  final String score;
  final String type;
  final String term;
  final String name;
  final String teacher;
  final int week;
  final int start;
  final int stop;
  final String place;

  factory SportClassItem.fromData({
    required String termName,
    required String name,
    required String score,
    required String type,
    required String teacher,
    required String time,
    required String place,
  }) {
    var termDealer = _termDealer.firstMatch(termName)!;
    var timeDealer = _timeDealer.firstMatch(time)!;

    late int week;
    switch (timeDealer.namedGroup('week')!) {
      case '一':
        week = 1;
      case '二':
        week = 2;
      case '三':
        week = 3;
      case '四':
        week = 4;
      case '五':
        week = 5;
      case '六':
        week = 6;
      case '日':
        week = 7;
    }

    String term = "${termDealer.namedGroup("year_start")}-"
        "${termDealer.namedGroup("year_end")}-"
        "${termDealer.namedGroup("term")}";

    return SportClassItem._(
      termToShow: termName,
      score: score,
      type: type,
      term: term,
      name: name,
      teacher: teacher,
      start: int.parse(timeDealer.namedGroup('start')!),
      stop: int.parse(timeDealer.namedGroup('stop')!),
      week: week,
      place: place,
    );
  }

  factory SportClassItem.empty() => SportClassItem._(
        termToShow: "",
        score: "",
        term: "",
        type: "",
        name: "",
        teacher: "",
        start: 0,
        stop: 0,
        week: 0,
        place: "",
      );

  SportClassItem._({
    required this.termToShow,
    required this.term,
    required this.score,
    required this.type,
    required this.name,
    required this.teacher,
    required this.start,
    required this.stop,
    required this.week,
    required this.place,
  });
}

class SportClass {
  List<SportClassItem> items = [];
  String? situation;
}
