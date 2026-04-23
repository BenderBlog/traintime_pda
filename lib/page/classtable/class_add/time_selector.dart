// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/wheel_choser.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

class TimeSelector extends StatefulWidget {
  final int initialWeek;
  final int initialStart;
  final int initialStop;
  final ValueChanged<(int week, int start, int stop)> onChanged;
  final Color color;

  const TimeSelector({
    super.key,
    required this.initialWeek,
    required this.initialStart,
    required this.initialStop,
    required this.onChanged,
    required this.color,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late int week;
  late int start;
  late int stop;

  @override
  void initState() {
    super.initState();
    week = widget.initialWeek;
    start = widget.initialStart;
    stop = widget.initialStop;
  }

  void _notifyChange() {
    widget.onChanged((week, start, stop));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: widget.color, size: 16),
                Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_time_hint",
                  ),
                ).textStyle(TextStyle(color: widget.color)).padding(left: 4),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.class_add.input_time_weekday_hint",
                          ),
                        )
                        .textStyle(TextStyle(color: widget.color))
                        .center()
                        .flexible(),
                    Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.class_add.input_start_time_hint",
                          ),
                        )
                        .textStyle(TextStyle(color: widget.color))
                        .center()
                        .flexible(),
                    Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.class_add.input_end_time_hint",
                          ),
                        )
                        .textStyle(TextStyle(color: widget.color))
                        .center()
                        .flexible(),
                  ],
                ),
                Row(
                  children: [
                    WheelChoose(
                      changeBookIdCallBack: (choiceWeek) {
                        setState(() => week = choiceWeek + 1);
                        _notifyChange();
                      },
                      defaultPage: week - 1,
                      options: List.generate(
                        7,
                        (index) => WheelChooseOptions(
                          data: index,
                          hint: getWeekString(context, index),
                        ),
                      ),
                    ).flexible(),
                    WheelChoose(
                      changeBookIdCallBack: (choiceStart) {
                        setState(() => start = choiceStart);
                        _notifyChange();
                      },
                      defaultPage: start - 1,
                      options: List.generate(
                        11,
                        (index) => WheelChooseOptions(
                          data: index + 1,
                          hint: FlutterI18n.translate(
                            context,
                            "classtable.class_add.wheel_choose_hint",
                            translationParams: {
                              "index": (index + 1).toString(),
                            },
                          ),
                        ),
                      ),
                    ).flexible(),
                    WheelChoose(
                      changeBookIdCallBack: (choiceStop) {
                        setState(() => stop = choiceStop);
                        _notifyChange();
                      },
                      defaultPage: stop - 1,
                      options: List.generate(
                        11,
                        (index) => WheelChooseOptions(
                          data: index + 1,
                          hint: FlutterI18n.translate(
                            context,
                            "classtable.class_add.wheel_choose_hint",
                            translationParams: {
                              "index": (index + 1).toString(),
                            },
                          ),
                        ),
                      ),
                    ).flexible(),
                  ],
                ),
              ],
            ),
          ],
        )
        .padding(all: 12)
        .card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        );
  }
}
