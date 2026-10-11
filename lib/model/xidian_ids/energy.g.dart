// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityHistoryInfo _$ElectricityHistoryInfoFromJson(
  Map<String, dynamic> json,
) => ElectricityHistoryInfo(
  fetchDay: DateTime.parse(json['fetchDay'] as String),
  historyInfo: (json['historyInfo'] as List<dynamic>)
      .map((e) => MeterInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  remain: json['remain'] as num,
);

Map<String, dynamic> _$ElectricityHistoryInfoToJson(
  ElectricityHistoryInfo instance,
) => <String, dynamic>{
  'fetchDay': instance.fetchDay.toIso8601String(),
  'remain': instance.remain,
  'historyInfo': instance.historyInfo,
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
  electricityMeterList: (json['electricityMeterList'] as Map<String, dynamic>)
      .map(
        (k, e) => MapEntry(
          k,
          ElectricityHistoryInfo.fromJson(e as Map<String, dynamic>),
        ),
      ),
  waterMeterList: (json['waterMeterList'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => MeterInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$EnergyInfoToJson(EnergyInfo instance) =>
    <String, dynamic>{
      'electricityMeterList': instance.electricityMeterList,
      'waterMeterList': instance.waterMeterList,
    };
