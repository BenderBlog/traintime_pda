// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/model/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';

///
/// Classtable blanks below per blocks.
///  * Morning 1-4 each 5 blocks.
///  * Noon break 3 blocks
///  * Afternoon 5-8 each 5 blocks.
///  * Supper time 3 blocks.
///  * Evening time 9-11 each 5 blocks.
/// Total 61 parts, 49 as phone divider.
///

/// One week of the class table: the class cards, the day-column highlight and the current-time
/// indicator.
///
/// The date row and the time line are deliberately not here. They belong to `ClassTableSheet`, which
/// lays them out once for the whole table so that they stay still while the weeks page horizontally.
class ClassTableView extends StatefulWidget {
  /// The week this page shows.
  final int index;

  /// The width of the time column, which the seven day columns share what is left of.
  final double timeColumnWidth;

  /// The height of one of the 61 blocks of a day, measured by the sheet so that the grid, the time
  /// line and the settings preview all size a block the same way.
  final double blockUnit;

  /// The width the whole grid has to share between the time column and the seven days.
  final double maxWidth;

  const ClassTableView({
    super.key,
    required this.index,
    required this.timeColumnWidth,
    required this.blockUnit,
    required this.maxWidth,
  });

  @override
  State<ClassTableView> createState() => _ClassTableViewState();
}

class _ClassTableViewState extends State<ClassTableView>
    with AutomaticKeepAliveClientMixin {
  late ClasstableWidgetState classTableState;
  bool _isBound = false;

  @override
  bool get wantKeepAlive => true;

  DateTime get _visibleWeekStart => classTableState.startDay
      .add(Duration(days: 7 * classTableState.offset))
      .add(Duration(days: 7 * widget.index));

  double _completedHeight(ClassOrgainzedData data, int dayIndex) {
    final now = classTableState.currentTime;
    final dayStart = _visibleWeekStart.add(Duration(days: dayIndex - 1));
    final today = DateTime(now.year, now.month, now.day);

    if (today.isBefore(dayStart)) {
      return 0;
    }
    if (today.isAfter(dayStart)) {
      return blockheight(data.stop - data.start);
    }

    final currentIndex = CurrentTimeIndicator.transferTimeToBlockIndex(now);
    if (currentIndex <= data.start) {
      return 0;
    }

    final completedBlocks = (currentIndex - data.start).clamp(
      0.0,
      data.stop - data.start,
    );
    final visibleProgress =
        blockheight(completedBlocks) - classCardContentInset;
    return visibleProgress > 0 ? visibleProgress : 0;
  }

  Positioned? _currentDayColumnBox() => CurrentTimeIndicator.buildDayColumnBox(
    context: context,
    now: classTableState.currentTime,
    weekStart: _visibleWeekStart,
    leftRow: widget.timeColumnWidth,
    blockWidth: blockwidth,
    height: blockheight(61),
  );

  /// The height of the class card.
  double blockheight(double count) => count * widget.blockUnit;

  double get blockwidth => (widget.maxWidth - widget.timeColumnWidth) / 7;

  /// The class cards of this week, plus the highlight and the current-time indicator over them.
  List<Widget> _classLayer() {
    final List<Widget> thisRow = [];

    final currentDayColumnBox = _currentDayColumnBox();
    if (currentDayColumnBox != null) {
      thisRow.add(currentDayColumnBox);
    }

    for (var index = 1; index <= 7; ++index) {
      final List<ClassOrgainzedData> arrangedEvents = classTableState
          .getArrangement(weekIndex: widget.index, dayIndex: index);

      /// Choice the day and render it!
      for (var i in arrangedEvents) {
        /// Generate the row.
        final double cardHeight = blockheight(i.stop - i.start);

        /// Cards and time labels share the top of the grid as the first period's start.
        final double cardTop = blockheight(i.start);
        final double cardLeft =
            widget.timeColumnWidth + blockwidth * (index - 1);
        final completedHeight = _completedHeight(i, index);
        thisRow.add(
          Positioned(
            top: cardTop,
            height: cardHeight,
            left: cardLeft,
            width: blockwidth,
            child: ClassCard(
              detail: i,
              completedHeight: completedHeight,

              /// Known here already, so the card does not have to measure itself.
              height: cardHeight - 2 * classCardContentInset,
              width: blockwidth,
            ),
          ),
        );
      }
    }

    if (thisRow.isEmpty && !classTableState.decorated) {
      thisRow.add(
        Center(
          child: Column(
            children: [
              SizedBox(height: blockheight(8)),
              Image.asset("assets/art/pda_classtable_empty.webp", scale: 2),
              const SizedBox(height: 20),
              ...context.t.classtable.noClass.split("\n").map((e) => Text(e)),
            ],
          ),
        ).padding(left: widget.timeColumnWidth),
      );
    }

    return thisRow;
  }

  /// Whether this page was the current week at the last tick.
  bool _wasCurrentWeek = false;

  /// Triggered on minute time ticks: only the current week updates its time indicator and progress.
  ///
  /// The page that just stopped being the current week redraws once more as well, or it would keep
  /// last Sunday's day-column highlight after midnight.
  ///
  /// Data changes do not come through here any more: the scope this page reads in [build] rebuilds
  /// it whenever the table's snapshot changes.
  void _onTimeTick() {
    if (!mounted) return;
    final bool isCurrentWeek = widget.index == classTableState.currentWeek;
    if (isCurrentWeek || _wasCurrentWeek) {
      setState(() {});
    }
    _wasCurrentWeek = isCurrentWeek;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isBound) return;
    classTableState = ClasstableScope.read(context);
    _wasCurrentWeek = widget.index == classTableState.currentWeek;
    classTableState.now.addListener(_onTimeTick);
    _isBound = true;
  }

  @override
  void dispose() {
    classTableState.now.removeListener(_onTimeTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// The whole date row, time line and viewport belong to `ClassTableSheet` in this branch's
    /// rendering path; this page is only the seven columns of one week. Upstream still carries the
    /// older all-in-one build here, and its one change to it (forcing [ClampingScrollPhysics] on
    /// the settings preview's viewport) is honoured in `ClassTableSheet.verticalPhysics` instead.
    super.build(context);
    classTableState = ClasstableScope.of(context);
    return Stack(children: _classLayer());
  }
}
