// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomClassTimeRange _$CustomClassTimeRangeFromJson(
  Map<String, dynamic> json,
) => CustomClassTimeRange(
  id: json['id'] as String,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
);

Map<String, dynamic> _$CustomClassTimeRangeToJson(
  CustomClassTimeRange instance,
) => <String, dynamic>{
  'id': instance.id,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
};

CustomClass _$CustomClassFromJson(Map<String, dynamic> json) => CustomClass(
  id: json['id'] as String,
  name: json['name'] as String,
  teacher: json['teacher'] as String?,
  classroom: json['classroom'] as String?,
  timeRanges: (json['time_ranges'] as List<dynamic>)
      .map((e) => CustomClassTimeRange.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CustomClassToJson(CustomClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'time_ranges': instance.timeRanges.map((e) => e.toJson()).toList(),
    };
