// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class MainPageCard extends StatelessWidget {
  final bool isLoad;
  final IconData icon;
  final String text;
  final double? progress;
  final Widget infoText;
  final Widget bottomText;
  final Widget? rightButton;
  final bool? isBold;
  const MainPageCard({
    super.key,
    required this.icon,
    required this.text,
    required this.infoText,
    required this.bottomText,
    required this.isLoad,
    this.rightButton,
    this.progress,
    this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
      textColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurfaceVariant,
      title: infoText,
      subtitle: Builder(
        builder: (context) {
          if (isLoad ||
              (progress != null && progress! >= 0 && progress! <= 1)) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isLoad ? null : progress,
                minHeight: 4,
              ),
            );
          } else {
            return bottomText;
          }
        },
      ),
      trailing: rightButton,
    ).withHomeCardStyle(context);
  }
}
