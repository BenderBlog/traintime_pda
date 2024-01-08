// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:jiffy/jiffy.dart';

class Subject {
  String subject;
  String typeStr;
  //DateTime start;
  //DateTime end;
  String time;
  String place;
  int seat;

  static RegExp timeRegExp = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})-(?<stopHour>\d{2})(::?)(?<stopMinute>\d{2})',
  );

  @override
  String toString() => "$subject $typeStr $type $time $place $seat\n";

  Jiffy get startTime {
    RegExpMatch? match = timeRegExp.firstMatch(time);
    if (match == null) throw NotImplementedException();

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('hour')!),
      int.parse(match.namedGroup('minute')!),
    ));
  }

  Jiffy get stopTime {
    RegExpMatch? match = timeRegExp.firstMatch(time);
    if (match == null) throw NotImplementedException();

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('stopHour')!),
      int.parse(match.namedGroup('stopMinute')!),
    ));
  }

  String get type {
    if (typeStr.contains("期末考试")) return "期末考试";
    if (typeStr.contains("期中考试")) return "期中考试";
    if (typeStr.contains("结课考试")) return "结课考试";
    if (typeStr.contains("入学")) return "入学考试";
    return typeStr;
  }

  Subject({
    required this.subject,
    required this.typeStr,
    required this.time,
    //required this.start,
    //required this.end,
    required this.place,
    required this.seat,
  });
}

// Or should I say, to be dead?
class ToBeArranged {
  String subject;
  String id;

  @override
  String toString() => "$subject $id\n";

  ToBeArranged({
    required this.subject,
    required this.id,
  });
}

class NotImplementedException implements Exception {}
