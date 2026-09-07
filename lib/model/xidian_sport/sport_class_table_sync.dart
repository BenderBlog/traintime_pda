// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';

ClassTableData mergeSportClassLocations({
  required ClassTableData classTable,
  required Iterable<SportClassItem> sportClasses,
}) {
  final locations = <(String, String, int, int, int), Set<String>>{};

  for (final sportClass in sportClasses) {
    final place = sportClass.place.trim();
    final teacher = _normalizeTeacher(sportClass.teacher);
    if (sportClass.term != classTable.semesterCode ||
        teacher.isEmpty ||
        place.isEmpty) {
      continue;
    }

    final key = (
      sportClass.term,
      teacher,
      sportClass.week,
      sportClass.start,
      sportClass.stop,
    );
    locations.putIfAbsent(key, () => <String>{}).add(place);
  }

  final timeArrangement = classTable.timeArrangement
      .map(_copyTimeArrangement)
      .toList();

  for (final arrangement in timeArrangement) {
    if (arrangement.source != Source.school ||
        arrangement.classroom?.trim().isNotEmpty == true ||
        arrangement.index < 0 ||
        arrangement.index >= classTable.classDetail.length) {
      continue;
    }

    final key = (
      classTable.semesterCode,
      _normalizeTeacher(arrangement.teacher),
      arrangement.day,
      arrangement.start,
      arrangement.stop,
    );
    final matchedLocations = locations[key];
    if (matchedLocations?.length == 1) {
      arrangement.classroom = matchedLocations!.single;
    }
  }

  return ClassTableData(
    semesterLength: classTable.semesterLength,
    semesterCode: classTable.semesterCode,
    termStartDay: classTable.termStartDay,
    classDetail: classTable.classDetail.map(ClassDetail.from).toList(),
    notArranged: classTable.notArranged
        .map(NotArrangementClassDetail.from)
        .toList(),
    timeArrangement: timeArrangement,
    classChanges: List<ClassChange>.from(classTable.classChanges),
  );
}

String _normalizeTeacher(String? teacher) =>
    (teacher ?? '').replaceAll(RegExp(r'\s+'), '');

TimeArrangement _copyTimeArrangement(TimeArrangement arrangement) =>
    TimeArrangement(
      source: arrangement.source,
      index: arrangement.index,
      weekList: List<bool>.from(arrangement.weekList),
      classroom: arrangement.classroom,
      teacher: arrangement.teacher,
      day: arrangement.day,
      start: arrangement.start,
      stop: arrangement.stop,
    );
