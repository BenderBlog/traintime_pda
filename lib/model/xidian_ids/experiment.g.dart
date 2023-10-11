// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentData _$ExperimentDataFromJson(Map<String, dynamic> json) =>
    ExperimentData(
      name: json['name'] as String,
      score: json['score'] as String,
      classroom: json['classroom'] as String,
      date: json['date'] as String,
      timeStr: json['timeStr'] as String,
      teacher: json['teacher'] as String,
      reference: json['reference'] as String,
    );

Map<String, dynamic> _$ExperimentDataToJson(ExperimentData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'score': instance.score,
      'classroom': instance.classroom,
      'date': instance.date,
      'timeStr': instance.timeStr,
      'teacher': instance.teacher,
      'reference': instance.reference,
    };
