// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/widget.dart';

class BookPlaceCard extends StatelessWidget {
  final BookLocation toUse;
  const BookPlaceCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InfoDetailBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(toUse.bookAddress),
                TagsBoxes(
                  text: toUse.borrowStatus == 0
                      ? "在架"
                      : toUse.noBorrowingReason != null
                          ? "不在架"
                          : "已借出",
                  backgroundColor:
                      toUse.borrowStatus == 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            Text("书籍编号：${toUse.barCode}"),
            if (toUse.noBorrowingReason != null)
              Text("不在架原因：${toUse.noBorrowingReason}"),
          ],
        ),
      ),
    );
  }
}
