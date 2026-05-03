// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class CompletedClassStyleConfig {
  /// Default tuning parameters for completed classes.
  /// Completed-card color tuning.
  /// Lower values make finished classes look more muted and faded.
  static double completedSaturationFactor = 0.25;
  static double completedBrightnessFactor = 0.75;
  static double completedTextSaturationFactor = 0.75;
  static double completedBorderAlpha = 0.75;
  static double completedInnerAlpha = 0.75;
  /// Active-card baseline appearance.
  static double activeBrightnessFactor = 1.0;
  static double activeBorderAlpha = 1.0;
  static double activeInnerAlpha = 0.9;

  static void loadFromPreference() {
    if (preference.contains(
      preference.Preference.classStyleActiveBrightnessFactor,
    )) {
      activeBrightnessFactor = preference
          .getDouble(preference.Preference.classStyleActiveBrightnessFactor)
          .clamp(0.5, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleActiveBorderAlpha,
    )) {
      activeBorderAlpha = preference
          .getDouble(preference.Preference.classStyleActiveBorderAlpha)
          .clamp(0.1, 1.0)
          .toDouble();
    }
    if (preference.contains(preference.Preference.classStyleActiveInnerAlpha)) {
      activeInnerAlpha = preference
          .getDouble(preference.Preference.classStyleActiveInnerAlpha)
          .clamp(0.1, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleCompletedSaturationFactor,
    )) {
      completedSaturationFactor = preference
          .getDouble(preference.Preference.classStyleCompletedSaturationFactor)
          .clamp(0.1, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleCompletedBrightnessFactor,
    )) {
      completedBrightnessFactor = preference
          .getDouble(preference.Preference.classStyleCompletedBrightnessFactor)
          .clamp(0.5, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleCompletedTextSaturationFactor,
    )) {
      completedTextSaturationFactor = preference
          .getDouble(
            preference.Preference.classStyleCompletedTextSaturationFactor,
          )
          .clamp(0.1, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleCompletedBorderAlpha,
    )) {
      completedBorderAlpha = preference
          .getDouble(preference.Preference.classStyleCompletedBorderAlpha)
          .clamp(0.1, 1.0)
          .toDouble();
    }
    if (preference.contains(
      preference.Preference.classStyleCompletedInnerAlpha,
    )) {
      completedInnerAlpha = preference
          .getDouble(preference.Preference.classStyleCompletedInnerAlpha)
          .clamp(0.1, 1.0)
          .toDouble();
    }
  }

  static Future<void> saveToPreference() async {
    await preference.setDouble(
      preference.Preference.classStyleActiveBrightnessFactor,
      activeBrightnessFactor.clamp(0.5, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleActiveBorderAlpha,
      activeBorderAlpha.clamp(0.1, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleActiveInnerAlpha,
      activeInnerAlpha.clamp(0.1, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleCompletedSaturationFactor,
      completedSaturationFactor.clamp(0.1, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleCompletedBrightnessFactor,
      completedBrightnessFactor.clamp(0.5, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleCompletedTextSaturationFactor,
      completedTextSaturationFactor.clamp(0.1, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleCompletedBorderAlpha,
      completedBorderAlpha.clamp(0.1, 1.0).toDouble(),
    );
    await preference.setDouble(
      preference.Preference.classStyleCompletedInnerAlpha,
      completedInnerAlpha.clamp(0.1, 1.0).toDouble(),
    );
  }
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

  static Color _adjustBrightness(Color color, {double factor = 1.0}) {
    final hsl = HSLColor.fromColor(color);
    final brightness = (hsl.lightness * factor).clamp(0.0, 1.0).toDouble();
    return hsl.withLightness(brightness).toColor();
  }

  static Color _tuneColor(
    Color color, {
    required double saturationFactor,
    required double brightnessFactor,
  }) {
    final desaturated = _desaturateColor(color, factor: saturationFactor);
    return _adjustBrightness(desaturated, factor: brightnessFactor);
  }

  static CompletedClassStyleData resolve({
    required MaterialColor palette,
    required bool isCompleted,
  }) {
    final saturationFactor = isCompleted
        ? CompletedClassStyleConfig.completedSaturationFactor
        : 1.0;
    final brightnessFactor =
        (isCompleted
                ? CompletedClassStyleConfig.completedBrightnessFactor
                : CompletedClassStyleConfig.activeBrightnessFactor)
            .clamp(0.5, 1.0)
            .toDouble();
    final borderColor = isCompleted
        ? _tuneColor(
            palette.shade300,
            saturationFactor: saturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade300, factor: brightnessFactor);
    final innerColor = isCompleted
        ? _tuneColor(
            palette.shade100,
            saturationFactor: saturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade100, factor: brightnessFactor);
    final textColor = isCompleted
        ? _tuneColor(
            palette.shade900,
            saturationFactor:
                CompletedClassStyleConfig.completedTextSaturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade900, factor: brightnessFactor);

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
