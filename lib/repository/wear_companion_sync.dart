// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';

/// Phone-side endpoint of the XDYou Wear companion protocol.
class WearCompanionSyncService {
  static const channelName =
      'io.github.benderblog.traintime_pda/wear_companion_phone';
  static const syncPath = '/traintime_pda_wear_os/sync/v1';
  static const _channel = MethodChannel(channelName);

  const WearCompanionSyncService();

  Map<String, dynamic> buildSnapshot({required String sessionId}) {
    final account = preference.getString(preference.Preference.idsAccount);
    final password = preference.getString(preference.Preference.idsPassword);
    final semester = preference.getString(
      preference.Preference.currentSemester,
    );
    final classTable = ClassTableSession.getCache()?.$2;
    if (account.isEmpty || password.isEmpty) {
      throw StateError('请先在手机端登录 IDS');
    }
    if (classTable == null) {
      throw StateError('手机端暂无课表缓存，请先刷新首页');
    }

    final experiments = SysjSession.getCache()?.$2;
    return {
      'schemaVersion': 1,
      'sessionId': sessionId,
      // The watch uses these credentials only for the payment-code exception.
      'credentials': {
        'idsAccount': account,
        'idsPassword': password,
        if (preference.contains(preference.Preference.role))
          'isPostGraduate': preference.getBool(preference.Preference.role),
        'currentSemester': semester,
      },
      'schedule': {
        'classTable': classTable.toJson(),
        if (experiments != null)
          'otherExperiments': experiments.map((item) => item.toJson()).toList(),
      },
      'generatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
    };
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
          );
        })
        .toList(growable: false);
  }

  Future<void> pairAndSync(WearNode node) async {
    final snapshot = buildSnapshot(sessionId: 'direct-pairing');
    snapshot['directPairing'] = true;
    final payload = jsonEncode(snapshot);
    await _channel.invokeMethod<void>('sendSyncPayload', {
      'nodeId': node.id,
      'messagePath': syncPath,
      'payload': payload,
    });
  }

  /// Updates the native cache used to answer a bound watch in the background.
  Future<void> cacheLatestSnapshot() async {
    final payload = jsonEncode(buildSnapshot(sessionId: 'background-sync'));
    await _channel.invokeMethod<void>('cacheSyncPayload', {'payload': payload});
  }
}

class WearNode {
  final String id;
  final String name;
  final bool isNearby;

  const WearNode({
    required this.id,
    required this.name,
    required this.isNearby,
  });
}
