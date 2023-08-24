/*
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Additionaly, for this file,

limitLicensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
ations under the License.
*/

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

  /// Requires:
  ///   * [classTableData]: the class table data, but not the startday.
  ///   * [pretendLayout]: a multiplex array which means List[week][day][classindex][classes]
  ///     * week: The week index of the week.
  ///     * day: days in the week
  ///     * classindex: indicate the range of the time when we attending class, normally 0-9
  ///     * classes: the classes in this time, maybe conflicts occurs.
  ///   * [currentWeek]: decide the week to show.
  const ClassTableWindow({
    super.key,
    required this.classTableData,
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
      child: const ClassTablePage(),
    );
  }
}
