// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The date row of the class table: the month and the seven day headers.
///
/// The rounded panel is static; only the headers move. The headers are painted with a fractional
/// translation from the page position, so following a swipe does not drive a second scrollable.
class ClassTableDateRow extends StatefulWidget {
  const ClassTableDateRow({
    super.key,
    required this.index,
    required this.firstDayOfWeek,
    this.pageControl,
    this.semesterLength = 1,
  });

  /// The week on show when there is no [pageControl], and the week the headers start on.
  final int index;

  /// First day of the week at the given index.
  final DateTime Function(int index) firstDayOfWeek;

  /// The week pages. When set, the headers slide with them.
  final PageController? pageControl;

  /// How many weeks the row has headers for.
  final int semesterLength;

  @override
  State<ClassTableDateRow> createState() => _ClassTableDateRowState();
}

class _ClassTableDateRowState extends State<ClassTableDateRow> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// The floating panel, matching the time line beside it.
        ///
        /// The class cards scroll underneath this row, so unlike the time line — which has nothing
        /// but the wallpaper behind it — the panel blurs what is passing behind it. The shadow is
        /// painted outside the blur so the clip cannot eat it.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(timeLineInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(timeLineRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: timeLineShadowAlpha),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GlassBlur(
                borderRadius: BorderRadius.circular(timeLineRadius),
                sigma: GlassStyleConfig.dateRowSigma,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh
                        .withValues(alpha: timeLineSurfaceAlpha),
                    borderRadius: BorderRadius.circular(timeLineRadius),
                  ),
                ),
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
          child: ClipRect(
            /// Clipped to the panel rather than to the row, so a header sliding out of the way
            /// disappears behind the panel's edge instead of hanging outside it.
            clipper: const _HeaderClip(),
            child: _headers(context),
          ),
        ),
      ],
    );
  }

  /// The headers, one week wide each, sliding with the pages when there are pages to follow.
  Widget _headers(BuildContext context) {
    if (widget.pageControl == null) {
      return _weekRow(context, widget.index);
    }

    final PageController pages = widget.pageControl!;
    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: AnimatedBuilder(
          animation: pages,

          /// The headers are the same widget every frame; the barrier keeps them out of the repaint
          /// that the sliding transform would otherwise force on all of them, every frame.
          child: RepaintBoundary(
            child: Row(
              children: List.generate(
                widget.semesterLength,
                (index) => SizedBox(
                  width: constraints.maxWidth,
                  child: ExcludeSemantics(
                    excluding: index != widget.index,
                    child: _weekRow(context, index),
                  ),
                ),
              ),
            ),
          ),
          builder: (context, child) {
            final double offset = pages.hasClients
                ? pages.position.pixels
                : widget.index * constraints.maxWidth;
            return Transform.translate(
              offset: Offset(-offset, 0),
              child: child,
            );
          },
        ),
      ),
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

/// Keeps the headers inside the panel while they slide.
///
/// The panel sits [timeLineInset] inside the row while the cells keep the table's full width so the
/// columns stay aligned with the grid, so the clip has to be pulled in by that same inset: without
/// it a month or a date sliding out of the way hangs outside the panel's edge.
class _HeaderClip extends CustomClipper<Rect> {
  const _HeaderClip();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    timeLineInset,
    0,
    size.width - timeLineInset,
    size.height,
  );

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
