// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import 'class_schedule_date_rules_dialog.dart';
import 'class_schedule_time_rules_dialog.dart';
import 'overlapping_time_ranges.dart';

const double _scheduleListTileHeight = 56;
const double _scheduleListTileOuterRadius = 12;

class ClassScheduleBottomSheet extends StatefulWidget {
  const ClassScheduleBottomSheet({
    super.key,
    required this.semesterStartDay,
    required this.semesterLength,
    required this.existingRanges,
  });

  final DateTime semesterStartDay;
  final int semesterLength;
  final List<DateTimeRange> existingRanges;

  /// A wrapper around the native modal bottom sheet route
  static Future<List<DateTimeRange>?> push(
    BuildContext context, {
    required DateTime semesterStartDay,
    required int semesterLength,
    required List<DateTimeRange> existingRanges,
  }) {
    final navigator = Navigator.of(context);
    return navigator.push<List<DateTimeRange>>(
      ModalBottomSheetRoute<List<DateTimeRange>>(
        builder: (_) => ClassScheduleBottomSheet(
          semesterStartDay: semesterStartDay,
          semesterLength: semesterLength,
          existingRanges: List.unmodifiable(existingRanges),
        ),
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        showDragHandle: false,
        useSafeArea: true,
        constraints: const BoxConstraints(maxWidth: 600),
      ),
    );
  }

  @override
  State<ClassScheduleBottomSheet> createState() =>
      _ClassScheduleBottomSheetState();
}

class _ClassScheduleBottomSheetState extends State<ClassScheduleBottomSheet> {
  Set<DateTime> _selectedDates = {};
  ClassScheduleTimeSelection? _timeSelection;

  DateTime get _firstDate => DateUtils.dateOnly(widget.semesterStartDay);

  DateTime get _lastDate {
    final first = _firstDate;
    return DateTime(
      first.year,
      first.month,
      first.day + widget.semesterLength * 7 - 1,
    );
  }

  Future<void> _editDates() async {
    final selected = await Navigator.of(context).push<Set<DateTime>>(
      DialogRoute<Set<DateTime>>(
        context: context,
        builder: (_) => ClassScheduleDateRulesDialog(
          initialDates: _selectedDates,
          firstDate: _firstDate,
          lastDate: _lastDate,
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedDates = selected);
  }

  Future<void> _editTimes() async {
    final selection = await Navigator.of(context)
        .push<ClassScheduleTimeSelection>(
          DialogRoute<ClassScheduleTimeSelection>(
            context: context,
            builder: (_) =>
                ClassScheduleTimeRulesDialog(initialSelection: _timeSelection),
          ),
        );
    if (!mounted || selection == null) return;
    setState(() => _timeSelection = selection);
  }

  List<ClassScheduleTimeRange> get _activeTimeRanges =>
      _timeSelection?.activeRanges ?? const [];

  List<int> _findOverlapIndices(List<DateTimeRange> candidates) {
    final existingCount = widget.existingRanges.length;
    final overlappingIndices = findOverlappingTimeRangeIndices([
      for (final range in widget.existingRanges) (range.start, range.end),
      for (final range in candidates) (range.start, range.end),
    ]);
    return [
      for (var index = 0; index < candidates.length; index++)
        if (overlappingIndices.contains(existingCount + index)) index,
    ];
  }

  Future<void> _showOverlapDialog(
    List<int> conflictIndices,
    List<DateTimeRange> candidates,
  ) async {
    await Navigator.of(context).push<void>(
      DialogRoute<void>(
        context: context,
        builder: (dialogContext) {
          final localizations = MaterialLocalizations.of(dialogContext);
          final translations =
              dialogContext.t.classtable.classAdd.scheduleBuilder;
          String formatRange(DateTimeRange range) {
            final start = localizations.formatTimeOfDay(
              TimeOfDay.fromDateTime(range.start),
              alwaysUse24HourFormat: true,
            );
            final end = localizations.formatTimeOfDay(
              TimeOfDay.fromDateTime(range.end),
              alwaysUse24HourFormat: true,
            );
            return '$start-$end';
          }

          return AlertDialog(
            title: Text(translations.overlapTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations.overlapMessage(count: conflictIndices.length),
                  ),
                  const SizedBox(height: 12),
                  for (final index in conflictIndices.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        translations.overlapRange(
                          date: localizations.formatFullDate(
                            DateUtils.dateOnly(candidates[index].start),
                          ),
                          range: formatRange(candidates[index]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(dialogContext.t.common.confirm),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirm() async {
    final timeRanges = _activeTimeRanges;
    if (_selectedDates.isEmpty || timeRanges.isEmpty) return;

    final count = _selectedDates.length * timeRanges.length;
    final confirmed = await Navigator.of(context).push<bool>(
      DialogRoute<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            dialogContext.t.classtable.classAdd.scheduleBuilder.confirmAddTitle,
          ),
          content: Text(
            dialogContext.t.classtable.classAdd.scheduleBuilder
                .confirmAddMessage(
                  date_count: _selectedDates.length,
                  time_count: timeRanges.length,
                  range_count: count,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogContext.t.common.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(dialogContext.t.common.confirm),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmed != true) return;

    final dates = _selectedDates.toList()..sort();
    final ranges = [
      for (final date in dates)
        for (final range in timeRanges)
          DateTimeRange(
            start: DateTime(
              date.year,
              date.month,
              date.day,
              range.start.hour,
              range.start.minute,
            ),
            end: DateTime(
              date.year,
              date.month,
              date.day,
              range.end.hour,
              range.end.minute,
            ),
          ),
    ];
    final conflictIndices = _findOverlapIndices(ranges);
    if (conflictIndices.isNotEmpty) {
      await _showOverlapDialog(conflictIndices, ranges);
      return;
    }
    Navigator.of(context).pop(ranges);
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                context.t.classtable.classAdd.scheduleBuilder.editRules,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildDateSummary() {
    if (_selectedDates.isEmpty) {
      return _EmptyRuleSummary(
        text: context.t.classtable.classAdd.scheduleBuilder.emptySelection,
      );
    }
    final dates = _selectedDates.toList()..sort();
    return M3ESegmentedColumn(
      outerRadius: _scheduleListTileOuterRadius,
      gap: 2,
      padding: EdgeInsets.zero,
      children: [
        for (final date in dates)
          M3EListItem(
            key: ValueKey(date),
            minHeight: _scheduleListTileHeight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            headline: Text(
              MaterialLocalizations.of(context).formatFullDate(date),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeSummary() {
    final selection = _timeSelection;
    if (selection == null || _activeTimeRanges.isEmpty) {
      return _EmptyRuleSummary(
        text: context.t.classtable.classAdd.scheduleBuilder.emptySelection,
      );
    }
    return ClassScheduleTimeSummary(selection: selection);
  }

  @override
  Widget build(BuildContext context) {
    final translations = context.t.classtable.classAdd.scheduleBuilder;
    final canConfirm =
        _selectedDates.isNotEmpty && _activeTimeRanges.isNotEmpty;

    return M3EBottomSheet(
      title: Text(translations.addTime),
      actions: [
        IconButton(
          onPressed: Navigator.of(context).pop,
          tooltip: context.t.common.cancel,
          icon: const Icon(Icons.close),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: translations.dateRules,
              onEdit: _editDates,
              child: _buildDateSummary(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: translations.timeRules,
              onEdit: _editTimes,
              child: _buildTimeSummary(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canConfirm ? _confirm : null,
              icon: const Icon(Icons.add),
              label: Text(translations.generateAndAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRuleSummary extends StatelessWidget {
  const _EmptyRuleSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    child: Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
