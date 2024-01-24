// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class EmptyClasstablePage extends StatelessWidget {
  const EmptyClasstablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error,
          size: 100,
        ).padding(bottom: 30),
        Text(
          "${ClassTableState.of(context)!.controllers.semesterCode} 学期没有课程。",
        ),
        const Text("如果刚选完课，过几天就更新了吧。"),
        const Text("如果你没选课，快去 xk.xidian.edu.cn！"),
        const Text("如果你你要毕业或已经毕业，快去关注 SuperBart 哔哩哔哩帐号！"),
      ],
    ).center();
  }
}
