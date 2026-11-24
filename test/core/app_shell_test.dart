// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell_page_interface.dart';

class _Page implements AppShellPageInterface {
  const _Page(this.name);

  final String name;

  @override
  String label(BuildContext context) => name;

  @override
  Widget icon(BuildContext context) => const Icon(Icons.circle_outlined);

  @override
  Widget selectedIcon(BuildContext context) => const Icon(Icons.circle);

  @override
  Widget buildPage(BuildContext context) =>
      Center(child: Text('$name content'));
}

void main() {
  testWidgets('tabs and swipes select the same page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AppShell(pages: const [_Page('A'), _Page('B')])),
    );
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('B content'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('A content'), findsOneWidget);
  });

  testWidgets('changing tabs clears focus immediately', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          pages: [
            _WidgetPage('Input', TextField(focusNode: focus)),
            const _Page('Other'),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    expect(focus.hasFocus, isTrue);
    await tester.tap(find.text('Other'));
    expect(focus.hasFocus, isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets('resizing keeps the master page state', (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: AppShell(pages: [_WidgetPage('Input', TextField())])),
    );
    await tester.enterText(find.byType(TextField), 'saved');
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(find.text('saved'), findsOneWidget);
  });

  testWidgets('narrow detail animates over the master and back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<AppShellState>();
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(key: key, pages: const [_Page('A')]),
      ),
    );

    key.currentState!.pushDetail(const Text('Detail'));
    await tester.pump();
    expect(find.text('A content'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);

    await tester.pumpAndSettle();
    key.currentState!.popDetail();
    await tester.pump();
    expect(find.text('A content'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('A content'), findsOneWidget);
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets('detail survives a width change and can pop', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<AppShellState>();
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(key: key, pages: const [_Page('A')]),
      ),
    );
    key.currentState!.pushDetail(const Text('Detail'));
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsNothing);
    key.currentState!.pushDetail(const Text('Detail'));
    await tester.pumpAndSettle();
    key.currentState!.pushDetail(const Text('Nested'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(find.text('A content'), findsOneWidget);
    expect(find.text('Nested'), findsOneWidget);
    expect(tester.getSize(find.byType(PageView)).width, 364);
    final divider = tester.getRect(find.byType(VerticalDivider));
    final drag = await tester.startGesture(divider.center);
    await drag.moveBy(const Offset(80, 0));
    await drag.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PageView)).width, greaterThan(364));
    tester.view.physicalSize = const Size(729, 800);
    await tester.pumpAndSettle();
    expect(find.byType(VerticalDivider), findsNothing);
    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(find.text('Nested'), findsOneWidget);
    key.currentState!.replaceDetail(const Text('Replacement'));
    await tester.pumpAndSettle();
    expect(find.text('Replacement'), findsOneWidget);
    expect(find.text('Detail'), findsNothing);
    key.currentState!.popDetail();
    await tester.pumpAndSettle();
    expect(find.text('Replacement'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}

class _WidgetPage extends _Page {
  const _WidgetPage(super.name, this.child);

  final Widget child;

  @override
  Widget buildPage(BuildContext context) => child;
}
