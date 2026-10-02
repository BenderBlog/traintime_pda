// Copyright 2026 Traintime PDA Authours, originally by aqqkad.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';

class AirconSession {
  static const host = "gxkt.juhaolian.cn";
  static const _userAgent =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 26_5 like Mac OS X) "
      "AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 "
      "MicroMessenger/8.0.73(0x18004939) NetType/WIFI Language/zh_CN";

  AirconSession({Dio? client}) : _client = client ?? NetworkClients.otherDio;

  final Dio _client;

  static const airconEnergyCache = "AirconEnergyCache.json";
  static File fileCache = File("${supportPath.path}/$airconEnergyCache");

  static const airconEnergyHistory = "AirconEnergyHistory.json";
  static File fileHistory = File("${supportPath.path}/$airconEnergyHistory");

  bool get isCacheExist => fileCache.existsSync();

  FetchResult<AirconEnergyInfo>? getCache({String? imei}) {
    if (!isCacheExist) return null;
    log.info("[AirconSession][cache] Checking out cache.");
    try {
      final cache = AirconEnergyInfo.fromJson(
        jsonDecode(fileCache.readAsStringSync()),
      );
      if (imei != null && cache.imei != imei) return null;
      return FetchResult.cache(
        fetchTime: fileCache.lastModifiedSync(),
        data: cache,
      );
    } catch (e, s) {
      log.handle(e, s);
      return null;
    }
  }

  void saveCache(AirconEnergyInfo info) {
    if (!isCacheExist) {
      fileCache.createSync(recursive: true);
    }
    fileCache.writeAsStringSync(jsonEncode(info.toJson()));
  }

  void clearCache() {
    if (!AirconSession.fileCache.existsSync()) {
      return;
    }
    AirconSession.fileCache.deleteSync();
  }

  List<ElectricityHistoryInfo> getEnergyHistory() {
    final list = <ElectricityHistoryInfo>[];

    if (!fileHistory.existsSync()) {
      fileHistory.createSync(recursive: true);
      return list;
    }

    try {
      final rawHistory = fileHistory.readAsStringSync();
      if (rawHistory.isEmpty) return list;
      final toAdd = jsonDecode(rawHistory)
          .map<ElectricityHistoryInfo>(
            (data) => ElectricityHistoryInfo.fromJson(data),
          )
          .toList();
      list.addAll(toAdd);
      list.sort((a, b) => a.fetchDay.compareTo(b.fetchDay));
    } catch (e, s) {
      log.handle(e, s);
    }

    return list;
  }

  static void saveEnergyHistory(List<ElectricityHistoryInfo> history) {
    if (!fileHistory.existsSync()) {
      fileHistory.createSync(recursive: true);
    }
    fileHistory.writeAsStringSync(jsonEncode(history));
  }

  static void clearEnergyHistory() {
    if (fileHistory.existsSync()) {
      fileHistory.deleteSync();
    }
  }

  Future<AirconState> getDeviceState(String imei) async {
    final result = await _requestDeviceState(imei);
    return AirconState.fromJson(result);
  }

  Future<Map<String, dynamic>> _requestDeviceState(String imei) async {
    final response = await _client.get(
      "https://$host/api/device/direct/state",
      queryParameters: {"imei": imei},
      options: Options(headers: _headers),
    );
    final data = _ensureSuccess(response.data);
    final result = data["result"];
    if (result is! Map) {
      throw const AirconResponseException("返回结果不是设备状态");
    }
    return Map<String, dynamic>.from(result);
  }

  Future<void> sendCommand({
    required String imei,
    required Map<String, dynamic> command,
  }) async {
    final response = await _client.post(
      "https://$host/api/device/direct/command",
      data: {...command, "imei": imei},
      options: Options(headers: _headers),
    );
    _ensureSuccess(response.data);
  }

  Future<AirconEnergyInfo> getEnergyInfo(String imei) async {
    final state = await _requestDeviceState(imei);
    final timestamp = state["timestamp"] is num
        ? (state["timestamp"] as num).toInt()
        : int.tryParse(state["timestamp"]?.toString() ?? "");
    final electricAmount = state["electricAmount"] is num
        ? state["electricAmount"] as num
        : num.tryParse(state["electricAmount"]?.toString() ?? "");
    if (timestamp == null || electricAmount == null) {
      throw const AirconResponseException("空调用电数据不完整");
    }

    return AirconEnergyInfo(
      imei: state["imei"]?.toString() ?? "",
      fetchTime: DateTime.now(),
      stateTime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      electricAmount: electricAmount,
    );
  }

  Map<String, String> get _headers => {
    HttpHeaders.contentTypeHeader: Headers.jsonContentType,
    HttpHeaders.userAgentHeader: _userAgent,
  };

  Map<dynamic, dynamic> _ensureSuccess(dynamic data) {
    if (data is! Map) {
      throw const AirconResponseException("服务器返回格式错误");
    }
    if (data["success"] != true) {
      throw AirconResponseException(data["message"]?.toString() ?? "");
    }
    return data;
  }

  Future<FetchResult<AirconEnergyInfo>> getAirconEnergyInfo(String imei) async {
    log.info("[AirconSession][update] Ready to update electricity info. ");
    DateTime fetchDay = DateTime.now();

    final cache = getCache(imei: imei);

    try {
      log.info("[AirconSession][update] Fetching from Internet.");
      var toReturn = await getEnergyInfo(imei);
      saveCache(toReturn);
      return FetchResult.fresh(fetchTime: fetchDay, data: toReturn);
    } catch (e, s) {
      log.handle(e, s, "[AirconSession][update] Have issue");
      if (cache != null) {
        return FetchResult.cache(
          fetchTime: cache.fetchTime,
          data: cache.data,
          hintKey: e.toString(),
        );
      }
      rethrow;
    }
  }
}

class AirconResponseException implements Exception {
  final String message;

  const AirconResponseException(this.message);

  @override
  String toString() => message.isEmpty
      ? "Aircon request failed"
      : "Aircon request failed: $message";
}
