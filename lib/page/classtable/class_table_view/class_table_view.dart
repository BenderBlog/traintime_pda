// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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

  const ClassTableView({
    super.key,
    required this.index,
    required this.timeColumnWidth,
    required this.blockUnit,
  });

  @override
  State<ClassTableView> createState() => _ClassTableViewState();
}

class _ClassTableViewState extends State<ClassTableView>
    with AutomaticKeepAliveClientMixin {
  late ClassTableWidgetState classTableState;
  late BoxConstraints size;
  bool _isListening = false;

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
    return blockheight(completedBlocks);
  }

  Positioned? _currentDayColumnBox() => CurrentTimeIndicator.buildDayColumnBox(
    context: context,
    now: classTableState.currentTime,
    weekStart: _visibleWeekStart,
    leftRow: widget.timeColumnWidth,
    blockWidth: blockwidth,
  );

  /// The height of the class card.
  double blockheight(double count) => count * widget.blockUnit;

  double get blockwidth => (size.maxWidth - widget.timeColumnWidth) / 7;

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
              height: cardHeight - 2,
              width: blockwidth,
            ),
          ),
        );
      }
    }

    if (thisRow.isEmpty &&
        !preference.getBool(preference.Preference.decorated)) {
      thisRow.add(
        Center(
          child: Column(
            children: [
              SizedBox(height: blockheight(8)),
              Image.asset("assets/art/pda_classtable_empty.webp", scale: 2),
              const SizedBox(height: 20),
              ...FlutterI18n.translate(
                context,
                "classtable.no_class",
              ).split("\n").map((e) => Text(e)),
            ],
          ),
        ).padding(left: widget.timeColumnWidth),
      );
    }

    return thisRow;
  }

  int _lastScheduleVersion = 0;

  /// This function will be triggered when user changed class info.
  void _reload() {
    if (!mounted) return;
    if (_lastScheduleVersion != classTableState.scheduleVersion) {
      _lastScheduleVersion = classTableState.scheduleVersion;
      setState(() {});
    }
  }

  /// Triggered on minute time ticks: only the current week updates its time indicator and progress.
  void _onTimeTick() {
    if (!mounted) return;
    if (widget.index == classTableState.currentWeek) {
      setState(() {});
    }
  }

  void updateSize() => size = ClassTableState.of(context)!.constraints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListening) {
      classTableState = ClassTableState.of(context)!.controllers;
      _lastScheduleVersion = classTableState.scheduleVersion;
      classTableState.addListener(_reload);
      classTableState.timeTickNotifier.addListener(_onTimeTick);
      _isListening = true;
    }
    updateSize();
  }

  @override
  void dispose() {
    classTableState.removeListener(_reload);
    classTableState.timeTickNotifier.removeListener(_onTimeTick);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClassTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateSize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: _classLayer());
  }
}
