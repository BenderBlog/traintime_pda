// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircon_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirconState _$AirconStateFromJson(Map<String, dynamic> json) => AirconState(
  imei: json['imei'] as String? ?? '',
  switchStatus: (json['switchStatus'] as num).toInt(),
  mode: $enumDecode(_$AirconModeEnumMap, json['runMode']),
  windSpeed: $enumDecode(_$AirconWindSpeedEnumMap, json['windSpeed']),
  targetTemperature: (json['tempSet'] as num).toInt(),
  indoorTemperature: json['indoorTemp'] as num?,
  verticalSwingStatus: (json['verticalSwing'] as num).toInt(),
  strongModeStatus: (json['strongMode'] as num).toInt(),
  electricHeatingStatus: (json['electricHeating'] as num).toInt(),
  electricAmount: json['electricAmount'] as num?,
  timestampSeconds: (json['timestamp'] as num?)?.toInt(),
  errorCode: json['errCode'] as String?,
);

Map<String, dynamic> _$AirconStateToJson(AirconState instance) =>
    <String, dynamic>{
      'imei': instance.imei,
      'switchStatus': instance.switchStatus,
      'runMode': _$AirconModeEnumMap[instance.mode]!,
      'windSpeed': _$AirconWindSpeedEnumMap[instance.windSpeed]!,
      'tempSet': instance.targetTemperature,
      'indoorTemp': instance.indoorTemperature,
      'verticalSwing': instance.verticalSwingStatus,
      'strongMode': instance.strongModeStatus,
      'electricHeating': instance.electricHeatingStatus,
      'electricAmount': instance.electricAmount,
      'timestamp': instance.timestampSeconds,
      'errCode': instance.errorCode,
    };

const _$AirconModeEnumMap = {
  AirconMode.fan: 0,
  AirconMode.heat: 1,
  AirconMode.cool: 2,
  AirconMode.dry: 3,
  AirconMode.auto: 4,
};

const _$AirconWindSpeedEnumMap = {
  AirconWindSpeed.auto: 0,
  AirconWindSpeed.silent: 1,
  AirconWindSpeed.low: 2,
  AirconWindSpeed.medium: 3,
  AirconWindSpeed.high: 4,
};
