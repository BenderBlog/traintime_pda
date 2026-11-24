// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/core/secure_storage/data/platform_secure_store.dart';
import 'package:watermeter/core/secure_storage/secure_store_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final values = <String, String>{};

  setUp(() {
    values.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      final arguments = Map<String, Object?>.from(call.arguments as Map);
      final key = arguments['key'] as String;
      switch (call.method) {
        case 'read':
          return values[key];
        case 'write':
          values[key] = arguments['value'] as String;
          return null;
        case 'delete':
          values.remove(key);
          return null;
        default:
          throw UnimplementedError(call.method);
      }
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'constructing twice returns the same store and shares its values',
    () async {
      final SecureStoreInterface first = PlatformSecureStore();
      final SecureStoreInterface second = PlatformSecureStore();

      expect(identical(first, second), isTrue);
      expect(await first.read('password'), isNull);
      await first.write('password', 'secret');
      expect(await second.read('password'), 'secret');
      await second.delete('password');
      expect(await first.read('password'), isNull);
    },
  );

  test('platform failures remain failures', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'locked');
    });

    final store = PlatformSecureStore();
    expect(store.read('password'), throwsA(isA<PlatformException>()));
  });
}
