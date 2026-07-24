// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

class AirconSession extends NetworkSession {
  static const host = "gxkt.juhaolian.cn";
  static const airconEnergyHistory = "AirconEnergyHistory.json";
  static File fileHistory = File("${supportPath.path}/$airconEnergyHistory");

  static String? tryParseImei(String raw) {
    final matches = RegExp(
      r"\d{15}",
    ).allMatches(raw).map((e) => e.group(0)!).toList();
    if (matches.isEmpty) return null;
    return matches.first;
  }

  static String normalizeImei(String raw) {
    final parsed = tryParseImei(raw.trim());
    if (parsed == null) {
      throw AirconImeiInvalidException(raw);
    }
    return parsed;
  }

  Future<AirconEnergyInfo> getEnergyInfo(String rawImei) async {
    final imei = normalizeImei(rawImei);
    final response = await dio.get(
      "https://$host/api/device/direct/state",
      queryParameters: {"imei": imei},
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (data is! Map) {
      throw const AirconEnergyParseException("response is not a map");
    }

    return AirconEnergyInfo.fromJuhaolianJson(Map<String, dynamic>.from(data));
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
}

class AirconImeiInvalidException implements Exception {
  final String raw;

  const AirconImeiInvalidException(this.raw);

  @override
  String toString() => "Invalid aircon IMEI: $raw";
}
