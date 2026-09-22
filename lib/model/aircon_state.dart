// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'aircon_state.g.dart';

@JsonEnum(valueField: "value")
enum AirconMode {
  fan(0, "electricity.aircon_mode_fan"),
  heat(1, "electricity.aircon_mode_heat"),
  cool(2, "electricity.aircon_mode_cool"),
  dry(3, "electricity.aircon_mode_dry"),
  auto(4, "electricity.aircon_mode_auto");

  const AirconMode(this.value, this.labelKey);

  final int value;
  final String labelKey;
}

@JsonEnum(valueField: "value")
enum AirconWindSpeed {
  auto(0, "electricity.aircon_wind_auto"),
  silent(1, "electricity.aircon_wind_silent"),
  low(2, "electricity.aircon_wind_low"),
  medium(3, "electricity.aircon_wind_medium"),
  high(4, "electricity.aircon_wind_high");

  const AirconWindSpeed(this.value, this.labelKey);

  final int value;
  final String labelKey;
}

@JsonSerializable()
class AirconState {
  const AirconState({
    required this.imei,
    required this.switchStatus,
    required this.mode,
    required this.windSpeed,
    required this.targetTemperature,
    required this.indoorTemperature,
    required this.verticalSwingStatus,
    required this.strongModeStatus,
    required this.electricHeatingStatus,
    required this.electricAmount,
    required this.timestampSeconds,
    required this.errorCode,
  });

  @JsonKey(defaultValue: "")
  final String imei;

  final int switchStatus;

  @JsonKey(name: "runMode")
  final AirconMode mode;

  final AirconWindSpeed windSpeed;

  @JsonKey(name: "tempSet")
  final int targetTemperature;

  @JsonKey(name: "indoorTemp")
  final num? indoorTemperature;

  @JsonKey(name: "verticalSwing")
  final int verticalSwingStatus;

  @JsonKey(name: "strongMode")
  final int strongModeStatus;

  @JsonKey(name: "electricHeating")
  final int electricHeatingStatus;

  final num? electricAmount;

  @JsonKey(name: "timestamp")
  final int? timestampSeconds;

  @JsonKey(name: "errCode")
  final String? errorCode;

  bool get isOn => switchStatus == 1;
  bool get verticalSwing => verticalSwingStatus == 1;
  bool get strongMode => strongModeStatus == 1;
  bool get electricHeating => electricHeatingStatus == 1;
  DateTime? get timestamp => timestampSeconds == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(timestampSeconds! * 1000);

  factory AirconState.fromJson(Map<String, dynamic> json) =>
      _$AirconStateFromJson(json);

  Map<String, dynamic> toJson() => _$AirconStateToJson(this);

  AirconState copyWith({
    bool? isOn,
    AirconMode? mode,
    AirconWindSpeed? windSpeed,
    int? targetTemperature,
    bool? verticalSwing,
    bool? strongMode,
    bool? electricHeating,
  }) {
    return AirconState(
      imei: imei,
      switchStatus: isOn == null ? switchStatus : (isOn ? 1 : 0),
      mode: mode ?? this.mode,
      windSpeed: windSpeed ?? this.windSpeed,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      indoorTemperature: indoorTemperature,
      verticalSwingStatus: verticalSwing == null
          ? verticalSwingStatus
          : (verticalSwing ? 1 : 0),
      strongModeStatus: strongMode == null
          ? strongModeStatus
          : (strongMode ? 1 : 0),
      electricHeatingStatus: electricHeating == null
          ? electricHeatingStatus
          : (electricHeating ? 1 : 0),
      electricAmount: electricAmount,
      timestampSeconds: timestampSeconds,
      errorCode: errorCode,
    );
  }
}
