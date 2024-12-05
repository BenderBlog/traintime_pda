// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

enum Type {
  reading,
  defaultimg,
}

class EmptyListView extends StatelessWidget {
  final String text;
  final String assets;

  static String _getAssets(Type type) {
    switch (type) {
      case Type.reading:
        return "assets/art/pda_girl_reading.png";
      default:
        return "assets/art/pda_girl_default.png";
    }
  }

  EmptyListView({
    super.key,
    required this.text,
    required Type type,
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
