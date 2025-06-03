// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:intl/intl.dart';
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

  static RegExp timeRegExpUnderGraduate = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})-(?<stopHour>\d{2})(::?)(?<stopMinute>\d{2})',
  );
  static RegExp timeRegExpPostGraduate = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (.{3})\((?<hour>\d{2})(::?)(?<minute>\d{2})-(?<stopHour>\d{2})(::?)(?<stopMinute>\d{2})\)',
  );

  @override
  String toString() => "$subject $typeStr $type $time $place $seat\n";

  DateTime? get startTime {
    RegExpMatch? match = timeRegExpUnderGraduate.firstMatch(time) ??
        timeRegExpPostGraduate.firstMatch(time);
    if (match == null) return null;

    return DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('hour')!),
      int.parse(match.namedGroup('minute')!),
    );
  }

  DateTime? get stopTime {
    RegExpMatch? match = timeRegExpUnderGraduate.firstMatch(time) ??
        timeRegExpPostGraduate.firstMatch(time);
    if (match == null) return null;

    return DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('stopHour')!),
      int.parse(match.namedGroup('stopMinute')!),
    );
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
    RegExpMatch? match = timeRegExpUnderGraduate.firstMatch(time) ??
        timeRegExpPostGraduate.firstMatch(time);
    late String startTime, stopTime;
    if (match != null) {
      DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");

      startTime = formatter.format(DateTime(
        int.parse(match.namedGroup('year')!),
        int.parse(match.namedGroup('month')!),
        int.parse(match.namedGroup('day')!),
        int.parse(match.namedGroup('hour')!),
        int.parse(match.namedGroup('minute')!),
      ));

      stopTime = formatter.format(DateTime(
        int.parse(match.namedGroup('year')!),
        int.parse(match.namedGroup('month')!),
        int.parse(match.namedGroup('day')!),
        int.parse(match.namedGroup('stopHour')!),
        int.parse(match.namedGroup('stopMinute')!),
      ));
    } else {
      startTime = stopTime = "cancel_exam";
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
