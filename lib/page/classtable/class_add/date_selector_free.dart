// Copyright 2026 Hazuki Keatsu.
// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';

class DateSelectorFree extends StatefulWidget {
  final List<DateTimeRange> initialDates;
  final DateTime semesterStartDay;
  final int semesterLength;
  final ValueChanged<List<DateTimeRange>> onChanged;
  final Color color;
  final Color deleteColor;
  final bool enableBorder;

  const DateSelectorFree({
    super.key,
    required this.initialDates,
    required this.semesterStartDay,
    required this.semesterLength,
    required this.onChanged,
    required this.color,
    required this.deleteColor,
    this.enableBorder = false,
  });

  @override
  State<DateSelectorFree> createState() => _DateSelectorFree();
}

class _DateSelectorFree extends State<DateSelectorFree> {
  static const int _earliestInMinutes = 8 * 60 + 30;
  static const int _latestInMinutes = 21 * 60 + 25;

  late List<DateTimeRange> chosenDatesRanges;

  DateTime get _semesterFirstDate =>
      DateUtils.dateOnly(widget.semesterStartDay);

  DateTime get _semesterLastDate =>
      _semesterFirstDate.add(Duration(days: widget.semesterLength * 7 - 1));

  bool _isWithinSemester(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return !day.isBefore(_semesterFirstDate) && !day.isAfter(_semesterLastDate);
  }

  @override
  void initState() {
    super.initState();
    chosenDatesRanges = widget.initialDates
        .where((range) => _isWithinSemester(range.start))
        .toList();
  }

  int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

  bool _isInRange(TimeOfDay time) {
    final value = _minutesOf(time);
    return value >= _earliestInMinutes && value <= _latestInMinutes;
  }

