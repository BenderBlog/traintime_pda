// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/ids_session/classtable_session.dart';
import 'package:watermeter/repository/ids_session/school_card_session.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';
import 'package:watermeter/repository/ids_session/sysj_session.dart';

/// Phone-side endpoint of the XDYou Wear companion protocol.
class WearCompanionSyncService {
  static const channelName =
      'io.github.benderblog.traintime_pda/wear_companion_phone';
  static const syncPath = '/traintime_pda_wear_os/sync/v1';
  static const _channel = MethodChannel(channelName);

  const WearCompanionSyncService();

  String get phoneAccount =>
      preference.getString(preference.Preference.idsAccount);

  Future<void> startPaymentProxy() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'receivePaymentQrRequest') {
        throw MissingPluginException('Unknown companion call ${call.method}');
      }
      final nodeId = call.arguments;
      if (nodeId is! String || nodeId.isEmpty) return;
      Map<String, dynamic> response;
      try {
        final bytes = await SchoolCardSession().getQRCode();
        response = {
          'ok': true,
          'pngBase64': base64Encode(bytes),
          'fetchedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        };
      } on IDSReAuthRequiredException {
        response = {'ok': false, 'error': 'phone_authentication_required'};
      } on IDSReAuthCancelledException {
        response = {'ok': false, 'error': 'phone_authentication_cancelled'};
      } catch (_) {
        response = {'ok': false, 'error': 'phone_payment_request_failed'};
      }
      await _channel.invokeMethod<void>('sendPaymentQrResponse', {
        'nodeId': nodeId,
        'payload': jsonEncode(response),
      });
    });
  }

  Map<String, dynamic> buildSnapshot({
    required String sessionId,
    Uint8List? paymentQr,
    DateTime? paymentQrFetchedAt,
  }) {
    final account = phoneAccount;
    final password = preference.getString(preference.Preference.idsPassword);
    final classTable = ClassTableSession().getCache()?.$2;
    if (account.isEmpty || password.isEmpty) {
      throw StateError('请先在手机端登录 IDS');
    }
    if (classTable == null) {
      throw StateError('手机端暂无课表缓存，请先刷新首页');
    }

    final experiments = SysjSession().getCache()?.$2;
    return {
      'schemaVersion': 1,
      'sessionId': sessionId,
      'schedule': {
        'classTable': classTable.toJson(),
        if (experiments != null)
          'otherExperiments': experiments.map((item) => item.toJson()).toList(),
      },
      if (paymentQr != null)
        'paymentQr': {
          'pngBase64': base64Encode(paymentQr),
          'fetchedAtEpochMs':
              (paymentQrFetchedAt ?? DateTime.now()).millisecondsSinceEpoch,
        },
      'generatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<Map<String, dynamic>> _buildSnapshotWithCachedPaymentQr({
    required String sessionId,
  }) async {
    final snapshot = buildSnapshot(sessionId: sessionId);
    try {
      final cached = await _channel
          .invokeMapMethod<String, dynamic>('getCachedPaymentQr', {
            'idsAccount': phoneAccount,
          })
          .timeout(const Duration(seconds: 2));
      if (cached?['profileId'] is String) {
        snapshot['profileId'] = cached!['profileId'];
      }
      if (cached != null &&
          cached['pngBase64'] is String &&
          (cached['pngBase64'] as String).isNotEmpty &&
          cached['fetchedAtEpochMs'] is num &&
          (cached['fetchedAtEpochMs'] as num) >= 0) {
        snapshot['paymentQr'] = {
          'pngBase64': cached['pngBase64'],
          'fetchedAtEpochMs': cached['fetchedAtEpochMs'],
        };
      }
    } catch (_) {
      // An optional cached code must never block offline schedule synchronization.
    }
    return snapshot;
  }

  Future<List<WearNode>> connectedNodes() async {
    final raw = await _channel.invokeListMethod<Object>(
      'getConnectedWearNodes',
    );
    return (raw ?? const <Object>[])
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return WearNode(
            id: map['id']! as String,
            name: map['name']! as String,
            isNearby: map['isNearby'] == true,
            isPaired: map['isPaired'] == true,
          );
        })
        .toList(growable: false);
  }

  Future<bool> pairAndSync(WearNode node) async {
    final snapshot = await _buildSnapshotWithCachedPaymentQr(
      sessionId: 'direct-pairing',
    );
    snapshot['directPairing'] = true;
    final payload = jsonEncode(snapshot);
    await _channel
        .invokeMethod<void>('sendSyncPayload', {
          'nodeId': node.id,
          'messagePath': syncPath,
          'payload': payload,
        })
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw StateError('同步超时，请保持手表应用在前台后重试'),
        );
    return snapshot.containsKey('paymentQr');
  }

  /// Updates the native cache used to answer a bound watch in the background.
  Future<void> cacheLatestSnapshot() async {
    final snapshot = await _buildSnapshotWithCachedPaymentQr(
      sessionId: 'background-sync',
    );
    final payload = jsonEncode(snapshot);
    await _channel.invokeMethod<void>('cacheSyncPayload', {'payload': payload});
  }
}

class WearNode {
  final String id;
  final String name;
  final bool isNearby;
  final bool isPaired;

  const WearNode({
    required this.id,
    required this.name,
    required this.isNearby,
    required this.isPaired,
  });
}
