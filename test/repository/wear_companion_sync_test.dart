// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/wear_companion_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(WearCompanionSyncService.channelName);
  const node = WearNode(
    id: 'watch',
    name: 'Test watch',
    isNearby: true,
    isPaired: true,
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'sync uses existing payment cache without waiting for live authentication',
    () async {
      final calls = <String>[];
      Map<String, dynamic>? sent;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        if (call.method == 'getCachedPaymentQr') {
          expect(call.arguments['idsAccount'], 'test-account');
          return {'pngBase64': 'AQI=', 'fetchedAtEpochMs': 1000};
        }
        if (call.method == 'sendSyncPayload') {
          sent = jsonDecode(call.arguments['payload'] as String);
          return null;
        }
        throw PlatformException(code: 'unexpected_method');
      });
      expect(await _SnapshotService().pairAndSync(node), isTrue);
      expect(calls, ['getCachedPaymentQr', 'sendSyncPayload']);
      expect(sent!['paymentQr']['fetchedAtEpochMs'], 1000);
      expect(sent!['directPairing'], isTrue);
    },
  );

  test(
    'absent optional payment cache cannot prevent paired-watch schedule sync',
    () async {
      Map<String, dynamic>? sent;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getCachedPaymentQr') return null;
        if (call.method == 'sendSyncPayload') {
          sent = jsonDecode(call.arguments['payload'] as String);
          return null;
        }
        throw PlatformException(code: 'unexpected_method');
      });
      expect(await _SnapshotService().pairAndSync(node), isFalse);
      expect(sent!['schedule'], {'cached': true});
      expect(sent!.containsKey('paymentQr'), isFalse);
    },
  );

  test(
    'older phone bridge still supports sync when cache-reading method is unavailable',
    () async {
      var sent = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getCachedPaymentQr') throw MissingPluginException();
        if (call.method == 'sendSyncPayload') {
          sent = true;
          return null;
        }
        throw PlatformException(code: 'unexpected_method');
      });
      expect(await _SnapshotService().pairAndSync(node), isFalse);
      expect(sent, isTrue);
    },
  );

  test(
    'unconfirmed import surfaces failure rather than reporting sync success',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getCachedPaymentQr') return null;
        throw PlatformException(code: 'sync_not_confirmed');
      });
      await expectLater(
        _SnapshotService().pairAndSync(node),
        throwsA(isA<PlatformException>()),
      );
    },
  );
  testWidgets(
    'missing watch confirmation cannot keep phone sync waiting forever',
    (tester) async {
      final pending = Completer<Object?>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getCachedPaymentQr') return null;
        return pending.future;
      });
      final result = _SnapshotService().pairAndSync(node);
      final check = expectLater(result, throwsA(isA<StateError>()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 21));
      await check;
      pending.complete();
      await tester.pump();
    },
  );
}

class _SnapshotService extends WearCompanionSyncService {
  @override
  String get phoneAccount => 'test-account';

  @override
  Map<String, dynamic> buildSnapshot({
    required String sessionId,
    Uint8List? paymentQr,
    DateTime? paymentQrFetchedAt,
  }) => {
    'sessionId': sessionId,
    'schedule': {'cached': true},
  };
}
