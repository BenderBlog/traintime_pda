// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ReXCard extends StatelessWidget {
  static const _rem = 12.0;
  static const _cardPadding = 8.0;

  final String title;
  final List<ReXCardRemaining> remaining;
  final Widget bottomRow;
  final double opacity;

  const ReXCard({
    super.key,
    required this.title,
    required this.remaining,
    required this.bottomRow,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ).flexible(),
              if (remaining.isNotEmpty)
                Row(
                  children: [
                    Text(
                      remaining.first.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: remaining.first.color,
                      ),
                    ),
                    for (int i = 1; i < remaining.length; ++i) ...[
                      const VerticalDivider(width: 8),
                      Text(
                        remaining[i].text,
                        style: TextStyle(
                          color: remaining[i].color,
                        ),
                      ),
                    ]
                  ],
                ),
            ],
          ).backgroundColor(
            Theme.of(context).colorScheme.primary.withOpacity(opacity),
          ),
        )
            .padding(
              horizontal: _rem,
              top: _rem,
              bottom: 0.5 * _rem,
            )
            .backgroundColor(
              Theme.of(context).colorScheme.primary.withOpacity(opacity),
            ),
        bottomRow.padding(
          horizontal: _rem,
          top: 0.75 * _rem,
          bottom: _rem,
        ),
      ],
    )
        .backgroundColor(
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(opacity),
        )
        .clipRRect(all: _rem)
        .padding(all: _cardPadding);
  }
}

class ReXCardRemaining {
  final String text;
  final Color? color;
  ReXCardRemaining(this.text, {this.color});
}
