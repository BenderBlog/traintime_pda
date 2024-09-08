// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// A new page to show the class without time arrangement.

class NotArrangedClassList extends StatelessWidget {
  const NotArrangedClassList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotArrangementClassDetail> notArranged =
        ClassTableState.of(context)!.controllers.notArranged;

    return Scaffold(
      appBar: AppBar(
        title: const Text("没有时间安排的科目"),
      ),
      body: ListView.builder(
        itemCount: notArranged.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(notArranged[index].name),
          subtitle: Text(
            "编号: ${notArranged[index].code} | "
            "${notArranged[index].number} 班\n"
            "老师: ${notArranged[index].teacher ?? "没有数据"}",
          ),
        ),
      ).constrained(maxWidth: 600).center(),
    );
  }
}
