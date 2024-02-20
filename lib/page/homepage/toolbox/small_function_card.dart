// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/toolbox_addresses.dart';

class SmallFunctionCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const SmallFunctionCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    this.onTap,
    this.onLongPress,
  });

  SmallFunctionCard.fromSchoolAddress({
    super.key,
    required WebViewAddresses data,
    this.onTap,
    this.onLongPress,
  })  : icon = data.iconData,
        name = data.name,
        description = data.description;

  @override
  Widget build(BuildContext context) {
    return [
      Icon(
        icon,
        size: 48,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      const VerticalDivider(
        width: 16,
        color: Colors.transparent,
      ),
      [
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSecondaryContainer
                .withOpacity(0.6),
          ),
        ),
      ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
      )
    ]
        .toRow(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )
        .padding(all: 8)
        .card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Theme.of(context).colorScheme.secondary,
        )
        .center()
        .gestures(
          onTap: onTap,
          onLongPress: onLongPress,
        );
  }
}
