// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The class table sheet: the static time line and date row, plus the week pages.

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_time_line.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The class table sheet.
///
/// The time line and the date row live here rather than inside a week page, so that they stay still
/// while the weeks page horizontally. The vertical scroll is owned here too, which is both what
/// keeps the time line moving with the grid and what makes the scroll position survive a week
/// change: before, every week page had its own scrollable, so the position was lost on every swipe.
class ClassTableSheet extends StatefulWidget {
  const ClassTableSheet({
    super.key,
    required this.singleIndex,
    this.pageControl,
    this.semesterLength = 1,
    this.onPageChanged,
    this.enableVerticalScrolling = true,
  });

  /// The week shown when [pageControl] is null.
  final int singleIndex;

  /// When set, the sheet pages horizontally between weeks.
  final PageController? pageControl;
  final int semesterLength;
  final ValueChanged<int>? onPageChanged;
  final bool enableVerticalScrolling;

  @override
  State<ClassTableSheet> createState() => _ClassTableSheetState();
}

class _ClassTableSheetState extends State<ClassTableSheet> {
  final ScrollController _verticalControl = ScrollController();

  /// The floating date row, measured so the sheet can reserve exactly its height at the top.
  ///
  /// Measuring beats a constant because the row grows with the system font scale, and the
  /// reservation is what keeps the grid aligned under the row at rest.
  final GlobalKey _dateRowKey = GlobalKey();
  double _dateRowHeight = 0;

  @override
  void dispose() {
    _verticalControl.dispose();
    super.dispose();
  }

  void _measureDateRow(Duration _) {
    if (!mounted) return;
    final RenderBox? box =
        _dateRowKey.currentContext?.findRenderObject() as RenderBox?;
    final double height = box?.size.height ?? 0;
    if (height <= 0) {
      // Not laid out yet. Retry, otherwise the row would never reserve its room and the grid would
      // stay hidden underneath it.
      WidgetsBinding.instance.addPostFrameCallback(_measureDateRow);
      return;
    }
    if ((height - _dateRowHeight).abs() > 0.5) {
      setState(() => _dateRowHeight = height);
    }
  }

  DateTime _firstDayOfWeek(int index) {
    final state = ClassTableState.of(context)!.controllers;
    return state.startDay
        .add(Duration(days: 7 * state.offset))
        .add(Duration(days: 7 * index));
  }

  /// The current-time label.
  ///
  /// It is built here rather than by the week page, because the time line is stacked above the
  /// classes and the label has to stay on top of the time line's panel.
  Widget? _currentTimeLabel(BuildContext context, double available) {
    final ClassTableState? state = ClassTableState.of(context);
    if (state == null) return null;

    final ClassTableWidgetState controllers = state.controllers;
    final DateTime weekStart = controllers.startDay
        .add(Duration(days: 7 * controllers.offset))
        .add(Duration(days: 7 * widget.singleIndex));

    return CurrentTimeIndicator.buildLabel(
      context: context,
      now: controllers.currentTime,
      weekStart: weekStart,
      leftRow: leftRow,
      blockWidth: (state.constraints.maxWidth - leftRow) / 7,
      blockHeight: (double count) =>
          classTableBlockHeight(context, available, count),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// The date row must be laid out once before its height is known; the sheet then reserves
    /// exactly that much room so the grid still starts right below it at rest.
    if (_dateRowHeight == 0) {
      WidgetsBinding.instance.addPostFrameCallback(_measureDateRow);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxHeight;
        final double gridHeight = classTableBlockHeight(
          context,
          available,
          61,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            /// The sheet fills the whole area, so its content slides underneath the date row
            /// instead of being cut off at a hard edge below it.
            SingleChildScrollView(
              controller: _verticalControl,
              physics: widget.enableVerticalScrolling
                  ? null
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  /// Room reserved for the floating date row.
                  SizedBox(height: _dateRowHeight),

                  SizedBox(
                    height: gridHeight,
                    child: Stack(
                      children: [
                        /// The classes, below everything else, so a card sliding in from the next
                        /// week passes behind the time line rather than over it.
                        _pages(available),

                        /// Laid out once for the whole table, so it does not page with the weeks.
                        ClassTableTimeLine(available: available),

                        /// The current-time label rides on top of the time line's panel.
                        ?_currentTimeLabel(context, available),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// The date row floats above the sheet and is never clipped, so scrolled content passes
            /// behind it rather than being truncated by it.
            ///
            /// Positioned rather than Align on purpose: a StackFit.expand Stack hands a
            /// non-positioned child a tight, finite height, and the row's own `Center` and
            /// space-between `Column` would then expand to fill the whole table. Leaving the height
            /// unbounded keeps it content-sized.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ClassTableDateRow(
                key: _dateRowKey,
                index: widget.singleIndex,
                firstDayOfWeek: _firstDayOfWeek,

                /// Handed the pages so the headers can slide with them rather than flipping over
                /// once the week has already changed.
                pageControl: widget.pageControl,
                semesterLength: widget.semesterLength,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pages(double available) {
    final PageController? control = widget.pageControl;
    if (control == null) {
      return ClassTableView(index: widget.singleIndex, available: available);
    }
    return PageView.builder(
      controller: control,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.semesterLength,
      itemBuilder: (context, index) =>
          ClassTableView(index: index, available: available),
    );
  }
}
