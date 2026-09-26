// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The box behind the week button on show.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// The highlight behind the week button on show.
///
/// A single box rather than a tint on every button: a change of week then slides it from the old
/// week to the new one, instead of the tint jumping across the row. It also rides the row's own
/// scrolling, so it stays on its week while the table drags the row along.
///
/// The week arrives as a [ValueListenable] so the box can follow it on its own, without the week bar
/// being rebuilt: that rebuild is a page's worth of overview buttons, and spending it on the last
/// frames of a swipe is what makes the end of a swipe stutter.
class WeekSelectionHighlight extends StatefulWidget {
  const WeekSelectionHighlight({
    super.key,
    required this.week,
    required this.rowControl,
  });

  /// The week on show.
  final ValueListenable<int> week;

  /// The row's controller, so the highlight follows when the row scrolls.
  final ScrollController rowControl;

  @override
  State<WeekSelectionHighlight> createState() => _WeekSelectionHighlightState();
}

class _WeekSelectionHighlightState extends State<WeekSelectionHighlight>
    with SingleTickerProviderStateMixin {
  /// Where the highlight is, measured in weeks.
  ///
  /// Tweened rather than read straight from [WeekSelectionHighlight.week], so a change of week
  /// slides the box across instead of moving it in one frame.
  late Animation<double> _weeks = AlwaysStoppedAnimation<double>(
    widget.week.value.toDouble(),
  );

  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: changePageTime),
  );

  @override
  void initState() {
    super.initState();
    widget.week.addListener(_onWeekChanged);
  }

  @override
  void didUpdateWidget(covariant WeekSelectionHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.week != widget.week) {
      oldWidget.week.removeListener(_onWeekChanged);
      widget.week.addListener(_onWeekChanged);
      _onWeekChanged();
    }
  }

  @override
  void dispose() {
    widget.week.removeListener(_onWeekChanged);
    _slide.dispose();
    super.dispose();
  }

  void _onWeekChanged() {
    /// From wherever it is now, which may be halfway through an earlier slide.
    _weeks =
        Tween<double>(begin: _weeks.value, end: widget.week.value.toDouble())
            .animate(
              CurvedAnimation(parent: _slide, curve: Curves.easeInOutCubic),
            );
    _slide.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slide, widget.rowControl]),
      builder: (context, child) {
        final double scrolled = widget.rowControl.hasClients
            ? widget.rowControl.offset
            : 0;
        return Stack(
          children: [
            Positioned(
              left:
                  _weeks.value * weekChoiceItemExtent -
                  scrolled +
                  weekChoiceCardInset,
              top: weekChoiceCardMargin,
              bottom: weekChoiceCardMargin,
              width: weekChoiceItemExtent - 2 * weekChoiceCardInset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor.withValues(
                    alpha: weekChoiceHighlightAlpha,
                  ),
                  borderRadius: BorderRadius.circular(weekChoiceCardRadius),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
