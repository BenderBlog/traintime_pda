// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircon_energy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirconEnergyInfo _$AirconEnergyInfoFromJson(Map<String, dynamic> json) =>
    AirconEnergyInfo(
      imei: json['imei'] as String,
      fetchTime: DateTime.parse(json['fetchTime'] as String),
      stateTime: DateTime.parse(json['stateTime'] as String),
      electricAmount: json['electricAmount'] as num,
    );

Map<String, dynamic> _$AirconEnergyInfoToJson(AirconEnergyInfo instance) =>
    <String, dynamic>{
      'imei': instance.imei,
      'fetchTime': instance.fetchTime.toIso8601String(),
      'stateTime': instance.stateTime.toIso8601String(),
      'electricAmount': instance.electricAmount,
    };
