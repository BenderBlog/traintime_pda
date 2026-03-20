// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/wheel_choser.dart';

class DateSelectorFree extends StatefulWidget {
  final List<DateTimeRange> initialDates;
  final ValueChanged<List<DateTimeRange>> onChanged;
  final Color color;

  const DateSelectorFree({
    super.key,
    required this.initialDates,
    required this.onChanged,
    required this.color,
  });

  @override
  State<DateSelectorFree> createState() => _DateSelectorFree();
}

class _DateSelectorFree extends State<DateSelectorFree> {
  static const int _earliestInMinutes = 8 * 60 + 30;
  static const int _latestInMinutes = 21 * 60 + 25;

  late List<DateTimeRange> chosenDatesRanges;

  @override
  void initState() {
    super.initState();
    chosenDatesRanges = List<DateTimeRange>.from(widget.initialDates);
  }

  int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

  bool _isInRange(TimeOfDay time) {
    final value = _minutesOf(time);
    return value >= _earliestInMinutes && value <= _latestInMinutes;
  }

  List<int> _allowedMinutes(int hour) {
    if (hour == 8) {
      return List<int>.generate(30, (index) => index + 30);
    }
    if (hour == 21) {
      return List<int>.generate(26, (index) => index);
    }
    return List<int>.generate(60, (index) => index);
  }

