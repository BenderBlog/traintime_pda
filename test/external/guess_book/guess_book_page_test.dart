import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/external/guess_book/lib/guess_book_page.dart';
import 'package:watermeter/generated/translations.g.dart';

void main() {
  testWidgets('答题、切换模式及更换题库', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget page(Map<String, String> books) => TranslationProvider(
      child: MaterialApp(home: GuessBookPage(books: books)),
    );

    await tester.pumpWidget(page(const {'三体': '🌍'}));
    expect(find.text('🌍'), findsOneWidget);
    await tester.tap(find.text('三体'));
    await tester.pump();
    expect(find.text('答对了！'), findsOneWidget);

    await tester.tap(find.text('下一题'));
    await tester.pump();
    expect(find.text('答对了！'), findsNothing);

    await tester.tap(find.text('输入题'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '《三体》');
    await tester.pump();
    await tester.tap(find.text('提交答案'));
    await tester.pump();
    expect(find.text('答对了！'), findsOneWidget);

    await tester.pumpWidget(page(const {'新书': '📚'}));
    expect(find.text('📚'), findsOneWidget);
    expect(find.text('答对了！'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

    await tester.pumpWidget(page(const {}));
    expect(find.text('题库暂时为空'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
