// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/rat_card.dart';

class SmallFunctionCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color backgroundColor;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const SmallFunctionCard({
    super.key,
    required this.icon,
    required this.name,
    required this.backgroundColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: RatCard(
        backgroundColor: backgroundColor,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                icon,
                color: Colors.white,
                size: 40.0,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
