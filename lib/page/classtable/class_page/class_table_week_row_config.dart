// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// Whether the week choice row at the top of the classtable is shown.
///
/// The value is kept in a notifier, not read from the preference every time it
/// is needed, because the row can be switched from both the classtable itself
/// and the settings. While the classtable is open behind the settings page, it
/// has to follow a change made there.
class ClassTableWeekRowConfig {
  ClassTableWeekRowConfig._();

  /// A table which has never been touched keeps its row, so the setting has to
  /// default to `true` instead of the `false` a preference defaults to.
  static final ValueNotifier<bool> visible = ValueNotifier(
    preference.contains(preference.Preference.classTableWeekRowVisible)
        ? preference.getBool(preference.Preference.classTableWeekRowVisible)
        : true,
  );

  static Future<void> setVisible(bool value) async {
    visible.value = value;
    await preference.setBool(
      preference.Preference.classTableWeekRowVisible,
      value,
    );
  }
}
