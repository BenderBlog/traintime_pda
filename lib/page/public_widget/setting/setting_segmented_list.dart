// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

/// Groups setting rows into adjacent Material surfaces with segmented corners.
///
/// Children remain responsible for their own interactions. This widget only
/// provides the surface, clipping, spacing, and corner shape for each row.
class SettingSegmentedList extends StatelessWidget {
  const SettingSegmentedList({
    super.key,
    required this.items,
    this.gap = 2,
    this.outerRadius = 24,
    this.innerRadius = 4,
    this.color,
  });

  final List<Widget> items;
  final double gap;
  final double outerRadius;
  final double innerRadius;
  final Color? color;

  BorderRadius _borderRadiusForIndex(int index) {
    if (items.length == 1) {
      return BorderRadius.circular(outerRadius);
    }
    if (index == 0) {
      return BorderRadius.vertical(
        top: Radius.circular(outerRadius),
        bottom: Radius.circular(innerRadius),
      );
    }
    if (index == items.length - 1) {
      return BorderRadius.vertical(
        top: Radius.circular(innerRadius),
        bottom: Radius.circular(outerRadius),
      );
    }
    return BorderRadius.circular(innerRadius);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final surfaceColor =
        color ?? Theme.of(context).colorScheme.surfaceContainer;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) SizedBox(height: gap),
            Material(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: _borderRadiusForIndex(index),
              ),
              clipBehavior: Clip.antiAlias,
              child: items[index],
            ),
          ],
        ],
      ),
    );
  }
}
