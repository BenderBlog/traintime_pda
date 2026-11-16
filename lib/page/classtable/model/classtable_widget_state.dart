// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/pda_service/custom_class_occurrence.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/model/class_organized_data.dart';
import 'package:watermeter/page/classtable/model/classtable_snapshot.dart';
import 'package:watermeter/page/classtable/model/classtable_source.dart';
import 'package:watermeter/page/classtable/model/classtable_status_source.dart';
import 'package:watermeter/page/classtable/model/style_config/class_card_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/class_table_background_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/current_time_indicator_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/glass_style_config.dart';
import 'package:watermeter/page/classtable/model/style_config/week_bar_style_config.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/system_calendar_sync_service.dart';
import 'package:watermeter/themes/color_seed.dart';

class ClasstableWidgetState with ChangeNotifier {
  ClasstableWidgetState({
    required ClasstableDataSource source,
    bool loadStyleSettings = true,
  }) : _source = source {
    _snapshot = source.snapshot.value;
    source.snapshot.addListener(_onSnapshot);
    if (loadStyleSettings) {
      CurrentTimeIndicatorConfig.loadFromPreference();
      ClassCardStyleConfig.loadFromPreference();
      GlassStyleConfig.loadFromPreference();
    }
    final int week = currentWeek;
    _chosenWeek = week < 0
        ? 0
        : math.min(week, math.max(0, semesterLength - 1));
    weekNavigationNotifier.value = _chosenWeek;
  }

  final ClasstableDataSource _source;
  late ClasstableSnapshot _snapshot;

  /// Notifies only when the visible week changes (tap or swipe), not on every data change.
  final ValueNotifier<int> weekNavigationNotifier = ValueNotifier<int>(0);

  /// The clock, straight from the source: the time indicator and the finished-card styling follow
  /// it without the data snapshot being rebuilt once a minute.
  ValueListenable<DateTime> get now => _source.now;

  DateTime get currentTime => now.value;

  @override
  void dispose() {
    _source.snapshot.removeListener(_onSnapshot);
    _source.dispose();
    weekNavigationNotifier.dispose();
    super.dispose();
  }

  void _onSnapshot() {
    _snapshot = _source.snapshot.value;
    _arrangementCache.clear();

    /// A new semester can be shorter than the week the user was looking at.
    final int maxWeek = math.max(0, semesterLength - 1);
    if (_chosenWeek > maxWeek) {
      _chosenWeek = maxWeek;
      weekNavigationNotifier.value = maxWeek;
    }
    notifyListeners();
  }

  ///*****************************///
  /// Data.                       ///
  ///*****************************///

  int get semesterLength => _snapshot.semesterLength;
  int get offset => _snapshot.weekOffset;
  String get semesterCode => _snapshot.semesterCode;
  bool get haveClass => _snapshot.hasData;
  int get currentWeek => _snapshot.weekOf(currentTime);

  bool get hasExamArrangement => _snapshot.hasExamArrangement;
  bool get hasExperimentArrangement => _snapshot.hasExperimentArrangement;

  /// The first day of the semester, before [offset].
  DateTime get startDay => _snapshot.gridStartDay ?? DateTime(2000);

  List<NotArrangementClassDetail> get notArranged =>
      _snapshot.classTableData.notArranged;
  List<TimeArrangement> get timeArrangement =>
      _snapshot.classTableData.timeArrangement;
  List<ClassChange> get classChange => _snapshot.classTableData.classChanges;
  List<CustomClass> get customClasses => _snapshot.customClasses;

  ClassDetail getClassDetail(int index) =>
      _snapshot.classTableData.getClassDetail(timeArrangement[index]);

  List<ClasstableStatusSource> get loadingSources => _snapshot.loadingSources;
  List<ClasstableStatusSource> get errorWithoutCacheSources =>
      _snapshot.errorWithoutCacheSources;
  List<ClasstableStatusSource> get errorWithCacheSources =>
      _snapshot.errorWithCacheSources;

  CacheHint? get classTableCacheHintKey => _snapshot.classTable.cacheHint;
  CacheHint? get examCacheHintKey => _snapshot.exam.cacheHint;
  CacheHint? get physicsExperimentCacheHintKey =>
      _snapshot.physicsExperiment.cacheHint;
  CacheHint? get otherExperimentCacheHintKey =>
      _snapshot.otherExperiment.cacheHint;

  /// Current showing week.
  int _chosenWeek = 0;

  int get chosenWeek => _chosenWeek;

  /// Change chosen week. Values outside the semester are clamped.
  set chosenWeek(int chosenWeek) {
    final int clamped = chosenWeek.clamp(0, math.max(0, semesterLength - 1));
    if (clamped == _chosenWeek) return;
    _chosenWeek = clamped;
    weekNavigationNotifier.value = clamped;
  }

