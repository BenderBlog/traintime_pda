// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

/// 手机端发送给 Apple Watch 的日程类型。
///
/// 枚举名称会通过 `kind.name` 写入 JSON，修改已有枚举值会破坏旧版手表兼容性。
enum WatchScheduleEntryKind { course, exam, physicsExperiment, otherExperiment }

/// 已经展开到具体日期和时间的一条手表日程。
///
/// 手机课表中的常规课程通常使用“第几周、星期几、第几节”的重复规则；
/// Apple Watch 不再解释这些规则，而是直接接收可显示的具体起止时间。
class WatchCourseOccurrence {
  const WatchCourseOccurrence({
    required this.id,
    required this.name,
    required this.startAt,
    required this.endAt,
    required this.startSection,
    required this.endSection,
    required this.colorARGB,
    required this.kind,
    this.teacher,
    this.classroom,
    this.note,
  });

  /// 在一次完整学期同步中保持唯一的日程标识。
  final String id;
  final String name;
  final DateTime startAt;
  final DateTime endAt;
  final int startSection;
  final int endSection;
  final int colorARGB;
  final WatchScheduleEntryKind kind;
  final String? teacher;
  final String? classroom;
  final String? note;

  /// 转为 Swift `Codable` 模型所期望的 JSON 字段。
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'teacher': teacher,
    'classroom': classroom,
    'startAtEpochMs': startAt.millisecondsSinceEpoch,
    'endAtEpochMs': endAt.millisecondsSinceEpoch,
    'startSection': startSection,
    'endSection': endSection,
    'colorARGB': colorARGB,
    'kind': kind.name,
    'note': note,
  };
}

/// 一次同步阶段的自包含课表快照。
///
/// 快照带有覆盖范围和有效期，手表可以在手机不在线时自行选择当天、
/// 近 14 天或整学期缓存，不需要依赖 Flutter 进程继续运行。
class WatchScheduleSnapshot {
  const WatchScheduleSnapshot({
    required this.generatedAt,
    required this.semesterStart,
    required this.currentWeekIndex,
    required this.validThrough,
    required this.rangeStart,
    required this.rangeEnd,
    required this.reminderMinutes,
    required this.courses,
  });

  /// 每次修改 JSON 字段语义时必须递增，并同步更新 Swift 支持范围。
  static const schemaVersion = 4;

  final DateTime generatedAt;
  final DateTime semesterStart;
  final int currentWeekIndex;
  final DateTime validThrough;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int reminderMinutes;
  final List<WatchCourseOccurrence> courses;

  /// 生成稳定、跨语言的 JSON 结构。
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'generatedAtEpochMs': generatedAt.millisecondsSinceEpoch,
    'semesterStartEpochMs': semesterStart.millisecondsSinceEpoch,
    'currentWeekIndex': currentWeekIndex,
    'validThroughEpochMs': validThrough.millisecondsSinceEpoch,
    'rangeStartEpochMs': rangeStart.millisecondsSinceEpoch,
    'rangeEndEpochMs': rangeEnd.millisecondsSinceEpoch,
    'timeZoneOffsetMinutes': generatedAt.timeZoneOffset.inMinutes,
    'reminderMinutes': reminderMinutes,
    'courses': courses.map((course) => course.toJson()).toList(),
  };

  /// 编码后交给 Pigeon 和原生 WatchConnectivity 层。
  String encode() => jsonEncode(toJson());
}

/// 构建过程中使用的左闭右开日期范围 `[start, end)`。
final class _ScheduleWindow {
  const _ScheduleWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// 只按日程开始时间决定归属，保持与周/日视图现有行为一致。
  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}

/// 把手机端的所有课程来源展开成 Apple Watch 可直接消费的快照。
class WatchScheduleSnapshotBuilder {
  const WatchScheduleSnapshotBuilder();

  /// Material 课程色的精确 ARGB 值，与手机端 `color_seed.dart` 顺序一致。
  static const _courseColors = <int>[
    0xFFF44336,
    0xFFE91E63,
    0xFF9C27B0,
    0xFF673AB7,
    0xFF3F51B5,
    0xFF2196F3,
    0xFF03A9F4,
    0xFF00BCD4,
    0xFF009688,
    0xFF4CAF50,
    0xFF8BC34A,
    0xFFCDDC39,
    0xFFFFEB3B,
    0xFFFF9800,
    0xFFFF5722,
    0xFF795548,
  ];

