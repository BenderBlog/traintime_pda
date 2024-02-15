// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/classtable/arrangement_detail/course_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_state.dart';
import 'package:watermeter/page/classtable/arrangement_detail/exam_detail_card.dart';
import 'package:watermeter/themes/color_seed.dart';

/// A list of the class info in that period, in case of conflict class.
class ArrangementList extends StatelessWidget {
  const ArrangementList({super.key});

  @override
  Widget build(BuildContext context) {
    ArrangementDetailState classDetailState =
        ArrangementDetailState.of(context)!;
    return ListView(
      shrinkWrap: true,
      children: List.generate(classDetailState.information.length, (i) {
        if (classDetailState.information[i] is (ClassDetail, TimeArrangement)) {
          return ClassDetailCard(
            classDetail: classDetailState.information[i].$1,
            timeArrangement: classDetailState.information[i].$2,
            infoColor: colorList[
                classDetailState.information[i].$2.index % colorList.length],
            currentWeek: classDetailState.currentWeek,
          );
        } else if (classDetailState.information[i] is Subject) {
          return ExamDetailCard(
            subject: classDetailState.information[i],
            infoColor: colorList[2 % colorList.length],
          );
        }
        return Placeholder();
      }),
    );
  }
}
