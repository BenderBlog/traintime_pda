// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// A new page to show the class without time arrangement.
///
/// When executing [Navigator.of(context).push()], the page is not mounted under
/// the [ClassTableState] node on the Widget Tree, so I cannot use [ClassTableState.of(context)!].

class NotArrangedClassList extends StatelessWidget {
  /// A list of [ClassDetail] which do not have the time arrangement.
  final List<NotArrangementClassDetail> notArranged;
  const NotArrangedClassList({
    super.key,
    required this.notArranged,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
