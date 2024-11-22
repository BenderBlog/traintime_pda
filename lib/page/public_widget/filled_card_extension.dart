// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

extension FilledCardPadding on Widget {
  Widget withFilledCardStyle(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.primary.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.075,
          ),
      child: this,
    );
  }
}
