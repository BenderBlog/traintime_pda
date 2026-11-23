import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/shared/layouts/grid_page/grid_page.dart';
import 'package:watermeter/core/shared/layouts/grid_page/grid_page_card_interface.dart';
import 'package:watermeter/generated/translations.g.dart';

class _Preferences implements PreferenceStoreInterface {
  final values = <String, String>{};
  @override
  String? getString(String key) => values[key];
  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  bool? getBool(String key) => null;
  @override
  int? getInt(String key) => null;
  @override
  double? getDouble(String key) => null;
  @override
  bool contains(String key) => values.containsKey(key);
  @override
  Future<void> setBool(String key, bool value) async {}
  @override
  Future<void> setInt(String key, int value) async {}
  @override
  Future<void> setDouble(String key, double value) async {}
}

class _Card implements GridPageCardInterface {
  _Card(this.id, this._flex);
  @override
  final String id;
  final int _flex;
  @override
  int flex() => _flex;
  @override
  String title(BuildContext context) => id;
  @override
  Widget buildCard(BuildContext context, bool editMode) => Text(id);
}

Widget _app(Widget home) => TranslationProvider(child: MaterialApp(home: home));

GridPage _page(List<GridPageCardInterface> cards, _Preferences preferences) =>
    GridPage(
      icons: const GridPageIcons(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
      ),
      navigationLabel: 'Info',
      cards: cards,
      preferences: preferences,
    );

