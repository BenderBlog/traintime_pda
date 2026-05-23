// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/arrangement_detail/course_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_class_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_state.dart';
import 'package:watermeter/page/classtable/arrangement_detail/exam_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/experiment_detail_card.dart';
import 'package:watermeter/themes/color_seed.dart';

/// A list of the class info in that period, in case of conflict class.
class ArrangementList extends StatelessWidget {
  const ArrangementList({super.key});

  @override
  Widget build(BuildContext context) {
    final ArrangementDetailState? classDetailState = ArrangementDetailState.of(
      context,
    );
    // 空列表收缩
    if (classDetailState == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      shrinkWrap: true,
      children: List.generate(classDetailState.information.length, (i) {
        if (classDetailState.information[i] is (ClassDetail, TimeArrangement)) {
          return ClassDetailCard(
            classDetail: classDetailState.information[i].$1,
            timeArrangement: classDetailState.information[i].$2,
            infoColor:
                colorList[classDetailState.information[i].$2.index %
                    colorList.length],
            currentWeek: classDetailState.currentWeek,
          );
        } else if (classDetailState.information[i] is Subject) {
          return ExamDetailCard(
            subject: classDetailState.information[i],
            infoColor: colorList[2 % colorList.length],
          );
        } else if (classDetailState.information[i] is ExperimentData) {
          return ExperimentDetailCard(
            experiment: classDetailState.information[i],
            infoColor: colorList[2 % colorList.length],
          );
        } else if (classDetailState.information[i]
            is (CustomClass, CustomClassTimeRange, MaterialColor)) {
          return CustomClassDetailCard(
            customClass: classDetailState.information[i].$1,
            timeRange: classDetailState.information[i].$2,
            infoColor: classDetailState.information[i].$3,
          );
        } else if (classDetailState.information[i]
            is (CustomClass, CustomClassTimeRange)) {
              // 颜色降级
          return CustomClassDetailCard(
            customClass: classDetailState.information[i].$1,
            timeRange: classDetailState.information[i].$2,
            infoColor: colorList[0],
          );
        }
        return const Placeholder();
      }),
    );
  }
}
