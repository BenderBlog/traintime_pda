// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/class_add/date_selector_free.dart';

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
        msg: FlutterI18n.translate(
          context,
          "classtable.class_add.class_name_empty_message",
        ),
      );
      return;
    }

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
      body: Align(
        alignment: AlignmentGeometry.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_classname_hint",
                      ),
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
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_teacher_hint",
                      ),
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
                      hintText: FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_classroom_hint",
                      ),
                    ),
                  ).padding(vertical: inputFieldVerticalPadding),
                ],
              ).padding(vertical: 8),
              DateSelectorFree(
                initialDates: chosenDates,
                semesterStartDay: semesterStartDate,
                semesterLength: widget.semesterLength,
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
