// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'electricity.g.dart';

@JsonSerializable()
class ElectricityInfo {
  DateTime fetchDay;
  String remain;
  String owe;

  ElectricityInfo({
    required this.fetchDay,
    required this.remain,
    required this.owe,
  });

  factory ElectricityInfo.empty(
    DateTime time,
  ) =>
      ElectricityInfo(
        fetchDay: time,
        remain: "electricity_status.pending",
        owe: "electricity_status.pending",
      );

  factory ElectricityInfo.fromJson(Map<String, dynamic> json) =>
      _$ElectricityInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricityInfoToJson(this);
}
