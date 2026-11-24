// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:catcher_2/model/platform_type.dart';
import 'package:catcher_2/model/report.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/core/presentation/crush_page/pda_page_report_mode.dart';

void main() {
  Report report() => Report(
    'Test error',
    StackTrace.fromString('frame one\nframe two'),
    DateTime(2026),
    {},
    {},
    {},
    null,
    PlatformType.macOS,
    null,
  );

  testWidgets('copies the displayed error and stack trace', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final mode = PdaPageReportMode();
    await tester.pumpWidget(MaterialApp(home: PdaPageWidget(mode, report())));
    final copyButton = find.byTooltip('Copy report');
    final description = find.text(
      mode.localizationOptions.pageReportModeDescription,
    );
    expect(
      tester.getCenter(copyButton).dy,
      greaterThan(tester.getCenter(description).dy),
    );
    expect(
      tester.getCenter(copyButton).dx,
      greaterThan(tester.getCenter(description).dx),
    );
    expect(
      tester.getTopLeft(find.text('Test error')).dy,
      lessThan(tester.getCenter(copyButton).dy),
    );
    await tester.tap(copyButton);
    await tester.pump();

    expect(copiedText, 'Test error\nframe one\nframe two');
  });

  testWidgets('opens from a material_ui navigator', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Home')),
      ),
    );

    PdaPageReportMode().requestAction(
      report(),
      navigatorKey.currentState!.overlay!.context,
    );
    await tester.pumpAndSettle();

    expect(find.byType(PdaPageWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
