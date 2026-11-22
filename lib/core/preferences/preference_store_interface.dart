// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

/// @docImport '../preferences/shared_preference_store.dart';
/// 
/// The interface for Preference Foundation
/// 
/// All the outer module should use this rather than the implementation, [SharedPreferenceStore].
abstract interface class PreferenceStoreInterface {
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  double? getDouble(String key);
  bool contains(String key);

  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setDouble(String key, double value);
  Future<void> remove(String key);
}
