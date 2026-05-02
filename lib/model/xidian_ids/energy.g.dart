// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityHistoryInfo _$ElectricityHistoryInfoFromJson(
  Map<String, dynamic> json,
) => ElectricityHistoryInfo(
  fetchDay: DateTime.parse(json['fetchDay'] as String),
  remain: json['remain'] as String,
);

Map<String, dynamic> _$ElectricityHistoryInfoToJson(
  ElectricityHistoryInfo instance,
) => <String, dynamic>{
  'fetchDay': instance.fetchDay.toIso8601String(),
  'remain': instance.remain,
};

MeterInfo _$MeterInfoFromJson(Map<String, dynamic> json) => MeterInfo(
  ReadTime: DateTime.parse(json['ReadTime'] as String),
  ReadNum: json['ReadNum'] as num,
  StartNum: json['StartNum'] as num,
  EndNum: json['EndNum'] as num,
);

Map<String, dynamic> _$MeterInfoToJson(MeterInfo instance) => <String, dynamic>{
  'ReadTime': instance.ReadTime.toIso8601String(),
  'ReadNum': instance.ReadNum,
  'StartNum': instance.StartNum,
  'EndNum': instance.EndNum,
};

EnergyInfo _$EnergyInfoFromJson(Map<String, dynamic> json) => EnergyInfo(
  lastReadDate: DateTime.parse(json['lastReadDate'] as String),
  electricityRemain: json['electricityRemain'] as num,
  electricityMeterList: (json['electricityMeterList'] as List<dynamic>)
      .map((e) => MeterInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  waterMeterList: (json['waterMeterList'] as List<dynamic>)
      .map((e) => MeterInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EnergyInfoToJson(EnergyInfo instance) =>
    <String, dynamic>{
      'lastReadDate': instance.lastReadDate.toIso8601String(),
      'electricityRemain': instance.electricityRemain,
      'electricityMeterList': instance.electricityMeterList,
      'waterMeterList': instance.waterMeterList,
    };
