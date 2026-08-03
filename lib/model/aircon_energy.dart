// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'aircon_energy.g.dart';

@JsonSerializable(explicitToJson: true)
class AirconEnergyInfo {
  final String imei;
  final DateTime fetchTime;
  final DateTime stateTime;
  final num electricAmount;

  const AirconEnergyInfo({
    required this.imei,
    required this.fetchTime,
    required this.stateTime,
    required this.electricAmount,
  });

  factory AirconEnergyInfo.fromJson(Map<String, dynamic> json) =>
      _$AirconEnergyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AirconEnergyInfoToJson(this);
}
