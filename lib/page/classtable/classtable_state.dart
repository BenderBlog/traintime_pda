/*
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Additionaly, for this file,

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// The controllers and shared datas of the class table.
class ClassTableState extends InheritedWidget {
  /// The length of the semester, the amount of the class table.
  final int semesterLength;

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

  /// Refrence [ClassTableWidgetState.isTopRowLocked]
  bool get isTopRowLocked => controllers.isTopRowLocked;
  set isTopRowLocked(bool status) =>
      status ? controllers.lockTopRow() : controllers.unlockTopRow();

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
  }) {
    late int toShowChoiceWeek;
    if (currentWeek < 0) {
      toShowChoiceWeek = 0;
    } else if (currentWeek >= semesterLength) {
      toShowChoiceWeek = semesterLength - 1;
    } else {
      toShowChoiceWeek = currentWeek;
    }
    controllers = ClassTableWidgetState(choiceWeek: toShowChoiceWeek, totalWeek: semesterLength,);
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
  /// Week choice row controller.
  late ScrollController rowControl;

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Current showing week.
  late int chosenWeek;

  /// From the length of the semester.
  final int totalWeek;

  /// A lock of the week choice row.
  ///
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  void changeTopRow(int index) => rowControl.animateTo(
        (weekButtonWidth + 2 * weekButtonHorizontalPadding) * index,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime ~/ 1.5),
      );

  ClassTableWidgetState({
    required int choiceWeek,
    required this.totalWeek,
  }) {
    chosenWeek = choiceWeek;
    pageControl = PageController(
      initialPage: chosenWeek,
      keepPage: true,
    );

    /// (weekButtonWidth + 2 * weekButtonHorizontalPadding)
    /// is the width of the week choose button.
    rowControl = ScrollController(
      initialScrollOffset:
        totalWeek - chosenWeek < 5 ? (weekButtonWidth + 2 * weekButtonHorizontalPadding) * (totalWeek - 5)
        :
          (weekButtonWidth + 2 * weekButtonHorizontalPadding) * chosenWeek,
    );
  }

  void lockTopRow() => isTopRowLocked = true;

  /// When top row unlocked, notify the week choice row to refresh the state.
  void unlockTopRow() {
    isTopRowLocked = false;
    notifyListeners();
  }
}
