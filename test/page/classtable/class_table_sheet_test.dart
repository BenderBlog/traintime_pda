// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Geometry checks for the class table sheet.
//
// The sheet hoists the time line and the date row out of the week pages. Getting that layout wrong
// is invisible in a compile, so the sizes are asserted here instead.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_sheet.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_time_line.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/repository/network_client.dart' as repo_general;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

const double kSheetWidth = 360;
const double kSheetHeight = 520;

/// The sheet's own height budget, mirrored from the real page.
double get kGridHeight =>
    61 * (kSheetHeight - midRowHeight) / 48; // kSheetWidth < 480, so it counts as a phone.

/// A stand-in for the real controller, in the spirit of the settings preview.
class _StubClassTableState extends ClassTableWidgetState {
  final List<ClassDetail> _details = [
    ClassDetail(name: 'Test', code: 'T', number: '1'),
  ];

  final List<TimeArrangement> _arrangements = [
    TimeArrangement(
      source: Source.school,
      index: 0,
      weekList: List<bool>.filled(16, false)..[1] = true,
      teacher: 'T',
      classroom: 'A-101',
      day: 2,
      start: 3,
      stop: 7,
    ),
  ];

  @override
  int get offset => 0;

  @override
  int get semesterLength => 16;

  @override
  int get currentWeek => 1;

  @override
  DateTime get startDay => DateTime(2026, 9, 7);

  @override
  List<ClassDetail> get classDetail => _details;

  @override
  List<TimeArrangement> get timeArrangement => _arrangements;

  @override
  ClassDetail getClassDetail(int index) => _details[0];

  @override
  bool isClassCardInteractive(ClassOrgainzedData detail) => false;

  @override
  List<Subject> get subjects => const [];

  @override
  List<ExperimentData> get experiments => const [];

  @override
  DateTime get currentTime => DateTime(2026, 9, 16, 14, 0);

  @override
  List<ClassOrgainzedData> getArrangement({
    required int weekIndex,
    required int dayIndex,
  }) {
    return [
      for (final arrangement in _arrangements)
        if (arrangement.weekList[weekIndex] && arrangement.day == dayIndex)
          ClassOrgainzedData.fromTimeArrangement(
            arrangement,
            colorList[0],
            'Test',
          ),
    ];
  }
}

/// Loads short stand-in strings.
///
/// `FileTranslationLoader` never finishes inside `flutter_test`, which leaves `WidgetsApp` showing
/// its empty placeholder and the widget under test never builds. The strings still have to be short
/// and realistic: falling back to the raw keys makes the labels wrap and inflates the row, which
/// would hide any real geometry bug behind a fake one.
class _StubTranslationLoader extends TranslationLoader {
  static const Map<String, dynamic> _values = <String, dynamic>{
    'classtable': <String, dynamic>{
      'month': '{month}月',
      'noon_break': '午休',
      'supper_break': '晚休',
      'no_class': '今天没有课',
    },
    'weekday': <String, dynamic>{
      'monday': '周一',
      'tuesday': '周二',
      'wednesday': '周三',
      'thursday': '周四',
      'friday': '周五',
      'saturday': '周六',
      'sunday': '周日',
    },
  };

