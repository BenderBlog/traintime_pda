// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      subject: json['subject'] as String,
      typeStr: json['typeStr'] as String,
      time: json['time'] as String,
      startTimeStr: json['startTimeStr'] as String,
      endTimeStr: json['endTimeStr'] as String,
      place: json['place'] as String,
      seat: (json['seat'] as num).toInt(),
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'subject': instance.subject,
      'typeStr': instance.typeStr,
      'startTimeStr': instance.startTimeStr,
      'endTimeStr': instance.endTimeStr,
      'time': instance.time,
      'place': instance.place,
      'seat': instance.seat,
    };

ToBeArranged _$ToBeArrangedFromJson(Map<String, dynamic> json) => ToBeArranged(
      subject: json['subject'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$ToBeArrangedToJson(ToBeArranged instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'id': instance.id,
    };

ExamData _$ExamDataFromJson(Map<String, dynamic> json) => ExamData(
      subject: (json['subject'] as List<dynamic>)
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
      toBeArranged: (json['toBeArranged'] as List<dynamic>)
          .map((e) => ToBeArranged.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamDataToJson(ExamData instance) => <String, dynamic>{
      'subject': instance.subject.map((e) => e.toJson()).toList(),
      'toBeArranged': instance.toBeArranged.map((e) => e.toJson()).toList(),
    };
