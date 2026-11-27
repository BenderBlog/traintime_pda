// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'style_config_preference_functions.dart';

/// Background wallpaper settings and image metadata for the timetable.
class ClassTableBackgroundStyleConfig {
  /// Published after a replacement background has been saved so the settings preview and the
  /// live timetable can both rebuild their image widgets.
  static final ValueNotifier<int> imageChangeRevision = ValueNotifier<int>(0);

  static void notifyImageChanged() {
    imageChangeRevision.value++;
  }

  static bool get decorated => StyleConfigPreferenceFunctions.getBool(
    StyleConfigPreferenceKey.decorated,
  );

  static double get blur => StyleConfigPreferenceFunctions.getDouble(
    StyleConfigPreferenceKey.classTableBackgroundBlur,
  ).clamp(0.0, maxClassTableBackgroundBlur).toDouble();

  static File? image({required Directory directory, required String fileName}) {
    if (!decorated) return null;
    final file = File('${directory.path}/$fileName');
    return file.existsSync() ? file : null;
  }

  static String? imageRevision(File? file) {
    if (file == null) return null;
    return '${file.lengthSync()}:${file.lastModifiedSync().microsecondsSinceEpoch}';
  }

  static Future<void> setDecorated(bool value) =>
      StyleConfigPreferenceFunctions.setBool(
        StyleConfigPreferenceKey.decorated,
        value,
      );

  static Future<void> setImageAvailable(bool value) =>
      StyleConfigPreferenceFunctions.setBool(
        StyleConfigPreferenceKey.decoration,
        value,
      );

  static Future<void> setBlur(double value) =>
      StyleConfigPreferenceFunctions.setDouble(
        StyleConfigPreferenceKey.classTableBackgroundBlur,
        value.clamp(0.0, maxClassTableBackgroundBlur).toDouble(),
      );

  static bool get hasImageConfigured => StyleConfigPreferenceFunctions.getBool(
    StyleConfigPreferenceKey.decoration,
  );

  static bool hasImage({
    required Directory directory,
    required String fileName,
  }) {
    if (!hasImageConfigured) return false;
    return File('${directory.path}/$fileName').existsSync();
  }
}
