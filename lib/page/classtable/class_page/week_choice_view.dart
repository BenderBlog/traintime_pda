// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// This is the button of the toprow
class WeekChoiceView extends StatefulWidget {
  final int index;
  const WeekChoiceView({
    super.key,
    required this.index,
  });

  @override
  State<WeekChoiceView> createState() => _WeekChoiceViewState();
}

class _WeekChoiceViewState extends State<WeekChoiceView> {
  late ClassTableWidgetState controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ClassTableState.of(context)!.controllers;
  }

  /// The dot of the overview, [isOccupied] is used to identify the opacity of the dot.
  Widget dot({required bool isOccupied}) {
    double opacity = isOccupied ? 1 : 0.25;
    return ClipOval(
      child: Container(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: opacity),
      ),
    );
  }

  /// [buttonInformaion] shows the botton's [index] and the overview.
  ///
  /// A [index] is required to render the botton for the week.
  Widget buttonInformaion({required int index}) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            FlutterI18n.translate(
              context,
              "classtable.week_title",
              translationParams: {
                "week": (index + 1).toString(),
              },
            ),
            style: TextStyle(
              fontWeight: index == controller.currentWeek
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 1,
            group: AutoSizeGroup(),
          ),

          /// These code are used to render the overview of the week,
          /// as long as the height of the page is over 500.
          if (MediaQuery.sizeOf(context).height >= 500)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  6,
                  4,
                  6,
                  2,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(25, (i) {
                    int day = i % 5 + 1;
                    int time = i ~/ 5;
                    bool isOccupied = false;
                    List<ClassOrgainzedData> arrangedEvents =
                        controller.getArrangement(
                      weekIndex: widget.index,
                      dayIndex: day,
                    );

                    for (var i in arrangedEvents) {
                      int start = 0;
                      int stop = 0;

                      switch (time) {
                        case 0:
                          start = 0;
                          stop = 10;
                          break;
                        case 1:
                          start = 10;
                          stop = 20;
                          isOccupied = i.stop > 10.0 && i.stop <= 20.0;
                          break;
                        case 2:
                          start = 20;
                          stop = 33;
                          isOccupied = i.stop > 23.0 && i.stop <= 33.0;
                          break;
                        case 3:
                          start = 33;
                          stop = 43;
                          isOccupied = i.stop > 33.0 && i.stop <= 43.0;
                          break;
                        case 4:
                          start = 46;
                          stop = 49; // 49 is the limit of the classtable...
                          break;
                      }

                      if ((i.stop != start && i.start != stop) &&
                          ((start < i.stop && i.start < stop) ||
                              (stop > i.start && i.stop > start))) {
                        isOccupied = true;
                      }

                      if (isOccupied) break;
                    }

                    return dot(isOccupied: isOccupied);
                  }),
                ),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: weekButtonHorizontalPadding,
      ),
      child: SizedBox(
        width: weekButtonWidth,
        child: buttonInformaion(index: widget.index),
      ),
    );
  }
}
