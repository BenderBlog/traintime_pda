// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/model/classtable_file_constants.dart';
import 'package:watermeter/page/classtable/model/classtable_snapshot.dart';
import 'package:watermeter/page/classtable/model/classtable_source.dart';

typedef _Course = ({
  String name,
  String code,
  String number,
  String teacher,
  String classroom,
  int day,
  int start,
  int stop,
});

/// A sample class table, for the settings preview.
///
/// It answers the same port as the live data, so the preview runs the real table widgets without the
/// real controllers ever being read. Writes  are not supported and throw.
class PreviewClasstableDataSource extends ClasstableDataSource {
  PreviewClasstableDataSource() {
    _snapshot = ValueNotifier<ClasstableSnapshot>(_snapshotOf());
    _now = ValueNotifier<DateTime>(DateTime(2026, 9, 17, 14));
  }

  static const int _semesterLength = 16;

  late final ValueNotifier<ClasstableSnapshot> _snapshot;
  late final ValueNotifier<DateTime> _now;

  @override
  ValueListenable<ClasstableSnapshot> get snapshot => _snapshot;

  @override
  ValueListenable<DateTime> get now => _now;

  @override
  String get decorationFileName => classTableDecorationFileName;

  @override
  void dispose() {
    _snapshot.dispose();
    _now.dispose();
  }

  ClasstableSnapshot _snapshotOf() => ClasstableSnapshot(
    classTableData: ClassTableData(
      semesterLength: _semesterLength,
      termStartDay: "2026-09-07",
      classDetail: [
        for (final c in _courses)
          ClassDetail(name: c.name, code: c.code, number: c.number),
      ],
      timeArrangement: [
        for (var i = 0; i < _courses.length; i++)
          TimeArrangement(
            source: Source.school,
            index: i,
            weekList: List<bool>.filled(_semesterLength, false)..[1] = true,
            teacher: _courses[i].teacher,
            classroom: _courses[i].classroom,
            day: _courses[i].day,
            start: _courses[i].start,
            stop: _courses[i].stop,
          ),
      ],
    ),
    classTable: const ClassSourceStatus(),
    exam: const ClassSourceStatus(),
    physicsExperiment: const ClassSourceStatus(hasArrangement: false),
    otherExperiment: const ClassSourceStatus(hasArrangement: false),
    subjects: const [],
    experiments: const [],
    customClasses: const [],
    weekOffset: 0,
    hasExamArrangement: false,
    havePhysicsExperiment: false,
    haveOtherExperiment: false,
  );

  static const List<_Course> _courses = [
    (
      name: "这里没有彩蛋",
      code: "There is no Easter Egg here",
      number: "果真没有彩蛋吗",
      teacher: "看来真的没有彩蛋",
      classroom: "没有彩蛋的地方",
      day: 1,
      start: 1,
      stop: 4,
    ),
    (
      name: "红石电路基础",
      code: "Shining MC 方块人之家",
      number: "684941112",
      teacher: "FlyingPig",
      classroom: "xducraft.cn",
      day: 2,
      start: 3,
      stop: 7,
    ),
    (
      name: "Löschen",
      code: "BV1zD4y1F7xo",
      number: "MV",
      teacher: "BlackY feat. Risa Yuzuki",
      classroom: "Music Appreciation",
      day: 3,
      start: 1,
      stop: 4,
    ),
    (
      name: "延安文艺研讨会",
      code: "亚托莉文艺部",
      number: "589443175",
      teacher: "鹿鸣学会举办",
      classroom: "网安大楼",
      day: 1,
      start: 6,
      stop: 9,
    ),
    (
      name: "Give Me the Night",
      code: "George Benson",
      number: "HS 3453",
      teacher: "Quincy Jones",
      classroom: "Music Appreciation",
      day: 3,
      start: 6,
      stop: 9,
    ),
    (
      name: "通信的基本原理",
      code: "无线电社团",
      number: "1013367376",
      teacher: "BI9CBK",
      classroom: "空中常见",
      day: 4,
      start: 1,
      stop: 9,
    ),
    (
      name: "world.execute(me);",
      code: "BV1ds411e7df",
      number: "BV1sx411C75U",
      teacher: "ProjectMili",
      classroom: "Music Appreciation",
      day: 5,
      start: 1,
      stop: 4,
    ),
    (
      name: "优秀百合作品欣赏",
      code: "Shining 幻想乡办事处",
      number: "345988348",
      teacher: "帕秋莉老师",
      classroom: "红魔乡图书馆",
      day: 6,
      start: 1,
      stop: 4,
    ),
    (
      name: "空殻",
      code: "BV1h9Kb6nEYp",
      number: "MV",
      teacher: "Camellia feat. NANO",
      classroom: "In Falsus",
      day: 7,
      start: 3,
      stop: 7,
    ),
    (
      name: "Shelter",
      code: "BV1qbtLzdEAk",
      number: "345988348",
      teacher: "Porter Robinson, Madeon",
      classroom: "Music Appreciation",
      day: 5,
      start: 6,
      stop: 9,
    ),
    (
      name: "本页面的来源",
      code: "traintime_pda",
      number: "PR 182",
      teacher: "Lagrange-X",
      classroom: "GitHub",
      day: 6,
      start: 6,
      stop: 9,
    ),
  ];
}
