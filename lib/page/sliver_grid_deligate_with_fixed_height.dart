/* 
Modified version of the SliverGridDelegateWithMaxCrossAxisExtent.
Used when the height of the children in the GridView is identical.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/rendering.dart';
import 'dart:math' as math;

// All children should have the same height.
class SliverGridDelegateWithFixedHeight extends SliverGridDelegate {
  // Apart from height, all variables unchanged.
  final double height;

  //final double minCrossAxisExtent;

  final double maxCrossAxisExtent;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  SliverGridDelegateWithFixedHeight({
    required this.maxCrossAxisExtent,
    //required this.minCrossAxisExtent,
    required this.height,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // The way calculating childCrossAxisExtent is also simplified.
    final int crossAxisCount = math.max(
      1,
      constraints.crossAxisExtent ~/ (maxCrossAxisExtent + crossAxisSpacing),
    );
    final double usableCrossAxisExtent = math.max(
      1.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    // Focus to use the height.
    final double childMainAxisExtent = height;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedHeight oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.height != height ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}
