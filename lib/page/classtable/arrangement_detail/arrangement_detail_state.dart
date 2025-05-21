// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// This is the shared data in the [ClassDetail].
class ArrangementDetailState extends InheritedWidget {
  final int currentWeek;
  final List<dynamic> information;

  const ArrangementDetailState({
    super.key,
    required this.currentWeek,
    required this.information,
    required super.child,
  });

  static ArrangementDetailState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ArrangementDetailState>();
  }

  @override
  bool updateShouldNotify(covariant ArrangementDetailState oldWidget) {
    return false;
  }
}
