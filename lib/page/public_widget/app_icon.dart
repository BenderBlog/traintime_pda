// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/widgets.dart';

class AppIconWidget extends StatelessWidget {
  final double size;

  const AppIconWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS || Platform.isMacOS)
        ? ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(29 * size / 120),
            ),
            child: Image.asset(
              "assets/Icon-App-iTunes.png",
              width: size,
              height: size,
            ),
          )
        : Image.asset(
            "assets/icon.png",
            width: size,
            height: size,
          );
  }
}