  /// 构建指定日期范围内的完整日程。
  ///
  /// 四种来源分别展开，最后统一排序。每个辅助函数只负责一种模型，
  /// 以后新增日程类型时不会继续扩大这个入口函数。
  WatchScheduleSnapshot build({
    required ClassTableData classTable,
    required DateTime effectiveTermStart,
    required int currentWeekIndex,
    required DateTime now,
    List<CustomClass> customClasses = const [],
    List<Subject> subjects = const [],
    List<ExperimentData> experiments = const [],
    DateTime? rangeStart,
    int days = 14,
    int reminderMinutes = 5,
  }) {
    _validateDays(days);

    final semesterStart = _startOfDay(effectiveTermStart);
    final window = _makeWindow(requestedStart: rangeStart ?? now, days: days);
    final occurrences = <WatchCourseOccurrence>[
      ..._buildSchoolCourses(
        classTable: classTable,
        semesterStart: semesterStart,
        window: window,
      ),
      ..._buildCustomCourses(
        classTable: classTable,
        customClasses: customClasses,
        window: window,
      ),
      ..._buildExams(subjects: subjects, window: window),
      ..._buildExperiments(experiments: experiments, window: window),
    ]..sort(_compareOccurrences);

    return WatchScheduleSnapshot(
      generatedAt: now,
      semesterStart: semesterStart,
      currentWeekIndex: currentWeekIndex,
      validThrough: window.end,
      rangeStart: window.start,
      rangeEnd: window.end,
      reminderMinutes: reminderMinutes,
      courses: occurrences,
    );
  }

