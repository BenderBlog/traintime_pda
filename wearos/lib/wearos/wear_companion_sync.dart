// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart' as network;
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/wearos/wear_schedule_service.dart';
import 'package:watermeter/wearos/wear_qr_page.dart';

const wearCompanionSyncEnvelopeExampleJson = '''
{
  "schemaVersion": 1,
  "sessionId": "<sessionId from pairing QR>",
  "credentials": {
    "idsAccount": "2200000000",
    "idsPassword": "saved-password",
    "isPostGraduate": false,
    "currentSemester": "2026-1"
  },
  "schedule": {
    "classTable": {
      "semesterLength": 16,
      "semesterCode": "2026-1",
      "termStartDay": "2026-05-18 00:00:00",
      "classDetail": [{"name": "数据库系统"}],
      "userDefinedDetail": [],
      "notArranged": [],
      "timeArrangement": [],
      "classChanges": []
    }
  }
}
''';

class WearCredentialSyncPayload {
  final String idsAccount;
  final String idsPassword;
  final bool? isPostGraduate;
  final String? currentSemester;

  const WearCredentialSyncPayload({
    required this.idsAccount,
    required this.idsPassword,
    this.isPostGraduate,
    this.currentSemester,
  });
}

class WearScheduleSyncPayload {
  final ClassTableData? classTable;
  final List<ExperimentData>? otherExperiments;

  const WearScheduleSyncPayload({this.classTable, this.otherExperiments});
}

class WearPaymentQrSyncPayload {
  final Uint8List bytes;
  final DateTime fetchedAt;

  const WearPaymentQrSyncPayload({
    required this.bytes,
    required this.fetchedAt,
  });
}

class WearCompanionSyncEnvelope {
  final String sessionId;
  final WearCredentialSyncPayload credentials;
  final WearScheduleSyncPayload schedule;
  final WearPaymentQrSyncPayload? paymentQr;

  const WearCompanionSyncEnvelope({
    required this.sessionId,
    required this.credentials,
    required this.schedule,
    this.paymentQr,
  });

  factory WearCompanionSyncEnvelope.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version != 1) {
      throw const FormatException('Unsupported Wear sync schema version.');
    }
    final sessionId = json['sessionId'];
    if (sessionId is! String || sessionId.isEmpty) {
      throw const FormatException('Wear sync session is missing.');
    }
    final credentials = _credentialPayloadFromJson(json['credentials']);
    final schedule = _schedulePayloadFromJson(json['schedule']);
    final paymentQr = _paymentQrPayloadFromJson(json['paymentQr']);
    return WearCompanionSyncEnvelope(
      sessionId: sessionId,
      credentials: credentials,
      schedule: schedule,
      paymentQr: paymentQr,
    );
  }

  static WearCompanionSyncEnvelope decode(Object? payload) {
    if (payload is String) {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return WearCompanionSyncEnvelope.fromJson(decoded);
      }
      throw const FormatException('Wear sync payload must be a JSON object.');
    }
    if (payload is Map) {
      return WearCompanionSyncEnvelope.fromJson(_stringKeyedMap(payload));
    }
    throw const FormatException('Wear sync payload must be a string or map.');
  }

  Future<void> importInto(WearCompanionSyncPort port) async {
    await port.importCredentials(credentials);
    await port.importSchedule(schedule);
    final qr = paymentQr;
    if (qr != null) await port.importPaymentQr(qr);
  }
}

class WearCompanionSyncBridge {
  static const channelName =
      'io.github.benderblog.traintime_pda/wear_companion_sync';
  static const syncMessagePath = '/traintime_pda_wear_os/sync/v1';
  static const _channel = MethodChannel(channelName);

  final WearCompanionSyncPort _port;
  final MethodChannel _methodChannel;
  final _imports = StreamController<WearCompanionSyncEnvelope>.broadcast();

  WearCompanionSyncBridge({
    WearCompanionSyncPort port = const WearLocalCompanionSyncPort(),
    MethodChannel methodChannel = _channel,
  }) : _port = port,
       _methodChannel = methodChannel;

  Stream<WearCompanionSyncEnvelope> get imports => _imports.stream;

  Future<void> beginDirectPairing() =>
      _methodChannel.invokeMethod<void>('beginDirectPairing');

  Future<void> start() async {
    _methodChannel.setMethodCallHandler(_handleNativeCall);
    final pending = await _methodChannel.invokeMethod<Object>(
      'readPendingSyncPayload',
    );
    if (pending != null) {
      await _importNativePayload(pending);
    }
  }

  Future<void> requestSync() =>
      _methodChannel.invokeMethod<void>('requestCompanionSync');

  Future<void> stop() async {
    _methodChannel.setMethodCallHandler(null);
  }

  Future<void> dispose() async {
    await stop();
    await _imports.close();
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'receiveSyncPayload':
        try {
          await _importNativePayload(call.arguments);
        } catch (error, stackTrace) {
          _imports.addError(error, stackTrace);
          rethrow;
        }
        return;
      default:
        throw MissingPluginException('Unknown Wear sync method ${call.method}');
    }
  }

  Future<void> _importNativePayload(Object? payload) async {
    final envelope = WearCompanionSyncEnvelope.decode(payload);
    await envelope.importInto(_port);
    _imports.add(envelope);
  }
}

