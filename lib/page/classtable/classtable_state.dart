// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// The controllers and shared datas of the class table.
class ClassTableState extends InheritedWidget {
  /// The length of the semester, the amount of the class table.
  final int semesterLength;

  /// The offset append to start day of the week.
  late final int offset;

  /// The class details.
  final List<ClassDetail> classDetail;

  /// The classes without time arrangements.
  final List<ClassDetail> notArranged;

  /// The time arrangements of the class details, use with [classDetail].
  final List<TimeArrangement> timeArrangement;

  /// Multiplex array which means List[week][day][classindex][classes]
  ///   * week: The week index of the week.
  ///   * day: days in the week
  ///   * classindex: indicate the range of the time when we attending class, normally 0-9
  ///   * classes: the classes in this time, maybe conflicts occurs.
  final List<List<List<List<int>>>> pretendLayout;

  /// The day the semester start, used to calculate the first day of the week.
  final DateTime startDay;

  /// The currentWeek.
  final int currentWeek;

  /// The changeable data of the state.
  late final ClassTableWidgetState controllers;

  ClassTableState({
    super.key,
    required super.child,
    required this.semesterLength,
    required this.startDay,
    required this.notArranged,
    required this.timeArrangement,
    required this.classDetail,
    required this.pretendLayout,
    required this.currentWeek,
    required BuildContext context,
    int? offset,
  }) {
    this.offset = offset ?? 0;
    late int toShowChoiceWeek;
    if (currentWeek < 0) {
      toShowChoiceWeek = 0;
    } else if (currentWeek >= semesterLength) {
      toShowChoiceWeek = semesterLength - 1;
    } else {
      toShowChoiceWeek = currentWeek;
    }
    controllers = ClassTableWidgetState(
      chosenWeek: toShowChoiceWeek,
    );
  }

  static ClassTableState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassTableState>();
  }

  @override
  bool updateShouldNotify(covariant ClassTableState oldWidget) {
    return controllers.chosenWeek != oldWidget.controllers.chosenWeek;
  }
}

/// The changeable data of the class table state.
class ClassTableWidgetState extends ChangeNotifier {
  /// Current showing week.
  int chosenWeek;

  ClassTableWidgetState({
    required this.chosenWeek,
  });
}
