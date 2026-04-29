// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'energy.g.dart';

@JsonSerializable()
class ElectricityHistoryInfo {
  DateTime fetchDay;
  String remain;

  ElectricityHistoryInfo({required this.fetchDay, required this.remain});

  factory ElectricityHistoryInfo.fromJson(Map<String, dynamic> json) =>
      _$ElectricityHistoryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricityHistoryInfoToJson(this);
}

@JsonSerializable()
class MeterInfo {
  final DateTime ReadTime;
  final num ReadNum;
  final num StartNum;
  final num EndNum;

  MeterInfo({
    required this.ReadTime,
    required this.ReadNum,
    required this.StartNum,
    required this.EndNum,
  });

  factory MeterInfo.fromJson(Map<String, dynamic> json) =>
      _$MeterInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MeterInfoToJson(this);
}

@JsonSerializable()
class EnergyInfo {
  final DateTime lastReadDate;
  final num electricityRemain;
  final List<MeterInfo> electricityMeterList;
  final List<MeterInfo> waterMeterList;

  EnergyInfo({
    required this.lastReadDate,
    required this.electricityRemain,
    required this.electricityMeterList,
    required this.waterMeterList,
  });

  factory EnergyInfo.fromJson(Map<String, dynamic> json) =>
      _$EnergyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$EnergyInfoToJson(this);
}
