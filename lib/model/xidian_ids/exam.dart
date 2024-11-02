// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam.g.dart';

@JsonSerializable(explicitToJson: true)
class Subject {
  String subject;
  String typeStr;
  String startTimeStr;
  String endTimeStr;
  String time;
  String place;
  String? seat;

  static RegExp timeRegExp = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})-(?<stopHour>\d{2})(::?)(?<stopMinute>\d{2})',
  );

  @override
  String toString() => "$subject $typeStr $type $time $place $seat\n";

  Jiffy? get startTime {
    RegExpMatch? match = timeRegExp.firstMatch(time);
    if (match == null) return null;

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('hour')!),
      int.parse(match.namedGroup('minute')!),
    ));
  }

  Jiffy? get stopTime {
    RegExpMatch? match = timeRegExp.firstMatch(time);
    if (match == null) return null;

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

  factory Subject.generate({
    required String subject,
    required String typeStr,
    required String time,
    required String place,
    String? seat,
  }) {
    RegExpMatch? match = timeRegExp.firstMatch(time);
    late String startTime, stopTime;
    if (match != null) {
      startTime = Jiffy.parseFromDateTime(DateTime(
        int.parse(match.namedGroup('year')!),
        int.parse(match.namedGroup('month')!),
        int.parse(match.namedGroup('day')!),
        int.parse(match.namedGroup('hour')!),
        int.parse(match.namedGroup('minute')!),
      )).format(pattern: "yyyy-MM-dd HH:mm:ss");

      stopTime = Jiffy.parseFromDateTime(DateTime(
        int.parse(match.namedGroup('year')!),
        int.parse(match.namedGroup('month')!),
        int.parse(match.namedGroup('day')!),
        int.parse(match.namedGroup('stopHour')!),
        int.parse(match.namedGroup('stopMinute')!),
      )).format(pattern: "yyyy-MM-dd HH:mm:ss");
    } else {
      startTime = stopTime = "取消考试资格:P";
    }

    return Subject(
      subject: subject,
      typeStr: typeStr,
      time: time,
      place: place,
      seat: seat,
      startTimeStr: startTime,
      endTimeStr: stopTime,
    );
  }

  Subject({
    required this.subject,
    required this.typeStr,
    required this.time,
    required this.startTimeStr,
    required this.endTimeStr,
    required this.place,
    required this.seat,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

// Or should I say, to be dead?
@JsonSerializable(explicitToJson: true)
class ToBeArranged {
  String subject;
  String id;

  @override
  String toString() => "$subject $id\n";

  ToBeArranged({
    required this.subject,
    required this.id,
  });

  factory ToBeArranged.fromJson(Map<String, dynamic> json) =>
      _$ToBeArrangedFromJson(json);

  Map<String, dynamic> toJson() => _$ToBeArrangedToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExamData {
  List<Subject> subject;
  List<ToBeArranged> toBeArranged;

  ExamData({
    required this.subject,
    required this.toBeArranged,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) =>
      _$ExamDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDataToJson(this);
}

class NotImplementedException implements Exception {}
