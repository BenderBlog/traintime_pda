/*
Class Table Interface.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

import 'classtable_page.dart';

class ClassTableWindow extends StatelessWidget {
  final ClassTableData classTableData;
  final List<List<List<List<int>>>> pretendLayout;
  final int currentWeek;

  const ClassTableWindow({
    super.key,
    required this.classTableData,
    required this.pretendLayout,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClassTableState(
      //classTableData: widget.classTableData,
      pretendLayout: pretendLayout,
      currentWeek: currentWeek,
      classDetail: classTableData.classDetail,
      notArranged: classTableData.notArranged,
      timeArrangement: classTableData.timeArrangement,
      semesterLength: classTableData.semesterLength,
      startDay: Jiffy.parse(classTableData.termStartDay).dateTime,
      child: const ClassTablePage(),
    );
  }
}
