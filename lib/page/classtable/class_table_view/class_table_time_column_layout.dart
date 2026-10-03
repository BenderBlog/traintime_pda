// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// Measures the time column using the same styles and scaling as its labels.
class ClassTableTimeColumnLayout {
  final double width;
  final double minimumBlockHeight;
  final TextStyle timeStyle;
  final TextStyle periodStyle;
  final TextStyle breakStyle;

  const ClassTableTimeColumnLayout._({
    required this.width,
    required this.minimumBlockHeight,
    required this.timeStyle,
    required this.periodStyle,
    required this.breakStyle,
  });

  factory ClassTableTimeColumnLayout.of(BuildContext context) {
    final defaults = DefaultTextStyle.of(context);
    final baseStyle = defaults.style.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: MediaQuery.boldTextOf(context)
          ? FontWeight.bold
          : defaults.style.fontWeight,
    );
    final timeStyle = baseStyle.copyWith(fontSize: 8);
    final periodStyle = baseStyle.copyWith(fontSize: 14);
    final breakStyle = baseStyle.copyWith(fontSize: 12);
    final textScaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final locale = Localizations.localeOf(context);

    Size measure(String text, TextStyle style, {double? maxWidth}) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textScaler: textScaler,
        textDirection: direction,
        locale: locale,
        textHeightBehavior: defaults.textHeightBehavior,
      )..layout(maxWidth: maxWidth ?? double.infinity);
      final size = painter.size;
      painter.dispose();
      return size;
    }

    double labelWidth = 0;
    double timeHeight = 0;
    double periodHeight = 0;
    for (final time in timeList) {
      final size = measure(time, timeStyle);
      labelWidth = math.max(labelWidth, size.width);
      timeHeight = math.max(timeHeight, size.height);
    }
    for (var period = 1; period <= timeList.length ~/ 2; period++) {
      final size = measure('$period', periodStyle);
      labelWidth = math.max(labelWidth, size.width);
      periodHeight = math.max(periodHeight, size.height);
    }

    final width = math.max(leftRow, labelWidth.ceilToDouble() + 4);
    // A class occupies five blocks; leave room between its three labels.
    var minimumBlockHeight = math.max(
      minBlockUnitHeight,
      (timeHeight * 2 + periodHeight + 4) / 5,
    );
    // Break labels may wrap in some languages and occupy three blocks.
    for (final key in ['classtable.noon_break', 'classtable.supper_break']) {
      final size = measure(
        FlutterI18n.translate(context, key),
        breakStyle,
        maxWidth: width,
      );
      minimumBlockHeight = math.max(minimumBlockHeight, (size.height + 4) / 3);
    }

    return ClassTableTimeColumnLayout._(
      width: width,
      minimumBlockHeight: minimumBlockHeight,
      timeStyle: timeStyle,
      periodStyle: periodStyle,
      breakStyle: breakStyle,
    );
  }
}
