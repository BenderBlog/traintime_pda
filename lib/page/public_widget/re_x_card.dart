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

  Widget _buildRemainingItem(ReXCardRemaining item) {
    final text = Text(
      item.text,
      style: TextStyle(
        color: item.color,
        fontWeight: item.isBold ? FontWeight.w700 : null,
      ),
    );

    if (item.onTap != null) {
      return InkWell(
        onTap: item.onTap,
        child: text,
      );
    }

    return text;
  }

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
                          _buildRemainingItem(remaining.first),
                          for (int i = 1; i < remaining.length; ++i) ...[
                            const VerticalDivider(width: 8),
                            _buildRemainingItem(remaining[i]),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            )
            .padding(horizontal: _rem, top: _rem, bottom: 0.5 * _rem)
            .backgroundColor(
              Theme.of(context).colorScheme.primary.withValues(alpha: opacity),
            ),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 0.875 * _rem),
          child: bottomRow,
        ).padding(horizontal: _rem, top: 0.75 * _rem, bottom: _rem),
      ],
    ).card(elevation: 0);
  }
}

class ReXCardRemaining {
  final String text;
  final Color? color;
  final bool isBold;
  final VoidCallback? onTap;
  
  ReXCardRemaining(
    this.text, {
    this.color,
    this.isBold = false,
    this.onTap,
  });
}
