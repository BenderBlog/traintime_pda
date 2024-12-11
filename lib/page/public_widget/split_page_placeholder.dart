// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:vector_graphics/vector_graphics.dart';

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
          return SvgPicture(
            const AssetBytesLoader("assets/art/CP1919.svg.vec"),
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ).constrained(maxWidth: 300, maxHeight: 500);
        }
      }).center(),
    );
  }
}
