// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'experiment.g.dart';

enum ExperimentType { physics, others }

@JsonSerializable(explicitToJson: true)
class ExperimentData {
  final ExperimentType type;
  final String name;
  final String? score;
  final String classroom;
  final List<(DateTime, DateTime)> timeRanges;
  // final String week;
  final String teacher;
  final String? reference;

  const ExperimentData({
    required this.type,
    required this.name,
    this.score,
    required this.classroom,
    required this.timeRanges,
    required this.teacher,
    this.reference,
  });

  factory ExperimentData.fromJson(Map<String, dynamic> json) =>
      _$ExperimentDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentDataToJson(this);

  @override
  String toString() {
    return 'ExperimentData('
        'type: $type, '
        'name: $name, '
        'score: ${score ?? "N/A"}, '
        'classroom: $classroom, '
        'timeRanges: ${timeRanges.map((range) => "[${range.$1.toIso8601String()} - ${range.$2.toIso8601String()}]").join(", ")}, '
        'teacher: $teacher, '
        'reference: ${reference ?? "N/A"}'
        ')';
  }
}