  TimeOfDay _sanitizeTime(TimeOfDay source) {
    int hour = source.hour.clamp(8, 21);
    int minute = source.minute;
    if (hour == 8 && minute < 30) {
      minute = 30;
    }
    if (hour == 21 && minute > 25) {
      minute = 25;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<(TimeOfDay, TimeOfDay)?> _showRangeTimePicker(
    BuildContext context, {
    required TimeOfDay initialStart,
    required TimeOfDay initialEnd,
    required String helpText,
  }) async {
    TimeOfDay start = _sanitizeTime(initialStart);
    TimeOfDay end = _sanitizeTime(initialEnd);
    if (_minutesOf(end) <= _minutesOf(start)) {
      final int fixedEnd = (_minutesOf(start) + 60).clamp(
        _earliestInMinutes + 1,
        _latestInMinutes,
      );
      end = TimeOfDay(hour: fixedEnd ~/ 60, minute: fixedEnd % 60);
    }

    return await showModalBottomSheet<(TimeOfDay, TimeOfDay)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builderContext) {
        return StatefulBuilder(
          builder: (context, setModalState) => SizedBox(
            height: 480,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(builderContext).pop(),
                        child: Text(
                          FlutterI18n.translate(context, 'cancel'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Text(
                        helpText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (!_isInRange(start) || !_isInRange(end)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  FlutterI18n.translate(
                                    context,
                                    "classtable.class_add.date_selector_free.rule",
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          if (_minutesOf(end) <= _minutesOf(start)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  FlutterI18n.translate(
                                    context,
                                    "classtable.class_add.date_selector_free.rule_2",
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.of(builderContext).pop((start, end));
                        },
                        child: Text(
                          FlutterI18n.translate(context, "confirm"),
                          style: TextStyle(color: widget.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      _buildTimeEditor(
                        keyPrefix: 'start',
                        title: FlutterI18n.translate(
                          context,
                          "classtable.class_add.date_selector_free.class_start_time",
                        ),
                        color: widget.color,
                        current: start,
                        onHourChanged: (hour) {
                          setModalState(() {
                            final mins = _allowedMinutes(hour);
                            int minute = start.minute;
                            if (!mins.contains(minute)) {
                              minute = mins.first;
                            }
                            start = TimeOfDay(hour: hour, minute: minute);
                          });
                        },
                        onMinuteChanged: (minute) {
                          setModalState(() {
                            start = TimeOfDay(hour: start.hour, minute: minute);
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTimeEditor(
                        keyPrefix: 'end',
                        title: FlutterI18n.translate(
                          context,
                          "classtable.class_add.date_selector_free.class_end_time",
                        ),
                        color: widget.color,
                        current: end,
                        onHourChanged: (hour) {
                          setModalState(() {
                            final mins = _allowedMinutes(hour);
                            int minute = end.minute;
                            if (!mins.contains(minute)) {
                              minute = mins.first;
                            }
                            end = TimeOfDay(hour: hour, minute: minute);
                          });
                        },
                        onMinuteChanged: (minute) {
                          setModalState(() {
                            end = TimeOfDay(hour: end.hour, minute: minute);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeEditor({
    required String keyPrefix,
    required String title,
    required Color color,
    required TimeOfDay current,
    required ValueChanged<int> onHourChanged,
    required ValueChanged<int> onMinuteChanged,
  }) {
    final allowedHours = List<int>.generate(14, (index) => index + 8);
    final allowedMinutes = _allowedMinutes(current.hour);
    final hourPage = allowedHours.indexOf(current.hour);
    final minutePage = allowedMinutes.indexOf(current.minute);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.08),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  child: WheelChoose<int>(
                    defaultPage: hourPage < 0 ? 0 : hourPage,
                    changeBookIdCallBack: onHourChanged,
                    options: allowedHours
                        .map(
                          (hour) => WheelChooseOptions(
                            data: hour,
                            hint: hour.toString().padLeft(2, '0'),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: WheelChoose<int>(
                    key: ValueKey('$keyPrefix-${current.hour}'),
                    defaultPage: minutePage < 0 ? 0 : minutePage,
                    changeBookIdCallBack: onMinuteChanged,
                    options: allowedMinutes
                        .map(
                          (minute) => WheelChooseOptions(
                            data: minute,
                            hint: minute.toString().padLeft(2, '0'),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editChosenDate(int index) async {
    final old = chosenDatesRanges[index];
    final result = await _showRangeTimePicker(
      context,
      initialStart: TimeOfDay.fromDateTime(old.start),
      initialEnd: TimeOfDay.fromDateTime(old.end),
      helpText: FlutterI18n.translate(
        context,
        "classtable.class_add.date_selector_free.edit_class_time",
      ),
    );

    if (!mounted || result == null) return;
    final start = DateTime(
      old.start.year,
      old.start.month,
      old.start.day,
      result.$1.hour,
      result.$1.minute,
    );
    final end = DateTime(
      old.end.year,
      old.end.month,
      old.end.day,
      result.$2.hour,
      result.$2.minute,
    );
    setState(() {
      chosenDatesRanges[index] = DateTimeRange(start: start, end: end);
    });
    widget.onChanged(chosenDatesRanges);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: widget.color, size: 16),
                Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_week_hint",
                  ),
                ).textStyle(TextStyle(color: widget.color)).padding(left: 4),
              ],
            ),
            const SizedBox(height: 8),
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.multi,
                selectedDayHighlightColor: widget.color,
              ),
              value: chosenDatesRanges.map((e) => e.start).toList(),
              onValueChanged: (dates) async {
                final newBaseDates = dates.whereType<DateTime>().toList();
                final oldBaseDates = chosenDatesRanges
                    .map((d) => DateUtils.dateOnly(d.start))
                    .toList();

                DateTime? addedDate;
                for (var d in newBaseDates) {
                  if (!oldBaseDates.contains(DateUtils.dateOnly(d))) {
                    addedDate = d;
                    break;
                  }
                }

                if (addedDate != null) {
                  final pickedRange = await _showRangeTimePicker(
                    context,
                    initialStart: const TimeOfDay(hour: 8, minute: 30),
                    initialEnd: const TimeOfDay(hour: 9, minute: 15),
                    helpText: FlutterI18n.translate(
                      context,
                      "classtable.class_add.date_selector_free.choose_class_time",
                    ),
                  );

                  if (pickedRange != null) {
                    final finalStartDate = DateTime(
                      addedDate.year,
                      addedDate.month,
                      addedDate.day,
                      pickedRange.$1.hour,
                      pickedRange.$1.minute,
                    );
                    final finalEndDate = DateTime(
                      addedDate.year,
                      addedDate.month,
                      addedDate.day,
                      pickedRange.$2.hour,
                      pickedRange.$2.minute,
                    );

                    setState(() {
                      chosenDatesRanges.add(
                        DateTimeRange(start: finalStartDate, end: finalEndDate),
                      );
                    });
                    widget.onChanged(chosenDatesRanges);
                  } else {
                    setState(() {});
                  }
                } else {
                  setState(() {
                    chosenDatesRanges.removeWhere(
                      (d) => !newBaseDates
                          .map((nd) => DateUtils.dateOnly(nd))
                          .contains(DateUtils.dateOnly(d.start)),
                    );
                  });
                  widget.onChanged(chosenDatesRanges);
                }
              },
            ),
            if (chosenDatesRanges.isNotEmpty)
              ...List.generate(chosenDatesRanges.length, (index) {
                final d = chosenDatesRanges[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _editChosenDate(index),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.color.withValues(alpha: 0.08),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: widget.color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DateFormat('yyyy-MM-dd').format(d.start)}  '
                              '${DateFormat('HH:mm').format(d.start)}-${DateFormat('HH:mm').format(d.end)}',
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            color: widget.color,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
