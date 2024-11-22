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
        color: Theme.of(context).brightness == Brightness.dark
            ? null
            : Theme.of(context).colorScheme.primary,
      ),
      title: DefaultTextStyle.merge(
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? null
              : Theme.of(context).colorScheme.primary,
        ),
        child: infoText,
      ),
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
            return DefaultTextStyle.merge(
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Theme.of(context).colorScheme.primary,
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
      trailing: rightButton,
    ).withHomeCardStyle(context);
  }
}
