// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:jiffy/jiffy.dart';

RegExp timeRegExp = RegExp(r'[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}');

class Subject {
  String subject;
  String type;
  //DateTime start;
  //DateTime end;
  String time;
  String place;
  int seat;

  @override
  String toString() => "$subject $type $time $place $seat\n";

  Jiffy get startTime => Jiffy.parse(timeRegExp.firstMatch(time)![0]!);

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