  ///*****************************/ ///
  /// Writes: the only place that touches the table's data or settings. ///
  ///*****************************/ ///

  Future<void> addCustomClass(CustomClass customClass) =>
      _source.addCustomClass(customClass);

  Future<void> editCustomClassById(
    String customClassId,
    CustomClass customClass,
  ) => _source.editCustomClassById(customClassId, customClass);

  Future<void> deleteCustomClassById(String customClassId) =>
      _source.deleteCustomClassById(customClassId);

  Future<void> deleteCustomClassTimeRange({
    required String customClassId,
    required String timeRangeId,
  }) => _source.deleteCustomClassTimeRange(
    customClassId: customClassId,
    timeRangeId: timeRangeId,
  );

  /// Fresh ids for the add/edit form.
  String newCustomClassId() => _source.newCustomClassId();

  String newTimeRangeId() => _source.newTimeRangeId();

  bool get decorated => ClassTableBackgroundStyleConfig.decorated;

  /// The user defined background picture, or null when decoration is off or the file is gone.
  File? get decorationImage {
    return ClassTableBackgroundStyleConfig.image(
      directory: supportPath,
      fileName: _source.decorationFileName,
    );
  }

  /// Changes whenever the decoration picture is replaced, so the view can re-key its image.
  String? get decorationImageRevision {
    final image = decorationImage;
    return ClassTableBackgroundStyleConfig.imageRevision(image);
  }

  double get backgroundBlur => ClassTableBackgroundStyleConfig.blur;

  bool get weekBarCollapsed => WeekBarStyleConfig.collapsed;

  Future<void> setWeekBarCollapsed(bool collapsed) =>
      WeekBarStyleConfig.setCollapsed(collapsed);

  Future<void> applyCurrentTimeIndicatorStyle({
    required bool enabled,
    required bool showTimeLabel,
    required bool showTodayColumnHighlight,
  }) async {
    CurrentTimeIndicatorConfig.enabled = enabled;
    CurrentTimeIndicatorConfig.showTimeLabel = showTimeLabel;
    CurrentTimeIndicatorConfig.showTodayColumnHighlight =
        showTodayColumnHighlight;
    await CurrentTimeIndicatorConfig.saveToPreference();
    notifyListeners();
  }

  Future<void> applyCompletedClassStyle({
    required bool completedEnabled,
    required double activeBrightnessFactor,
    required double activeBorderAlpha,
    required double activeInnerAlpha,
    required double completedSaturationFactor,
    required double completedBrightnessFactor,
    required double completedTextSaturationFactor,
    required double completedBorderAlpha,
    required double completedInnerAlpha,
  }) async {
    ClassCardStyleConfig.completedEnabled = completedEnabled;
    ClassCardStyleConfig.activeBrightnessFactor = activeBrightnessFactor
        .clamp(0.5, 1.0)
        .toDouble();
    ClassCardStyleConfig.activeBorderAlpha = activeBorderAlpha;
    ClassCardStyleConfig.activeInnerAlpha = activeInnerAlpha;
    ClassCardStyleConfig.completedSaturationFactor = completedSaturationFactor;
    ClassCardStyleConfig.completedBrightnessFactor = completedBrightnessFactor
        .clamp(0.5, 1.0)
        .toDouble();
    ClassCardStyleConfig.completedTextSaturationFactor =
        completedTextSaturationFactor;
    ClassCardStyleConfig.completedBorderAlpha = completedBorderAlpha;
    ClassCardStyleConfig.completedInnerAlpha = completedInnerAlpha;
    await ClassCardStyleConfig.saveToPreference();
    notifyListeners();
  }

  ///*****************************/ ///
  /// Calendar export and refresh. ///
  ///*****************************/ ///

  String get iCalenderStr => buildICalendarString(
    buildCalendarEvents(
      classTableData: _snapshot.classTableData,
      subjects: _snapshot.subjects,
      experiments: _snapshot.experiments,
      customClasses: _snapshot.customClasses,
    ),
  );

  Future<bool> outputToCalendar(Future<void> Function() showDialog) =>
      SystemCalendarSyncService().syncSystemCalendar(
        requestPermissionsIfNeeded: true,
        onlyIfCalendarExists: false,
        showDialog: showDialog,
      );

  Future<void> updateClasstable() async {
    log.info("Updating time arrangement data...");
    await _source.refresh();
    await maybeAutoSyncSystemCalendar();
    notifyListeners();
  }

  ///*****************************/ ///
  /// Arrangement of a week and a day. ///
  ///*****************************/ ///

