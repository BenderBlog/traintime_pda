// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:watermeter/core/interfaces/preference_store_interface.dart';

/// The `core` implementation of [PreferenceStore]. 
/// 
/// This object should be inject into each feature at the assembling place.
final class SharedPreferenceStore implements PreferenceStoreInterface {
  SharedPreferenceStore._(this._preferences);

  final SharedPreferencesWithCache _preferences;

  static Future<SharedPreferenceStore>? _instance;

  static Future<SharedPreferenceStore> get instance =>
      _instance ??= _create().onError((Object error, StackTrace stack) {
        _instance = null;
        Error.throwWithStackTrace(error, stack);
      });

  static Future<SharedPreferenceStore> _create() async {
    final legacy = await SharedPreferences.getInstance();
    if (legacy.getKeys().isNotEmpty) {
      await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
        legacySharedPreferencesInstance: legacy,
        sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
        migrationCompletedKey: ' pdaMigrationCompleted',
      );
    }

    return SharedPreferenceStore._(
      await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      ),
    );
  }

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  int? getInt(String key) => _preferences.getInt(key);

  @override
  double? getDouble(String key) => _preferences.getDouble(key);

  @override
  bool contains(String key) => _preferences.containsKey(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  Future<void> setDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}
