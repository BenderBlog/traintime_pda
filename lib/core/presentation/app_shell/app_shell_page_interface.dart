// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';

abstract interface class AppShellPageInterface {
  /// Get the label displayed at the navigation bar. Context may be used for translation.
  String label(BuildContext context);

  /// Get the icon displayed at the navigation bar.
  Widget icon(BuildContext context);

  /// Get the icon displayed at the navigation bar while the page be selected.
  Widget selectedIcon(BuildContext context);

  /// How to build this page.
  Widget buildPage(BuildContext context);
}