  /// Cached per week and day, so a rebuild does not re-sort and re-merge every card.
  final Map<(int, int), List<ClassOrgainzedData>> _arrangementCache = {};

  /// [weekIndex] starts from 0, [dayIndex] from 1.
  List<ClassOrgainzedData> getArrangement({
    required int weekIndex,
    required int dayIndex,
  }) {
    final cached = _arrangementCache[(weekIndex, dayIndex)];
    if (cached != null) return cached;

    final List<ClassOrgainzedData> events = [];
    final data = _snapshot.classTableData;
    final gridStartDay = _snapshot.gridStartDay;

    for (var index = 0; index < data.timeArrangement.length; index++) {
      final arrangement = data.timeArrangement[index];
      if (weekIndex >= 0 &&
          arrangement.weekList.length > weekIndex &&
          arrangement.weekList[weekIndex] &&
          arrangement.day == dayIndex) {
        events.add(
          ClassOrgainzedData.fromTimeArrangement(
            arrangement,
            colorList[index % colorList.length],
            data.getClassDetail(arrangement).name,
          ),
        );
      }
    }

    if (gridStartDay != null) {
      events.addAll(
        _eventsOnDay(_snapshot.subjects, gridStartDay, weekIndex, dayIndex),
      );
      events.addAll(
        _eventsOnDay(_snapshot.experiments, gridStartDay, weekIndex, dayIndex),
      );

      final occurrences = customClassOccurrencesForDay(
        classes: _snapshot.customClasses,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        semesterStartDay: gridStartDay,
      );
      for (final occurrence in occurrences) {
        final int colorIndex = _snapshot.customClasses.indexWhere(
          (item) => item.id == occurrence.customClass.id,
        );
        events.add(
          ClassOrgainzedData.fromCustomClass(
            colorList[math.max(0, colorIndex) % colorList.length],
            occurrence.customClass,
            occurrence.timeRange,
          ),
        );
      }
    }

    /// Sort it with the ascending order of start time, then merge whatever overlaps.
    events.sort((a, b) => a.start.compareTo(b.start));
    final List<ClassOrgainzedData> arranged = [];

    for (final event in events) {
      final overlapping = arranged.indexWhere(
        (other) => _checkIsOverlapping(
          other.start,
          other.stop,
          event.start,
          event.stop,
        ),
      );

      if (overlapping < 0) {
        arranged.add(event);
        continue;
      }

      final other = arranged[overlapping];
      final longerIsEvent =
          (event.stop - event.start) >= (other.stop - other.start);
      arranged[overlapping] = ClassOrgainzedData(
        start: math.min(event.start, other.start),
        stop: math.max(event.stop, other.stop),
        data: [...other.data, ...event.data],
        color: longerIsEvent ? event.color : other.color,
        name: longerIsEvent ? event.name : other.name,
        place: longerIsEvent ? event.place : other.place,
      );
    }

    _arrangementCache[(weekIndex, dayIndex)] = arranged;
    return arranged;
  }

  /// Exams and experiments, placed by their date rather than by period number.
  List<ClassOrgainzedData> _eventsOnDay(
    List<Object> items,
    DateTime gridStartDay,
    int weekIndex,
    int dayIndex,
  ) {
    final List<ClassOrgainzedData> events = [];

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final color = colorList[index % colorList.length];

      if (item is Subject) {
        final start = item.startTime;
        final stop = item.stopTime;
        if (start == null || stop == null || start.isBefore(gridStartDay)) {
          continue;
        }
        if (_isOnDay(start, gridStartDay, weekIndex, dayIndex)) {
          events.add(ClassOrgainzedData.fromSubject(color, item));
        }
      } else if (item is ExperimentData) {
        for (final range in item.timeRanges) {
          if (range.$1.isBefore(gridStartDay)) continue;
          if (_isOnDay(range.$1, gridStartDay, weekIndex, dayIndex)) {
            events.add(
              ClassOrgainzedData.fromExperiment(
                color,
                item,
                range.$1,
                range.$2,
              ),
            );
          }
        }
      }
    }

    return events;
  }

  bool _isOnDay(DateTime date, DateTime gridStartDay, int week, int day) {
    final int diff = date.difference(gridStartDay).inDays;
    return diff ~/ 7 == week && diff % 7 + 1 == day;
  }

  bool _checkIsOverlapping(
    double eStart1,
    double eEnd1,
    double eStart2,
    double eEnd2,
  ) =>
      (eStart1 >= eStart2 && eStart1 < eEnd2) ||
      (eEnd1 > eStart2 && eEnd1 <= eEnd2) ||
      (eStart2 >= eStart1 && eStart2 < eEnd1) ||
      (eEnd2 > eStart1 && eEnd2 <= eEnd1);
}
