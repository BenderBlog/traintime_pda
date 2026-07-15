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

typedef HomepageWidgetBuilder =
    Widget Function(BuildContext context, bool editMode);

class HomepageWidgetEntry {
  final String id;
  final String titleKey;
  final HomepageWidgetBuilder builder;
  final bool Function()? visible;
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
  // ---- 大卡片 ----
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
  // ---- 小格子 ----
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

// ---- 顺序读写 ----

List<String> _readOrder(prefs.Preference prefKey) {
  final raw = prefs.getString(prefKey);
  if (raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
  } catch (_) {}
  return [];
}

List<HomepageWidgetEntry> getOrderedEntries() {
  List<String> saved = _readOrder(prefs.Preference.homepageAllOrder);
  if (saved.isEmpty) {
    final info = _readOrder(prefs.Preference.homepageInfoOrder);
    final small = _readOrder(prefs.Preference.homepageSmallOrder);
    saved = [...info, ...small];
  }
  if (saved.isEmpty) saved = defaultAllOrder;

  final map = {for (var e in homepageRegistry) e.id: e};
  final ordered = <HomepageWidgetEntry>[];
  for (final id in saved) {
    if (map.containsKey(id)) ordered.add(map.remove(id)!);
  }
  ordered.addAll(map.values);

  return ordered.where((e) => e.visible?.call() ?? true).toList();
}

Future<void> saveOrder(List<String> ids) async {
  await prefs.setString(prefs.Preference.homepageAllOrder, jsonEncode(ids));
}

// ---- 隐藏读写 ----

List<String> _readHiddenIds() {
  final raw = prefs.getString(prefs.Preference.homepageHiddenIds);
  if (raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
  } catch (_) {}
  return [];
}

Future<void> _saveHiddenIds(List<String> ids) async {
  await prefs.setString(prefs.Preference.homepageHiddenIds, jsonEncode(ids));
}

/// 获取已隐藏的条目（从注册表中查，保证顺序和完整性）。
List<HomepageWidgetEntry> getHiddenEntries() {
  final hidden = _readHiddenIds();
  final map = {for (var e in homepageRegistry) e.id: e};
  return hidden
      .where((id) => map.containsKey(id))
      .map((id) => map[id]!)
      .toList();
}

/// 过滤掉已隐藏的条目。
List<HomepageWidgetEntry> filterHidden(List<HomepageWidgetEntry> entries) {
  final hidden = _readHiddenIds().toSet();
  return entries.where((e) => !hidden.contains(e.id)).toList();
}

/// 隐藏一张卡片。
Future<void> hideEntry(String id) async {
  final hidden = _readHiddenIds();
  if (!hidden.contains(id)) {
    hidden.add(id);
    await _saveHiddenIds(hidden);
  }
}

/// 取消隐藏一张卡片。
Future<void> unhideEntry(String id) async {
  final hidden = _readHiddenIds();
  if (hidden.remove(id)) {
    await _saveHiddenIds(hidden);
  }
}

/// 清除所有隐藏。
Future<void> clearHidden() async {
  await prefs.remove(prefs.Preference.homepageHiddenIds);
}

/// 重置为默认顺序并清除隐藏。
Future<void> resetAll() async {
  await prefs.remove(prefs.Preference.homepageAllOrder);
  await prefs.remove(prefs.Preference.homepageInfoOrder);
  await prefs.remove(prefs.Preference.homepageSmallOrder);
  await clearHidden();
}
