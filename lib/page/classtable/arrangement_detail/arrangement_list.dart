// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/arrangement_detail/course_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_class_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/exam_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/experiment_detail_card.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_data.dart';

/// A list of the class info in that period, in case of conflict class.
class ArrangementDetail extends StatelessWidget {
  final ArrangementDetailData data;
  const ArrangementDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: data.arrangements.map((item) {
        if (item.type == ArrangementDetailType.course) {
          return ClassDetailCard(
            item: item,
            currentWeek: data.currentWeek,
            semesterWeekCount: data.semesterWeekCount,
          );
        } else if (item.type == ArrangementDetailType.exam) {
          return ExamDetailCard(item: item);
        } else if (item.type == ArrangementDetailType.physicsExperiment ||
            item.type == ArrangementDetailType.otherExperiment) {
          return ExperimentDetailCard(item: item);
        } else if (item.type == ArrangementDetailType.customCourse) {
          return CustomClassDetailCard(item: item);
        }
        return const Placeholder();
      }).toList(),
    );
  }
}
