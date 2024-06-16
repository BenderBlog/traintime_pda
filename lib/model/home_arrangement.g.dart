// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_arrangement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeArrangement _$HomeArrangementFromJson(Map<String, dynamic> json) =>
    HomeArrangement(
      name: json['name'] as String,
      startTimeStr: json['start_time'] as String,
      endTimeStr: json['end_time'] as String,
      teacher: json['teacher'] as String?,
      place: json['place'] as String?,
      seat: json['seat'] as String?,
    );

Map<String, dynamic> _$HomeArrangementToJson(HomeArrangement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacher': instance.teacher,
      'place': instance.place,
      'seat': instance.seat,
      'start_time': instance.startTimeStr,
      'end_time': instance.endTimeStr,
    };
