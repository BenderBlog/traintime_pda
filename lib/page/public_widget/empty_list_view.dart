// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

enum EmptyListViewType { reading, singing, rolling, defaultimg }

class EmptyListView extends StatelessWidget {
  final String text;
  final String assets;

  static String _getAssets(EmptyListViewType type) {
    switch (type) {
      case EmptyListViewType.reading:
        return "assets/art/pda_girl_reading.webp";
      case EmptyListViewType.rolling:
        return "assets/art/pda_classtable_empty.webp";
      default:
        return "assets/art/pda_girl_default.webp";
    }
  }

  EmptyListView({
    super.key,
    required this.text,
    required EmptyListViewType type,
  }) : assets = _getAssets(type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.hasBoundedHeight &&
                    constraints.maxHeight < 240) {
                  return const Center(
                    child: Icon(Icons.inbox_outlined, size: 64),
                  );
                }

                return Image.asset(assets, scale: 1.5, fit: BoxFit.contain);
              },
            ),
          ),
          const Divider(color: Colors.transparent),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
