// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The class table sheet: the static time line and date row, plus the week pages.

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_time_column_layout.dart';
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
    this.verticalPhysics,
    this.heightReference,
    this.bottomClearance = 0,
  });

  /// The week shown when [pageControl] is null.
  final int singleIndex;

  /// When set, the sheet pages horizontally between weeks.
  final PageController? pageControl;
  final int semesterLength;
  final ValueChanged<int>? onPageChanged;
  final bool enableVerticalScrolling;

  /// Overrides the physics of the sheet's own vertical scroll.
  ///
  /// The timetable pulls against [classTableBounceOverscroll] because the pull itself is its
  /// feedback, but the settings preview is a small pane inside a page that already scrolls, so
  /// there the same pull would fight the page and it clamps instead. Null keeps the timetable's
  /// own behaviour.
  final ScrollPhysics? verticalPhysics;

  /// The height the blocks are scaled against, [classTableHeightReference] when null.
  ///
  /// A fixed reference rather than the viewport, so the blocks keep their size whether the week bar
  /// is docked or collapsed, and in the settings preview, which has no viewport of its own.
  final double? heightReference;

  /// The room kept after the last period, for the bottom of the display.
  ///
  /// It is a blank stretch at the end of the time line rather than a padding around the sheet: the
  /// table stays borderless and reaches the edges, and the last period simply has that much empty
  /// room after it. Scrolled all the way down, the room is what holds the last time, the last class
  /// card and the current time indicator clear of the navigation bar and of the rounded corners of
  /// the screen, which curve inwards over exactly this much at the very bottom.
  final double bottomClearance;

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
      setState(() {
        _dateRowHeight = height;
      });
    }
  }

  DateTime _firstDayOfWeek(int index) {
    final state = ClassTableState.of(context)!.controllers;
    return state.startDay
        .add(Duration(days: 7 * state.offset))
        .add(Duration(days: 7 * index));
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
        final double available =
            widget.heightReference ?? classTableHeightReference;

        /// Measured once and handed down, so the time line, the grid and the floating indicators
        /// cannot drift apart: the column is as wide as its widest label needs, and a block is never
        /// shorter than the labels stacked inside it.
        final ClassTableTimeColumnLayout timeColumnLayout =
            ClassTableTimeColumnLayout.of(context);
        final double timeColumnWidth = timeColumnLayout.width;
        final double blockUnit = classTableBlockUnit(
          context,
          available,
          minimumUnit: timeColumnLayout.minimumBlockHeight,
        );

        /// The room the last period still needs below itself: the rounded corner of the sheet
        /// reaches in at the bottom, and without it the end of the 11th class is cut off at the
        /// very end of the scroll. [ClassTableSheet.bottomClearance] adds the room the bottom of the
        /// display itself needs, which is what keeps the last time and the current time indicator
        /// clear of the navigation bar and of the screen's own rounded corners.
        ///
        /// [classTableTimeLineTopGap] leads instead: the grid starts one strip lower than the sheet,
        /// so that before the first class the current time indicator has somewhere to be other than
        /// on top of the 8:30 label.
        final double gridHeight =
            classTableTimeLineTopGap +
            61 * blockUnit +
            classTableSheetEndGap +
            widget.bottomClearance;

        final Widget content = Stack(
          fit: StackFit.expand,
          children: [
            /// The sheet fills the whole area, so its content slides underneath the date row
            /// instead of being cut off at a hard edge below it.
            ///
            /// Under [_ClassTableScrollBehavior]: the platform's overscroll indicator is diverted to the
            /// glow, because the stretch scales its child and a scaled subtree breaks every backdrop
            /// filter inside it — the frost would blink out on each top and bottom pull.
            ScrollConfiguration(
              behavior: const _ClassTableScrollBehavior(),
              child: SingleChildScrollView(
                controller: _verticalControl,
                physics: !widget.enableVerticalScrolling
                    ? const NeverScrollableScrollPhysics()
                    : widget.verticalPhysics ??
                          (classTableBounceOverscroll
                              ? const BouncingScrollPhysics()
                              : null),
                child: Column(
                  children: [
                    /// Room reserved for the floating date row.
                    SizedBox(height: _dateRowHeight),

                    SizedBox(
                      height: gridHeight,
                      child: Stack(
                        children: [
                          /// The classes, below everything else, so a card sliding in from the
                          /// next week passes behind the time line rather than over it.
                          _pages(timeColumnWidth, blockUnit),

                          /// Laid out once for the whole table, so it does not page with the weeks.
                          ClassTableTimeLine(
                            timeColumnWidth: timeColumnWidth,
                            blockUnit: blockUnit,
                          ),

                          /// The current-time indicator (time buoy + horizontal line) as a connected whole.
                          Positioned.fill(
                            child: _CurrentTimeIndicatorLayer(
                              pageControl: widget.pageControl,
                              singleIndex: widget.singleIndex,
                              timeColumnWidth: timeColumnWidth,
                              blockUnit: blockUnit,
                              maxWidth: constraints.maxWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                timeColumnWidth: timeColumnWidth,

                /// Handed the pages so the headers can slide with them rather than flipping over
                /// once the week has already changed.
                pageControl: widget.pageControl,
                semesterLength: widget.semesterLength,
              ),
            ),
          ],
        );

        if (!widget.enableVerticalScrolling) {
          /// Nothing scrolls in here, so the sheet takes its full height and the page around it does
          /// the scrolling. Confining it to the box it was given is what used to hide the last
          /// periods of the settings preview.
          return SizedBox(height: _dateRowHeight + gridHeight, child: content);
        }

        return content;
      },
    );
  }

  Widget _pages(double timeColumnWidth, double blockUnit) {
    final PageController? control = widget.pageControl;
    if (control == null) {
      return ClassTableView(
        index: widget.singleIndex,
        timeColumnWidth: timeColumnWidth,
        blockUnit: blockUnit,
      );
    }
    return PageView.builder(
      controller: control,
      physics: const ClassTablePageScrollPhysics(),
      onPageChanged: widget.onPageChanged,
      itemCount: widget.semesterLength,
      itemBuilder: (context, index) => ClassTableView(
        index: index,
        timeColumnWidth: timeColumnWidth,
        blockUnit: blockUnit,
      ),
    );
  }
}

/// Custom scroll physics for week page swiping in the class table.
///
/// Reduces accidental page flips caused by slight diagonal drags or tiny release flings
/// when scrolling vertically.
///
/// - For a quick flick to turn pages, the user must exceed a deliberate velocity threshold
///   ([_kMinFlingVelocity]) AND have moved at least [_kMinDragFractionForFling] of the page in
///   that direction.
/// - For a slow drag without a quick flick, the page must be dragged past
///   [_kSlowDragCommitThreshold] (the midpoint) in either direction to settle onto the
///   neighbouring page, otherwise it springs back.
class ClassTablePageScrollPhysics extends PageScrollPhysics {
  const ClassTablePageScrollPhysics({super.parent});

  @override
  ClassTablePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ClassTablePageScrollPhysics(parent: buildParent(ancestor));
  }

  /// Minimum fling velocity in logical pixels/second required to flip page
  /// with a short swipe.
  static const double _kMinFlingVelocity = 400.0;

  /// Minimum fraction of page width dragged before a flick is allowed to flip pages.
  static const double _kMinDragFractionForFling = 0.20;

  /// Fraction of page width dragged required to commit to flipping page during slow dragging.
  ///
  /// The physics only sees where the pages are, not which page the drag started on, so this is the
  /// point where the drag lands on the nearer page. Only 0.5 is symmetric: any other value would
  /// make one direction need more than this and the other direction less (at 0.6, forward needed
  /// 60% while backward flipped at 40%).
  static const double _kSlowDragCommitThreshold = 0.5;

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.8,
    stiffness: 120.0,
    ratio: 1.2,
  );

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (!position.hasPixels || position.viewportDimension <= 0) {
      return null;
    }

    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double page = position.pixels / position.viewportDimension;
    final int pageFloor = page.floor();
    final double fraction = page - pageFloor;

    final int targetPage;
    if (velocity > _kMinFlingVelocity) {
      targetPage = fraction >= _kMinDragFractionForFling
          ? pageFloor + 1
          : pageFloor;
    } else if (velocity < -_kMinFlingVelocity) {
      targetPage = fraction <= (1.0 - _kMinDragFractionForFling)
          ? pageFloor
          : pageFloor + 1;
    } else {
      // Slow drag: settle onto whichever page is more than half in view, in either direction.
      targetPage = fraction >= _kSlowDragCommitThreshold
          ? pageFloor + 1
          : pageFloor;
    }

    final Tolerance tolerance = toleranceFor(position);
    final double targetPixels = (targetPage * position.viewportDimension).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (targetPixels != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPixels,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }
}

/// Whether the table pulls out past its ends and springs back, instead of using the platform's
/// overscroll indicator.
///
/// A bounce only moves the content, which the frosted controls handle like any other scroll, so the
/// blur survives the pull and the table still answers the finger. The platform's stretch scales its
/// child instead, and a scaled subtree breaks the backdrop filters underneath it: with the stretch
/// the blur disappears for the length of the pull. Set this to false to go back to it.
const bool classTableBounceOverscroll = true;

/// The table's overscroll feedback.
///
/// With [classTableBounceOverscroll] the pull itself is the feedback, so no indicator is drawn; that
/// is also the only way the blur survives, since every platform indicator either scales the content
/// or paints a layer over it. Set the flag to false to get the platform default back.
class _ClassTableScrollBehavior extends MaterialScrollBehavior {
  const _ClassTableScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (classTableBounceOverscroll) {
      return child;
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}

/// The current-time indicator layer: combines the time buoy on the timeline with the horizontal line
/// as a single connected whole, visible only on the current week.
///
/// Correlates fade-in and fade-out animations directly with horizontal swiping progress:
/// - Fades out quickly in place as swiping starts away from the current week.
/// - Stays invisible while swiping and on other weeks.
/// - Fades in smoothly in place as the swipe brings the current week back into view and settles.
class _CurrentTimeIndicatorLayer extends StatelessWidget {
  const _CurrentTimeIndicatorLayer({
    required this.pageControl,
    required this.singleIndex,
    required this.timeColumnWidth,
    required this.blockUnit,
    required this.maxWidth,
  });

  final PageController? pageControl;
  final int singleIndex;
  final double timeColumnWidth;
  final double blockUnit;
  final double maxWidth;

  /// Fraction of a page swipe over which the indicator fades out/in.
  /// Beyond this distance, the indicator is completely invisible (opacity 0).
  static const double _fadeThreshold = 0.25;

  @override
  Widget build(BuildContext context) {
    final ClassTableState? state = ClassTableState.of(context);
    if (state == null) return const SizedBox.shrink();

    final ClassTableWidgetState controllers = state.controllers;
    final int currentWeek = controllers.currentWeek;

    if (pageControl == null) {
      if (singleIndex != currentWeek) {
        return const SizedBox.shrink();
      }
      return ListenableBuilder(
        listenable: controllers.timeTickNotifier,
        builder: (context, _) {
          final indicator = _buildIndicator(
            context: context,
            controllers: controllers,
            currentWeek: currentWeek,
            opacity: 1.0,
          );
          if (indicator == null) return const SizedBox.shrink();
          return IgnorePointer(child: Stack(children: [indicator]));
        },
      );
    }

    final PageController pages = pageControl!;

    return AnimatedBuilder(
      animation: Listenable.merge([pages, controllers.timeTickNotifier]),
      builder: (context, _) {
        final double page;
        if (pages.hasClients && pages.position.hasPixels) {
          page =
              pages.page ??
              (maxWidth > 0
                  ? pages.position.pixels / maxWidth
                  : singleIndex.toDouble());
        } else {
          page = singleIndex.toDouble();
        }

        final double dist = (page - currentWeek).abs();
        if (dist >= _fadeThreshold) {
          return const SizedBox.shrink();
        }

        // Correlate fade directly with swipe progress:
        // As dist increases from 0, opacity quickly drops to 0.
        // As dist decreases to 0, opacity smoothly fades in to 1.
        final double t = (1.0 - (dist / _fadeThreshold)).clamp(0.0, 1.0);
        final double opacity = Curves.easeIn.transform(t);

        if (opacity <= 0.0) {
          return const SizedBox.shrink();
        }

        final Positioned? indicator = _buildIndicator(
          context: context,
          controllers: controllers,
          currentWeek: currentWeek,
          opacity: opacity,
        );

        if (indicator == null) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(child: Stack(children: [indicator]));
      },
    );
  }

  Positioned? _buildIndicator({
    required BuildContext context,
    required ClassTableWidgetState controllers,
    required int currentWeek,
    required double opacity,
  }) {
    final DateTime weekStart = controllers.startDay
        .add(Duration(days: 7 * controllers.offset))
        .add(Duration(days: 7 * currentWeek));

    return CurrentTimeIndicator.build(
      context: context,
      now: controllers.currentTime,
      weekStart: weekStart,
      leftRow: timeColumnWidth,
      blockWidth: (maxWidth - timeColumnWidth) / 7,

      /// Block 0 sits [classTableTimeLineTopGap] below the top of the grid, exactly like the class
      /// cards do. Before the first class the indicator still uses its own minimum instead, so it
      /// waits in that strip rather than on the 8:30 label.
      blockHeight: (double count) =>
          classTableTimeLineTopGap + count * blockUnit,
      opacity: opacity,
    );
  }
}
