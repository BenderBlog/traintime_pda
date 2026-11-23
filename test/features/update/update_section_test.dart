// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/features/update/application/update_checker.dart';
import 'package:watermeter/features/update/presentation/update_card.dart';
import 'package:watermeter/features/update/presentation/update_section.dart';
import 'package:watermeter/features/update/update.dart';
import 'package:watermeter/generated/translations.g.dart';

void main() {
  testWidgets('feature owns the shared update check for both surfaces', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final feature = UpdateFeature(_Repository(), localVersion: '1.2.0');
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ListView(
                children: [
                  feature.card.buildCard(context, false),
                  ...feature.section.items(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await feature.start();
    await tester.pumpAndSettle();
    expect(find.textContaining('New version released'), findsOneWidget);
    expect(find.textContaining('Latest version: 1.3.0'), findsOneWidget);
    feature.dispose();
  });

  testWidgets('one update result reaches the card and settings', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final checker = UpdateChecker(_Repository(), localVersion: '1.2.0');
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ListView(
                children: [
                  UpdateCard(checker).buildCard(context, false),
                  ...UpdateSection(checker).items(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Fetching update information'), findsOneWidget);
    await checker.check();
    await tester.pumpAndSettle();
    expect(find.textContaining('New version released'), findsOneWidget);
    expect(find.textContaining('1.3.0'), findsOneWidget);
    checker.dispose();
  });

  testWidgets('checking updates opens the release details', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final checker = UpdateChecker(_Repository(), localVersion: '1.2.0');
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  ListView(children: UpdateSection(checker).items(context)),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();

    expect(find.text('New version available'), findsOneWidget);
    expect(find.textContaining('New timetable'), findsOneWidget);
    checker.dispose();
  });
}

class _Repository implements UpdateRepository {
  @override
  Future<UpdateReleaseData> fetchLatest() async => (
    code: '1.3.0',
    changes: ['New timetable'],
    iosUrl: 'https://example.org/ios',
    androidUrl: 'https://example.org/android',
    githubUrl: 'https://example.org/releases',
  );
}
