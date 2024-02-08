// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_list.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';

/// The class info of the period. This is an entry.
class ClassDetailPopUp extends StatelessWidget {
  final int currentWeek;
  final List<(ClassDetail, TimeArrangement)> information;
  const ClassDetailPopUp({
    super.key,
    required this.currentWeek,
    required this.information,
  });

  @override
  Widget build(BuildContext context) {
    return ClassDetailState(
      currentWeek: currentWeek,
      information: information,
      child: const ClassDetailList(),
    );
  }
}
