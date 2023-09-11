// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ClassDetailTile extends StatelessWidget {
  final bool isTomorrow;
  final String name;
  final String place;
  final String time;
  const ClassDetailTile({
    super.key,
    required this.name,
    required this.place,
    required this.time,
    required this.isTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "$place ${isTomorrow ? "明日" : ""}$time",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    )
        .padding(
          left: 16,
          right: 8,
          vertical: 6,
        )
        .border(
          left: 8.0,
          color: Theme.of(context).colorScheme.primary,
        )
        .backgroundColor(
          Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4)
              : Theme.of(context).colorScheme.onPrimary,
        )
        .clipRRect(all: 12)
        .padding(bottom: 8);
  }
}
