// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'style_config_preference_functions.dart';

/// Persistence for whether the timetable week selector is pinned or collapsed.
class WeekBarStyleConfig {
  static bool get collapsed => StyleConfigPreferenceFunctions.getBool(
    StyleConfigPreferenceKey.classTableWeekBarCollapsed,
  );

  static Future<void> setCollapsed(bool value) =>
      StyleConfigPreferenceFunctions.setBool(
        StyleConfigPreferenceKey.classTableWeekBarCollapsed,
        value,
      );
}
