// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

enum EmptyListViewType {
  reading,
  singing,
  defaultimg,
}

class EmptyListView extends StatelessWidget {
  final String text;
  final String assets;

  static String _getAssets(EmptyListViewType type) {
    switch (type) {
      case EmptyListViewType.reading:
        return "assets/art/pda_girl_reading.png";
      case EmptyListViewType.singing:
        return "assets/art/pda_girl_singing.png";
      default:
        return "assets/art/pda_girl_default.png";
    }
  }

  EmptyListView({
    super.key,
    required this.text,
    required EmptyListViewType type,
  }) : assets = _getAssets(type);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          assets,
          scale: 1.5,
        ),
        const Divider(color: Colors.transparent),
        Text(text),
      ],
    );
  }
}
