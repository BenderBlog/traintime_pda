// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

class ClassTableLaunchTarget {
  final String? source;
  final int? index;
  final int? weekIndex;
  final int? dayIndex;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? startPeriod;
  final int? stopPeriod;
  final String? name;
  final String? place;

  const ClassTableLaunchTarget({
    this.source,
    this.index,
    this.weekIndex,
    this.dayIndex,
    this.startTime,
    this.endTime,
    this.startPeriod,
    this.stopPeriod,
    this.name,
    this.place,
  });

  bool get opensSchedule => source != null;

  static ClassTableLaunchTarget? fromUri(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme != "xdyou" || uri.host != "classtable") return null;

    final params = uri.queryParameters;
    return ClassTableLaunchTarget(
      source: params["source"],
      index: int.tryParse(params["index"] ?? ""),
      weekIndex: int.tryParse(params["week"] ?? ""),
      dayIndex: int.tryParse(params["day"] ?? ""),
      startTime: DateTime.tryParse(params["start"] ?? ""),
      endTime: DateTime.tryParse(params["end"] ?? ""),
      startPeriod: int.tryParse(params["startPeriod"] ?? ""),
      stopPeriod: int.tryParse(params["stopPeriod"] ?? ""),
      name: params["name"],
      place: params["place"],
    );
  }
}
