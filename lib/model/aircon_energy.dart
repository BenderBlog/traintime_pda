// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

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

  factory AirconEnergyInfo.fromJuhaolianJson(Map<String, dynamic> json) {
    final result = json["result"];
    if (json["success"] != true || result is! Map) {
      throw AirconEnergyParseException(json["message"]?.toString() ?? "");
    }

    final electricAmount = _numValue(result["electricAmount"]);
    if (electricAmount == null) {
      throw const AirconEnergyParseException("electricAmount is missing");
    }

    return AirconEnergyInfo(
      imei: _stringValue(result["imei"]),
      fetchTime: _dateTimeFromTimestamp(json["timestamp"]),
      stateTime: _dateTimeFromTimestamp(result["timestamp"]),
      electricAmount: electricAmount,
    );
  }
}

DateTime _dateTimeFromTimestamp(Object? value) {
  final timestamp = _intValue(value);
  if (timestamp == null || timestamp <= 0) {
    return DateTime.now();
  }
  if (timestamp > 100000000000) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num? _numValue(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

String _stringValue(Object? value) => value?.toString() ?? "";

class AirconEnergyParseException implements Exception {
  final String message;

  const AirconEnergyParseException(this.message);

  @override
  String toString() => message.isEmpty
      ? "Aircon energy response parse failed"
      : "Aircon energy response parse failed: $message";
}
