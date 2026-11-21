import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/core/interfaces/preference_store_interface.dart';
import 'package:watermeter/core/preferences/shared_preference_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('free keys cannot collide with owned preference keys', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'legacy': 'saved'});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final PreferenceStoreInterface free =
        await SharedPreferenceStore.instance();
    final PreferenceStoreInterface theme = await SharedPreferenceStore.forOwner(
      'theme',
    );
    expect(await SharedPreferenceStore.instance(), same(free));
    expect(await SharedPreferenceStore.forOwner('free'), same(free));
    expect(await SharedPreferenceStore.forOwner('theme'), same(theme));
    expect(theme, isNot(same(free)));
    expect(free.getString('legacy'), isNull);
    expect(free.getBool('missing'), isNull);

    await free.setBool('enabled', true);
    await free.setInt('palette', 7);
    await free.setDouble('scale', 1.25);
    await free.setString('label', 'mine');
    await theme.setInt('palette', 3);
    expect(free.getInt('palette'), 7);
    expect(theme.getInt('palette'), 3);
    expect(free.getBool('enabled'), isTrue);
    expect(free.getDouble('scale'), 1.25);
    expect(free.getString('label'), 'mine');
    expect(free.contains('enabled'), isTrue);

    await free.remove('enabled');
    expect(free.getBool('enabled'), isNull);
    expect(free.contains('enabled'), isFalse);
    expect(theme.getBool('enabled'), isNull);

    final raw = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    expect(raw.getInt('free.palette'), 7);
    expect(raw.getInt('theme.palette'), 3);
    expect(raw.getBool('free.enabled'), isNull);
  });
}
