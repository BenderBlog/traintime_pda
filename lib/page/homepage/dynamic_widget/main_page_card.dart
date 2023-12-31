// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // 这里调整圆角的大小
      ),
      elevation: 0,
      color: colorPrimary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    textBaseline: TextBaseline.alphabetic,
                    color: colorOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: colorOnPrimary,
                  size: 16,
                )
              ],
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      size: 52,
                      color: colorOnPrimary,
                    ),
                    Expanded(
                      child: Center(
                        child: infoText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoad ||
                (progress != null && progress! >= 0 && progress! <= 1))
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: isLoad ? null : progress,
                      backgroundColor: colorLineProgressBG,
                      color: colorLineProgress,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              )
            else
              const SizedBox(height: 8),
            DefaultTextStyle.merge(
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
            ),
          ],
        ),
      ),
    );
  }
}
