// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/model/xidian_sport/sport_class_table_sync.dart';

void main() {
  SportClassItem sportClass({
    String termName = '2025-2026第1学期',
    String teacher = '张老师',
    String time = '星期一12',
    String place = '体育馆',
  }) {
    return SportClassItem.fromData(
      termName: termName,
      name: '篮球',
      score: '',
      type: '体育',
      teacher: teacher,
      time: time,
      place: place,
    );
  }

  ClassTableData classTable({
    String teacher = '张老师',
    String? classroom,
    int start = 1,
    int stop = 2,
  }) {
    return ClassTableData(
      semesterLength: 16,
      semesterCode: '2025-2026-1',
      termStartDay: '2026-02-23',
      classDetail: [ClassDetail(name: '篮球', code: 'PE001')],
      timeArrangement: [
        TimeArrangement(
          source: Source.school,
          index: 0,
          weekList: List<bool>.filled(16, true),
          teacher: teacher,
          day: 1,
          start: start,
          stop: stop,
          classroom: classroom,
        ),
      ],
    );
  }

  test('fills an empty classroom after all four checks match', () {
    final source = classTable();

    final result = mergeSportClassLocations(
      classTable: source,
      sportClasses: [sportClass()],
    );

    expect(result.timeArrangement.single.classroom, '体育馆');
    expect(source.timeArrangement.single.classroom, isNull);
  });

  test('does not fill when term, teacher, or period does not match', () {
    final source = classTable();

    final result = mergeSportClassLocations(
      classTable: source,
      sportClasses: [
        sportClass(termName: '2024-2025第2学期'),
        sportClass(teacher: '李老师'),
        sportClass(time: '星期二12'),
        sportClass(time: '星期一23'),
      ],
    );

    expect(result.timeArrangement.single.classroom, isNull);
  });

  test('keeps an existing classroom and skips conflicting sport locations', () {
    final existing = classTable(classroom: '教学楼A');
    final existingResult = mergeSportClassLocations(
      classTable: existing,
      sportClasses: [sportClass(place: '体育馆')],
    );
    expect(existingResult.timeArrangement.single.classroom, '教学楼A');

    final conflicting = mergeSportClassLocations(
      classTable: classTable(),
      sportClasses: [
        sportClass(place: '体育馆'),
        sportClass(place: '操场'),
      ],
    );
    expect(conflicting.timeArrangement.single.classroom, isNull);
  });

  test('applies one sport location to all matching class arrangements', () {
    final source = classTable()
      ..timeArrangement.add(
        TimeArrangement(
          source: Source.school,
          index: 0,
          weekList: List<bool>.filled(16, false),
          teacher: '张 老师',
          day: 1,
          start: 1,
          stop: 2,
        ),
      );

    final result = mergeSportClassLocations(
      classTable: source,
      sportClasses: [sportClass()],
    );

    expect(
      result.timeArrangement.map((arrangement) => arrangement.classroom),
      everyElement('体育馆'),
    );
  });
}
