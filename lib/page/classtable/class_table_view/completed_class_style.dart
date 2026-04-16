// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';

class CompletedClassStyleConfig {
  /// Completed-card color tuning.
  /// Lower values make finished classes look more muted and faded.
  static double completedSaturationFactor = 0.35;
  static double completedTextSaturationFactor = 0.55;
  static double completedBorderAlpha = 0.55;
  static double completedInnerAlpha = 0.45;

  /// Active-card baseline appearance.
  static double activeBorderAlpha = 0.8;
  static double activeInnerAlpha = 0.7;
}

class CompletedClassStyleData {
  final Color borderColor;
  final Color innerColor;
  final Color textColor;
  final double borderAlpha;
  final double innerAlpha;

  const CompletedClassStyleData({
    required this.borderColor,
    required this.innerColor,
    required this.textColor,
    required this.borderAlpha,
    required this.innerAlpha,
  });
}

class CompletedClassStyle {
  static Color _desaturateColor(Color color, {double factor = 0.35}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(hsl.saturation * factor).toColor();
  }

  static CompletedClassStyleData resolve({
    required MaterialColor palette,
    required bool isCompleted,
  }) {
    final borderColor = isCompleted
        ? _desaturateColor(
            palette.shade300,
            factor: CompletedClassStyleConfig.completedSaturationFactor,
          )
        : palette.shade300;
    final innerColor = isCompleted
        ? _desaturateColor(
            palette.shade100,
            factor: CompletedClassStyleConfig.completedSaturationFactor,
          )
        : palette.shade100;
    final textColor = isCompleted
        ? _desaturateColor(
            palette.shade900,
            factor: CompletedClassStyleConfig.completedTextSaturationFactor,
          )
        : palette.shade900;

    return CompletedClassStyleData(
      borderColor: borderColor,
      innerColor: innerColor,
      textColor: textColor,
      borderAlpha: isCompleted
          ? CompletedClassStyleConfig.completedBorderAlpha
          : CompletedClassStyleConfig.activeBorderAlpha,
      innerAlpha: isCompleted
          ? CompletedClassStyleConfig.completedInnerAlpha
          : CompletedClassStyleConfig.activeInnerAlpha,
    );
  }

  static DateTime eventEndTime({
    required ClassOrgainzedData data,
    required DateTime dayStart,
  }) {
    if (data.actualEndTime != null) {
      return data.actualEndTime!;
    }

    if (data.data.isEmpty || data.data.first is! TimeArrangement) {
      return dayStart;
    }

    final arrangement = data.data.first as TimeArrangement;
    final stopIndex = (arrangement.stop - 1) * 2 + 1;
    final stopTime = timeList[stopIndex].split(':');

    return DateTime(
      dayStart.year,
      dayStart.month,
      dayStart.day,
      int.parse(stopTime[0]),
      int.parse(stopTime[1]),
    );
  }

  static bool isCompleted({
    required ClassOrgainzedData data,
    required DateTime now,
    required DateTime dayStart,
  }) {
    final end = eventEndTime(data: data, dayStart: dayStart);
    return end.isBefore(now);
  }
}
