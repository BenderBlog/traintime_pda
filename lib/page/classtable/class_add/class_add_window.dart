// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/class_add/class_schedule_bottom_sheet.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/generated/translations.g.dart';

const double _scheduleListTileHeight = 56;
const double _scheduleListTileOuterRadius = 12;

class ClassAddWindow extends StatefulWidget {
  final CustomClass? customToChange;
  final int semesterLength;
  const ClassAddWindow({
    super.key,
    this.customToChange,
    required this.semesterLength,
  });

  @override
  State<ClassAddWindow> createState() => _ClassAddWindowState();
}

class _ClassAddWindowState extends State<ClassAddWindow> {
  late final CustomClassController customClassController;

  late List<DateTimeRange> chosenDates;
  late TextEditingController classNameController;
  late TextEditingController teacherNameController;
  late TextEditingController classRoomController;

  final double inputFieldVerticalPadding = 4;
  final double horizontalPadding = 10;

  Color get color => Theme.of(context).colorScheme.primary;
  Color get deleteColor => Theme.of(context).colorScheme.error;

  DateTime get semesterStartDate {
    final String termStartDay =
        ClassTableController.i.classTableComputedSignal.value.termStartDay;
    return DateTime.tryParse(termStartDay) ??
        DateUtils.dateOnly(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    customClassController = CustomClassController.i;
    if (widget.customToChange != null) {
      final cc = widget.customToChange!;
      classNameController = TextEditingController(text: cc.name);
      teacherNameController = TextEditingController(text: cc.teacher);
      classRoomController = TextEditingController(text: cc.classroom);
      chosenDates = cc.timeRanges
          .map((e) => DateTimeRange(start: e.startTime, end: e.endTime))
          .toList();
    } else {
      classNameController = TextEditingController();
      teacherNameController = TextEditingController();
      classRoomController = TextEditingController();
      chosenDates = [];
    }
  }

  @override
  void dispose() {
    classNameController.dispose();
    teacherNameController.dispose();
    classRoomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (classNameController.text.isEmpty) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.classNameEmptyMessage,
      );
      return;
    }

    if (chosenDates.isEmpty) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.chooseAtLeastOne,
      );
      return;
    }

    try {
      final Map<String, List<String>> existingRangeIds = {};
      for (final range in widget.customToChange?.timeRanges ?? []) {
        final key =
            '${range.startTime.microsecondsSinceEpoch}-${range.endTime.microsecondsSinceEpoch}';
        existingRangeIds.putIfAbsent(key, () => []).add(range.id);
      }
      final customClass = CustomClass(
        id:
            widget.customToChange?.id ??
            customClassController.generateCustomClassId(),
        name: classNameController.text,
        teacher: teacherNameController.text.isNotEmpty
            ? teacherNameController.text
            : null,
        classroom: classRoomController.text.isNotEmpty
            ? classRoomController.text
            : null,
        timeRanges: chosenDates.map((e) {
          final String key =
              '${e.start.microsecondsSinceEpoch}-${e.end.microsecondsSinceEpoch}';
          final ids = existingRangeIds[key];
          return CustomClassTimeRange(
            id: ids != null && ids.isNotEmpty
                ? ids.removeAt(0)
                : customClassController.generateTimeRangeId(),
            startTime: e.start,
            endTime: e.end,
          );
        }).toList(),
      );
      Navigator.of(context).pop(customClass);
    } catch (e) {
      showToast(context: context, msg: e.toString());
    }
  }

  Future<void> _openScheduleSheet() async {
    // 使用封装的模态路由入栈
    final ranges = await ClassScheduleBottomSheet.push(
      context,
      semesterStartDay: semesterStartDate,
      semesterLength: widget.semesterLength,
      existingRanges: chosenDates,
    );
    if (!mounted || ranges == null) return;
    setState(() => chosenDates.addAll(ranges));
  }

  Widget _buildScheduleList() {
    // 以日期为依据分组
    final groupedIndices = <DateTime, List<int>>{};
    for (var index = 0; index < chosenDates.length; index++) {
      final day = DateUtils.dateOnly(chosenDates[index].start);
      groupedIndices.putIfAbsent(day, () => []).add(index);
    }
    // 对组内的时间段以开始时间为依据排序
    for (final indices in groupedIndices.values) {
      indices.sort(
        (a, b) => chosenDates[a].start.compareTo(chosenDates[b].start),
      );
    }
    final days = groupedIndices.keys.toList()..sort();
    final localizations = MaterialLocalizations.of(context);
    final translations = context.t.classtable.classAdd.scheduleBuilder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 12, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.event_note_outlined, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                translations.scheduleListTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
        for (final day in days) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              localizations.formatFullDate(day),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          M3ESegmentedColumn(
            outerRadius: _scheduleListTileOuterRadius,
            gap: 2,
            padding: EdgeInsets.zero,
            children: [
              for (final index in groupedIndices[day]!)
                M3EListItem(
                  key: ValueKey('schedule-$index'),
                  minHeight: _scheduleListTileHeight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  trailingSpacing: 8,
                  headline: Text(
                    '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(chosenDates[index].start), alwaysUse24HourFormat: true)}–${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(chosenDates[index].end), alwaysUse24HourFormat: true)}',
                  ),
                  trailing: IconButton(
                    onPressed: () =>
                        setState(() => chosenDates.removeAt(index)),
                    tooltip: context.t.classtable.courseDetailCard.delete,
                    icon: Icon(Icons.delete_outline, color: deleteColor),
                  ),
                ),
            ],
          ),
        ],
        if (days.isEmpty)
          Center(
            child: Text(
              t.classtable.classAdd.scheduleBuilder.emptySelection,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _openScheduleSheet,
          icon: const Icon(Icons.add),
          label: Text(translations.addTime),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder inputEnabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color.withValues(alpha: 0.25)),
    );
    final OutlineInputBorder inputFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.2),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customToChange == null
              ? context.t.classtable.classAdd.addClassTitle
              : context.t.classtable.classAdd.changeClassTitle,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(context.t.classtable.classAdd.saveButton),
          ),
        ],
      ),
      body: Align(
        alignment: AlignmentGeometry.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ).withSafeBottom(context),
            children: [
              Column(
                children: [
                  TextField(
                    controller: classNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.book, color: color),
                      enabledBorder: inputEnabledBorder,
                      focusedBorder: inputFocusedBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      hintText:
                          context.t.classtable.classAdd.inputClassnameHint,
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                  TextField(
                    controller: teacherNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: color),
                      enabledBorder: inputEnabledBorder,
                      focusedBorder: inputFocusedBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      hintText: context.t.classtable.classAdd.inputTeacherHint,
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                  TextField(
                    controller: classRoomController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place, color: color),
                      enabledBorder: inputEnabledBorder,
                      focusedBorder: inputFocusedBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      hintText:
                          context.t.classtable.classAdd.inputClassroomHint,
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                ],
              ).padding(vertical: 8),
              _buildScheduleList(),
            ],
          ),
        ),
      ),
    );
  }
}
