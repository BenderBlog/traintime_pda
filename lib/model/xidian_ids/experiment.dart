// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';
import 'package:watermeter/repository/experiment_score/image_recognition.dart';

part 'experiment.g.dart';

enum ExperimentType { physics, others }

@JsonSerializable(explicitToJson: true)
class ExperimentData {
  final ExperimentType type;
  final String name;
  @JsonKey(
    fromJson: _recognitionResultFromJson,
    toJson: _recognitionResultToJson,
  )
  final RecognitionResult? score;
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
        'score: ${score?.toString() ?? "N/A"}, '
        'classroom: $classroom, '
        'timeRanges: ${timeRanges.map((range) => "[${range.$1.toIso8601String()} - ${range.$2.toIso8601String()}]").join(", ")}, '
        'teacher: $teacher, '
        'reference: ${reference ?? "N/A"}'
        ')';
  }

  factory ExperimentData.from(ExperimentData src) => ExperimentData(
    type: src.type,
    name: src.name,
    score: src.score,
    classroom: src.classroom,
    timeRanges: src.timeRanges.toList(),
    teacher: src.teacher,
    reference: src.reference,
  );
}

// JSON converter helper functions for RecognitionResult
// Supports migration from old String? format to new RecognitionResult? format
RecognitionResult? _recognitionResultFromJson(dynamic json) {
  if (json == null) return null;
  
  // Handle old format: score was a String
  // Return null to trigger data refresh in ExperimentController
  if (json is String) {
    // Mark as old format by returning null
    // This will be detected in ExperimentController.onInit() 
    // and trigger a refresh to fetch new data with proper RecognitionResult
    return null;
  }
  
  // Handle new format: score is a Map (RecognitionResult)
  if (json is Map<String, dynamic>) {
    return RecognitionResult.fromJson(json);
  }
  
  // Invalid format
  return null;
}

Map<String, dynamic>? _recognitionResultToJson(RecognitionResult? result) {
  return result?.toJson();
}
