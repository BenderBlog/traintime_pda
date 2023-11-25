// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// This is the shared data in the [ClassDetail].
class ClassDetailState extends InheritedWidget {
  final int currentWeek;
  final List<(ClassDetail, TimeArrangement)> information;

  const ClassDetailState({
    super.key,
    required this.currentWeek,
    required this.information,
    required super.child,
  });

  static ClassDetailState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassDetailState>();
  }

  @override
  bool updateShouldNotify(covariant ClassDetailState oldWidget) {
    return false;
  }
}
