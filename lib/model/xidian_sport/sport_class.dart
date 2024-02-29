// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class SportClass {
  static final RegExp _termDealer = RegExp(
    r'^(?<year_start>\d{4})-(?<year_end>\d{4})(.*)(?<term>\d{1})',
  );
  static final RegExp _timeDealer = RegExp(
    r'^星期(?<week>\*{1})(?<start>\d{1})(?<end>\d{1})',
  );

  final String term;
  final String name;
  final String teacher;
  final int week;
  final int start;
  final int stop;
  final String place;

  factory SportClass.fromData({
    required String termName,
    required String name,
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

    return SportClass._(
      term: term,
      name: name,
      teacher: teacher,
      start: week,
      stop: int.parse(timeDealer.namedGroup('start')!),
      week: int.parse(timeDealer.namedGroup('end')!),
      place: place,
    );
  }

  SportClass._({
    required this.term,
    required this.name,
    required this.teacher,
    required this.start,
    required this.stop,
    required this.week,
    required this.place,
  });
}
