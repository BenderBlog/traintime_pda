// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/page/classtable/model/style_config/class_card_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/class_table_background_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/current_time_indicator_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/glass_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/style_config_preference_functions.dart';
import 'package:watermeter/page/classtable/model/style_config/week_bar_style_config.dart';

void main() {
  late Map<StyleConfigPreferenceKey, Object> values;

  setUp(() {
    values = {};
    StyleConfigPreferenceFunctions.install(
      getBool: (key) => values[key] as bool? ?? false,
      getDouble: (key) => values[key] as double? ?? 0,
      setBool: (key, value) async => values[key] = value,
      setDouble: (key, value) async => values[key] = value,
      contains: values.containsKey,
    );

    // Configs expose their current render values statically, so reset them between cases.
    CurrentTimeIndicatorConfig.enabled = true;
    CurrentTimeIndicatorConfig.showTimeLabel = true;
    CurrentTimeIndicatorConfig.showTodayColumnHighlight = true;

    ClassCardStyleConfig.completedEnabled = false;
    ClassCardStyleConfig.completedSaturationFactor = 0.25;
    ClassCardStyleConfig.completedBrightnessFactor = 0.75;
    ClassCardStyleConfig.completedTextSaturationFactor = 0.75;
    ClassCardStyleConfig.completedBorderAlpha = 0.75;
    ClassCardStyleConfig.completedInnerAlpha = 0.62;
    ClassCardStyleConfig.activeBrightnessFactor = 1;
    ClassCardStyleConfig.activeBorderAlpha = 1;
    ClassCardStyleConfig.activeInnerAlpha = 0.78;

    GlassStyleConfig.enabled = true;
    GlassStyleConfig.cardSigma = 12;
    GlassStyleConfig.timeLineSigma = 12;
    GlassStyleConfig.dateRowSigma = 12;
    GlassStyleConfig.weekBarSigma = 12;
    GlassStyleConfig.bannerSigma = 12;
    GlassStyleConfig.appBarSigma = 12;
  });

  group('CurrentTimeIndicatorConfig', () {
    test('loads all indicator switches and preserves defaults when unset', () {
      CurrentTimeIndicatorConfig.loadFromPreference();
      expect(CurrentTimeIndicatorConfig.enabled, isTrue);
      expect(CurrentTimeIndicatorConfig.showTimeLabel, isTrue);
      expect(CurrentTimeIndicatorConfig.showTodayColumnHighlight, isTrue);

      values.addAll({
        StyleConfigPreferenceKey.currentTimeIndicatorEnabled: false,
        StyleConfigPreferenceKey.currentTimeIndicatorShowTimeLabel: false,
        StyleConfigPreferenceKey.currentTimeIndicatorShowTodayColumnHighlight:
            true,
      });
      CurrentTimeIndicatorConfig.loadFromPreference();
      expect(CurrentTimeIndicatorConfig.enabled, isFalse);
      expect(CurrentTimeIndicatorConfig.showTimeLabel, isFalse);
      expect(CurrentTimeIndicatorConfig.showTodayColumnHighlight, isTrue);
    });

    test('each switch setter persists its value', () async {
      await CurrentTimeIndicatorConfig.setEnabled(false);
      await CurrentTimeIndicatorConfig.setShowTimeLabel(false);
      await CurrentTimeIndicatorConfig.setShowTodayColumnHighlight(false);

      expect(values, {
        StyleConfigPreferenceKey.currentTimeIndicatorEnabled: false,
        StyleConfigPreferenceKey.currentTimeIndicatorShowTimeLabel: false,
        StyleConfigPreferenceKey.currentTimeIndicatorShowTodayColumnHighlight:
            false,
      });
    });
  });

  group('ClassCardStyleConfig', () {
    test('round trips active and completed card settings', () async {
      ClassCardStyleConfig.completedEnabled = true;
      ClassCardStyleConfig.activeBrightnessFactor = 0.81;
      ClassCardStyleConfig.activeBorderAlpha = 0.71;
      ClassCardStyleConfig.activeInnerAlpha = 0.61;
      ClassCardStyleConfig.completedSaturationFactor = 0.51;
      ClassCardStyleConfig.completedBrightnessFactor = 0.91;
      ClassCardStyleConfig.completedTextSaturationFactor = 0.41;
      ClassCardStyleConfig.completedBorderAlpha = 0.31;
      ClassCardStyleConfig.completedInnerAlpha = 0.21;
      await ClassCardStyleConfig.saveToPreference();

      ClassCardStyleConfig.completedEnabled = false;
      ClassCardStyleConfig.activeBrightnessFactor = 1;
      ClassCardStyleConfig.activeBorderAlpha = 1;
      ClassCardStyleConfig.activeInnerAlpha = 1;
      ClassCardStyleConfig.completedSaturationFactor = 1;
      ClassCardStyleConfig.completedBrightnessFactor = 1;
      ClassCardStyleConfig.completedTextSaturationFactor = 1;
      ClassCardStyleConfig.completedBorderAlpha = 1;
      ClassCardStyleConfig.completedInnerAlpha = 1;
      ClassCardStyleConfig.loadFromPreference();

      expect(ClassCardStyleConfig.completedEnabled, isTrue);
      expect(ClassCardStyleConfig.activeBrightnessFactor, 0.81);
      expect(ClassCardStyleConfig.activeBorderAlpha, 0.71);
      expect(ClassCardStyleConfig.activeInnerAlpha, 0.61);
      expect(ClassCardStyleConfig.completedSaturationFactor, 0.51);
      expect(ClassCardStyleConfig.completedBrightnessFactor, 0.91);
      expect(ClassCardStyleConfig.completedTextSaturationFactor, 0.41);
      expect(ClassCardStyleConfig.completedBorderAlpha, 0.31);
      expect(ClassCardStyleConfig.completedInnerAlpha, 0.21);
      expect(values.length, 9);
    });

    test('clamps every persisted factor to its supported range', () async {
      ClassCardStyleConfig.activeBrightnessFactor = 2;
      ClassCardStyleConfig.activeBorderAlpha = -1;
      ClassCardStyleConfig.activeInnerAlpha = 2;
      ClassCardStyleConfig.completedSaturationFactor = -1;
      ClassCardStyleConfig.completedBrightnessFactor = -1;
      ClassCardStyleConfig.completedTextSaturationFactor = 2;
      ClassCardStyleConfig.completedBorderAlpha = -1;
      ClassCardStyleConfig.completedInnerAlpha = 2;
      await ClassCardStyleConfig.saveToPreference();
      ClassCardStyleConfig.loadFromPreference();

      expect(ClassCardStyleConfig.activeBrightnessFactor, 1);
      expect(ClassCardStyleConfig.activeBorderAlpha, 0.1);
      expect(ClassCardStyleConfig.activeInnerAlpha, 1);
      expect(ClassCardStyleConfig.completedSaturationFactor, 0.1);
      expect(ClassCardStyleConfig.completedBrightnessFactor, 0.5);
      expect(ClassCardStyleConfig.completedTextSaturationFactor, 1);
      expect(ClassCardStyleConfig.completedBorderAlpha, 0.1);
      expect(ClassCardStyleConfig.completedInnerAlpha, 1);
    });
  });

  group('GlassStyleConfig', () {
    test('round trips all blur settings and the master switch', () async {
      GlassStyleConfig.enabled = false;
      GlassStyleConfig.cardSigma = 3;
      GlassStyleConfig.timeLineSigma = 5;
      GlassStyleConfig.dateRowSigma = 7;
      GlassStyleConfig.weekBarSigma = 9;
      GlassStyleConfig.bannerSigma = 11;
      GlassStyleConfig.appBarSigma = 13;
      await GlassStyleConfig.saveToPreference();

      GlassStyleConfig.enabled = true;
      GlassStyleConfig.cardSigma = 0;
      GlassStyleConfig.timeLineSigma = 0;
      GlassStyleConfig.dateRowSigma = 0;
      GlassStyleConfig.weekBarSigma = 0;
      GlassStyleConfig.bannerSigma = 0;
      GlassStyleConfig.appBarSigma = 0;
      GlassStyleConfig.loadFromPreference();

      expect(GlassStyleConfig.enabled, isFalse);
      expect(GlassStyleConfig.cardSigma, 3);
      expect(GlassStyleConfig.timeLineSigma, 5);
      expect(GlassStyleConfig.dateRowSigma, 7);
      expect(GlassStyleConfig.weekBarSigma, 9);
      expect(GlassStyleConfig.bannerSigma, 11);
      expect(GlassStyleConfig.appBarSigma, 13);
      expect(values.length, 7);
    });

    test(
      'clamps blur values loaded from storage and set through the API',
      () async {
        values.addAll({
          StyleConfigPreferenceKey.classStyleGlassCardSigma: -1.0,
          StyleConfigPreferenceKey.classStyleGlassTimeLineSigma: 45.0,
        });
        GlassStyleConfig.loadFromPreference();
        expect(GlassStyleConfig.cardSigma, GlassStyleConfig.minSigma);
        expect(GlassStyleConfig.timeLineSigma, GlassStyleConfig.maxSigma);

        GlassStyleConfig.cardSigma = -5;
        GlassStyleConfig.appBarSigma = 100;
        await GlassStyleConfig.saveToPreference();
        expect(values[StyleConfigPreferenceKey.classStyleGlassCardSigma], 0);
        expect(values[StyleConfigPreferenceKey.classStyleGlassAppBarSigma], 40);
      },
    );

    test('master switch setter persists the new value', () async {
      await GlassStyleConfig.setEnabled(false);
      expect(values[StyleConfigPreferenceKey.classStyleGlassEnabled], false);
    });
  });

  group('ClassTableBackgroundStyleConfig', () {
    test('persists wallpaper switches and clamps background blur', () async {
      await ClassTableBackgroundStyleConfig.setDecorated(true);
      await ClassTableBackgroundStyleConfig.setImageAvailable(true);
      await ClassTableBackgroundStyleConfig.setBlur(100);

      expect(ClassTableBackgroundStyleConfig.decorated, isTrue);
      expect(ClassTableBackgroundStyleConfig.hasImageConfigured, isTrue);
      expect(ClassTableBackgroundStyleConfig.blur, 20);
      expect(values[StyleConfigPreferenceKey.classTableBackgroundBlur], 20);

      await ClassTableBackgroundStyleConfig.setBlur(-2);
      expect(values[StyleConfigPreferenceKey.classTableBackgroundBlur], 0);
    });

    test(
      'checks a background image and creates a stable file revision',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'classtable-style-config-',
        );
        addTearDown(() => directory.delete(recursive: true));
        const fileName = 'background.webp';

        await ClassTableBackgroundStyleConfig.setImageAvailable(true);
        await ClassTableBackgroundStyleConfig.setDecorated(false);
        expect(
          ClassTableBackgroundStyleConfig.image(
            directory: directory,
            fileName: fileName,
          ),
          isNull,
        );

        await ClassTableBackgroundStyleConfig.setDecorated(true);
        final image = File('${directory.path}/$fileName');
        await image.writeAsBytes([1, 2, 3]);
        expect(
          ClassTableBackgroundStyleConfig.hasImage(
            directory: directory,
            fileName: fileName,
          ),
          isTrue,
        );
        expect(
          ClassTableBackgroundStyleConfig.imageRevision(image),
          startsWith('3:'),
        );
      },
    );
  });

  group('WeekBarStyleConfig', () {
    test('reads and writes the collapsed state', () async {
      expect(WeekBarStyleConfig.collapsed, isFalse);
      await WeekBarStyleConfig.setCollapsed(true);
      expect(WeekBarStyleConfig.collapsed, isTrue);
      await WeekBarStyleConfig.setCollapsed(false);
      expect(WeekBarStyleConfig.collapsed, isFalse);
    });
  });
}
