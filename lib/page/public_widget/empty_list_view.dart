// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class EmptyListView extends StatelessWidget {
  final String text;
  const EmptyListView({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/Empty-Cover.jpg",
          scale: 1.5,
        ),
        const Divider(color: Colors.transparent),
        Text(text),
      ],
    );
  }
}
