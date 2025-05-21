// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/widgets.dart';

class AppIconWidget extends StatelessWidget {
  final double size;

  const AppIconWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(29 * size / 120),
      ),
      child: Image.asset(
        (Platform.isIOS || Platform.isMacOS)
            ? "assets/Icon-App-iTunes.png"
            : "assets/icon.png",
        width: size,
        height: size,
      ),
    );
  }
}
