// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

class ClassTableController {
  static const decorationName = "decoration.jpg";
  static final ClassTableController i = ClassTableController._();
  bool _isReloading = false;

  ClassTableController._() {
    final cache = ClassTableSession.getCache();
    if (cache != null) {
      final cached = FetchResult.cache(fetchTime: cache.$1, data: cache.$2);
      _lastValidSchoolClassTable.value = cached;
      schoolClassTableStateSignal.value = AsyncState.data(cached);
    }
    _initEffects();
  }

  SemesterSyncEvent? _lastHandledSemesterSyncEvent;

  final _lastValidSchoolClassTable = signal<FetchResult<ClassTableData>?>(null);
  final schoolClassTableStateSignal =
      signal<AsyncState<FetchResult<ClassTableData>>>(const AsyncLoading());

  void _initEffects() {
    effect(() {
      final semesterChangeEvent =
          SemesterController.i.semesterSyncEventSignal.value;
      if (semesterChangeEvent == null ||
          identical(semesterChangeEvent, _lastHandledSemesterSyncEvent)) {
        return;
      }

      _lastHandledSemesterSyncEvent = semesterChangeEvent;
      if (semesterChangeEvent.didChange) {
        _lastValidSchoolClassTable.value = null;
        ClassTableSession.deleteCache();
        unawaited(CustomClassController.i.clearAll());
      }
      unawaited(reloadClassTable());
      log.info(
        "[ClassTableController][_initEffects] "
        "${semesterChangeEvent.didChange ? "Clear user defined classtable because semester changed" : "Reload classtable because semester synced"} "
        "from ${semesterChangeEvent.oldSemester} "
        "to ${semesterChangeEvent.effectiveSemester}.",
      );
    }, debugLabel: "ClassTableControllerSemesterChangeEffect");
  }

  Future<void> reloadClassTable() async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = _lastValidSchoolClassTable.value;
    schoolClassTableStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await getClassTable(
        SemesterController.i.semesterSignal.value,
      );
      _lastValidSchoolClassTable.value = result;
      schoolClassTableStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      schoolClassTableStateSignal.value = AsyncState.error(e, s);
      log.handle(
        e,
        s,
        "[ClassTableControllerNew][reloadClassTable] Have issue",
      );
    } finally {
      _isReloading = false;
    }
  }

  late final schoolClassTableComputedSignal = computed<ClassTableData>(
    () => _lastValidSchoolClassTable.value?.data ?? ClassTableData(),
  );

  late final classTableComputedSignal = computed<ClassTableData>(() {
    final networkClassTable = schoolClassTableComputedSignal.value;

    return ClassTableData(
      semesterLength: networkClassTable.semesterLength,
      semesterCode: networkClassTable.semesterCode,
      termStartDay: networkClassTable.termStartDay,
      classDetail: List<ClassDetail>.from(networkClassTable.classDetail),
      notArranged: List<NotArrangementClassDetail>.from(
        networkClassTable.notArranged,
      ),
      timeArrangement: List<TimeArrangement>.from(
        networkClassTable.timeArrangement,
      ),
      classChanges: List<ClassChange>.from(networkClassTable.classChanges),
    );
  });

  late final isClassTableFromCacheComputedSignal = computed(
    () => _lastValidSchoolClassTable.value?.isCache ?? false,
  );

  late final classTableFetchTimeComputedSignal = computed<DateTime?>(
    () => _lastValidSchoolClassTable.value?.fetchTime,
  );

  late final hasValidClassInfo = computed(
    () =>
        classTableFetchTimeComputedSignal.value != null ||
        classTableComputedSignal.value.classDetail.isNotEmpty ||
        classTableComputedSignal.value.timeArrangement.isNotEmpty,
  );

  late final classTableCacheHintKeyComputedSignal = computed<String?>(
    () => _lastValidSchoolClassTable.value?.hintKey,
  );

  late final startDayComputedSignal = computed<DateTime?>(() {
    final termStartDay = classTableComputedSignal.value.termStartDay;
    final weekSwift = WeekSwiftController.i.weekSwiftSignal.value;
    if (termStartDay.isEmpty) return null;

    return DateTime.parse(termStartDay).add(Duration(days: 7 * weekSwift));
  });

  int getCurrentWeek(DateTime time) {
    final startDay = startDayComputedSignal.value;
    if (startDay == null) return -1;

    int delta = time.difference(startDay).inDays;
    if (delta < 0) delta = -7;
    return delta ~/ 7;
  }

  late final currentWeekComputedSignal = computed<int>(() {
    return getCurrentWeek(GlobalTimerController.i.currentTimeSignal.value);
  });

  ClassDetail getClassDetail(TimeArrangement timeArrangementIndex) =>
      classTableComputedSignal.value.getClassDetail(timeArrangementIndex);

  List<HomeArrangement> getArrangementOfDay(DateTime updateTime) {
    final formatter = DateFormat(HomeArrangement.format);
    final currentWeek = currentWeekComputedSignal.value;
    final classTableData = classTableComputedSignal.value;
    final arrangementSet = <HomeArrangement>{};

    if (currentWeek < 0 || currentWeek >= classTableData.semesterLength) {
      return const <HomeArrangement>[];
    }

    for (final arrangement in classTableData.timeArrangement) {
      if (arrangement.weekList.length <= currentWeek ||
          !arrangement.weekList[currentWeek] ||
          arrangement.day != updateTime.weekday) {
        continue;
      }

      arrangementSet.add(
        HomeArrangement(
          name: getClassDetail(arrangement).name,
          teacher: arrangement.teacher,
          place: arrangement.classroom,
          startTimeStr: formatter.format(
            DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(timeList[(arrangement.start - 1) * 2].split(':')[0]),
              int.parse(timeList[(arrangement.start - 1) * 2].split(':')[1]),
            ),
          ),
          endTimeStr: formatter.format(
            DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(timeList[(arrangement.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(timeList[(arrangement.stop - 1) * 2 + 1].split(':')[1]),
            ),
          ),
        ),
      );
    }

    final result = arrangementSet.toList();
    result.sort((a, b) => a.startTime.compareTo(b.startTime));
    return result;
  }

  late final arrangementOfTodayComputedSignal = computed<List<HomeArrangement>>(
    () => getArrangementOfDay(GlobalTimerController.i.currentTimeSignal.value),
  );

  late final arrangementOfTomorrowComputedSignal =
      computed<List<HomeArrangement>>(
        () => getArrangementOfDay(
          GlobalTimerController.i.currentTimeSignal.value.add(
            const Duration(days: 1),
          ),
        ),
      );

  late final numberOfClassComputedSignal = computed<Map<String, int>>(() {
    final toReturn = <String, int>{};
    final classTableData = classTableComputedSignal.value;

    for (final arrangement in classTableData.timeArrangement) {
      final className = classTableData.getClassDetail(arrangement).name;
      final classCount = arrangement.weekList.where((ok) => ok).length;
      toReturn.update(
        className,
        (value) => value + classCount,
        ifAbsent: () => classCount,
      );
    }

    return toReturn;
  });

  late final havePhysicsExperimentSignal = computed<bool>(() {
    var classData = classTableComputedSignal.value;
    return classData.classDetail.any(
          (element) => element.name.contains("物理实验"),
        ) ||
        classData.notArranged.any((element) => element.name.contains("物理实验"));
  });
}
