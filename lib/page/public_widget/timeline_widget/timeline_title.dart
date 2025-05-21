// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class TimelineTitle extends StatelessWidget {
  final String title;

  const TimelineTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textScaler: const TextScaler.linear(1.1),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
