// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:jiffy/jiffy.dart';

class Subject {
  String subject;
  String type;
  //DateTime start;
  //DateTime end;
  String time;
  String place;
  int seat;

  static RegExp timeRegExp = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})',
  );

  @override
  String toString() => "$subject $type $time $place $seat\n";

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

  Subject({
    required this.subject,
    required this.type,
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
