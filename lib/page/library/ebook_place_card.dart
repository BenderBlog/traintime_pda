// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';

class EBookPlaceCard extends StatelessWidget {
  final EBookItem toUse;
  const EBookPlaceCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return [
      [
        Icon(
          Icons.cloud,
          color: Colors.lightBlue.shade900,
        ),
        const SizedBox(width: 8),
        Text(
          toUse.collectionName,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.lightBlue.shade900,
          ),
        ),
      ].toRow(),
      const SizedBox(height: 8),
      Text(
        "URL：${toUse.url}",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.lightBlue.shade900,
        ),
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 12)
        .backgroundColor(Colors.lightBlue.shade200)
        .clipRRect(all: 12)
        .padding(vertical: 4);
  }
}
