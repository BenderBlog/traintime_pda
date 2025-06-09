// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class SplitPagePlaceholder extends StatelessWidget {
  const SplitPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return Opacity(
            opacity: 0.25,
            child: Image.asset(
              "assets/Icon-App-iTunes-Background.png",
            ),
          ).constrained(maxWidth: 300);
        } else {
          return Image.asset(
            "assets/art/Fxemoji_u1F4BE_Kazami_Yuka.png",
          ).constrained(maxWidth: 300, maxHeight: 300);
        }
      }).center(),
    );
  }
}
