// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/energy_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/toolbox/class_attendance_card.dart';
import 'package:watermeter/page/homepage/toolbox/dorm_water_card.dart';
import 'package:watermeter/page/homepage/toolbox/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/exam_card.dart';
import 'package:watermeter/page/homepage/toolbox/experiment_card.dart';
import 'package:watermeter/page/homepage/toolbox/schoolnet_card.dart';
import 'package:watermeter/page/homepage/toolbox/score_card.dart';
import 'package:watermeter/page/homepage/toolbox/sport_card.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

/// [editMode] 为 true 时卡片应禁用交互（enabled: false），
/// 以便父级 [LongPressDraggable] 能正常接管长按拖拽手势。
typedef HomepageWidgetBuilder =
    Widget Function(BuildContext context, bool editMode);

class HomepageWidgetEntry {
  final String id;
  final String titleKey;
  final HomepageWidgetBuilder builder;
  final bool Function()? visible;

  /// 在 4 列网格中占据的列数（1 或 2）。
  final int gridSpan;

  const HomepageWidgetEntry({
    required this.id,
    required this.titleKey,
    required this.builder,
    required this.gridSpan,
    this.visible,
  });
}

const defaultAllOrder = [
  'energy',
  'library',
  'schoolcard',
  'score',
  'exam',
  'empty_classroom',
  'class_attendance',
  'schoolnet',
  'dorm_water',
  'experiment',
  'sport',
];

final homepageRegistry = <HomepageWidgetEntry>[
  // ---- 4 列大卡片 ----
  HomepageWidgetEntry(
    id: 'energy',
    titleKey: 'homepage.electricity_card.title',
    gridSpan: 4,
    builder: (_, _) => EnergyCard(),
  ),
  HomepageWidgetEntry(
    id: 'library',
    titleKey: 'homepage.library_card.title',
    gridSpan: 4,
    builder: (_, _) => const LibraryCard(),
  ),
  HomepageWidgetEntry(
    id: 'schoolcard',
    titleKey: 'homepage.school_card_info_card.bill',
    gridSpan: 4,
    builder: (_, _) => SchoolCardInfoCard(),
  ),
  // ---- 1 列小格子 ----
  HomepageWidgetEntry(
    id: 'score',
    titleKey: 'homepage.toolbox.score',
    gridSpan: 1,
    builder: (_, _) => const ScoreCard(),
  ),
  HomepageWidgetEntry(
    id: 'exam',
    titleKey: 'homepage.toolbox.exam',
    gridSpan: 1,
    builder: (_, _) => const ExamCard(),
  ),
  HomepageWidgetEntry(
    id: 'empty_classroom',
    titleKey: 'homepage.toolbox.empty_classroom',
    gridSpan: 1,
    builder: (_, _) => const EmptyClassroomCard(),
  ),
  HomepageWidgetEntry(
    id: 'class_attendance',
    titleKey: 'homepage.toolbox.class_attendance',
    gridSpan: 1,
    builder: (_, _) => const ClassAttendanceCard(),
  ),
  HomepageWidgetEntry(
    id: 'schoolnet',
    titleKey: 'homepage.toolbox.schoolnet',
    gridSpan: 1,
    builder: (_, _) => const SchoolnetCard(),
  ),
  HomepageWidgetEntry(
    id: 'dorm_water',
    titleKey: 'homepage.toolbox.dorm_water',
    gridSpan: 1,
    builder: (_, _) => const DormWaterCard(),
  ),
  HomepageWidgetEntry(
    id: 'experiment',
    titleKey: 'homepage.toolbox.experiment',
    gridSpan: 1,
    builder: (_, _) => const ExperimentCard(),
    visible: () => prefs.getBool(prefs.Preference.role) == false,
  ),
  HomepageWidgetEntry(
    id: 'sport',
    titleKey: 'homepage.toolbox.sport',
    gridSpan: 1,
    builder: (_, _) => const SportCard(),
    visible: () => prefs.getBool(prefs.Preference.role) == false,
  ),
];

List<String> _readOrder(prefs.Preference prefKey) {
  final raw = prefs.getString(prefKey);
  if (raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
  } catch (_) {}
  return [];
}

/// 读取合并顺序（兼容旧的 info/small 分开存储格式）。
List<HomepageWidgetEntry> getOrderedEntries() {
  // 优先读新的合并 key
  List<String> saved = _readOrder(prefs.Preference.homepageAllOrder);
  // 兼容旧格式：合并 info + small
  if (saved.isEmpty) {
    final info = _readOrder(prefs.Preference.homepageInfoOrder);
    final small = _readOrder(prefs.Preference.homepageSmallOrder);
    saved = [...info, ...small];
  }
  if (saved.isEmpty) saved = defaultAllOrder;

  final map = {for (var e in homepageRegistry) e.id: e};

  // 按 saved 顺序排列；新注册但不在 saved 中的追加到末尾
  final ordered = <HomepageWidgetEntry>[];
  for (final id in saved) {
    if (map.containsKey(id)) ordered.add(map.remove(id)!);
  }
  ordered.addAll(map.values);

  // 过滤不可见条目
  return ordered.where((e) => e.visible?.call() ?? true).toList();
}

/// 拖拽/重排后写入 prefs。
Future<void> saveOrder(List<String> ids) async {
  await prefs.setString(prefs.Preference.homepageAllOrder, jsonEncode(ids));
}

/// 重置为默认顺序。
Future<void> resetOrder() async {
  await prefs.remove(prefs.Preference.homepageAllOrder);
  await prefs.remove(prefs.Preference.homepageInfoOrder);
  await prefs.remove(prefs.Preference.homepageSmallOrder);
}