  TimeOfDay _sanitizeTime(TimeOfDay source, {required bool isStart}) {
    int hour = source.hour.clamp(8, 21);
    int minute = source.minute;
    if (hour == 8 && minute < 30) {
      minute = 30;
    }
    if (hour == 21) {
      final int maxMinute = isStart ? 24 : 25;
      if (minute > maxMinute) {
        minute = maxMinute;
      }
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<(TimeOfDay, TimeOfDay)?> _showRangeTimePicker(
    BuildContext context, {
    required TimeOfDay initialStart,
    required TimeOfDay initialEnd,
    required String helpText,
  }) async {
    TimeOfDay start = _sanitizeTime(initialStart, isStart: true);
    TimeOfDay end = _sanitizeTime(initialEnd, isStart: false);
    if (_minutesOf(end) <= _minutesOf(start)) {
      final int fixedEnd = (_minutesOf(start) + 60).clamp(
        _earliestInMinutes + 1,
        _latestInMinutes,
      );
      end = TimeOfDay(hour: fixedEnd ~/ 60, minute: fixedEnd % 60);
    }

    FocusScope.of(context).unfocus();
    final startSelection = await showTimePicker(
      context: context,
      initialTime: start,
      initialEntryMode: TimePickerEntryMode.input,
      helpText:
          '$helpText · ${context.t.classtable.classAdd.dateSelectorFree.classStartTime}',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!context.mounted || startSelection == null) return null;
    if (!_isInRange(startSelection)) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.dateSelectorFree.rule,
      );
      return null;
    }
    start = startSelection;

    if (_minutesOf(end) <= _minutesOf(start)) {
      final int suggestedEnd = (_minutesOf(start) + 60).clamp(
        _earliestInMinutes + 1,
        _latestInMinutes,
      );
      end = TimeOfDay(hour: suggestedEnd ~/ 60, minute: suggestedEnd % 60);
    }

    final endSelection = await showTimePicker(
      context: context,
      initialTime: end,
      initialEntryMode: TimePickerEntryMode.input,
      helpText:
          '$helpText · ${context.t.classtable.classAdd.dateSelectorFree.classEndTime}',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!context.mounted || endSelection == null) return null;
    if (!_isInRange(endSelection)) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.dateSelectorFree.rule,
      );
      return null;
    }
    if (_minutesOf(endSelection) <= _minutesOf(start)) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.dateSelectorFree.rule2,
      );
      return null;
    }
    return (start, endSelection);
  }

  Future<void> _editChosenDate(int index) async {
    final old = chosenDatesRanges[index];
    final result = await _showRangeTimePicker(
      context,
      initialStart: TimeOfDay.fromDateTime(old.start),
      initialEnd: TimeOfDay.fromDateTime(old.end),
      helpText: context.t.classtable.classAdd.dateSelectorFree.editClassTime,
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

  void _deleteChosenDate(int index) {
    setState(() {
      chosenDatesRanges.removeAt(index);
    });
    widget.onChanged(chosenDatesRanges);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 2),
                Icon(Icons.calendar_month, color: widget.color),
                SizedBox(width: 16),
                Text(
                  context.t.classtable.classAdd.inputWeekHint,
                ).textStyle(TextStyle(color: widget.color)),
              ],
            ),
            const SizedBox(height: 8),
            // calendar_date_picker2 still uses package:flutter/material.dart,
            // while this app uses material_ui. Its InkResponse widgets require
            // Flutter's own Theme and Material ancestors.
            // Required until calendar_date_picker2 migrates to material_ui.
            // ignore: deprecated_member_use
            MaterialUiCompatibilityBridge(
              child: legacy.Material(
                type: legacy.MaterialType.transparency,
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.multi,
                    hideMonthPickerDividers: true,
                    firstDate: _semesterFirstDate,
                    lastDate: _semesterLastDate,
                    firstDayOfWeek: MaterialLocalizations.of(
                      context,
                    ).firstDayOfWeekIndex,
                    selectedDayHighlightColor: widget.color,
                    disableModePicker: true,
                    disableMonthPicker: true,
                    selectableYearPredicate: (_) => false,
                    weekdayLabels: [
                      context.t.weekday.sunday,
                      context.t.weekday.monday,
                      context.t.weekday.tuesday,
                      context.t.weekday.wednesday,
                      context.t.weekday.thursday,
                      context.t.weekday.friday,
                      context.t.weekday.saturday,
                    ],
                    modePickerTextHandler:
                        ({required DateTime monthDate, bool? isMonthPicker}) {
                          final monthIndex = monthDate.month - 1;
                          final tr = context.t;
                          final monthNameList = [
                            tr.month.january,
                            tr.month.february,
                            tr.month.march,
                            tr.month.april,
                            tr.month.may,
                            tr.month.june,
                            tr.month.july,
                            tr.month.august,
                            tr.month.september,
                            tr.month.october,
                            tr.month.november,
                            tr.month.december,
                          ];
                          final year = monthDate.year;
                          final yearName = context.t.classtable.semesterSwitcher
                              .year(year: '$year');
                          return "$yearName ${monthNameList[monthIndex]}";
                        },
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
                        helpText: context
                            .t
                            .classtable
                            .classAdd
                            .dateSelectorFree
                            .chooseClassTime,
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
                            DateTimeRange(
                              start: finalStartDate,
                              end: finalEndDate,
                            ),
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
              ),
            ),
            if (chosenDatesRanges.isNotEmpty)
              ...List.generate(chosenDatesRanges.length, (index) {
                final d = chosenDatesRanges[index];
                final weekNumber =
                    DateUtils.dateOnly(
                          d.start,
                        ).difference(_semesterFirstDate).inDays ~/
                        7 +
                    1;
                return Padding(
                  padding: EdgeInsetsGeometry.only(top: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _editChosenDate(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${DateFormat('yyyy-MM-dd').format(d.start)} · '
                                    '${getWeekString(context, d.start.weekday - 1)} · '
                                    '${context.t.classtable.weekTitle(week: '$weekNumber')}',
                                    style: TextStyle(
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('HH:mm').format(d.start)}-${DateFormat('HH:mm').format(d.end)}',
                                    style: TextStyle(color: widget.color),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: widget.deleteColor,
                                size: 18,
                              ),
                              onPressed: () => _deleteChosenDate(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        )
        .padding(all: 10)
        .decorated(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.25),
            width: widget.enableBorder ? 1.0 : 0.0,
          ),
        )
        .padding(vertical: 6);
  }
}
