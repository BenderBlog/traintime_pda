// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';

class BookPlaceCard extends StatelessWidget {
  final BookLocation toUse;
  const BookPlaceCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    final icon = toUse.processType == "在架"
        ? MingCuteIcons.mgc_book_5_line
        : MingCuteIcons.mgc_exit_line;

    return [
      [
        Icon(
          icon,
          color: toUse.processType == "在架"
              ? Colors.green.shade900
              : Colors.red.shade900,
        ),
        const SizedBox(width: 8),
        Text(
          toUse.locationName ?? "没有位置信息",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: toUse.processType == "在架"
                ? Colors.green.shade900
                : Colors.red.shade900,
          ),
        ),
      ].toRow(),
      const SizedBox(height: 8),
      Text(
        "书籍编号：${toUse.barCode}",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: toUse.processType == "在架"
              ? Colors.green.shade900
              : Colors.red.shade900,
        ),
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 12)
        .backgroundColor(toUse.processType == "在架"
            ? Colors.green.shade200
            : Colors.red.shade200)
        .clipRRect(all: 12)
        .padding(vertical: 4);
  }
}
