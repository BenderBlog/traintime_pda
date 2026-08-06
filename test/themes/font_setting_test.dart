// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/themes/font_setting.dart';

void main() {
  group('fontWeightFromSlider', () {
    test('maps slider levels to w300..w700', () {
      expect(fontWeightFromSlider(0.0), FontWeight.w300);
      expect(fontWeightFromSlider(0.25), FontWeight.w400);
      expect(fontWeightFromSlider(0.5), FontWeight.w500);
      expect(fontWeightFromSlider(0.75), FontWeight.w600);
      expect(fontWeightFromSlider(1.0), FontWeight.w700);
    });

    test('clamps out of range values', () {
      expect(fontWeightFromSlider(-1.0), FontWeight.w300);
      expect(fontWeightFromSlider(2.0), FontWeight.w700);
    });
  });

  group('fontWeightLabelIndex', () {
    test('maps slider levels to label indexes', () {
      expect(fontWeightLabelIndex(0.0), 0);
      expect(fontWeightLabelIndex(0.25), 1);
      expect(fontWeightLabelIndex(0.5), 2);
      expect(fontWeightLabelIndex(0.75), 3);
      expect(fontWeightLabelIndex(1.0), 4);
    });

    test('clamps out of range values', () {
      expect(fontWeightLabelIndex(-0.5), 0);
      expect(fontWeightLabelIndex(1.5), 4);
    });
  });

  group('applyFontWeightToTheme', () {
    test('applies weight to every text style', () {
      final theme = ThemeData.light();
      final weighted = applyFontWeightToTheme(theme.textTheme, FontWeight.w600);

      expect(weighted.displayLarge?.fontWeight, FontWeight.w600);
      expect(weighted.titleMedium?.fontWeight, FontWeight.w600);
      expect(weighted.bodySmall?.fontWeight, FontWeight.w600);
      expect(weighted.labelLarge?.fontWeight, FontWeight.w600);
      expect(weighted.labelSmall?.fontWeight, FontWeight.w600);
    });

    test('keeps other style properties unchanged', () {
      final theme = ThemeData.light();
      final weighted = applyFontWeightToTheme(theme.textTheme, FontWeight.w300);

      expect(
        weighted.bodyMedium?.fontSize,
        theme.textTheme.bodyMedium?.fontSize,
      );
      expect(
        weighted.titleLarge?.fontWeight,
        FontWeight.w300,
      );
    });
  });

  group('fontWeightThemeData extension', () {
    test('returns a theme copy with weighted text theme', () {
      final theme = ThemeData.light();
      final weighted = theme.applyFontWeight(FontWeight.w700);

      expect(weighted, isNot(same(theme)));
      expect(weighted.textTheme.bodyLarge?.fontWeight, FontWeight.w700);
      expect(theme.textTheme.bodyLarge?.fontWeight, isNot(FontWeight.w700));
    });
  });
}
