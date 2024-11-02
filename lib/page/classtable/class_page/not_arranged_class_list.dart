// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';

/// A new page to show the class without time arrangement.

class NotArrangedClassList extends StatelessWidget {
  const NotArrangedClassList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotArrangementClassDetail> notArranged =
        ClassTableState.of(context)!.controllers.notArranged;

    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(
            context,
            "classtable.not_arranged_page.title",
          )),
        ),
        body: Builder(builder: (context) {
          if (notArranged.isEmpty) {
            return EmptyListView(
              text: FlutterI18n.translate(
                context,
                "classtable.not_arranged_page.empty_message",
              ),
            );
          }
          return ListView.builder(
            itemCount: notArranged.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(notArranged[index].name),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  "classtable.not_arranged_page.content",
                  translationParams: {
                    "classCode": notArranged[index].code ?? "",
                    "classNumber": notArranged[index].number ?? "",
                    "teacher": notArranged[index].teacher ?? "没有数据",
                  },
                ),
              ),
            ),
          ).constrained(maxWidth: 600);
        }).center());
  }
}
