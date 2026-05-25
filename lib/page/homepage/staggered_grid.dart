// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';

/// 固定列数、固定行高、可变跨度的网格布局（非滚动）。
///
/// 每一列宽度相同，每一行高度相同，保证网格严格对齐。
/// 布局采用贪心行分配算法，尽可能靠上、靠左放置。
///
/// [builder] 回调会收到 [colWidth]（单列宽度），用于构建子组件。
class StaggeredGrid extends StatelessWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double rowHeight;
  final List<StaggeredGridCell> Function(double colWidth) builder;

  const StaggeredGrid({
    super.key,
    required this.crossAxisCount,
    required this.rowHeight,
    required this.builder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final colWidth =
            (totalWidth - crossAxisSpacing * (crossAxisCount - 1)) /
                crossAxisCount;

        final cells = builder(colWidth);

        final positions = _layout(
          crossAxisCount: crossAxisCount,
          spans: cells.map((c) => c.crossAxisCellCount).toList(),
        );

        final totalRows = positions.fold<int>(
          0,
          (mx, p) => mx > p.row + 1 ? mx : p.row + 1,
        );
        final stackHeight =
            totalRows * rowHeight + (totalRows - 1) * mainAxisSpacing;

        return SizedBox(
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < cells.length; i++)
                Positioned(
                  left: positions[i].col * (colWidth + crossAxisSpacing),
                  top: positions[i].row * (rowHeight + mainAxisSpacing),
                  width: positions[i].colSpan * colWidth +
                      (positions[i].colSpan - 1) * crossAxisSpacing,
                  height: rowHeight,
                  child: cells[i].child,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 网格子组件的跨度声明。
class StaggeredGridCell {
  final int crossAxisCellCount;
  final Widget child;

  const StaggeredGridCell({
    required this.crossAxisCellCount,
    required this.child,
  });
}

class _CellPosition {
  final int col;
  final int row;
  final int colSpan;

  const _CellPosition(this.col, this.row, this.colSpan);
}

/// 贪心行布局算法。
List<_CellPosition> _layout({
  required int crossAxisCount,
  required List<int> spans,
}) {
  final columns = List<int>.filled(crossAxisCount, 0);
  final result = <_CellPosition>[];

  for (int i = 0; i < spans.length; i++) {
    final colSpan = spans[i];

    int? bestCol;
    int bestRow = 1 << 30;

    for (int c = 0; c <= crossAxisCount - colSpan; c++) {
      final row = columns[c];
      bool level = true;
      for (int k = 1; k < colSpan; k++) {
        if (columns[c + k] != row) {
          level = false;
          break;
        }
      }
      if (level && row < bestRow) {
        bestRow = row;
        bestCol = c;
      }
    }

    if (bestCol == null) {
      final maxRow = columns.reduce((a, b) => a > b ? a : b);
      for (int c = 0; c < crossAxisCount; c++) {
        columns[c] = maxRow;
      }
      bestCol = 0;
      bestRow = maxRow;
    }

    for (int k = 0; k < colSpan; k++) {
      columns[bestCol + k] = bestRow + 1;
    }

    result.add(_CellPosition(bestCol, bestRow, colSpan));
  }

  return result;
}
