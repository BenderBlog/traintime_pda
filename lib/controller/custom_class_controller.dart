// Copyright 2026 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:signals/signals.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/repository/network_session.dart';

enum CustomClassState { fetching, fetched, error, none }

class CustomClassOccurrence {
  final CustomClass customClass;
  final CustomClassTimeRange timeRange;

  const CustomClassOccurrence({
    required this.customClass,
    required this.timeRange,
  });
}

class CustomClassController {
  static final CustomClassController i = CustomClassController._();

  static const String _customClassFileName = 'CustomClassesV2.json';
  static const String _customClassIdPrefix = 'cc';
  static const String _timeRangeIdPrefix = 'tr';

  late File customClassFile;

  CustomClassController._() {
    customClassFile = File('${supportPath.path}/$_customClassFileName');
    _load();
  }

  int _idSequence = 0;

  String _nextId(String prefix) {
    final int now = DateTime.now().microsecondsSinceEpoch;
    _idSequence = (_idSequence + 1) & 0xFFFFF;
    return '$prefix-${now.toRadixString(36)}-${_idSequence.toRadixString(36)}';
  }

  String generateCustomClassId() => _nextId(_customClassIdPrefix);

  String generateTimeRangeId() => _nextId(_timeRangeIdPrefix);

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  final errorSignal = signal<String?>(null);
  final stateSignal = signal<CustomClassState>(CustomClassState.none);
  final customClassesSignal = signal<List<CustomClass>>([]);

  String? get error => errorSignal.value;

  CustomClassState get state => stateSignal.value;

  List<CustomClass> get customClasses => customClassesSignal.value;

  void _load() {
    stateSignal.value = CustomClassState.fetching;
    errorSignal.value = null;
    try {
      if (!customClassFile.existsSync()) {
        customClassFile.writeAsStringSync('[]');
      }
      final dynamic decoded = jsonDecode(customClassFile.readAsStringSync());
      customClassesSignal.value = (decoded as List<dynamic>)
          .map((e) => CustomClass.fromJson(e as Map<String, dynamic>))
          .toList();
      stateSignal.value = CustomClassState.fetched;
    } catch (e) {
      stateSignal.value = CustomClassState.error;
      errorSignal.value = e.toString();
      customClassesSignal.value = [];
    }
  }

  bool _save(List<CustomClass> nextClasses) {
    try {
      customClassFile.writeAsStringSync(
        jsonEncode(nextClasses.map((e) => e.toJson()).toList()),
      );
      customClassesSignal.value = nextClasses;
      errorSignal.value = null;
      stateSignal.value = CustomClassState.fetched;
      return true;
    } catch (e) {
      stateSignal.value = CustomClassState.error;
      errorSignal.value = 'Failed to save custom classes: $e';
      return false;
    }
  }

  int _indexOfCustomClassById(String customClassId) => customClasses.indexWhere(
    (customClass) => customClass.id == customClassId,
  );

  /// 添加新的自定义课程
  Future<void> addCustomClass(CustomClass customClass) async {
    final List<CustomClass> updated = List<CustomClass>.from(customClasses)
      ..add(customClass);
    _save(updated);
  }

  /// 编辑已有的自定义课程
  Future<void> editCustomClassById(
    String customClassId,
    CustomClass customClass,
  ) async {
    final int index = _indexOfCustomClassById(customClassId);
    if (index < 0) return;
    final List<CustomClass> updated = List<CustomClass>.from(customClasses);
    updated[index] = customClass;
    _save(updated);
  }

  /// 删除已有的自定义课程
  Future<void> deleteCustomClassById(String customClassId) async {
    final int index = _indexOfCustomClassById(customClassId);
    if (index < 0) return;
    final List<CustomClass> updated = List<CustomClass>.from(customClasses)
      ..removeAt(index);
    _save(updated);
  }

  /// 从已有的自定义课程中一处某个时间段
  Future<void> deleteCustomClassTimeRange({
    required String customClassId,
    required String timeRangeId,
  }) async {
    final int customIndex = _indexOfCustomClassById(customClassId);
    if (customIndex < 0) return;

    final CustomClass customClass = customClasses[customIndex];
    final int timeRangeIndex = customClass.timeRanges.indexWhere(
      (timeRange) => timeRange.id == timeRangeId,
    );
    if (timeRangeIndex < 0) return;

    final List<CustomClassTimeRange> updatedRanges =
        List<CustomClassTimeRange>.from(customClass.timeRanges)
          ..removeAt(timeRangeIndex);

    if (updatedRanges.isEmpty) {
      final List<CustomClass> updated = List<CustomClass>.from(customClasses)
        ..removeAt(customIndex);
      _save(updated);
      return;
    }

    final CustomClass updatedClass = CustomClass(
      id: customClass.id,
      name: customClass.name,
      teacher: customClass.teacher,
      classroom: customClass.classroom,
      timeRanges: updatedRanges,
    );
    final List<CustomClass> updated = List<CustomClass>.from(customClasses);
    updated[customIndex] = updatedClass;
    _save(updated);
  }

  /// 通过周索引、日索引和学期开始日期来找到有日程的那天
  List<CustomClassOccurrence> getOccurrenceOfDay({
    required int weekIndex,
    required int dayIndex,
    required DateTime semesterStartDay,
  }) {
    final List<CustomClassOccurrence> occurrences = [];

    for (final customClass in customClasses) {
      for (final timeRange in customClass.timeRanges) {
        final int diffDays = _dateOnly(
          timeRange.startTime,
        ).difference(_dateOnly(semesterStartDay)).inDays;
        if (diffDays < 0) continue;

        final int targetWeek = diffDays ~/ 7;
        final int targetDay = diffDays % 7 + 1;

        if (targetWeek == weekIndex && targetDay == dayIndex) {
          occurrences.add(
            CustomClassOccurrence(
              customClass: customClass,
              timeRange: timeRange,
            ),
          );
        }
      }
    }

    return occurrences;
  }
}
