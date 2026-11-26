// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/core/secure_storage/secure_store_interface.dart';
import 'package:watermeter/features/ids/ids_credentials.model.dart';
import 'package:watermeter/features/ids/ids_credentials.store.dart';

void main() {
  test('saves and reads account and password as one secure value', () async {
    final secure = _MemorySecureStore();
    final store = SecureIdsCredentialsStore(secure);

    await store.write(IdsCredentials('alice', 'secret'));

    expect(secure.values.keys, ['ids.credentials']);
    expect((await store.read())?.username, 'alice');
    expect((await store.read())?.password, 'secret');
  });

  test('missing secure credentials report signed out', () async {
    final store = SecureIdsCredentialsStore(_MemorySecureStore());
    expect(await store.read(), isNull);
  });

  test('corrupt secure credentials fail explicitly', () async {
    final secure = _MemorySecureStore()..values['ids.credentials'] = '{broken';
    final store = SecureIdsCredentialsStore(secure);

    await expectLater(store.read(), throwsFormatException);
  });

  test('failed secure write does not report saved credentials', () async {
    final secure = _MemorySecureStore()..failWrite = true;
    final store = SecureIdsCredentialsStore(secure);

    await expectLater(
      store.write(IdsCredentials('alice', 'secret')),
      throwsStateError,
    );
    expect(await store.read(), isNull);
  });

  test('logout removes saved secure credentials', () async {
    final store = SecureIdsCredentialsStore(_MemorySecureStore());
    await store.write(IdsCredentials('alice', 'secret'));

    await store.clear();

    expect(await store.read(), isNull);
  });
}

final class _MemorySecureStore implements SecureStoreInterface {
  final values = <String, String>{};
  bool failWrite = false;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (failWrite) throw StateError('locked');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
