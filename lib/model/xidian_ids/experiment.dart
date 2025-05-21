// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'experiment.g.dart';

@JsonSerializable(explicitToJson: true)
class ExperimentData {
  final String name;
  final String score;
  final String classroom;
  final String date;
  // final String week;
  final String timeStr;
  final String teacher;
  final String reference;

  const ExperimentData({
    required this.name,
    required this.score,
    required this.classroom,
    required this.date,
    //required this.week,
    required this.timeStr,
    required this.teacher,
    required this.reference,
  });

  List<DateTime> get time {
    /// Return is month/day/year, hope not change...
    List<int> dateNums = List<int>.generate(
      date.split('/').length,
      (index) => int.parse(date.split('/')[index]),
    );

    /// And the time arrangement too.
    if (timeStr.contains("15")) {
      return [
        DateTime(dateNums[2], dateNums[0], dateNums[1], 15, 55, 00),
        DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 10, 00),
      ]; // Afternoon 15:55～18:10
    } else {
      return [
        DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 30, 00),
        DateTime(dateNums[2], dateNums[0], dateNums[1], 20, 45, 00),
      ]; // Evening 18:30～20:45
    }
  }

  factory ExperimentData.fromJson(Map<String, dynamic> json) =>
      _$ExperimentDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentDataToJson(this);
}
