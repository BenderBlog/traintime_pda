// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:shared_preferences/shared_preferences.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';

/// A preference store backed by shared preferences.
///
/// Keys are stored as `<namespace>.<key>`.
/// [instance] uses the `free.` namespace.
/// [forOwner] returns the same store for each namespace.
///
/// All the instances with the same namespace are the singleton instance.
final class SharedPreferenceStore implements PreferenceStoreInterface {
  SharedPreferenceStore._(this._preferences, this._prefix);

  final SharedPreferencesWithCache _preferences;
  final String _prefix;

  static Future<SharedPreferencesWithCache>? _backendFuture;
  static final Map<String, Future<SharedPreferenceStore>> _instances = {};

  static Future<SharedPreferencesWithCache> _load() => _backendFuture ??=
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      ).onError((Object error, StackTrace stack) {
        _backendFuture = null;
        Error.throwWithStackTrace(error, stack);
      });

  static Future<PreferenceStoreInterface> instance() => forOwner('free');

  static Future<PreferenceStoreInterface> forOwner(String namespace) {
    if (namespace.isEmpty || namespace.contains('.')) {
      throw ArgumentError.value(namespace, 'namespace');
    }
    return _instances.putIfAbsent(namespace, () {
      return _load()
          .then(
            (preferences) =>
                SharedPreferenceStore._(preferences, '$namespace.'),
          )
          .onError((Object error, StackTrace stack) {
            _instances.remove(namespace);
            Error.throwWithStackTrace(error, stack);
          });
    });
  }

  String _key(String key) => '$_prefix$key';

  @override
  String? getString(String key) => _preferences.getString(_key(key));

  @override
  bool? getBool(String key) => _preferences.getBool(_key(key));

  @override
  int? getInt(String key) => _preferences.getInt(_key(key));

  @override
  double? getDouble(String key) => _preferences.getDouble(_key(key));

  @override
  bool contains(String key) => _preferences.containsKey(_key(key));

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(_key(key), value);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(_key(key), value);

  @override
  Future<void> setInt(String key, int value) =>
      _preferences.setInt(_key(key), value);

  @override
  Future<void> setDouble(String key, double value) =>
      _preferences.setDouble(_key(key), value);

  @override
  Future<void> remove(String key) => _preferences.remove(_key(key));
}
