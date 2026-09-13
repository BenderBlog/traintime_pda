// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class SectionSettingScaffold extends StatelessWidget {
  final String? title;
  final List<Widget> items;
  const SectionSettingScaffold({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final testScale = MediaQuery.textScalerOf(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: testScale.scale(24),
              bottom: testScale.scale(10),
              start: 24,
              end: 24,
            ),
            child: Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ...items,
      ],
    );
  }
}
