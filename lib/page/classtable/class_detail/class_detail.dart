// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart' as model;
import 'package:watermeter/page/classtable/class_detail/class_detail_list.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';

/// The class info of the period. This is an entry.
class ClassDetail extends StatelessWidget {
  final int currentWeek;
  final List<model.TimeArrangement> information;
  final List<model.ClassDetail> classDetail;
  const ClassDetail({
    super.key,
    required this.currentWeek,
    required this.information,
    required this.classDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ClassDetailState(
      currentWeek: currentWeek,
      information: information,
      classDetail: classDetail,
      child: const ClassDetailList(),
    );
  }
}
