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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 这里调整圆角的大小
        ),
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 160,
              height: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  // const VerticalDivider(
                  //   width: 3,
                  //   color: Colors.transparent,
                  // ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                .withOpacity(0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
