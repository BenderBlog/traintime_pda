// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/classtable_page.dart';

/// Intro of the classtable.
class ClassTableWindow extends StatelessWidget {
  final ClassTableData classTableData;
  final List<List<List<List<int>>>> pretendLayout;
  final int currentWeek;
  final int? offset;

  /// Requires:
  ///   * [classTableData]: the class table data, but not the startday.
  ///   * [offset]: the offset of the start day of the semester set by the user, 0 by default.
  ///   * [pretendLayout]: a multiplex array which means List[week][day][classindex][classes]
  ///     * week: The week index of the week.
  ///     * day: days in the week
  ///     * classindex: indicate the range of the time when we attending class, normally 0-9
  ///     * classes: the classes in this time, maybe conflicts occurs.
  ///   * [currentWeek]: decide the week to show.
  const ClassTableWindow({
    super.key,
    required this.classTableData,
    required this.offset,
    required this.pretendLayout,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClassTableState(
      pretendLayout: pretendLayout,
      currentWeek: currentWeek,
      classDetail: classTableData.classDetail,
      notArranged: classTableData.notArranged,
      timeArrangement: classTableData.timeArrangement,
      semesterLength: classTableData.semesterLength,
      startDay: Jiffy.parse(classTableData.termStartDay).dateTime,
      context: context,
      offset: offset,
      child: const ClassTablePage(),
    );
  }
}
