// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class SplitPagePlaceholder extends StatelessWidget {
  const SplitPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Opacity(
          opacity: 0.25,
          child: Image.asset("assets/Icon-App-iTunes-Background.png"),
        ).constrained(maxWidth: 300),
      ),
    );
  }
}
