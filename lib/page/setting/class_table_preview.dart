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
      name: "这里没有彩蛋",
      code: "There is no Easter Egg here",
      number: "果真没有彩蛋吗",
      teacher: "看来真的没有彩蛋",
      classroom: "没有彩蛋的地方",
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
      name: "三线操作实战",
      code: "致命冲击",
      number: "S23",
      teacher: "苏联将军",
      classroom: "莫斯科郊外",
      placement: _PreviewPlacement(day: 1, start: 5, stop: 7),
      interactive: true,
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
      name: "论XDYou是怎样炼成的",
      code: "traintime_pda",
      number: "7d7ed22",
      teacher: "BenderBlog",
      classroom: "GitHub",
      placement: _PreviewPlacement(day: 4, start: 1, stop: 7),
      interactive: true,
    ),
    _PreviewCourse(
      name: "world.execute(me);",
      code: "BV1ds411e7df",
      number: "BV1sx411C75U",
      teacher: "ProjectMili",
      classroom: "Song",
      placement: _PreviewPlacement(day: 5, start: 1, stop: 2),
      interactive: true,
    ),
    _PreviewCourse(
      name: "world.search(me);",
      code: "bgqqAi9o",
      number: "Null",
      teacher: "ProjectMili",
      classroom: "Song",
      placement: _PreviewPlacement(day: 6, start: 1, stop: 2),
      interactive: true,
    ),
    _PreviewCourse(
      name: "Arcaea世界探索记录——从破碎世界到最低世界",
      code: "and in that light, I find deliverance",
      number: "Aegleseeker--ACT1-9",
      teacher: "拉格兰",
      classroom: "Arcaea",
      placement: _PreviewPlacement(day: 7, start: 2, stop: 6),
      interactive: true,
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
