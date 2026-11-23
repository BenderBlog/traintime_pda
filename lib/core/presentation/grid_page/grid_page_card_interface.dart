// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';

abstract interface class GridPageCardInterface {
  /// The stable mark of the card used for sorting, hiding state and persistence.
  String get id;

  /// Grid cards span this many columns; headers use it as a vertical height multiplier.
  int flex();

  /// Used in hidden card list to display to user. Context is used to generate translation.
  String title(BuildContext context);

  Widget buildCard(BuildContext context, bool editMode);
}
