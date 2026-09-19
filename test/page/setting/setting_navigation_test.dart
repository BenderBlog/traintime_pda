// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Use the plugin's in-memory backend without changing application dependencies.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/page/setting/groups/account_section.dart';
import 'package:watermeter/page/setting/groups/core_section.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/setting/settings_category_page.dart';
import 'package:watermeter/repository/network_client.dart' show supportPath;
import 'package:watermeter/repository/preference.dart' as preference;

const _placeholderKey = ValueKey('test-settings-detail-placeholder');

Finder _category(String id) => find.byKey(ValueKey('settings-category-$id'));

Future<void> _pumpSettings(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool split = false,
  double textScale = 1,
  PageController? pageController,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final settings = SettingWindow(key: GlobalKey());
  final master = pageController == null
      ? settings
      : PageView(
          key: GlobalKey(),
          controller: pageController,
          children: [
            settings,
            const Center(child: Text('Other page')),
          ],
        );
  final translations = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      forcedLocale: const Locale('en', 'US'),
      fallbackFile: 'en_US',
      useCountryCode: true,
    ),
  );
  // Asset decoding performs real asynchronous work outside the fake clock.
  await tester.runAsync(() => translations.load(const Locale('en', 'US')));
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: [
        translations,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: split
          ? BasedSplitView(
              navigatorKey: preference.splitViewKey,
              leftWidget: master,
              rightPlaceholder: const SizedBox(key: _placeholderKey),
            )
          : master,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _showCategory(WidgetTester tester, String id) async {
  final scrollable = find.descendant(
    of: find.byType(SettingWindow),
    matching: find.byType(Scrollable),
  );
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(_category(id), 120, scrollable: scrollable);
  await tester.pumpAndSettle();
}

Future<void> _openCategory(WidgetTester tester, String id) async {
  await _showCategory(tester, id);
  await tester.tap(_category(id));
  await tester.pumpAndSettle();
}

void main() {
  late Directory testSupportPath;
  setUpAll(() async {
    testSupportPath = await Directory.systemTemp.createTemp(
      'traintime_settings_test_',
    );
    supportPath = testSupportPath;
  });
  tearDownAll(() async {
    await testSupportPath.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          preference.Preference.role.key: false,
          preference.Preference.localization.key: 'en_US',
        });
    preference.prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    preference.packageInfo = PackageInfo(
      appName: 'XDYou',
      packageName: 'xyz.superbart.xdyou',
      version: '1.6.7',
      buildNumber: '51',
    );
  });

  testWidgets('standalone narrow settings push a category and return', (
    tester,
  ) async {
    await _pumpSettings(tester);
    expect(preference.splitViewKey.currentState, isNull);

    await _openCategory(tester, 'account');
    expect(find.byType(SettingsCategoryPage), findsOneWidget);
    expect(find.byType(AccountSection), findsOneWidget);
    expect(find.byType(SettingWindow), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingWindow), findsOneWidget);
    expect(find.byType(SettingsCategoryPage), findsNothing);
  });

  testWidgets('narrow split navigator preserves the category directory', (
    tester,
  ) async {
    await _pumpSettings(tester, split: true);
    expect(preference.splitViewKey.currentState!.canPop(), isFalse);

    await _openCategory(tester, 'account');
    expect(preference.splitViewKey.currentState!.canPop(), isTrue);
    expect(find.byType(AccountSection), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(preference.splitViewKey.currentState!.canPop(), isFalse);
    expect(_category('account'), findsOneWidget);
  });

  testWidgets(
    'wide category switches reuse the detail navigator and its root',
    (tester) async {
      await _pumpSettings(tester, split: true, size: const Size(1200, 800));
      final detailNavigator = preference.splitViewKey.currentState!;
      await _openCategory(tester, 'account');

      expect(find.byType(SettingWindow), findsOneWidget);
      expect(find.byType(AccountSection), findsOneWidget);
      expect(tester.widget<ListTile>(_category('account')).selected, isTrue);
      expect(
        tester.getRect(find.byType(SettingsCategoryPage)).left,
        greaterThanOrEqualTo(365),
      );
      expect(
        tester.getRect(_category('account')).right,
        lessThanOrEqualTo(364),
      );
      expect(
        Navigator.of(tester.element(find.byType(SettingWindow))).canPop(),
        isFalse,
      );

      await _openCategory(tester, 'core');
      expect(find.byType(CoreSection), findsOneWidget);
      expect(find.byType(AccountSection), findsNothing);
      expect(tester.widget<ListTile>(_category('core')).selected, isTrue);
      expect(tester.widget<ListTile>(_category('account')).selected, isFalse);
      await _openCategory(tester, 'account');
      expect(
        identical(preference.splitViewKey.currentState, detailNavigator),
        isTrue,
      );

      detailNavigator.pop();
      await tester.pumpAndSettle();
      expect(detailNavigator.canPop(), isFalse);
      expect(find.byKey(_placeholderKey), findsOneWidget);
      expect(find.byType(SettingsCategoryPage), findsNothing);
      expect(tester.widget<ListTile>(_category('account')).selected, isFalse);
    },
  );

  for (final postgraduate in [false, true]) {
    testWidgets(
      'account options retain the ${postgraduate ? 'postgraduate' : 'undergraduate'} role condition',
      (tester) async {
        await preference.setBool(preference.Preference.role, postgraduate);
        await _pumpSettings(tester);
        await _openCategory(tester, 'account');

        expect(find.text('Campus net password'), findsOneWidget);
        expect(
          find.text('PE system password'),
          postgraduate ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('Physics experiment password'),
          postgraduate ? findsNothing : findsOneWidget,
        );
      },
    );
  }

  testWidgets('English categories and account controls fit narrow large text', (
    tester,
  ) async {
    await _pumpSettings(tester, size: const Size(320, 568), textScale: 1.4);
    final ids = ['ui', 'classtable', 'account', 'core', 'about'];
    if (Platform.isAndroid || Platform.isIOS) ids.add('notifications');
    for (final id in ids) {
      await _showCategory(tester, id);
      expect(tester.takeException(), isNull, reason: 'category $id must fit');
    }
    expect(
      _category('notifications'),
      Platform.isAndroid || Platform.isIOS ? findsOneWidget : findsNothing,
    );

    await _openCategory(tester, 'account');
    await tester.ensureVisible(find.text('Campus net password'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Campus net password').hitTestable(), findsOneWidget);
  });

  testWidgets('logger subpage returns to its settings category', (
    tester,
  ) async {
    await _pumpSettings(tester, split: true, size: const Size(1200, 800));
    await _openCategory(tester, 'core');
    await tester.tap(find.text('View network interceptor and logs'));
    await tester.pumpAndSettle();
    expect(find.byType(TalkerScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(TalkerScreen), findsNothing);
    expect(find.byType(CoreSection), findsOneWidget);
    expect(find.byType(SettingsCategoryPage), findsOneWidget);
  });

  for (final layout in [
    (name: 'phone', size: const Size(390, 844), split: false, textScale: 1.0),
    (
      name: 'wide detail',
      size: const Size(1200, 800),
      split: true,
      textScale: 1.0,
    ),
    (
      name: 'narrow large text',
      size: const Size(320, 568),
      split: false,
      textScale: 1.4,
    ),
  ]) {
    testWidgets(
      'compact brightness controls fit ${layout.name} and preserve preference values',
      (tester) async {
        await _pumpSettings(
          tester,
          size: layout.size,
          split: layout.split,
          textScale: layout.textScale,
        );
        await _openCategory(tester, 'ui');
        final tile = find.ancestor(
          of: find.text('Light/Dark mode'),
          matching: find.byType(ListTile),
        );
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (layout.textScale == 1) {
          expect(tester.getSize(tile).height, lessThanOrEqualTo(112));
        }
        expect(
          tester.getSize(tile).width,
          lessThanOrEqualTo(layout.size.width),
        );
        for (final value in [2, 1, 0]) {
          await tester.tap(tile);
          await tester.pumpAndSettle();
          final choices = find.byType(RadioListTile<int>);
          expect(choices, findsNWidgets(3));
          for (final element in choices.evaluate()) {
            expect(
              tester.getSize(find.byWidget(element.widget)).height,
              greaterThanOrEqualTo(48),
            );
          }
          expect(tester.takeException(), isNull);
          await tester.tap(choices.at(value));
          await tester.pumpAndSettle();
          expect(preference.getInt(preference.Preference.brightness), value);
          expect(find.byType(SimpleDialog), findsNothing);
        }
        await tester.tap(tile);
        await tester.pumpAndSettle();
        Navigator.of(tester.element(find.byType(SimpleDialog))).pop();
        await tester.pumpAndSettle();
        expect(preference.getInt(preference.Preference.brightness), 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'category titles are unique and all settings have leading icons',
    (tester) async {
      await _pumpSettings(tester);
      for (final id in ['ui', 'classtable', 'account', 'core', 'about']) {
        await _openCategory(tester, id);
        final page = find.byType(SettingsCategoryPage);
        final appBar = tester.widget<AppBar>(
          find.descendant(of: page, matching: find.byType(AppBar)),
        );
        final title = (appBar.title! as Text).data!;
        expect(
          find.descendant(of: page, matching: find.text(title)),
          findsOneWidget,
        );
        for (final tile in tester.widgetList<ListTile>(
          find.descendant(of: page, matching: find.byType(ListTile)),
        )) {
          expect(
            tile.leading,
            isA<Icon>(),
            reason: '$id items need a visual cue',
          );
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('switching master tabs preserves the active settings category', (
    tester,
  ) async {
    final pageController = PageController();
    addTearDown(pageController.dispose);
    await _pumpSettings(
      tester,
      split: true,
      size: const Size(1200, 800),
      pageController: pageController,
    );
    await _openCategory(tester, 'account');

    pageController.jumpToPage(1);
    await tester.pumpAndSettle();
    expect(find.text('Other page'), findsOneWidget);
    expect(find.byType(AccountSection), findsOneWidget);

    pageController.jumpToPage(0);
    await tester.pumpAndSettle();
    expect(find.byType(AccountSection), findsOneWidget);
    expect(tester.widget<ListTile>(_category('account')).selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('crossing the split breakpoint keeps the active category', (
    tester,
  ) async {
    await _pumpSettings(tester, split: true, size: const Size(1200, 800));
    await _openCategory(tester, 'account');

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byType(AccountSection), findsOneWidget);
    expect(find.byType(SettingWindow), findsNothing);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpAndSettle();
    expect(find.byType(AccountSection), findsOneWidget);
    expect(find.byType(SettingWindow), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
