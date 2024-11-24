// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(BuildContext context) {
    return Card(
      //elevation: 0,
      shadowColor: Colors.transparent,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? null
              : Theme.of(context).colorScheme.primary,
        ),
        child: this,
      ),
    );
  }
}
