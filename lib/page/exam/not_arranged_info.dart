// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class NoArrangedInfo extends StatelessWidget {
  final List<ToBeArranged> list;
  const NoArrangedInfo({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "exam.no_arrangement.title",
          ),
        ),
      ),
      body: Builder(builder: (context) {
        if (list.isEmpty) {
          return EmptyListView(
            type: Type.reading,
            text: FlutterI18n.translate(
              context,
              "exam.no_arrangement.all_arranged",
            ),
          );
        }
        return DataList<ToBeArranged>(
          list: list,
          initFormula: (toUse) => Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: ListTile(
              title: Text(
                toUse.subject,
                textScaler: const TextScaler.linear(1.1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  "exam.no_arrangement.subtitle",
                  translationParams: {"id": toUse.id},
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
