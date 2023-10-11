// Copyright 2023 BenderBlog Rodriguez and contributors.
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

  factory ExperimentData.fromJson(Map<String, dynamic> json) =>
      _$ExperimentDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentDataToJson(this);
}
