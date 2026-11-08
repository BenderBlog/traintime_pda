// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

class ClassScheduleDateRulesDialog extends StatefulWidget {
  const ClassScheduleDateRulesDialog({
    super.key,
    required this.initialDates,
    required this.firstDate,
    required this.lastDate,
  });

  final Set<DateTime> initialDates;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<ClassScheduleDateRulesDialog> createState() =>
      _ClassScheduleDateRulesDialogState();
}

class _ClassScheduleDateRulesDialogState
    extends State<ClassScheduleDateRulesDialog> {
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialDates.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final tr = context.t;
    final months = [
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

    return AlertDialog(
      title: Text(tr.classtable.classAdd.scheduleBuilder.selectDates),
      content: SizedBox(
        width: 440,
        // calendar_date_picker2 still uses Flutter's Material widgets.
        // Remove this bridge when that package migrates to material_ui.
        // ignore: deprecated_member_use
        child: MaterialUiCompatibilityBridge(
          child: legacy.Material(
            type: legacy.MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr.classtable.classAdd.scheduleBuilder.multiDateTip,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.multi,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    firstDayOfWeek: MaterialLocalizations.of(
                      context,
                    ).firstDayOfWeekIndex,
                    selectedDayHighlightColor: color,
                    hideMonthPickerDividers: true,
                    disableModePicker: true,
                    disableMonthPicker: true,
                    selectableYearPredicate: (_) => false,
                    weekdayLabels: [
                      tr.weekday.sunday,
                      tr.weekday.monday,
                      tr.weekday.tuesday,
                      tr.weekday.wednesday,
                      tr.weekday.thursday,
                      tr.weekday.friday,
                      tr.weekday.saturday,
                    ],
                    modePickerTextHandler:
                        ({required DateTime monthDate, bool? isMonthPicker}) {
                          final yearName = tr.classtable.semesterSwitcher.year(
                            year: '${monthDate.year}',
                          );
                          return '$yearName ${months[monthDate.month - 1]}';
                        },
                  ),
                  value: _selectedDates,
                  onValueChanged: (dates) {
                    setState(() {
                      _selectedDates =
                          dates
                              .whereType<DateTime>()
                              .map(DateUtils.dateOnly)
                              .toSet()
                              .toList()
                            ..sort();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.common.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedDates.toSet()),
          child: Text(context.t.common.confirm),
        ),
      ],
    );
  }
}
