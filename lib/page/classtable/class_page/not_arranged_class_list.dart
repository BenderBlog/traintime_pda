// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/generated/l10n.dart';

/// A new page to show the class without time arrangement.

class NotArrangedClassList extends StatelessWidget {
  final List<NotArrangementClassDetail> notArranged;
  const NotArrangedClassList({super.key, required this.notArranged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context)!.classtableNotArrangedPageTitle),
      ),
      body: Builder(
        builder: (context) {
          if (notArranged.isEmpty) {
            return EmptyListView(
              type: EmptyListViewType.defaultimg,
              text: I18n.of(context)!.classtableNotArrangedPageEmptyMessage,
            );
          }
          return ListView.builder(
            itemCount: notArranged.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(notArranged[index].name),
              subtitle: Text(
                I18n.of(context)!.classtableNotArrangedPageContent(
                  notArranged[index].code ?? "",
                  notArranged[index].number ?? "",
                  notArranged[index].teacher ?? I18n.of(context)!.noInfo,
                ),
              ),
            ),
          ).constrained(maxWidth: 600);
        },
      ).center(),
    );
  }
}
