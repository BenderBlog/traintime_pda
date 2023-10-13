// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

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
                Text(toUse.locationName ?? "没有位置信息"),
                TagsBoxes(text: toUse.processType),
              ],
            ),
            Text("书籍编号：${toUse.barCode}"),
            Text("书籍状态：${toUse.circAttr}"),
          ],
        ),
      ),
    );
  }
}
