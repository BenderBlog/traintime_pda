import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/core/interfaces/preference_store_interface.dart';
import 'package:watermeter/core/preferences/shared_preference_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SharedPreferences test', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'legacy': 'saved'});
    SharedPreferencesAsyncPlatform.instance = null;
    await expectLater(SharedPreferenceStore.instance, throwsStateError);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final PreferenceStoreInterface first = await SharedPreferenceStore.instance;
    final PreferenceStoreInterface second = await SharedPreferenceStore.instance;
    expect(identical(first, second), isTrue);
    expect(first.getString('legacy'), 'saved');
    expect(first.getBool('missing'), isNull);

    await first.setBool('enabled', true);
    await first.setInt('count', 3);
    await first.setDouble('scale', 1.25);
    await first.setString('label', 'mine');
    expect(second.getBool('enabled'), isTrue);
    expect(second.getInt('count'), 3);
    expect(second.getDouble('scale'), 1.25);
    expect(second.getString('label'), 'mine');
    expect(second.contains('enabled'), isTrue);

    await second.remove('enabled');
    expect(first.getBool('enabled'), isNull);
    expect(first.contains('enabled'), isFalse);
  });
}
