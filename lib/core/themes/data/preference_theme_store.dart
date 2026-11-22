// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';

import 'package:watermeter/core/logging/logger_interface.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/themes/theme_store_interface.dart';

final class PreferenceThemeStore implements ThemeStoreInterface {
  PreferenceThemeStore(this._preferences, this._logger)
    : _settings = signal(_read(_preferences));

  final PreferenceStoreInterface _preferences;
  final LoggerInterface _logger;
  final Signal<ThemeSettings> _settings;
  Future<void> _pending = Future.value();

  static ThemeSettings _read(PreferenceStoreInterface preferences) {
    final color = preferences.getInt('palette') ?? 0;
    final brightness = preferences.getInt('brightness') ?? 0;
    final scale = preferences.getDouble('fontScale') ?? 1.0;
    final weight = preferences.getDouble('fontWeight') ?? 0.5;
    return ThemeSettings(
      palette: color >= 0 && color < ThemePalette.values.length
          ? ThemePalette.values[color]
          : ThemePalette.indigo,
      brightness: brightness >= 0 && brightness < ThemeBrightness.values.length
          ? ThemeBrightness.values[brightness]
          : ThemeBrightness.system,
      fontScale: scale.isFinite ? scale.clamp(0.8, 1.4) : 1.0,
      fontWeight: weight.isFinite ? weight.clamp(0.0, 1.0) : 0.5,
    );
  }

  @override
  ReadonlySignal<ThemeSettings> get settings => _settings.readonly();

  Future<void> _save(
    Future<void> Function() persist,
    ThemeSettings Function(ThemeSettings) apply,
  ) {
    final operation = _pending.then((_) async {
      try {
        await persist();
        _settings.value = apply(_settings.value);
      } catch (error, stackTrace) {
        _logger.error('Failed to save theme settings', error, stackTrace);
        rethrow;
      }
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  @override
  Future<void> setPalette(ThemePalette palette) => _save(
    () => _preferences.setInt('palette', palette.index),
    (settings) => settings.copyWith(palette: palette),
  );

  @override
  Future<void> setBrightness(ThemeBrightness brightness) => _save(
    () => _preferences.setInt('brightness', brightness.index),
    (settings) => settings.copyWith(brightness: brightness),
  );

  @override
  Future<void> setFontScale(double scale) {
    _settings.value.copyWith(fontScale: scale);
    return _save(
      () => _preferences.setDouble('fontScale', scale),
      (settings) => settings.copyWith(fontScale: scale),
    );
  }

  @override
  Future<void> setFontWeight(double weight) {
    _settings.value.copyWith(fontWeight: weight);
    return _save(
      () => _preferences.setDouble('fontWeight', weight),
      (settings) => settings.copyWith(fontWeight: weight),
    );
  }

  @override
  void dispose() => _settings.dispose();
}
