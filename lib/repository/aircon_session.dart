// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

Future<FetchResult<AirconEnergyInfo>> getAirconEnergyInfo(String imei) async {
  log.info("[AirconSession][update] Ready to update electricity info. ");
  DateTime fetchDay = DateTime.now();

  final cache = AirconSession.getCache(imei: imei);

  try {
    log.info("[AirconSession][update] Fetching from Internet.");
    var toReturn = await AirconSession().getEnergyInfo(imei);
    AirconSession.saveCache(toReturn);
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

class AirconSession extends NetworkSession {
  static const host = "gxkt.juhaolian.cn";

  static const airconEnergyCache = "AirconEnergyCache.json";
  static File fileCache = File("${supportPath.path}/$airconEnergyCache");

  static const airconEnergyHistory = "AirconEnergyHistory.json";
  static File fileHistory = File("${supportPath.path}/$airconEnergyHistory");

  static bool get isCacheExist => fileCache.existsSync();

  static FetchResult<AirconEnergyInfo>? getCache({String? imei}) {
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

  static void saveCache(AirconEnergyInfo info) {
    if (!isCacheExist) {
      fileCache.createSync(recursive: true);
    }
    fileCache.writeAsStringSync(jsonEncode(info.toJson()));
  }

  static void clearCache() {
    if (!AirconSession.fileCache.existsSync()) {
      return;
    }
    AirconSession.fileCache.deleteSync();
  }

  static List<ElectricityHistoryInfo> getEnergyHistory() {
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

  Future<AirconEnergyInfo> getEnergyInfo(String imei) async {
    final response = await dio.get(
      "https://$host/api/device/direct/state",
      queryParameters: {"imei": imei},
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;

    if (data is! Map) {
      log.error("[AirconSession][getEnergyInfo] response is not a map: $data");
      throw const AirconEnergyParseException("response is not a map");
    }

    if (data["success"] != true) {
      throw AirconEnergyParseException(data["message"]?.toString() ?? "");
    }

    return AirconEnergyInfo(
      imei: data["result"]["imei"] ?? "",
      fetchTime: DateTime.fromMillisecondsSinceEpoch(data["timestamp"] as int),
      stateTime: DateTime.fromMillisecondsSinceEpoch(
        (data["result"]["timestamp"] as int) * 1000,
      ),
      electricAmount: data["result"]["electricAmount"],
    );
  }
}

class AirconEnergyParseException implements Exception {
  final String message;

  const AirconEnergyParseException(this.message);

  @override
  String toString() => message.isEmpty
      ? "Aircon energy response parse failed"
      : "Aircon energy response parse failed: $message";
}