  @override
  Future<Map> load() async => <String, Map>{
    for (final String tag in <String>['zh', 'zh_CN', 'zh_TW', 'en', 'en_US'])
      tag: _values,
  };
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    // The controller singletons read these globals as soon as they are constructed.
    repo_general.supportPath = Directory.systemTemp.createTempSync('xdyou_test');
    preference.prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'XDYou',
      packageName: 'io.github.benderblog.traintime_pda',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    preference.packageInfo = await PackageInfo.fromPlatform();
    // The controller chain starts a periodic timer; without this the framework fails the test for a
    // pending timer after the tree is disposed.
    addTearDown(GlobalTimerController.i.dispose);
  });

  testWidgets('the sheet gives the date row and the time line a real size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(kSheetWidth, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final PageController pageControl = PageController();
    addTearDown(pageControl.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: _StubTranslationLoader(),
            missingTranslationHandler: (key, locale) {},
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        home: Scaffold(
          body: SizedBox(
            width: kSheetWidth,
            height: kSheetHeight,
            child: ClassTableState(
              constraints: const BoxConstraints(
                maxWidth: kSheetWidth,
                maxHeight: kSheetHeight,
              ),
              controllers: _StubClassTableState(),
              child: ClassTableSheet(
                singleIndex: 1,
                pageControl: pageControl,
                semesterLength: 16,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Size dateRow = tester.getSize(find.byType(ClassTableDateRow));
    final Size timeLine = tester.getSize(find.byType(ClassTableTimeLine));

    /// The absolute heights depend on the stand-in strings above, so they are not asserted. What is
    /// asserted is the geometry that broke: the date row has to be laid out at all, the time line
    /// has to get the grid's full height, and the sheet has to have reserved real room for the
    /// floating date row. When that reservation is zero the whole grid slides up under the row and
    /// the table stops scrolling.
    expect(dateRow.height, greaterThan(20), reason: 'the date row collapsed');
    expect(dateRow.width, greaterThan(kSheetWidth - 20));
    expect(
      timeLine.height,
      closeTo(kGridHeight, 1),
      reason: 'the time line collapsed',
    );
    expect(timeLine.width, greaterThan(0));
    expect(
      tester.getRect(find.byType(ClassTableTimeLine)).top,
      greaterThan(0),
      reason: 'the sheet reserved no room for the floating date row',
    );
  });

  /// The wrapper `ContentClassTablePage` puts in `Scaffold.body`, with placeholders standing in for
  /// the real widgets.
  ///
  /// The wrapper is a `StackFit.expand` Stack holding the page, a full-size tap catcher and the week
  /// bar, all three of them positioned and always present so the bar's implicit animations have a
  /// stable element to run on. Checking it on its own separates a wrapper mistake from a table
  /// mistake.
  testWidgets('the page body wrapper lays out', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const Duration instant = Duration(milliseconds: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('t')),
          body: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPositioned(
                left: 0,
                right: 0,
                top: 96,
                bottom: 0,
                duration: instant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        key: const ValueKey<String>('table'),
                        color: const Color(0xFF0000FF),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                  ),
                ),
              ),
              /// The bar. Its height comes from `AnimatedPositioned`, not from a `PreferredSize`:
              /// that one constrains nothing and would leave the horizontal viewport below with an
              /// unbounded height, which is a fault this test exists to catch.
              AnimatedPositioned(
                left: 4,
                right: 4,
                top: 4,
                height: 96,
                duration: instant,
                child: AnimatedContainer(
                  duration: instant,
                  color: const Color(0xFFFFFFFF),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemExtent: 78,
                          itemCount: 16,
                          itemBuilder: (context, index) => const Card(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.push_pin, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'the body wrapper threw');
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('table'))).height,
      greaterThan(200),
      reason: 'the body wrapper collapsed',
    );
  });

  /// The floating bar's tap catcher sits over the table and has to win taps without swallowing
  /// drags, which is what `HitTestBehavior.translucent` buys. `opaque` would take both and leave the
  /// table unscrollable while the bar is open.
  testWidgets('the tap catcher wins taps but lets drags through', (tester) async {
    int catcherTaps = 0;
    int rowTaps = 0;
    final ScrollController control = ScrollController();
    addTearDown(control.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              ListView.builder(
                controller: control,
                itemCount: 60,
                itemExtent: 40,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => rowTaps++,
                  child: SizedBox(height: 40, child: Text('row $index')),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => catcherTaps++,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('row 2'));
    await tester.pump();
    expect(catcherTaps, 1, reason: 'the tap catcher should take the tap');
    expect(rowTaps, 0, reason: 'the row underneath should not also be tapped');

    await tester.drag(find.text('row 2'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(
      control.offset,
      greaterThan(0),
      reason: 'the drag should reach the table through the catcher',
    );
  });
}
