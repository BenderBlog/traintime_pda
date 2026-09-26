// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_sheet.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/themes/color_seed.dart';

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

            /// No blur in here on purpose: this is a small static sample where the frosted look is
            /// barely legible, and a tableful of backdrop filters re-reading their backdrop on every
            /// frame is what made the settings page stutter while it scrolled.
            child: GlassBlurScope(
              enabled: false,
              child: ClassTableSheet(
                singleIndex: previewState.currentWeek,
                enableVerticalScrolling: false,
              ),
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

/// TODO: ClassTableWidgetState should be a abstrct class
class _PreviewClassTableState extends ClassTableWidgetState {
  static const _previewSemesterLength = 16;
  static const _previewCourses = <_PreviewCourse>[
    _PreviewCourse(
      name: "这里没有彩蛋",
      code: "There is no Easter Egg here",
      number: "果真没有彩蛋吗",
      teacher: "看来真的没有彩蛋",
      classroom: "没有彩蛋的地方",
      placement: _PreviewPlacement(day: 1, start: 1, stop: 4),
    ),
    _PreviewCourse(
      name: "方块建筑学的基本原理",
      code: "Shining MC 方块人之家",
      number: "684941112",
      teacher: "FlyingPig",
      classroom: "xducraft.cn",
      placement: _PreviewPlacement(day: 2, start: 3, stop: 7),
      interactive: true,
    ),
    _PreviewCourse(
      name: "Ego Eimi",
      code: "BV1H94y1Y72d",
      number: "MV",
      teacher: "BlackY feat. Risa Yuzuki",
      classroom: "Music Appreciation",
      placement: _PreviewPlacement(day: 3, start: 1, stop: 4),
      interactive: true,
    ),
    _PreviewCourse(
      name: "延安文艺研讨会",
      code: "亚托莉文艺部",
      number: "589443175",
      teacher: "鹿鸣学会举办",
      classroom: "网安大楼",
      placement: _PreviewPlacement(day: 1, start: 6, stop: 9),
      interactive: true,
    ),
    _PreviewCourse(
      name: "Sketches Of Spain",
      code: "Miles Davis",
      number: "CS 1480",
      teacher: "Teo Macero / Gil Evans",
      classroom: "Columbia CBS",
      placement: _PreviewPlacement(day: 3, start: 6, stop: 9),
      interactive: true,
    ),
    _PreviewCourse(
      name: "通信的基本原理",
      code: "无线电社团",
      number: "1013367376",
      teacher: "BI9CBK",
      classroom: "空中常见",
      placement: _PreviewPlacement(day: 4, start: 1, stop: 9),
      interactive: true,
    ),
    _PreviewCourse(
      name: "world.execute(me);",
      code: "BV1ds411e7df",
      number: "BV1sx411C75U",
      teacher: "ProjectMili",
      classroom: "Music Appreciation",
      placement: _PreviewPlacement(day: 5, start: 1, stop: 4),
      interactive: true,
    ),
    _PreviewCourse(
      name: "优秀百合作品欣赏",
      code: "Shining 幻想乡办事处",
      number: "345988348",
      teacher: "帕秋莉老师",
      classroom: "红魔乡图书馆",
      placement: _PreviewPlacement(day: 6, start: 1, stop: 4),
      interactive: true,
    ),
    _PreviewCourse(
      name: "Arcaea世界探索记录——从破碎世界到最低世界",
      code: "and in that light, I find deliverance",
      number: "Aegleseeker--ACT1-9",
      teacher: "拉格兰",
      classroom: "Arcaea",
      placement: _PreviewPlacement(day: 7, start: 3, stop: 7),
      interactive: true,
    ),
    _PreviewCourse(
      name: "Shelter",
      code: "BV1qbtLzdEAk",
      number: "345988348",
      teacher: "Porter Robinson, Madeon",
      classroom: "Music Appreciation",
      placement: _PreviewPlacement(day: 5, start: 6, stop: 9),
      interactive: true,
    ),
    _PreviewCourse(
      name: "本页面的来源",
      code: "traintime_pda",
      number: "PR 182",
      teacher: "Lagrange-X",
      classroom: "GitHub",
      interactive: true,
      placement: _PreviewPlacement(day: 6, start: 6, stop: 9),
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
  DateTime get startDay => DateTime(2026, 9, 7);

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
  List<ClassOrgainzedData> getArrangement({
    required int weekIndex,
    required int dayIndex,
  }) {
    return [
      for (final arrangement in timeArrangement)
        if (arrangement.weekList.length > weekIndex &&
            arrangement.weekList[weekIndex] &&
            arrangement.day == dayIndex)
          ClassOrgainzedData.fromTimeArrangement(
            arrangement,
            colorList[arrangement.index % colorList.length],
            getClassDetail(timeArrangement.indexOf(arrangement)).name,
          ),
    ];
  }

  @override
  DateTime get currentTime => DateTime(2026, 9, 17, 14, 00);
}
