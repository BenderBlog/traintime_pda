// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/model/class_organized_data.dart';
import 'package:watermeter/page/classtable/model/style_config/class_card_style_config.dart';

export 'package:watermeter/page/classtable/model/style_config/class_card_style_config.dart';

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
    final useCompletedStyle =
        isCompleted && ClassCardStyleConfig.completedEnabled;
    final saturationFactor = isCompleted
        ? ClassCardStyleConfig.completedSaturationFactor
        : 1.0;
    final brightnessFactor =
        (useCompletedStyle
                ? ClassCardStyleConfig.completedBrightnessFactor
                : ClassCardStyleConfig.activeBrightnessFactor)
            .clamp(0.5, 1.0)
            .toDouble();
    final borderColor = useCompletedStyle
        ? _tuneColor(
            palette.shade300,
            saturationFactor: saturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade300, factor: brightnessFactor);
    final innerColor = useCompletedStyle
        ? _tuneColor(
            palette.shade100,
            saturationFactor: saturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade100, factor: brightnessFactor);
    final textColor = useCompletedStyle
        ? _tuneColor(
            palette.shade900,
            saturationFactor:
                ClassCardStyleConfig.completedTextSaturationFactor,
            brightnessFactor: brightnessFactor,
          )
        : _adjustBrightness(palette.shade900, factor: brightnessFactor);

    return CompletedClassStyleData(
      borderColor: borderColor,
      innerColor: innerColor,
      textColor: textColor,
      borderAlpha: useCompletedStyle
          ? ClassCardStyleConfig.completedBorderAlpha
          : ClassCardStyleConfig.activeBorderAlpha,
      innerAlpha: useCompletedStyle
          ? ClassCardStyleConfig.completedInnerAlpha
          : ClassCardStyleConfig.activeInnerAlpha,
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
