// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart' as network;

class WearClassTableCache {
  WearClassTableCache._();

  static const fileName = 'ClassTable.json';
  static File file = File('${network.supportPath.path}/$fileName');

  static bool get exists => file.existsSync();

  static Future<void> write(ClassTableData data) =>
      file.writeAsString(jsonEncode(data.toJson()));

  static (DateTime, ClassTableData)? read() {
    if (!exists) return null;
    try {
      return (
        file.lastModifiedSync(),
        ClassTableData.fromJson(jsonDecode(file.readAsStringSync())),
      );
    } catch (error, stackTrace) {
      log.handle(error, stackTrace, '[WearClassTableCache] Invalid cache.');
      return null;
    }
  }

  static Future<void> clear() async {
    if (await file.exists()) await file.delete();
  }
}

class WearExperimentCache {
  WearExperimentCache._();

  static const fileName = 'OtherExperiment.json';
  static File file = File('${network.supportPath.path}/$fileName');

  static bool get exists => file.existsSync();

  static Future<void> write(List<ExperimentData> data) =>
      file.writeAsString(jsonEncode(data));

  static (DateTime, List<ExperimentData>)? read() {
    if (!exists) return null;
    try {
      final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      return (
        file.lastModifiedSync(),
        decoded
            .map((item) => ExperimentData.fromJson(item))
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      log.handle(error, stackTrace, '[WearExperimentCache] Invalid cache.');
      return null;
    }
  }

  static Future<void> clear() async {
    if (await file.exists()) await file.delete();
  }
}
