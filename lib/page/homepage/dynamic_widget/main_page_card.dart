// Copyright 2023 BenderBlog Rodriguez and contributors.
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
  final bool? isBold;
  const MainPageCard({
    super.key,
    required this.icon,
    required this.text,
    required this.infoText,
    required this.bottomText,
    required this.isLoad,
    this.progress,
    this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    final colorPrimary = isBold == true
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;

    final colorOnPrimary = isBold == true
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;

    final colorLineProgressBG = isBold == true
        ? Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context)
                .colorScheme
                .background
                .withOpacity(0.9) // 深色模式进度条特判
            : Theme.of(context).colorScheme.background.withOpacity(0.1)
        : Theme.of(context).colorScheme.primary.withOpacity(0.1);

    final colorLineProgress = isBold == true
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return ListTile(
      leading: Icon(
        icon,
        size: 32,
        color: colorOnPrimary,
      ),
      title: infoText,
      subtitle: Builder(
        builder: (context) {
          if (isLoad ||
              (progress != null && progress! >= 0 && progress! <= 1)) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isLoad ? null : progress,
                backgroundColor: colorLineProgressBG,
                color: colorLineProgress,
                minHeight: 4,
              ),
            );
          } else {
            return DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 12,
                color: colorOnPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: bottomText),
                  if (!isLoad &&
                      (progress != null && progress! >= 0 && progress! <= 1))
                    Text("${(progress! * 100).toInt()}%"),
                ],
              ),
            );
          }
        },
      ),
    ).withHomeCardStyle(colorPrimary);
  }
}
