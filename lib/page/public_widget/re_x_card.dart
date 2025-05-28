// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ReXCard extends StatelessWidget {
  static const _rem = 16.0;

  final Widget title;
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
      mainAxisSize: MainAxisSize.min,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 0.875 * _rem,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                title.flexible(),
                if (remaining.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        remaining.first.text,
                        style: TextStyle(
                          color: remaining.first.color,
                          fontWeight:
                              remaining.first.isBold ? FontWeight.w700 : null,
                        ),
                      ),
                      for (int i = 1; i < remaining.length; ++i) ...[
                        const VerticalDivider(width: 8),
                        Text(
                          remaining[i].text,
                          style: TextStyle(
                            color: remaining[i].color,
                            fontWeight:
                                remaining[i].isBold ? FontWeight.w700 : null,
                          ),
                        ),
                      ]
                    ],
                  ),
              ],
            ),
          ),
        )
            .padding(
              horizontal: _rem,
              top: _rem,
              bottom: 0.5 * _rem,
            )
            .backgroundColor(
              Theme.of(context).colorScheme.primary.withValues(alpha: opacity),
            ),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 0.875 * _rem),
          child: bottomRow,
        ).padding(
          horizontal: _rem,
          top: 0.75 * _rem,
          bottom: _rem,
        ),
      ],
    ).card(elevation: 0);
  }
}

class ReXCardRemaining {
  final String text;
  final Color? color;
  final bool isBold;
  ReXCardRemaining(
    this.text, {
    this.color,
    this.isBold = false,
  });
}
