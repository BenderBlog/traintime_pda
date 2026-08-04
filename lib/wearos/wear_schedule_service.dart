import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';

typedef ClassTableFetcher =
    Future<FetchResult<ClassTableData>> Function(String semesterCode);
typedef ClassTableCacheLoader =
    FetchResult<ClassTableData>? Function(String semesterCode);
typedef ExperimentFetcher =
    Future<FetchResult<List<ExperimentData>>> Function();
typedef ExperimentCacheLoader = FetchResult<List<ExperimentData>>? Function();
typedef BalanceFetcher = Future<String> Function();

Future<void> clearWearCampusCaches() async {
  ClassTableSession.deleteCache();
  await SysjSession.deleteCache();
}

enum WearAgendaKind { course, otherExperiment }

enum WearDataSource { classTable, otherExperiment, schoolCardBalance }

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

class WearSourceFailure {
  final WearDataSource source;
  final Object error;
  final StackTrace stackTrace;

  const WearSourceFailure({
    required this.source,
    required this.error,
    required this.stackTrace,
  });
}

class WearCachedDataException implements Exception {
  final String hintKey;

  const WearCachedDataException(this.hintKey);

  @override
  String toString() => hintKey;
}

class WearHomeData {
  final String? balanceText;
  final List<WearAgendaItem> todayItems;
  final List<WearAgendaItem> tomorrowItems;
  final DateTime fetchedAt;

  const WearHomeData({
    required this.todayItems,
    required this.tomorrowItems,
    required this.fetchedAt,
    this.balanceText,
  });
}

class WearHomeLoadResult {
  final WearHomeData data;
  final List<WearSourceFailure> failures;

  const WearHomeLoadResult({required this.data, required this.failures});

  bool get hasUsableData =>
      data.balanceText != null ||
      data.todayItems.isNotEmpty ||
      data.tomorrowItems.isNotEmpty;
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
      if (startIndex < 0 || endIndex >= timeList.length) {
        continue;
      }

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

Future<WearHomeLoadResult> loadCachedWearHomeData({
  required String semesterCode,
  DateTime? now,
  ClassTableCacheLoader? classTableCacheLoader,
  ExperimentCacheLoader? otherExperimentCacheLoader,
  ClassTableFetcher? classTableFetcher,
  ExperimentFetcher? otherExperimentFetcher,
  BalanceFetcher? balanceFetcher,
}) async {
  final effectiveNow = now ?? DateTime.now();
  final classCache = classTableCacheLoader ?? _loadClassTableCache;
  final experimentCache =
      otherExperimentCacheLoader ?? _loadOtherExperimentCache;
  return _buildWearHomeData(
    now: effectiveNow,
    classTableResult: classCache(semesterCode),
    otherExperimentResult: experimentCache(),
    balanceText: null,
  );
}

Future<WearHomeLoadResult> loadWearHomeData({
  required String semesterCode,
  DateTime? now,
  ClassTableFetcher? classTableFetcher,
  ExperimentFetcher? otherExperimentFetcher,
  BalanceFetcher? balanceFetcher,
}) async {
  final effectiveNow = now ?? DateTime.now();
  final failures = <WearSourceFailure>[];

  FetchResult<ClassTableData>? classTableResult;
  try {
    classTableResult = await (classTableFetcher ?? getClassTable)(semesterCode);
  } catch (error, stackTrace) {
    failures.add(
      WearSourceFailure(
        source: WearDataSource.classTable,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  String? balanceText;
  try {
    balanceText = await (balanceFetcher ?? _fetchSchoolCardBalance)();
  } catch (error, stackTrace) {
    failures.add(
      WearSourceFailure(
        source: WearDataSource.schoolCardBalance,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  final result = _buildWearHomeData(
    now: effectiveNow,
    classTableResult: classTableResult,
    otherExperimentResult: null,
    balanceText: balanceText,
    initialFailures: failures,
  );
  return result;
}

WearHomeLoadResult _buildWearHomeData({
  required DateTime now,
  required FetchResult<ClassTableData>? classTableResult,
  required FetchResult<List<ExperimentData>>? otherExperimentResult,
  required String? balanceText,
  List<WearSourceFailure> initialFailures = const <WearSourceFailure>[],
}) {
  final today = _dateOnly(now);
  final tomorrow = today.add(const Duration(days: 1));
  final failures = <WearSourceFailure>[...initialFailures];
  final todayItems = <WearAgendaItem>[];
  final tomorrowItems = <WearAgendaItem>[];

  if (classTableResult != null) {
    _recordCacheFailure(failures, WearDataSource.classTable, classTableResult);
    final table = classTableResult.data;
    todayItems.addAll(WearAgendaBuilder.courseItemsForDay(table, today));
    tomorrowItems.addAll(WearAgendaBuilder.courseItemsForDay(table, tomorrow));
  }

  if (otherExperimentResult != null) {
    _recordCacheFailure(
      failures,
      WearDataSource.otherExperiment,
      otherExperimentResult,
    );
    final experiments = otherExperimentResult.data;
    todayItems.addAll(
      WearAgendaBuilder.experimentItemsForDay(experiments, today),
    );
    tomorrowItems.addAll(
      WearAgendaBuilder.experimentItemsForDay(experiments, tomorrow),
    );
  }

  todayItems.sort(_compareAgendaItems);
  tomorrowItems.sort(_compareAgendaItems);
  return WearHomeLoadResult(
    data: WearHomeData(
      balanceText: balanceText,
      todayItems: List.unmodifiable(todayItems),
      tomorrowItems: List.unmodifiable(tomorrowItems),
      fetchedAt: DateTime.now(),
    ),
    failures: List.unmodifiable(failures),
  );
}

Future<String> _fetchSchoolCardBalance() => SchoolCardSession().getOverview();

FetchResult<ClassTableData>? _loadClassTableCache(String semesterCode) {
  final cache = ClassTableSession.getCache();
  if (cache == null || cache.$2.semesterCode != semesterCode) return null;
  return FetchResult.cache(fetchTime: cache.$1, data: cache.$2, hintKey: null);
}

FetchResult<List<ExperimentData>>? _loadOtherExperimentCache() {
  final cache = SysjSession.getCache();
  if (cache == null) return null;
  return FetchResult.cache(fetchTime: cache.$1, data: cache.$2, hintKey: null);
}

void _recordCacheFailure<T>(
  List<WearSourceFailure> failures,
  WearDataSource source,
  FetchResult<T> result,
) {
  final hintKey = result.hintKey;
  if (!result.isCache || hintKey == null) return;
  failures.add(
    WearSourceFailure(
      source: source,
      error: WearCachedDataException(hintKey),
      stackTrace: StackTrace.current,
    ),
  );
}

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
