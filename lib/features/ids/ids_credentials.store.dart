// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:watermeter/core/secure_storage/secure_store_interface.dart';

import 'ids_credentials.model.dart';

final class SecureIdsCredentialsStore {
  SecureIdsCredentialsStore(this._secure);

  static const _key = 'ids.credentials';

  final SecureStoreInterface _secure;

  Future<IdsCredentials?> read() async {
    final stored = await _secure.read(_key);
    return stored == null ? null : _decode(stored);
  }

  Future<void> write(IdsCredentials credentials) async {
    final encoded = jsonEncode({
      'username': credentials.username,
      'password': credentials.password,
    });
    await _secure.write(_key, encoded);
    if (await _secure.read(_key) != encoded) {
      throw StateError('IDS credentials were not saved');
    }
  }

  Future<void> clear() => _secure.delete(_key);

  IdsCredentials _decode(String stored) {
    final Object? value;
    try {
      value = jsonDecode(stored);
    } on FormatException {
      throw const FormatException('Invalid saved IDS credentials');
    }
    if (value is! Map<String, dynamic> ||
        value['username'] is! String ||
        value['password'] is! String) {
      throw const FormatException('Invalid saved IDS credentials');
    }
    try {
      return IdsCredentials(
        value['username'] as String,
        value['password'] as String,
      );
    } on ArgumentError {
      throw const FormatException('Invalid saved IDS credentials');
    }
  }
}
