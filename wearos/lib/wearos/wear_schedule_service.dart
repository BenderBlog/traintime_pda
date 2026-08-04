import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/wearos/wear_cache_store.dart';

typedef ClassTableCacheLoader = ClassTableData? Function(String semesterCode);
typedef ExperimentCacheLoader = List<ExperimentData>? Function();

Future<void> clearWearCampusCaches() async {
  await WearClassTableCache.clear();
  await WearExperimentCache.clear();
}

enum WearAgendaKind { course, otherExperiment }

class WearAgendaItem {
  final WearAgendaKind kind;
  final String title;
  final String? subtitle;
  final String? location;
  final DateTime start;
  final DateTime end;

  const WearAgendaItem({
    required this.kind,
    required this.title,
    required this.start,
    required this.end,
    this.subtitle,
    this.location,
  });
}

class WearHomeData {
  final List<WearAgendaItem> todayItems;
  final List<WearAgendaItem> tomorrowItems;

  const WearHomeData({required this.todayItems, required this.tomorrowItems});
}

class WearAgendaBuilder {
  const WearAgendaBuilder._();

  static List<WearAgendaItem> courseItemsForDay(
    ClassTableData table,
    DateTime day,
  ) {
    final weekIndex = weekIndexForDay(table, day);
    if (weekIndex < 0 || weekIndex >= table.semesterLength) {
      return const <WearAgendaItem>[];
    }

    final items = <WearAgendaItem>[];
    for (final arrangement in table.timeArrangement) {
      if (arrangement.source == Source.empty ||
          arrangement.day != day.weekday ||
          arrangement.weekList.length <= weekIndex ||
          !arrangement.weekList[weekIndex]) {
        continue;
      }

      final startIndex = (arrangement.start - 1) * 2;
      final endIndex = (arrangement.stop - 1) * 2 + 1;
      if (startIndex < 0 || endIndex >= timeList.length) continue;

      final ClassDetail detail;
      try {
        detail = table.getClassDetail(arrangement);
      } on Object {
        continue;
      }

      items.add(
        WearAgendaItem(
          kind: WearAgendaKind.course,
          title: detail.name,
          subtitle: _blankToNull(arrangement.teacher),
          location: _blankToNull(arrangement.classroom),
          start: _dateAtClassTime(day, timeList[startIndex]),
          end: _dateAtClassTime(day, timeList[endIndex]),
        ),
      );
    }
    items.sort(_compareAgendaItems);
    return items;
  }

  static List<WearAgendaItem> experimentItemsForDay(
    List<ExperimentData> experiments,
    DateTime day,
  ) {
    final items = <WearAgendaItem>[];
    for (final experiment in experiments) {
      for (final range in experiment.timeRanges) {
        if (!_isSameDate(range.$1, day)) continue;
        items.add(
          WearAgendaItem(
            kind: WearAgendaKind.otherExperiment,
            title: experiment.name,
            subtitle: _blankToNull(experiment.teacher),
            location: _blankToNull(experiment.classroom),
            start: range.$1,
            end: range.$2,
          ),
        );
      }
    }
    items.sort(_compareAgendaItems);
    return items;
  }

  static int weekIndexForDay(ClassTableData table, DateTime day) {
    if (table.termStartDay.isEmpty) return -1;
    final start = DateTime.parse(table.termStartDay);
    final delta = _dateOnly(day).difference(_dateOnly(start)).inDays;
    return delta < 0 ? -1 : delta ~/ DateTime.daysPerWeek;
  }
}

Future<WearHomeData> loadCachedWearHomeData({
  required String semesterCode,
  DateTime? now,
  ClassTableCacheLoader? classTableCacheLoader,
  ExperimentCacheLoader? otherExperimentCacheLoader,
}) async {
  final effectiveNow = now ?? DateTime.now();
  final today = _dateOnly(effectiveNow);
  final tomorrow = today.add(const Duration(days: 1));
  final classTable = (classTableCacheLoader ?? _loadClassTableCache)(
    semesterCode,
  );
  final experiments =
      (otherExperimentCacheLoader ?? _loadOtherExperimentCache)();
  final todayItems = <WearAgendaItem>[];
  final tomorrowItems = <WearAgendaItem>[];

  if (classTable != null) {
    todayItems.addAll(WearAgendaBuilder.courseItemsForDay(classTable, today));
    tomorrowItems.addAll(
      WearAgendaBuilder.courseItemsForDay(classTable, tomorrow),
    );
  }
  if (experiments != null) {
    todayItems.addAll(
      WearAgendaBuilder.experimentItemsForDay(experiments, today),
    );
    tomorrowItems.addAll(
      WearAgendaBuilder.experimentItemsForDay(experiments, tomorrow),
    );
  }

  todayItems.sort(_compareAgendaItems);
  tomorrowItems.sort(_compareAgendaItems);
  return WearHomeData(
    todayItems: List.unmodifiable(todayItems),
    tomorrowItems: List.unmodifiable(tomorrowItems),
  );
}

ClassTableData? _loadClassTableCache(String semesterCode) {
  final cache = WearClassTableCache.read();
  if (cache == null || cache.$2.semesterCode != semesterCode) return null;
  return cache.$2;
}

List<ExperimentData>? _loadOtherExperimentCache() =>
    WearExperimentCache.read()?.$2;

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _dateAtClassTime(DateTime day, String hhmm) {
  final hour = (hhmm.codeUnitAt(0) - 48) * 10 + hhmm.codeUnitAt(1) - 48;
  final minute = (hhmm.codeUnitAt(3) - 48) * 10 + hhmm.codeUnitAt(4) - 48;
  return DateTime(day.year, day.month, day.day, hour, minute);
}

bool _isSameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String? _blankToNull(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}

int _compareAgendaItems(WearAgendaItem left, WearAgendaItem right) {
  final start = left.start.compareTo(right.start);
  if (start != 0) return start;
  return left.end.compareTo(right.end);
}
