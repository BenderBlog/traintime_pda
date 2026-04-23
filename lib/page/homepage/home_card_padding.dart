// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

enum HomeCardType { plain, filled }

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(
    BuildContext context, {
    HomeCardType type = HomeCardType.plain,
    void Function()? onPressed,
  }) {
    return OutlinedButton(
      //elevation: 0,
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(14)),
        ),
        iconColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primary,
        ),
        iconSize: WidgetStateProperty.all(20),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final colorScheme = Theme.of(context).colorScheme;
          if (type == HomeCardType.filled) {
            return colorScheme.surfaceContainerHigh;
          }
          return colorScheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final colorScheme = Theme.of(context).colorScheme;
          if (type == HomeCardType.filled) {
            return colorScheme.onSurfaceVariant;
          }
          return colorScheme.onSurfaceVariant;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final colorScheme = Theme.of(context).colorScheme;
          if (type == HomeCardType.filled) {
            return BorderSide.none;
          }
          final hoverColor = colorScheme.primary.withValues(alpha: 0.6);
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return BorderSide(color: hoverColor);
          }
          return BorderSide(color: colorScheme.surfaceContainerHighest);
        }),
      ),
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: this,
      ),
    );
  }
}
