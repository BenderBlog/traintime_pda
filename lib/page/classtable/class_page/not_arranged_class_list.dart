// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/generated/translations.g.dart';

/// A new page to show the class without time arrangement.

class NotArrangedClassList extends StatelessWidget {
  final List<NotArrangementClassDetail> notArranged;
  const NotArrangedClassList({super.key, required this.notArranged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.classtable.notArrangedPage.title),
      ),
      body: Builder(
        builder: (context) {
          if (notArranged.isEmpty) {
            return EmptyListView(
              type: EmptyListViewType.defaultimg,
              text: context.t.classtable.notArrangedPage.emptyMessage,
            );
          }
          return ListView.builder(
            itemCount: notArranged.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(notArranged[index].name),
              subtitle: Text(
                context.t.classtable.notArrangedPage.content(class_code: notArranged[index].code ?? "", class_number: notArranged[index].number ?? "", teacher: notArranged[index].teacher ?? context.t.common.noInfo),
              ),
            ),
          ).constrained(maxWidth: 600);
        },
      ).center(),
    );
  }
}
