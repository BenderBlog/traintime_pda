// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// This is the button of the toprow
class WeekChoiceView extends StatefulWidget {
  final int index;
  const WeekChoiceView({super.key, required this.index});

  @override
  State<WeekChoiceView> createState() => _WeekChoiceViewState();
}

class _WeekChoiceViewState extends State<WeekChoiceView> {
  late ClassTableWidgetState controller;
  // 缓存 AutoSizeGroup，避免每次 build 创建新实例
  final AutoSizeGroup _autoSizeGroup = AutoSizeGroup();
  static const double _occupiedOpacity = 1.0;
  static const double _completedOpacity = 0.45;
  static const double _vacantOpacity = 0.25;

  Color _desaturateColor(Color color, {required double factor}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(hsl.saturation * factor).toColor();
  }

  ({int start, int stop}) _slotRange(int timeIndex) {
    switch (timeIndex) {
      case 0:
        return (start: 0, stop: 10);
      case 1:
        return (start: 10, stop: 20);
      case 2:
        return (start: 20, stop: 33);
      case 3:
        return (start: 33, stop: 43);
      default:
        // 49 is the visible limit of the compact week preview.
        return (start: 46, stop: 49);
    }
  }

  bool _eventOccupiesSlot({
    required ClassOrgainzedData event,
    required int slotStart,
    required int slotStop,
  }) {
    return (event.stop != slotStart && event.start != slotStop) &&
        ((slotStart < event.stop && event.start < slotStop) ||
            (slotStop > event.start && event.stop > slotStart));
  }

  bool _slotCompleted({
    required DateTime slotDate,
    required DateTime today,
    required int slotStop,
    required double currentBlockIndex,
  }) {
    if (slotDate.isBefore(today)) {
      return true;
    }
    if (slotDate.isAfter(today)) {
      return false;
    }
    return slotStop <= currentBlockIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ClassTableState.of(context)!.controllers;
  }

  /// The dot of the overview, [isOccupied] is used to identify the opacity of the dot.
  /// [primaryColor] is passed in from outside to avoid calling Theme.of(context) for each dot.
  Widget dot({
    required bool isOccupied,
    required bool isCompleted,
    required Color primaryColor,
  }) {
    double opacity = _vacantOpacity;
    Color dotColor = primaryColor;
    if (isOccupied) {
      opacity = isCompleted ? _completedOpacity : _occupiedOpacity;
      if (isCompleted) {
        dotColor = _desaturateColor(
          primaryColor,
          factor: CompletedClassStyleConfig.completedSaturationFactor,
        );
      }
    }
    return ClipOval(child: ColoredBox(color: dotColor.withValues(alpha: opacity)));
  }

  /// [buttonInformaion] shows the botton's [index] and the overview.
  ///
  /// A [index] is required to render the botton for the week.
  /// [showOverview] and [primaryColor] are passed in from the outside to avoid every instance listening to MediaQuery and Theme.
  Widget buttonInformaion({
    required int index,
    required bool showOverview,
    required Color primaryColor,
  }) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      AutoSizeText(
        FlutterI18n.translate(
          context,
          "classtable.week_title",
          translationParams: {"week": (index + 1).toString()},
        ),
        style: TextStyle(
          fontWeight: index == controller.currentWeek
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        maxLines: 1,
        group: _autoSizeGroup,
      ),

      /// These code are used to render the overview of the week,
      /// as long as the height of the page is over 500.
      if (showOverview)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(25, (i) {
                int day = i % 5 + 1;
                int time = i ~/ 5;
                final now = controller.currentTime;
                final today = DateTime(now.year, now.month, now.day);
                final weekStart = controller.startDay
                    .add(Duration(days: 7 * controller.offset))
                    .add(Duration(days: 7 * widget.index));
                final blockDate = weekStart.add(Duration(days: day - 1));
                final currentBlockIndex = CurrentTimeIndicator
                    .transferTimeToBlockIndex(now);
                List<ClassOrgainzedData> arrangedEvents = controller
                    .getArrangement(weekIndex: widget.index, dayIndex: day);

                final slot = _slotRange(time);

                var hasOccupiedEvent = false;
                var allOccupiedEventsCompleted = true;

                for (var event in arrangedEvents) {
                  final eventOccupiesCell = _eventOccupiesSlot(
                    event: event,
                    slotStart: slot.start,
                    slotStop: slot.stop,
                  );
                  if (!eventOccupiesCell) {
                    continue;
                  }

                  hasOccupiedEvent = true;

                  final eventCompleted = _slotCompleted(
                    slotDate: blockDate,
                    today: today,
                    slotStop: slot.stop,
                    currentBlockIndex: currentBlockIndex,
                  );

                  allOccupiedEventsCompleted =
                      allOccupiedEventsCompleted && eventCompleted;

                  // Any ongoing/upcoming arrangement in the same cell should keep
                  // the preview block highlighted as active.
                  if (!eventCompleted) {
                    break;
                  }
                }

                return dot(
                  isOccupied: hasOccupiedEvent,
                  isCompleted: hasOccupiedEvent && allOccupiedEventsCompleted,
                  primaryColor: primaryColor,
                );
              }),
            ),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // Retrieve the data once in the build to avoid multiple calls within sub-methods.
    final showOverview = MediaQuery.sizeOf(context).height >= 500;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: weekButtonHorizontalPadding,
      ),
      child: SizedBox(
        width: weekButtonWidth,
        child: buttonInformaion(
          index: widget.index,
          showOverview: showOverview,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}
