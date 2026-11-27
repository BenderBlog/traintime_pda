// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/class_add/date_selector_free.dart';
import 'package:watermeter/page/classtable/class_add/week_selector.dart';
import 'package:watermeter/page/classtable/class_add/time_selector.dart';
import 'package:watermeter/generated/translations.g.dart';

enum _ScheduleInputMode { exactDates, weekly }

class ClassAddWindow extends StatefulWidget {
  final ClasstableWidgetState state;
  final CustomClass? customToChange;

  const ClassAddWindow({super.key, required this.state, this.customToChange});

  @override
  State<ClassAddWindow> createState() => _ClassAddWindowState();
}

class _ClassAddWindowState extends State<ClassAddWindow> {
  late List<DateTimeRange> chosenDates;
  late TextEditingController classNameController;
  late TextEditingController teacherNameController;
  late TextEditingController classRoomController;
  late List<bool> chosenWeeks;
  _ScheduleInputMode scheduleInputMode = _ScheduleInputMode.exactDates;
  late int selectedWeekday;
  TimeOfDay selectedStartTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 9, minute: 15);

  final double inputFieldVerticalPadding = 4;
  final double horizontalPadding = 10;

  Color get color => Theme.of(context).colorScheme.primary;
  Color get deleteColor => Theme.of(context).colorScheme.error;
  bool get canUseWeeklySchedule =>
      widget.state.haveClass &&
      widget.state.semesterLength > 0 &&
      widget.state.startDay.year != 2000;

  @override
  void initState() {
    super.initState();
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
    final semesterWeekCount = widget.state.semesterLength;
    chosenWeeks = List<bool>.generate(
      semesterWeekCount,
      (index) => index == widget.state.chosenWeek,
    );
    selectedWeekday = DateTime.now().weekday;
    if (widget.customToChange == null && canUseWeeklySchedule) {
      scheduleInputMode = _ScheduleInputMode.weekly;
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

    if (scheduleInputMode == _ScheduleInputMode.weekly) {
      final startMinutes =
          selectedStartTime.hour * 60 + selectedStartTime.minute;
      final endMinutes = selectedEndTime.hour * 60 + selectedEndTime.minute;
      if (startMinutes < 8 * 60 + 30 ||
          startMinutes > 21 * 60 + 25 ||
          endMinutes < 8 * 60 + 30 ||
          endMinutes > 21 * 60 + 25) {
        showToast(
          context: context,
          msg: context.t.classtable.classAdd.dateSelectorFree.rule,
        );
        return;
      }
      if (endMinutes <= startMinutes) {
        showToast(
          context: context,
          msg: context.t.classtable.classAdd.dateSelectorFree.rule2,
        );
        return;
      }
    }

    final List<DateTimeRange> datesToSave =
        scheduleInputMode == _ScheduleInputMode.weekly
        ? _generateWeeklyDates()
        : chosenDates;

    if (datesToSave.isEmpty) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.chooseAtLeastOne,
      );
      return;
    }

    try {
      final Map<String, String> existingRangeIds = <String, String>{
        for (final range in widget.customToChange?.timeRanges ?? [])
          '${range.startTime.microsecondsSinceEpoch}-${range.endTime.microsecondsSinceEpoch}':
              range.id,
      };
      final customClass = CustomClass(
        id: widget.customToChange?.id ?? widget.state.newCustomClassId(),
        name: classNameController.text,
        teacher: teacherNameController.text.isNotEmpty
            ? teacherNameController.text
            : null,
        classroom: classRoomController.text.isNotEmpty
            ? classRoomController.text
            : null,
        timeRanges: datesToSave.map((e) {
          final String key =
              '${e.start.microsecondsSinceEpoch}-${e.end.microsecondsSinceEpoch}';
          return CustomClassTimeRange(
            id: existingRangeIds[key] ?? widget.state.newTimeRangeId(),
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

  List<DateTimeRange> _generateWeeklyDates() {
    final List<DateTimeRange> dates = [];
    final DateTime semesterStart = widget.state.startDay;
    for (var week = 0; week < chosenWeeks.length; week++) {
      if (!chosenWeeks[week]) continue;

      final DateTime day = semesterStart.add(
        Duration(days: week * 7 + selectedWeekday - 1),
      );
      dates.add(
        DateTimeRange(
          start: DateTime(
            day.year,
            day.month,
            day.day,
            selectedStartTime.hour,
            selectedStartTime.minute,
          ),
          end: DateTime(
            day.year,
            day.month,
            day.day,
            selectedEndTime.hour,
            selectedEndTime.minute,
          ),
        ),
      );
    }
    return dates;
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
              if (canUseWeeklySchedule && widget.customToChange == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(context.t.classtable.classAdd.repeatWeekly),
                        selected:
                            scheduleInputMode == _ScheduleInputMode.weekly,
                        onSelected: (_) => setState(
                          () => scheduleInputMode = _ScheduleInputMode.weekly,
                        ),
                      ),

                      ChoiceChip(
                        label: Text(context.t.classtable.classAdd.freeTime),
                        selected:
                            scheduleInputMode == _ScheduleInputMode.exactDates,
                        onSelected: (_) => setState(
                          () =>
                              scheduleInputMode = _ScheduleInputMode.exactDates,
                        ),
                      ),
                    ],
                  ),
                ),
              if (scheduleInputMode == _ScheduleInputMode.weekly) ...[
                WeekSelector(
                  key: const ValueKey('weekly-class-weeks'),
                  initialWeeks: chosenWeeks,
                  onChanged: (weeks) => chosenWeeks = List<bool>.from(weeks),
                  color: color,
                ),
                TimeSelector(
                  initialWeekday: selectedWeekday,
                  initialStartTime: selectedStartTime,
                  initialEndTime: selectedEndTime,
                  onChanged: (selection) {
                    selectedWeekday = selection.$1;
                    selectedStartTime = selection.$2;
                    selectedEndTime = selection.$3;
                  },
                  color: color,
                ),
              ] else
                DateSelectorFree(
                  initialDates: chosenDates,
                  semesterStartDay: widget.state.startDay,
                  semesterLength: widget.state.semesterLength,
                  onChanged: (dates) {
                    chosenDates = dates;
                  },
                  color: color,
                  deleteColor: deleteColor,
                  enableBorder: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
