// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/generated/translations.g.dart';

class NoArrangedInfo extends StatelessWidget {
  final List<ToBeArranged> list;
  const NoArrangedInfo({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t.exam.noArrangement.title,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (list.isEmpty) {
            return EmptyListView(
              type: EmptyListViewType.defaultimg,
              text: context.t.exam.noArrangement.allArranged,
            );
          }
          return DataList<ToBeArranged>(
            list: list,
            initFormula: (toUse) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: ListTile(
                title: Text(
                  toUse.subject,
                  textScaler: const TextScaler.linear(1.1),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                subtitle: Text(
                  context.t.exam.noArrangement.subtitle(id: toUse.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
