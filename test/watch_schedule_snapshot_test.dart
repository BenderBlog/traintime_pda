// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/watch/watch_schedule_snapshot.dart';

void main() {
  test('expands only active course weeks into concrete watch events', () {
    final classTable = ClassTableData(
      semesterLength: 2,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
      classDetail: [ClassDetail(name: '计算机网络')],
      timeArrangement: [
        TimeArrangement(
          source: Source.school,
          index: 0,
          weekList: [true, false],
          teacher: '张老师',
          classroom: 'B-201',
          day: DateTime.monday,
          start: 1,
          stop: 2,
        ),
      ],
    );

    final snapshot = const WatchScheduleSnapshotBuilder().build(
      classTable: classTable,
      effectiveTermStart: DateTime(2026, 7, 20),
      currentWeekIndex: 0,
      now: DateTime(2026, 7, 20, 7),
      days: 14,
      reminderMinutes: 10,
    );

    expect(snapshot.courses, hasLength(1));
    expect(snapshot.courses.single.name, '计算机网络');
    expect(snapshot.courses.single.startAt, DateTime(2026, 7, 20, 8, 30));
    expect(snapshot.courses.single.endAt, DateTime(2026, 7, 20, 10, 5));
    expect(snapshot.courses.single.startSection, 1);
    expect(snapshot.courses.single.endSection, 2);
    expect(snapshot.courses.single.colorARGB, 0xFFF44336);
    expect(snapshot.reminderMinutes, 10);
    expect(snapshot.rangeStart, DateTime(2026, 7, 20));
    expect(snapshot.rangeEnd, DateTime(2026, 8, 3));
    expect(snapshot.semesterStart, DateTime(2026, 7, 20));
    expect(snapshot.currentWeekIndex, 0);
    expect(snapshot.toJson()['schemaVersion'], 4);
    expect(
      snapshot.toJson()['semesterStartEpochMs'],
      DateTime(2026, 7, 20).millisecondsSinceEpoch,
    );
    expect(snapshot.toJson()['currentWeekIndex'], 0);
  });

  test('includes user-defined courses in the rolling snapshot', () {
    final classTable = ClassTableData(
      semesterLength: 1,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
    );
    final customClass = CustomClass(
      id: 'cc-1',
      name: '自习',
      classroom: '图书馆',
      timeRanges: [
        CustomClassTimeRange(
          id: 'tr-1',
          startTime: DateTime(2026, 7, 22, 19),
          endTime: DateTime(2026, 7, 22, 19, 45),
        ),
      ],
    );

    final snapshot = const WatchScheduleSnapshotBuilder().build(
      classTable: classTable,
      effectiveTermStart: DateTime(2026, 7, 20),
      currentWeekIndex: 0,
      now: DateTime(2026, 7, 20),
      customClasses: [customClass],
      days: 7,
    );

    expect(snapshot.courses.single.name, '自习');
    expect(snapshot.courses.single.classroom, '图书馆');
    expect(snapshot.courses.single.startAt, DateTime(2026, 7, 22, 19));
    expect(snapshot.courses.single.endAt, DateTime(2026, 7, 22, 19, 45));
    expect(snapshot.courses.single.startSection, 9);
    expect(snapshot.courses.single.endSection, 9);
  });

  test('includes exams and experiments in the watch schedule', () {
    final classTable = ClassTableData(
      semesterLength: 2,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
    );
    final exam = Subject.generate(
      subject: '红外物理',
      typeStr: '期末考试',
      time: '2026-07-21 14:00-15:35',
      place: 'A-422',
      seat: '8',
    );
    final experiment = ExperimentData(
      type: ExperimentType.physics,
      name: '光学实验',
      classroom: 'B-301',
      timeRanges: [
        (DateTime(2026, 7, 22, 15, 55), DateTime(2026, 7, 22, 17, 30)),
      ],
      teacher: '张老师',
    );

    final snapshot = const WatchScheduleSnapshotBuilder().build(
      classTable: classTable,
      effectiveTermStart: DateTime(2026, 7, 20),
      currentWeekIndex: 0,
      now: DateTime(2026, 7, 20),
      days: 7,
      subjects: [exam],
      experiments: [experiment],
    );

    expect(snapshot.courses, hasLength(2));
    expect(snapshot.courses[0].kind, WatchScheduleEntryKind.exam);
    expect(snapshot.courses[0].name, '红外物理期末考试');
    expect(snapshot.courses[0].classroom, 'A-422');
    expect(snapshot.courses[0].note, '座位 8');
    expect(snapshot.courses[1].kind, WatchScheduleEntryKind.physicsExperiment);
    expect(snapshot.courses[1].name, '光学实验');
    expect(snapshot.courses[1].teacher, '张老师');
  });

  test('rejects a non-positive synchronization range', () {
    final classTable = ClassTableData(
      semesterLength: 1,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
    );

    expect(
      () => const WatchScheduleSnapshotBuilder().build(
        classTable: classTable,
        effectiveTermStart: DateTime(2026, 7, 20),
        currentWeekIndex: 0,
        now: DateTime(2026, 7, 20),
        days: 0,
      ),
      throwsArgumentError,
    );
  });

  test('keeps exams with the same subject and time but different seats', () {
    final classTable = ClassTableData(
      semesterLength: 1,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
    );
    final firstSeat = Subject.generate(
      subject: '大学物理',
      typeStr: '期末考试',
      time: '2026-07-21 14:00-15:35',
      place: 'A-422',
      seat: '8',
    );
    final secondSeat = Subject.generate(
      subject: '大学物理',
      typeStr: '期末考试',
      time: '2026-07-21 14:00-15:35',
      place: 'A-422',
      seat: '9',
    );

    final snapshot = const WatchScheduleSnapshotBuilder().build(
      classTable: classTable,
      effectiveTermStart: DateTime(2026, 7, 20, 12),
      currentWeekIndex: 0,
      now: DateTime(2026, 7, 20, 18),
      subjects: [firstSeat, secondSeat],
      days: 7,
    );

    expect(snapshot.semesterStart, DateTime(2026, 7, 20));
    expect(snapshot.rangeStart, DateTime(2026, 7, 20));
    expect(snapshot.courses, hasLength(2));
    expect(snapshot.courses.map((course) => course.id).toSet(), hasLength(2));
    expect(
      snapshot.courses.map((course) => course.note),
      containsAll(<String?>['座位 8', '座位 9']),
    );
  });

  test('keeps overlapping school arrangements with different rooms', () {
    final classTable = ClassTableData(
      semesterLength: 1,
      semesterCode: '2026-1',
      termStartDay: '2026-07-20 00:00:00',
      classDetail: [ClassDetail(name: '大学英语')],
      timeArrangement: [
        TimeArrangement(
          source: Source.school,
          index: 0,
          weekList: [true],
          teacher: '张老师',
          classroom: 'A-101',
          day: DateTime.monday,
          start: 1,
          stop: 2,
        ),
        TimeArrangement(
          source: Source.school,
          index: 0,
          weekList: [true],
          teacher: '李老师',
          classroom: 'B-202',
          day: DateTime.monday,
          start: 1,
          stop: 2,
        ),
      ],
    );

    final snapshot = const WatchScheduleSnapshotBuilder().build(
      classTable: classTable,
      effectiveTermStart: DateTime(2026, 7, 20),
      currentWeekIndex: 0,
      now: DateTime(2026, 7, 20),
      days: 7,
    );

    expect(snapshot.courses, hasLength(2));
    expect(snapshot.courses.map((course) => course.id).toSet(), hasLength(2));
    expect(
      snapshot.courses.map((course) => course.classroom),
      containsAll(<String?>['A-101', 'B-202']),
    );
  });
}
