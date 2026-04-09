// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class CacheAlerter extends StatelessWidget {
  final String hint;
  final String? dataType;

  const CacheAlerter({super.key, required this.hint, this.dataType});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      ).decoration,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dataType == null ? hint : "$dataType: $hint",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
