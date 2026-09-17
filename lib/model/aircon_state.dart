// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

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

class AirconState {
  const AirconState({
    required this.imei,
    required this.isOn,
    required this.mode,
    required this.windSpeed,
    required this.targetTemperature,
    required this.indoorTemperature,
    required this.verticalSwing,
    required this.strongMode,
    required this.electricHeating,
    required this.electricAmount,
    required this.timestamp,
    required this.errorCode,
  });

  final String imei;
  final bool isOn;
  final AirconMode mode;
  final AirconWindSpeed windSpeed;
  final int targetTemperature;
  final num? indoorTemperature;
  final bool verticalSwing;
  final bool strongMode;
  final bool electricHeating;
  final num? electricAmount;
  final DateTime? timestamp;
  final String? errorCode;

  factory AirconState.fromJson(Map<String, dynamic> json) {
    final switchStatus = _toInt(json["switchStatus"]);
    final modeValue = _toInt(json["runMode"]);
    final windValue = _toInt(json["windSpeed"]);
    final targetTemperature = _toInt(json["tempSet"]);
    final verticalSwing = _toInt(json["verticalSwing"]);
    final strongMode = _toInt(json["strongMode"]);
    final electricHeating = _toInt(json["electricHeating"]);
    final timestamp = _toInt(json["timestamp"]);
    final mode = AirconMode.values
        .where((value) => value.value == modeValue)
        .firstOrNull;
    final windSpeed = AirconWindSpeed.values
        .where((value) => value.value == windValue)
        .firstOrNull;

    if (switchStatus == null ||
        mode == null ||
        windSpeed == null ||
        targetTemperature == null ||
        verticalSwing == null ||
        strongMode == null ||
        electricHeating == null) {
      throw const FormatException("Aircon state is incomplete");
    }

    return AirconState(
      imei: json["imei"]?.toString() ?? "",
      isOn: switchStatus == 1,
      mode: mode,
      windSpeed: windSpeed,
      targetTemperature: targetTemperature.clamp(18, 32).toInt(),
      indoorTemperature: _toNum(json["indoorTemp"]),
      verticalSwing: verticalSwing == 1,
      strongMode: strongMode == 1,
      electricHeating: electricHeating == 1,
      electricAmount: _toNum(json["electricAmount"]),
      timestamp: timestamp == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      errorCode: json["errCode"]?.toString(),
    );
  }

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
      isOn: isOn ?? this.isOn,
      mode: mode ?? this.mode,
      windSpeed: windSpeed ?? this.windSpeed,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      indoorTemperature: indoorTemperature,
      verticalSwing: verticalSwing ?? this.verticalSwing,
      strongMode: strongMode ?? this.strongMode,
      electricHeating: electricHeating ?? this.electricHeating,
      electricAmount: electricAmount,
      timestamp: timestamp,
      errorCode: errorCode,
    );
  }
}

int? _toInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? "");

num? _toNum(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? "");
