// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class SmallFunctionCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const SmallFunctionCard({
    super.key,
    required this.icon,
    required this.name,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return [
      Icon(
        icon,
        size: 32,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      const SizedBox(height: 4),
      Text(
        name,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
        )
        .alignment(
          Alignment.center,
        )
        .withHomeCardStyle(
          Theme.of(context).colorScheme.secondary,
        )
        .gestures(
          onTap: onTap,
          onLongPress: onLongPress,
        );
  }
}
