// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassTablePreview extends StatefulWidget {
  final bool loadStylePreferences;

  const ClassTablePreview({super.key, this.loadStylePreferences = true});

  @override
  State<ClassTablePreview> createState() => _ClassTablePreviewState();
}

class _ClassTablePreviewState extends State<ClassTablePreview> {
  @override
  void initState() {
    super.initState();
    if (widget.loadStylePreferences) {
      CurrentTimeIndicatorConfig.loadFromPreference();
      CompletedClassStyleConfig.loadFromPreference();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: LayoutBuilder(
        builder: (context, constraint) {
          final previewState = _PreviewClassTableState();
          return ClassTableState(
            constraints: constraint,
            controllers: previewState,
            child: ClassTableView(
              index: previewState.currentWeek,
              constraint: constraint,
              enableVerticalScrolling: false,
            ),
          );
        },
      ),
    );
  }
}

class _PreviewPlacement {
  final int day;
  final int start;
  final int stop;

  const _PreviewPlacement({
    required this.day,
    required this.start,
    required this.stop,
  });
}

class _PreviewCourse {
  final String name;
  final String code;
  final String number;
  final String teacher;
  final String classroom;
  final _PreviewPlacement placement;
  final bool interactive;

  const _PreviewCourse({
    required this.name,
    required this.code,
    required this.number,
    required this.teacher,
    required this.classroom,
    required this.placement,
    this.interactive = false,
  });
}

class _PreviewClassTableState extends ClassTableWidgetState {
  static const _previewSemesterLength = 16;
  static const _previewCourses = <_PreviewCourse>[
    _PreviewCourse(
      name: "测试课程 1",
      code: "TEST-01",
      number: "测试班级 1",
      teacher: "测试教师 1",
      classroom: "测试教室 1",
      placement: _PreviewPlacement(day: 1, start: 1, stop: 3),
    ),
    _PreviewCourse(
      name: "测试课程 2",
      code: "TEST-02",
      number: "测试班级 2",
      teacher: "测试教师 2",
      classroom: "测试教室 2",
      placement: _PreviewPlacement(day: 3, start: 1, stop: 3),
    ),
    _PreviewCourse(
      name: "测试课程 3",
      code: "TEST-03",
      number: "测试班级 3",
      teacher: "测试教师 3",
      classroom: "测试教室 3",
      placement: _PreviewPlacement(day: 2, start: 3, stop: 5),
    ),
    _PreviewCourse(
      name: "测试课程 4",
      code: "TEST-04",
      number: "测试班级 4",
      teacher: "测试教师 4",
      classroom: "测试教室 4",
      placement: _PreviewPlacement(day: 1, start: 5, stop: 7),
    ),
    _PreviewCourse(
      name: "测试课程 5",
      code: "TEST-05",
      number: "测试班级 5",
      teacher: "测试教师 5",
      classroom: "测试教室 5",
      placement: _PreviewPlacement(day: 3, start: 5, stop: 7),
    ),
    _PreviewCourse(
      name: "预览测试 6",
      code: "TEST-06",
      number: "这是一个彩蛋",
      teacher: "测试教师 6",
      classroom: "测试教室 6",
      placement: _PreviewPlacement(day: 4, start: 1, stop: 7),
      interactive: true,
    ),
    _PreviewCourse(
      name: "测试课程 7",
      code: "TEST-07",
      number: "测试班级 7",
      teacher: "测试教师 7",
      classroom: "测试教室 7",
      placement: _PreviewPlacement(day: 5, start: 1, stop: 2),
    ),
    _PreviewCourse(
      name: "测试课程 8",
      code: "TEST-08",
      number: "测试班级 8",
      teacher: "测试教师 8",
      classroom: "测试教室 8",
      placement: _PreviewPlacement(day: 6, start: 1, stop: 2),
    ),
    _PreviewCourse(
      name: "测试课程 9",
      code: "TEST-09",
      number: "测试班级 9",
      teacher: "测试教师 9",
      classroom: "测试教室 9",
      placement: _PreviewPlacement(day: 7, start: 2, stop: 6),
    ),
    _PreviewCourse(
      name: "测试课程 10",
      code: "TEST-10",
      number: "测试班级 10",
      teacher: "测试教师 10",
      classroom: "测试教室 10",
      placement: _PreviewPlacement(day: 5, start: 6, stop: 7),
    ),
    _PreviewCourse(
      name: "测试课程 11",
      code: "TEST-11",
      number: "测试班级 11",
      teacher: "测试教师 11",
      classroom: "测试教室 11",
      placement: _PreviewPlacement(day: 6, start: 6, stop: 7),
    ),
  ];

  late final List<ClassDetail> _previewClassDetails = List.generate(
    _previewCourses.length,
    (index) => ClassDetail(
      name: _previewCourses[index].name,
      code: _previewCourses[index].code,
      number: _previewCourses[index].number,
    ),
  );

  late final List<TimeArrangement> _previewTimeArrangements = [
    for (var index = 0; index < _previewCourses.length; index++)
      _arrangement(course: _previewCourses[index], index: index),
  ];

  TimeArrangement _arrangement({
    required _PreviewCourse course,
    required int index,
  }) {
    return TimeArrangement(
      source: Source.school,
      index: index,
      weekList: List<bool>.filled(_previewSemesterLength, false)..[1] = true,
      teacher: course.teacher,
      classroom: course.classroom,
      day: course.placement.day,
      start: course.placement.start,
      stop: course.placement.stop,
    );
  }

  @override
  int get offset => 0;

  @override
  int get semesterLength => _previewSemesterLength;

  @override
  int get currentWeek => 1;

  @override
  List<ClassDetail> get classDetail => _previewClassDetails;

  @override
  List<TimeArrangement> get timeArrangement => _previewTimeArrangements;

  @override
  ClassDetail getClassDetail(int index) =>
      _previewClassDetails[_previewTimeArrangements[index].index];

  @override
  bool isClassCardInteractive(ClassOrgainzedData detail) {
    final arrangements = detail.data.whereType<TimeArrangement>();
    return arrangements.isNotEmpty &&
        arrangements.every(
          (arrangement) => _previewCourses[arrangement.index].interactive,
        );
  }

  @override
  List<Subject> get subjects => const [];

  @override
  List<ExperimentData> get experiments => const [];

  @override
  DateTime get currentTime =>
      startDay.add(const Duration(days: 9, hours: 10, minutes: 24));
}