void main() {
  setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));
  testWidgets('page text follows the translation context', (tester) async {
    final original = LocaleSettings.currentLocale;
    addTearDown(() => LocaleSettings.setLocaleSync(original));
    LocaleSettings.setLocaleSync(AppLocale.zh);
    final page = _page([_Card('a', 1)], _Preferences());
    await tester.pumpWidget(_app(page));
    expect(page.label(tester.element(find.byType(GridPage))), 'Info');
    expect(find.text('校园信息查询'), findsOneWidget);
    expect(find.byTooltip('编辑布局'), findsOneWidget);
    await tester.tap(find.byTooltip('编辑布局'));
    await tester.pump();
    expect(find.byTooltip('完成'), findsOneWidget);
    expect(find.byTooltip('恢复默认布局'), findsOneWidget);
    await tester.tap(find.byTooltip('管理隐藏卡片'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('没有隐藏的卡片'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await LocaleSettings.setLocale(AppLocale.en);
    await tester.pump(const Duration(milliseconds: 500));
    expect(page.label(tester.element(find.byType(GridPage))), 'Info');
    expect(find.text('School Info Center'), findsOneWidget);
    await tester.tap(find.byTooltip('Done'));
    await tester.pump();
    expect(find.byTooltip('Edit Layout'), findsOneWidget);
  });

  testWidgets('renders cards in saved order and omits hidden cards', (
    tester,
  ) async {
    final preferences = _Preferences();
    preferences.values['order'] = '["b","a"]';
    preferences.values['hidden'] = '["a"]';
    final page = _page([
      _Card('a', 1),
      _Card('b', 1),
      _Card('c', 1),
    ], preferences);
    await tester.pumpWidget(_app(Builder(builder: page.buildPage)));
    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('b')).dx,
      lessThan(tester.getTopLeft(find.text('c')).dx),
    );
  });

  test('rejects invalid card spans and duplicate IDs', () {
    final preferences = _Preferences();
    expect(() => _page([_Card('a', 0)], preferences), throwsArgumentError);
    expect(
      () => _page([_Card('a', 1), _Card('a', 2)], preferences),
      throwsArgumentError,
    );
  });

  testWidgets('hides, restores and resets cards through preferences', (
    tester,
  ) async {
    final preferences = _Preferences();
    final page = _page([_Card('a', 1), _Card('b', 1)], preferences);
    await tester.pumpWidget(_app(page));
    await tester.tap(find.byTooltip('Edit Layout'));
    await tester.pump();
    await tester.tap(find.byTooltip('a'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(preferences.getString('hidden'), '["a"]');
    expect(find.text('a'), findsNothing);

    await tester.tap(find.byTooltip('Manage hidden cards'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byTooltip('a'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(preferences.getString('hidden'), '[]');
    expect(find.text('Manage hidden cards'), findsNothing);
    expect(find.text('a'), findsOneWidget);

    preferences.values['order'] = '["b","a"]';
    await tester.tap(find.byTooltip('Reset Layout'));
    await tester.pump();
    expect(preferences.getString('order'), '[]');
    expect(preferences.getString('hidden'), '[]');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _app(_page([_Card('a', 1), _Card('b', 1)], preferences)),
    );
    expect(find.text('a'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('a')).dx,
      lessThan(tester.getTopLeft(find.text('b')).dx),
    );
  });

  testWidgets('dragging a card saves its new order', (tester) async {
    final preferences = _Preferences();
    await tester.pumpWidget(
      _app(_page([_Card('a', 1), _Card('b', 1), _Card('c', 1)], preferences)),
    );
    await tester.tap(find.byTooltip('Edit Layout'));
    await tester.pump();
    final drag = await tester.startGesture(tester.getCenter(find.text('c')));
    await tester.pump(const Duration(milliseconds: 600));
    await drag.moveTo(tester.getCenter(find.text('a')));
    await tester.pump();
    await drag.up();
    await tester.pump();
    expect(preferences.getString('order'), '["c","a","b"]');
  });

  testWidgets('dragging a card forward moves it past the target', (tester) async {
    final preferences = _Preferences();
    await tester.pumpWidget(
      _app(_page([_Card('a', 1), _Card('b', 1), _Card('c', 1)], preferences)),
    );
    await tester.tap(find.byTooltip('Edit Layout'));
    await tester.pump();
    final drag = await tester.startGesture(tester.getCenter(find.text('a')));
    await tester.pump(const Duration(milliseconds: 600));
    await drag.moveTo(tester.getCenter(find.text('b')));
    await tester.pump();
    await drag.up();
    await tester.pump();
    expect(preferences.getString('order'), '["b","a","c"]');
    expect(
      tester.getTopLeft(find.text('b')).dx,
      lessThan(tester.getTopLeft(find.text('a')).dx),
    );
  });

  testWidgets('reordering keeps saved IDs for cards not registered yet', (
    tester,
  ) async {
    final preferences = _Preferences();
    preferences.values['order'] = '["future","b","a"]';
    await tester.pumpWidget(
      _app(_page([_Card('a', 1), _Card('b', 1)], preferences)),
    );
    await tester.tap(find.byTooltip('Edit Layout'));
    await tester.pump();
    final drag = await tester.startGesture(tester.getCenter(find.text('a')));
    await tester.pump(const Duration(milliseconds: 600));
    await drag.moveTo(tester.getCenter(find.text('b')));
    await tester.pump();
    await drag.up();
    await tester.pump();
    expect(preferences.getString('order'), '["future","a","b"]');
  });

  testWidgets('card spans keep the original four-column grid', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(240, 600));
    await tester.pumpWidget(
      _app(_page([_Card('wide', 4), _Card('small', 1)], _Preferences())),
    );
    final small = find
        .ancestor(of: find.text('small'), matching: find.byType(SizedBox))
        .first;
    expect(tester.widget<SizedBox>(small).width, 56);
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pump();
    expect(tester.widget<SizedBox>(small).width, 96);
  });

  testWidgets('narrow cards fill earlier gaps left by wide cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _page([
          _Card('first', 3),
          _Card('wide', 2),
          _Card('last', 1),
        ], _Preferences()),
      ),
    );
    expect(
      tester.getTopLeft(find.text('last')).dy,
      tester.getTopLeft(find.text('first')).dy,
    );
    expect(
      tester.getTopLeft(find.text('last')).dx,
      greaterThan(tester.getTopLeft(find.text('first')).dx),
    );
  });
}