  /// 天数必须为正，否则范围和有效期没有意义。
  void _validateDays(int days) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', 'Must be greater than zero.');
    }
  }

  /// 将请求起点归一化到本地零点，建立左闭右开的范围。
  _ScheduleWindow _makeWindow({
    required DateTime requestedStart,
    required int days,
  }) {
    final start = _startOfDay(requestedStart);
    return _ScheduleWindow(
      start: start,
      end: start.add(Duration(days: days)),
    );
  }

  /// 展开学校课表中的重复安排。
  List<WatchCourseOccurrence> _buildSchoolCourses({
    required ClassTableData classTable,
    required DateTime semesterStart,
    required _ScheduleWindow window,
  }) {
    final occurrences = <WatchCourseOccurrence>[];
    final dayCount = window.end.difference(window.start).inDays;

    for (var dayOffset = 0; dayOffset < dayCount; dayOffset++) {
      final date = window.start.add(Duration(days: dayOffset));
      final weekIndex = _weekIndexForDate(date, semesterStart: semesterStart);
      if (!_isWeekInsideSemester(weekIndex, classTable.semesterLength)) {
        continue;
      }

      for (final arrangement in classTable.timeArrangement) {
        if (!_arrangementOccurs(
          arrangement,
          date: date,
          weekIndex: weekIndex,
        )) {
          continue;
        }

        final interval = _schoolCourseInterval(arrangement, date: date);
        if (interval == null) continue;

        final detail = classTable.getClassDetail(arrangement);
        final teacher = _nonEmptyText(arrangement.teacher);
        final classroom = _nonEmptyText(arrangement.classroom);
        occurrences.add(
          WatchCourseOccurrence(
            id: _schoolCourseID(
              classTable: classTable,
              arrangement: arrangement,
              startAt: interval.$1,
              teacher: teacher,
              classroom: classroom,
            ),
            name: detail.name,
            teacher: teacher,
            classroom: classroom,
            startAt: interval.$1,
            endAt: interval.$2,
            startSection: arrangement.start,
            endSection: arrangement.stop,
            colorARGB: _colorAt(arrangement.index),
            kind: WatchScheduleEntryKind.course,
          ),
        );
      }
    }
    return occurrences;
  }

  /// 展开用户自行添加的课程时间段。
  List<WatchCourseOccurrence> _buildCustomCourses({
    required ClassTableData classTable,
    required List<CustomClass> customClasses,
    required _ScheduleWindow window,
  }) {
    final occurrences = <WatchCourseOccurrence>[];

    for (var classIndex = 0; classIndex < customClasses.length; classIndex++) {
      final customClass = customClasses[classIndex];
      for (final timeRange in customClass.timeRanges) {
        if (!_isValidInterval(
          start: timeRange.startTime,
          end: timeRange.endTime,
          window: window,
        )) {
          continue;
        }

        occurrences.add(
          WatchCourseOccurrence(
            id: 'custom-${customClass.id}-${timeRange.id}',
            name: customClass.name,
            teacher: _nonEmptyText(customClass.teacher),
            classroom: _nonEmptyText(customClass.classroom),
            startAt: timeRange.startTime,
            endAt: timeRange.endTime,
            startSection: _nearestSection(timeRange.startTime, isStart: true),
            endSection: _nearestSection(timeRange.endTime, isStart: false),
            colorARGB: _colorAt(classTable.classDetail.length + classIndex),
            kind: WatchScheduleEntryKind.course,
          ),
        );
      }
    }
    return occurrences;
  }

  /// 将考试信息转换为手表日程。
  List<WatchCourseOccurrence> _buildExams({
    required List<Subject> subjects,
    required _ScheduleWindow window,
  }) {
    final occurrences = <WatchCourseOccurrence>[];

    for (var index = 0; index < subjects.length; index++) {
      final subject = subjects[index];
      final startAt = subject.startTime;
      final endAt = subject.stopTime;
      if (startAt == null ||
          endAt == null ||
          !_isValidInterval(start: startAt, end: endAt, window: window)) {
        continue;
      }

      final classroom = _nonEmptyText(subject.place);
      final seat = _nonEmptyText(subject.seat);
      occurrences.add(
        WatchCourseOccurrence(
          id: _examID(
            subject: subject,
            startAt: startAt,
            classroom: classroom,
            seat: seat,
          ),
          name: '${subject.subject}${subject.type}',
          teacher: null,
          classroom: classroom,
          startAt: startAt,
          endAt: endAt,
          // 考试没有明确节次，传 0 让手表按具体时间推断。
          startSection: 0,
          endSection: 0,
          colorARGB: _colorAt(index),
          kind: WatchScheduleEntryKind.exam,
          note: seat == null ? null : '座位 $seat',
        ),
      );
    }
    return occurrences;
  }

  /// 将物理实验和其他实验转换为手表日程。
  List<WatchCourseOccurrence> _buildExperiments({
    required List<ExperimentData> experiments,
    required _ScheduleWindow window,
  }) {
    final occurrences = <WatchCourseOccurrence>[];

    for (var index = 0; index < experiments.length; index++) {
      final experiment = experiments[index];
      for (final timeRange in experiment.timeRanges) {
        final startAt = timeRange.$1;
        final endAt = timeRange.$2;
        if (!_isValidInterval(start: startAt, end: endAt, window: window)) {
          continue;
        }

        occurrences.add(
          WatchCourseOccurrence(
            id: _experimentID(
              experiment: experiment,
              index: index,
              startAt: startAt,
            ),
            name: experiment.name,
            teacher: _nonEmptyText(experiment.teacher),
            classroom: _nonEmptyText(experiment.classroom),
            startAt: startAt,
            endAt: endAt,
            // 实验时间可能不落在标准节次，交给手表按时间推断。
            startSection: 0,
            endSection: 0,
            colorARGB: _colorAt(index),
            kind: _experimentKind(experiment.type),
            note: _nonEmptyText(experiment.reference),
          ),
        );
      }
    }
    return occurrences;
  }

  /// 计算某日相对学期起点的零基周次。
  int _weekIndexForDate(DateTime date, {required DateTime semesterStart}) {
    final deltaDays = date.difference(semesterStart).inDays;
    if (deltaDays < 0) return -1;
    return deltaDays ~/ DateTime.daysPerWeek;
  }

  /// 判断周次是否落在学校课表定义的学期范围内。
  bool _isWeekInsideSemester(int weekIndex, int semesterLength) {
    return weekIndex >= 0 && weekIndex < semesterLength;
  }

  /// 判断一条学校课程安排是否在给定日期发生。
  bool _arrangementOccurs(
    TimeArrangement arrangement, {
    required DateTime date,
    required int weekIndex,
  }) {
    return arrangement.day == date.weekday &&
        weekIndex < arrangement.weekList.length &&
        arrangement.weekList[weekIndex];
  }

  /// 将学校课表节次转换为具体起止时间。
  ///
  /// `timeList` 中每节课包含开始和结束两个位置，因此第 n 节的开始索引为
  /// `(n - 1) * 2`，结束索引为 `(n - 1) * 2 + 1`。
  (DateTime, DateTime)? _schoolCourseInterval(
    TimeArrangement arrangement, {
    required DateTime date,
  }) {
    final startIndex = (arrangement.start - 1) * 2;
    final endIndex = (arrangement.stop - 1) * 2 + 1;
    if (startIndex < 0 ||
        endIndex >= timeList.length ||
        startIndex >= endIndex) {
      return null;
    }

    final startAt = _withTime(date, timeList[startIndex]);
    final endAt = _withTime(date, timeList[endIndex]);
    return endAt.isAfter(startAt) ? (startAt, endAt) : null;
  }

  /// 只有起点位于快照范围内且结束晚于开始时才接受。
  bool _isValidInterval({
    required DateTime start,
    required DateTime end,
    required _ScheduleWindow window,
  }) {
    return window.contains(start) && end.isAfter(start);
  }

  /// 常规课程 ID 由学期、安排字段和具体发生时间共同组成。
  ///
  /// 同一课程可能因为合班、调课或数据源异常，在同一时刻出现不同教师/教室
  /// 的多条安排；这些字段必须进入 ID，否则 Watch 端按 ID 合并学期分块时
  /// 会错误覆盖其中一条。
  String _schoolCourseID({
    required ClassTableData classTable,
    required TimeArrangement arrangement,
    required DateTime startAt,
    required String? teacher,
    required String? classroom,
  }) {
    return '${classTable.semesterCode}-${arrangement.source.name}-'
        '${arrangement.index}-${arrangement.day}-'
        '${arrangement.start}-${arrangement.stop}-'
        '${teacher ?? ''}-${classroom ?? ''}-'
        '${startAt.millisecondsSinceEpoch}';
  }

  /// 考试 ID 加入地点和座位，避免同科目同时间的多个考场互相覆盖。
  String _examID({
    required Subject subject,
    required DateTime startAt,
    required String? classroom,
    required String? seat,
  }) {
    return 'exam-${subject.subject}-${classroom ?? ''}-${seat ?? ''}-'
        '${startAt.millisecondsSinceEpoch}';
  }

  /// 实验 ID 使用类型、来源索引和具体发生时间。
  String _experimentID({
    required ExperimentData experiment,
    required int index,
    required DateTime startAt,
  }) {
    return 'experiment-${experiment.type.name}-$index-'
        '${startAt.millisecondsSinceEpoch}';
  }

  /// 映射实验模型类型。
  WatchScheduleEntryKind _experimentKind(ExperimentType type) {
    return type == ExperimentType.physics
        ? WatchScheduleEntryKind.physicsExperiment
        : WatchScheduleEntryKind.otherExperiment;
  }

  /// 获取与手机课程颜色序列一致的颜色，并安全处理任意索引。
  int _colorAt(int index) {
    return _courseColors[index % _courseColors.length];
  }

  /// 把 `HH:mm` 合并到给定日期。
  DateTime _withTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// 根据开始或结束时间寻找距离最近的标准节次。
  int _nearestSection(DateTime dateTime, {required bool isStart}) {
    final targetMinutes = _minutesSinceStartOfDay(dateTime);
    var nearestSection = 1;
    var nearestDistance = 1 << 30;

    for (var section = 0; section < timeList.length ~/ 2; section++) {
      final index = section * 2 + (isStart ? 0 : 1);
      final distance = (_minutesFromClockText(timeList[index]) - targetMinutes)
          .abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestSection = section + 1;
      }
    }
    return nearestSection;
  }

  /// 将日期时间转为当天零点后的分钟数。
  int _minutesSinceStartOfDay(DateTime dateTime) {
    return dateTime.hour * 60 + dateTime.minute;
  }

  /// 将 `HH:mm` 文本转为当天零点后的分钟数。
  int _minutesFromClockText(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// 去除首尾空白，并把空字符串统一转换为 null。
  String? _nonEmptyText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  /// 返回本地时区中的当天零点。
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 日程按开始时间排序；开始相同时用结束时间保证结果稳定。
  int _compareOccurrences(
    WatchCourseOccurrence left,
    WatchCourseOccurrence right,
  ) {
    final startComparison = left.startAt.compareTo(right.startAt);
    if (startComparison != 0) return startComparison;
    return left.endAt.compareTo(right.endAt);
  }
}
