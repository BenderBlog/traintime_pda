// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class SmallFunctionCard extends StatelessWidget {
  final IconData icon;
  final String nameKey;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const SmallFunctionCard({
    super.key,
    required this.icon,
    required this.nameKey,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return [
      Icon(
        icon,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 4),
      Text(
        FlutterI18n.translate(
          context,
          nameKey,
        ),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? null
              : Theme.of(context).colorScheme.onPrimaryFixedVariant,
        ),
      ),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
        )
        .alignment(
          Alignment.center,
        )
        .withHomeCardStyle(context)
        .gestures(
          onTap: onTap,
          onLongPress: onLongPress,
        );
  }
}
