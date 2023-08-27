// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipOval(
                  child: Container(
                    width: 48,
                    height: 48,
                    color: Colors.white,
                    child: Icon(
                      icon,
                      size: 36,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 10,
                  color: Colors.transparent,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
