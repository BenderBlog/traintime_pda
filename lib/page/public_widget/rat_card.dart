// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

// Designer: https://github.com/BrackRat

import "package:flutter/material.dart";

class RatCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  static const paddingValue = 14.0;

  static const List<Color> ratCardBackgroundColor = [
    Color(0xFF6FB1EC),
    Color(0xFF726FEC),
    Color(0xFFECB26F),
    Color(0xFFEC6FAB),
    Color(0xFFEC6F6F),
    Color(0xFFCB6FEC),
  ];

  const RatCard({
    super.key,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(paddingValue),
            color: backgroundColor,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(paddingValue),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x7affffff), Color(0x2da1a1a1)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(paddingValue),
          child: child,
        ),
      ],
    );
  }
}
