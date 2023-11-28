// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_dialog.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';
import 'package:watermeter/themes/color_seed.dart';

/// A list of the class info in that period, in case of conflict class.
class ClassDetailList extends StatelessWidget {
  const ClassDetailList({super.key});

  @override
  Widget build(BuildContext context) {
    ClassDetailState classDetailState = ClassDetailState.of(context)!;
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        classDetailState.information.length,
        (i) => ClassDetailDialog(
          classDetail: classDetailState.information[i].$1,
          timeArrangement: classDetailState.information[i].$2,
          infoColor: colorList[
              classDetailState.information[i].$2.index % colorList.length],
          currentWeek: classDetailState.currentWeek,
        ),
      ),
    );
  }
}
