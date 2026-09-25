// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The date row of the class table: the month and the seven day headers.
///
/// The rounded panel is static and only its contents change, so the row never slides even though
/// the week pages underneath do. A week change flips the contents over.
class ClassTableDateRow extends StatefulWidget {
  const ClassTableDateRow({
    super.key,
    required this.index,
    required this.firstDayOfWeek,
  });

  /// The week on show.
  final int index;

  /// First day of the week at the given index.
  final DateTime Function(int index) firstDayOfWeek;

  @override
  State<ClassTableDateRow> createState() => _ClassTableDateRowState();
}

class _ClassTableDateRowState extends State<ClassTableDateRow> {
  /// Which way the last week change went, so the flip follows the paging direction.
  bool _forward = true;

  @override
  void didUpdateWidget(covariant ClassTableDateRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _forward = widget.index > oldWidget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// The floating panel, matching the time line beside it.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(timeLineInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh
                    .withValues(alpha: timeLineSurfaceAlpha),
                borderRadius: BorderRadius.circular(timeLineRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: timeLineShadowAlpha),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// The cells size the row and span the table width, so they stay aligned with the columns
        /// underneath even though the panel is inset.
        Padding(
          /// The height is determined by the content, so the text will not overflow when the font
          /// scale is enlarged.
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
            width: double.infinity,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: _flip,
                child: KeyedSubtree(
                  key: ValueKey<int>(widget.index),
                  child: _weekRow(context, widget.index),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Slides the incoming week in from the direction of travel while the outgoing one leaves the
  /// other way.
  ///
  /// [AnimatedSwitcher] runs the outgoing child's animation in reverse, so testing the key tells
  /// the two apart and each can be given its own start offset.
  Widget _flip(Widget child, Animation<double> animation) {
    final Object? key = child.key;
    final bool incoming = key is ValueKey<int> && key.value == widget.index;
    final double from = incoming
        ? (_forward ? 1.0 : -1.0)
        : (_forward ? -1.0 : 1.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(from, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// One week: the month of its first day and the seven day headers.
  Widget _weekRow(BuildContext context, int weekIndex) {
    final DateTime firstDay = widget.firstDayOfWeek(weekIndex);
    final List<DateTime> dateList = List.generate(
      7,
      (i) => firstDay.add(Duration(days: i)),
    );

    return Row(
      children: [
        Text(
          FlutterI18n.translate(
            context,
            "classtable.month",
            translationParams: {"month": firstDay.month.toString()},
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ).center().constrained(width: leftRow),
        ...List.generate(7, (index) => WeekInfomation(time: dateList[index])),
      ],
    );
  }
}

/// The week index info, shows the day and the week.
class WeekInfomation extends StatelessWidget {
  final DateTime time;
  const WeekInfomation({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    bool isToday =
        (time.month == DateTime.now().month && time.day == DateTime.now().day);
    BoxConstraints size = ClassTableState.of(context)!.constraints;
    return SizedBox(
      width: (size.maxWidth - leftRow) / 7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getWeekString(context, time.weekday - 1),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
                time.day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : null,
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              )
              .center()
              .constrained(width: 26, height: 20)
              .decorated(
                color: isToday
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.transparent,
              )
              .clipRRect(all: 8),
        ],
      ),
    );
  }
}
