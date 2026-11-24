// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:watermeter/core/secure_storage/secure_store_interface.dart';

final class PlatformSecureStore implements SecureStoreInterface {
  factory PlatformSecureStore() => _instance;

  PlatformSecureStore._()
    : _storage = Platform.isMacOS
          ? const FlutterSecureStorage(
              mOptions: MacOsOptions(usesDataProtectionKeychain: false),
            )
          : const FlutterSecureStorage();

  static final PlatformSecureStore _instance = PlatformSecureStore._();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
