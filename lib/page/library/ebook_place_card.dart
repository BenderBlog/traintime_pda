// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/widget.dart';

class EBookPlaceCard extends StatelessWidget {
  final EBookItem toUse;
  const EBookPlaceCard({
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
            const Text("电子产品信息"),
            Text("位置：${toUse.collectionName}"),
            Text("URL：${toUse.url}"),
          ],
        ),
      ),
    );
  }
}