WearCredentialSyncPayload _credentialPayloadFromJson(Object? value) {
  if (value is! Map) {
    throw const FormatException('Wear sync credentials are required.');
  }
  final json = _stringKeyedMap(value);
  final idsAccount = json['idsAccount'];
  final idsPassword = json['idsPassword'];
  if (idsAccount is! String ||
      idsAccount.isEmpty ||
      idsPassword is! String ||
      idsPassword.isEmpty) {
    throw const FormatException('Wear sync credentials are invalid.');
  }
  return WearCredentialSyncPayload(
    idsAccount: idsAccount,
    idsPassword: idsPassword,
    isPostGraduate: json['isPostGraduate'] as bool?,
    currentSemester: json['currentSemester'] as String?,
  );
}

WearScheduleSyncPayload _schedulePayloadFromJson(Object? value) {
  if (value is! Map) {
    throw const FormatException('Wear sync schedule is required.');
  }
  final json = _stringKeyedMap(value);
  final classTableJson = json['classTable'];
  if (classTableJson is! Map) {
    throw const FormatException('Wear sync class table is required.');
  }
  final experimentsJson = json['otherExperiments'];
  if (experimentsJson != null && experimentsJson is! List) {
    throw const FormatException('Wear sync experiments must be a list.');
  }
  return WearScheduleSyncPayload(
    classTable: ClassTableData.fromJson(_stringKeyedMap(classTableJson)),
    otherExperiments: experimentsJson
        ?.map((item) {
          if (item is! Map) {
            throw const FormatException('Wear sync experiment is invalid.');
          }
          return ExperimentData.fromJson(_stringKeyedMap(item));
        })
        .toList(growable: false),
  );
}

WearPaymentQrSyncPayload? _paymentQrPayloadFromJson(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw const FormatException('Wear sync payment QR must be an object.');
  }
  final json = _stringKeyedMap(value);
  final encoded = json['pngBase64'];
  final fetchedAt = json['fetchedAtEpochMs'];
  if (encoded is! String || encoded.isEmpty || fetchedAt is! int) {
    throw const FormatException('Wear sync payment QR is invalid.');
  }
  try {
    return WearPaymentQrSyncPayload(
      bytes: base64Decode(encoded),
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(fetchedAt),
    );
  } on FormatException {
    throw const FormatException('Wear sync payment QR is invalid.');
  }
}

Map<String, dynamic> _stringKeyedMap(Map<dynamic, dynamic> value) =>
    value.map((key, value) => MapEntry(key as String, value));

abstract interface class WearCompanionSyncPort {
  Future<void> importCredentials(WearCredentialSyncPayload payload);

  Future<void> importSchedule(WearScheduleSyncPayload payload);

  Future<void> importPaymentQr(WearPaymentQrSyncPayload payload);
}

class WearLocalCompanionSyncPort implements WearCompanionSyncPort {
  const WearLocalCompanionSyncPort();

  @override
  Future<void> importCredentials(WearCredentialSyncPayload payload) async {
    final accountChanged =
        preference.getString(preference.Preference.idsAccount) !=
        payload.idsAccount;
    await _clearUserScopedState(clearPaymentQr: accountChanged);
    await preference.setString(
      preference.Preference.idsAccount,
      payload.idsAccount,
    );
    await preference.setString(
      preference.Preference.idsPassword,
      payload.idsPassword,
    );
    final isPostGraduate = payload.isPostGraduate;
    if (isPostGraduate != null) {
      await preference.setBool(preference.Preference.role, isPostGraduate);
    }
    final currentSemester = payload.currentSemester;
    if (currentSemester != null && currentSemester.isNotEmpty) {
      await preference.setString(
        preference.Preference.currentSemester,
        currentSemester,
      );
      await preference.setBool(
        preference.Preference.isUserDefinedSemester,
        false,
      );
    }
  }

  @override
  Future<void> importSchedule(WearScheduleSyncPayload payload) async {
    final classTable = payload.classTable;
    if (classTable != null) {
      await ClassTableSession.updateCacheAndGroup(classTable);
      if (classTable.semesterCode.isNotEmpty) {
        await preference.setString(
          preference.Preference.currentSemester,
          classTable.semesterCode,
        );
        await preference.setBool(
          preference.Preference.isUserDefinedSemester,
          false,
        );
      }
    }

    final otherExperiments = payload.otherExperiments;
    if (otherExperiments != null) {
      await SysjSession.writeCache(otherExperiments);
    }
  }

  @override
  Future<void> importPaymentQr(WearPaymentQrSyncPayload payload) =>
      storeCachedWearPaymentQr(payload.bytes, fetchedAt: payload.fetchedAt);
}

Future<void> _clearUserScopedState({required bool clearPaymentQr}) async {
  await _deleteIdsCookieStore();
  SchoolCardSession.resetOpenId();
  await clearWearCampusCaches();
  if (clearPaymentQr) await clearCachedWearPaymentQr();
  loginState = IDSLoginState.none;
  await preference.remove(preference.Preference.currentSemester);
  await preference.remove(preference.Preference.role);
  await preference.remove(preference.Preference.isUserDefinedSemester);
}

Future<void> _deleteIdsCookieStore() async {
  final cookieStore = Directory('${network.supportPath.path}/cookie/general');
  if (await cookieStore.exists()) {
    await cookieStore.delete(recursive: true);
  }
}
