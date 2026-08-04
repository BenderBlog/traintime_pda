// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'experiment.g.dart';

enum ExperimentType { others }

@JsonSerializable(explicitToJson: true)
class ExperimentData {
  final ExperimentType type;
  final String name;
  final String classroom;
  final List<(DateTime, DateTime)> timeRanges;
  final String teacher;
  final String? reference;

  const ExperimentData({
    required this.type,
    required this.name,
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
        'classroom: $classroom, '
        'timeRanges: ${timeRanges.map((range) => "[${range.$1.toIso8601String()} - ${range.$2.toIso8601String()}]").join(", ")}, '
        'teacher: $teacher, '
        'reference: ${reference ?? "N/A"}'
        ')';
  }

  factory ExperimentData.from(ExperimentData src) => ExperimentData(
    type: src.type,
    name: src.name,
    classroom: src.classroom,
    timeRanges: src.timeRanges.toList(),
    teacher: src.teacher,
    reference: src.reference,
  );
}
