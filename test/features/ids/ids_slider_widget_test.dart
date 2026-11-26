// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/features/ids/widgets/ids_slider.widget.dart';
import 'package:watermeter/generated/translations.g.dart';

final _image = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL/nwAAAABJRU5ErkJggg==',
);

Future<void> _openSlider(
  WidgetTester tester,
  List<List<IdsSliderPoint>?> results,
) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: material_ui.MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                results.add(await showIdsSlider(context, _image, _image)),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Offset _trackStart(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const ValueKey('ids-slider-track')));

void main() {
  testWidgets('ignores out of bounds moves while recording the release', (
    tester,
  ) async {
    final results = <List<IdsSliderPoint>?>[];
    await _openSlider(tester, results);
    final start = _trackStart(tester) + const Offset(20, 20);
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(start + const Offset(100, 0));
    await tester.pump();
    await gesture.moveTo(start + const Offset(300, 0));
    await tester.pump();
    await gesture.moveTo(start + const Offset(-10, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(results.single!.last.x, -10);
    expect(results.single!.map((point) => point.x), isNot(contains(300)));
  });

  testWidgets('drag returns the distance used by the slider verifier', (
    tester,
  ) async {
    final results = <List<IdsSliderPoint>?>[];
    await _openSlider(tester, results);

    final gesture = await tester.startGesture(
      _trackStart(tester) + const Offset(20, 20),
    );
    await gesture.moveBy(const Offset(100, 7));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(results.single!.last.x, 100);
    expect(results.single!.last.y, 7);
    expect(find.byKey(const ValueKey('ids-slider-track')), findsNothing);
  });

  testWidgets('zero movement and a drag outside the handle do not submit', (
    tester,
  ) async {
    final results = <List<IdsSliderPoint>?>[];
    await _openSlider(tester, results);

    final start = _trackStart(tester);
    final stationary = await tester.startGesture(start + const Offset(20, 20));
    await stationary.up();
    final outside = await tester.startGesture(start + const Offset(100, 20));
    await outside.moveBy(const Offset(100, 0));
    await outside.up();
    await tester.pumpAndSettle();

    expect(results, isEmpty);
    expect(find.byKey(const ValueKey('ids-slider-track')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(results, [null]);
  });

  testWidgets('release records the raw distance beyond the track', (
    tester,
  ) async {
    final results = <List<IdsSliderPoint>?>[];
    await _openSlider(tester, results);

    final gesture = await tester.startGesture(
      _trackStart(tester) + const Offset(20, 20),
    );
    await gesture.moveBy(const Offset(400, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(results.single!.last.x, 400);
  });

  testWidgets('cancelled pointer can be followed by a new drag', (
    tester,
  ) async {
    final results = <List<IdsSliderPoint>?>[];
    await _openSlider(tester, results);

    final start = _trackStart(tester) + const Offset(20, 20);
    final cancelled = await tester.startGesture(start);
    await cancelled.moveBy(const Offset(100, 0));
    await cancelled.cancel();
    await tester.pump();
    expect(results, isEmpty);

    final retry = await tester.startGesture(start + const Offset(100, 0));
    await retry.moveBy(const Offset(80, 0));
    await retry.up();
    await tester.pumpAndSettle();

    expect(results.single!.last.x, 80);
    expect(results.single!.map((point) => point.x), isNot(contains(100)));
  });
}
