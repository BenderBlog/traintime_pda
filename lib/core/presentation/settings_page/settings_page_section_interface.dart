// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

abstract interface class SettingsPageSectionInterface {
  /// The title for section, nullable.
  String? title();

  /// The icon for section, nullable.
  IconData? icon();

  /// The entries of the section
  List<SettingsPageSectionEntry> items(BuildContext context);
}

typedef SettingsPageSectionEntry = ListTile;
