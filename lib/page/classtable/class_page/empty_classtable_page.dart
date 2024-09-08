// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';

class EmptyClasstablePage extends StatelessWidget {
  const EmptyClasstablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyListView(
      text: "${ClassTableState.of(context)!.controllers.semesterCode} 学期没有课程\n"
          "如果刚选完课，过几天就更新了吧\n"
          "如果你没选课，快去 xk.xidian.edu.cn\n"
          "如果你你要毕业或已经毕业……\n"
          "快去关注 SuperBart 哔哩哔哩帐号！",
    );
  }
}
