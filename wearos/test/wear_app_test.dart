import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/wearos/wear_app.dart';
import 'package:watermeter/wearos/wear_home_page.dart';
import 'package:watermeter/wearos/wear_schedule_service.dart';

void main() {
  testWidgets('first launch is companion-only and has no IDS login form', (
    tester,
  ) async {
    const channel = MethodChannel(
      'io.github.benderblog.traintime_pda/wear_companion_sync',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(const WearApp(isFirst: true));
    await tester.pump();

    expect(find.text('等待手机配对'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('登录'), findsNothing);
    expect(find.textContaining('设置 > XDYou Wear'), findsOneWidget);
  });

  testWidgets('home dashboard bounds long text on a round watch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384, 384);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    const longTitle = '很长很长很长很长很长的课程名称';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WearHomeDashboard(
            data: WearHomeData(
              todayItems: [
                WearAgendaItem(
                  kind: WearAgendaKind.course,
                  title: longTitle,
                  start: DateTime(2026, 5, 19, 8, 30),
                  end: DateTime(2026, 5, 19, 10, 5),
                  location: '很长很长很长很长很长的教室名称',
                  subtitle: '很长很长很长很长很长的教师名称',
                ),
              ],
              tomorrowItems: const [],
            ),
            onRefresh: () async {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final titleText = tester.widget<Text>(find.text(longTitle));
    expect(titleText.maxLines, 1);
    expect(titleText.overflow, TextOverflow.ellipsis);
    expect(find.text('校园卡'), findsOneWidget);
  });
}
