// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/widgets.dart';

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS || Platform.isMacOS)
        ? ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(29),
            ),
            child: Image.asset(
              "assets/Icon-App-iTunes.png",
              width: 120,
              height: 120,
            ),
          )
        : Image.asset(
            "assets/icon.png",
            width: 120,
            height: 120,
          );
  }
}
