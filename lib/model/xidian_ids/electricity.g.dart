// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electricity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityInfo _$ElectricityInfoFromJson(Map<String, dynamic> json) =>
    ElectricityInfo(
      fetchDay: DateTime.parse(json['fetchDay'] as String),
      electricityRemain: json['electricityRemain'] as String,
      waterRemain: json['waterRemain'] as String,
    );

Map<String, dynamic> _$ElectricityInfoToJson(ElectricityInfo instance) =>
    <String, dynamic>{
      'fetchDay': instance.fetchDay.toIso8601String(),
      'electricityRemain': instance.electricityRemain,
      'waterRemain': instance.waterRemain,
    };
