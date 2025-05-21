// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(BuildContext context) {
    return Card(
      elevation: 0,
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
