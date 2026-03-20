// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/date_selector_free.dart';
import 'package:watermeter/page/classtable/class_add/week_selector.dart';
import 'package:watermeter/page/classtable/class_add/time_selector.dart';

class ClassAddWindow extends StatefulWidget {
  final (ClassDetail, TimeArrangement)? toChange;
  final CustomClass? customToChange;
  final int semesterLength;
  const ClassAddWindow({
    super.key,
    this.toChange,
    this.customToChange,
    required this.semesterLength,
  });

  @override
  State<ClassAddWindow> createState() => _ClassAddWindowState();
}

class _ClassAddWindowState extends State<ClassAddWindow> {
  bool useCustomDateFlow = false;

  late final CustomClassController customClassController;

  late List<bool> chosenWeek;
  late List<DateTimeRange> chosenDates;
  late TextEditingController classNameController;
  late TextEditingController teacherNameController;
  late TextEditingController classRoomController;

  late int week;
  late int start;
  late int stop;

  final double inputFieldVerticalPadding = 4;
  final double horizontalPadding = 10;

  late InputDecoration inputDecoration;

  Color get color => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    customClassController = CustomClassController.i;
    if (widget.customToChange != null) {
      useCustomDateFlow = true;
      classNameController = TextEditingController(
        text: widget.customToChange!.name,
      );
      teacherNameController = TextEditingController(
        text: widget.customToChange!.teacher,
      );
      classRoomController = TextEditingController(
        text: widget.customToChange!.classroom,
      );
      chosenWeek = List<bool>.generate(widget.semesterLength, (index) => false);
      chosenDates = widget.customToChange!.timeRanges
          .map((e) => DateTimeRange(start: e.startTime, end: e.endTime))
          .toList();
      week = 1;
      start = 1;
      stop = 1;
    } else if (widget.toChange == null) {
      classNameController = TextEditingController();
      teacherNameController = TextEditingController();
      classRoomController = TextEditingController();
      chosenWeek = List<bool>.generate(widget.semesterLength, (index) => false);
      chosenDates = [];
      week = 1;
      start = 1;
      stop = 1;
    } else {
      classNameController = TextEditingController(
        text: widget.toChange!.$1.name,
      );
      teacherNameController = TextEditingController(
        text: widget.toChange!.$2.teacher,
      );
      classRoomController = TextEditingController(
        text: widget.toChange!.$2.classroom,
      );
      chosenWeek = widget.toChange!.$2.weekList;
      chosenDates = [];
      week = widget.toChange!.$2.day;
      start = widget.toChange!.$2.start;
      stop = widget.toChange!.$2.stop;
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
        msg: FlutterI18n.translate(
          context,
          "classtable.class_add.class_name_empty_message",
        ),
      );
      return;
    }

    if (widget.customToChange != null ||
        (widget.toChange == null && useCustomDateFlow)) {
      if (chosenDates.isEmpty) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "classtable.class_add.choose_at_least_one",
          ),
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
            return CustomClassTimeRange(
              id:
                  existingRangeIds[key] ??
                  customClassController.generateTimeRangeId(),
              startTime: e.start,
              endTime: e.end,
            );
          }).toList(),
        );
        Navigator.of(context).pop(customClass);
      } catch (e) {
        showToast(context: context, msg: e.toString());
      }
      return;
    }

    if (!(week > 0 && week <= 7) || !(start <= stop)) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "classtable.class_add.wrong_time_message",
        ),
      );
      return;
    }

    if (widget.toChange == null) {
      Navigator.of(context).pop((
        ClassDetail(name: classNameController.text),
        TimeArrangement(
          source: Source.user,
          index: -1,
          teacher: teacherNameController.text.isNotEmpty
              ? teacherNameController.text
              : null,
          classroom: classRoomController.text.isNotEmpty
              ? classRoomController.text
              : null,
          weekList: chosenWeek,
          day: week,
          start: start,
          stop: stop,
        ),
      ));
    } else {
      Navigator.of(context).pop((
        widget.toChange!.$2,
        ClassDetail(name: classNameController.text),
        TimeArrangement(
          source: Source.user,
          index: widget.toChange!.$2.index,
          teacher: teacherNameController.text.isNotEmpty
              ? teacherNameController.text
              : null,
          classroom: classRoomController.text.isNotEmpty
              ? classRoomController.text
              : null,
          weekList: chosenWeek,
          day: week,
          start: start,
          stop: stop,
        ),
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.onPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.toChange == null && widget.customToChange == null
              ? FlutterI18n.translate(
                  context,
                  "classtable.class_add.add_class_title",
                )
              : FlutterI18n.translate(
                  context,
                  "classtable.class_add.change_class_title",
                ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              FlutterI18n.translate(
                context,
                "classtable.class_add.save_button",
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        children: [
          Column(
                children: [
                  TextField(
                    controller: classNameController,
                    decoration: inputDecoration.copyWith(
                      icon: Icon(Icons.calendar_month, color: color),
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_classname_hint",
                      ),
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                  TextField(
                    controller: teacherNameController,
                    decoration: inputDecoration.copyWith(
                      icon: Icon(Icons.person, color: color),
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_teacher_hint",
                      ),
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                  TextField(
                    controller: classRoomController,
                    decoration: inputDecoration.copyWith(
                      icon: Icon(Icons.place, color: color),
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_classroom_hint",
                      ),
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                ],
              )
              .padding(vertical: 8, horizontal: 16)
              .card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
          if (widget.toChange == null && widget.customToChange == null)
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.repeat),
                  label: Text(
                    FlutterI18n.translate(
                      context,
                      "classtable.class_add.repeat_weekly",
                    ),
                  ),
                ),
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.event),
                  label: Text(
                    FlutterI18n.translate(
                      context,
                      "classtable.class_add.free_time",
                    ),
                  ),
                ),
              ],
              selected: {useCustomDateFlow},
              onSelectionChanged: (selection) {
                setState(() {
                  useCustomDateFlow = selection.first;
                });
              },
            ).padding(vertical: 6),
          if (widget.toChange != null ||
              (widget.customToChange == null && !useCustomDateFlow)) ...[
            WeekSelector(
              initialWeeks: chosenWeek,
              onChanged: (weeks) {
                chosenWeek = weeks;
              },
              color: color,
            ),
            TimeSelector(
              initialWeek: week,
              initialStart: start,
              initialStop: stop,
              onChanged: (time) {
                week = time.$1;
                start = time.$2;
                stop = time.$3;
              },
              color: color,
            ),
          ] else
            DateSelectorFree(
              initialDates: chosenDates,
              onChanged: (dates) {
                chosenDates = dates;
              },
              color: color,
            ),
        ],
      ),
    );
  }
}
