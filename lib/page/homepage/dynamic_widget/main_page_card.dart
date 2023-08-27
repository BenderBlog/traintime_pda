// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class MainPageCard extends StatelessWidget {
  final bool isLoad;
  final IconData icon;
  final String text;
  final double? progress;
  final Widget infoText;
  final Widget bottomText;
  const MainPageCard({
    super.key,
    required this.icon,
    required this.text,
    required this.infoText,
    required this.bottomText,
    required this.isLoad,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 16,
                )
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  Expanded(
                    child: Center(
                      child: infoText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isLoad || (progress != null && progress! <= 1))
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: isLoad ? null : progress,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              )
            else
              const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomText,
                  if (!isLoad && (progress != null && progress! <= 1))
                    Text("${progress! * 100} %"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
