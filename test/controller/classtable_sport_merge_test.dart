// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/sport_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// 校验 ClassTableController.classTableComputedSignal 内联的体育地点合并：
/// 教务课表为空教室时，用体育系统登记的地点回填。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  // 单例 controller 在进程内只构造一次，全局依赖在 setUpAll 里准备。
  setUpAll(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    preference.prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    tempDir = await Directory.systemTemp.createTemp(
      'classtable_sport_merge_test',
    );
    supportPath = tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

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

  // 绕过网络，直接向两个单例 controller 注入测试数据。
  void inject(ClassTableData table, [SportClass sport = const []]) {
    final fetchTime = DateTime(2026, 2, 23);
    ClassTableController.i.debugSetClassTable(
      FetchResult.fresh(fetchTime: fetchTime, data: table),
    );
    SportController.i.debugSetSportClass(
      FetchResult.fresh(fetchTime: fetchTime, data: sport),
    );
  }

  ClassTableData merged() =>
      ClassTableController.i.classTableComputedSignal.value;

  test('fills an empty classroom after all four checks match', () {
    final source = classTable();

    inject(source, [sportClass()]);

    expect(merged().timeArrangement.single.classroom, '体育馆');
    // 合并输出全新对象，缓存中的原课表不被污染。
    expect(source.timeArrangement.single.classroom, isNull);
  });

  test('does not fill when term, teacher, or period does not match', () {
    inject(classTable(), [
      sportClass(termName: '2024-2025第2学期'),
      sportClass(teacher: '李老师'),
      sportClass(time: '星期二12'),
      sportClass(time: '星期一23'),
    ]);

    expect(merged().timeArrangement.single.classroom, isNull);
  });

  test('keeps an existing classroom and skips conflicting sport locations', () {
    inject(classTable(classroom: '教学楼A'), [sportClass(place: '体育馆')]);
    expect(merged().timeArrangement.single.classroom, '教学楼A');

    inject(classTable(), [sportClass(place: '体育馆'), sportClass(place: '操场')]);
    expect(merged().timeArrangement.single.classroom, isNull);
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

    inject(source, [sportClass()]);

    expect(
      merged().timeArrangement.map((arrangement) => arrangement.classroom),
      everyElement('体育馆'),
    );
  });

  test('recomputes classroom when sport classes arrive after classtable', () {
    // 先只有课表、没有体育数据：教室保持为空。
    inject(classTable());
    expect(merged().timeArrangement.single.classroom, isNull);

    // 体育数据后到，computed 因订阅了体育信号而自动重算并回填。
    SportController.i.debugSetSportClass(
      FetchResult.fresh(fetchTime: DateTime(2026, 2, 23), data: [sportClass()]),
    );
    expect(merged().timeArrangement.single.classroom, '体育馆');
  });
}
