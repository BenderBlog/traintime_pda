// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

/*
import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AirconController {
  static final AirconController i = AirconController._();

  bool _isReloading = false;

  AirconController._() {
    final imei = imeiSignal.peek();
    final cache = AirconSession.getCache(imei: imei);
    if (cache != null) {
      _lastValidInfo.value = cache;
      energyInfoStateSignal.value = AsyncState.data(cache);
    }

    energyHistoryInfoList
      ..clear()
      ..addAll(AirconSession.getEnergyHistory());

    if (imei.isNotEmpty) {
      Future.microtask(refreshEnergyInfo);
    }
  }

  final imeiSignal = signal<String>(
    preference.getString(preference.Preference.airconImei),
  );
  final _lastValidInfo = signal<FetchResult<AirconEnergyInfo>?>(null);
  final energyInfoStateSignal =
      signal<AsyncState<FetchResult<AirconEnergyInfo>>>(const AsyncLoading());
  final energyHistoryInfoList = <ElectricityHistoryInfo>[];

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

  void _syncEnergyHistory(FetchResult<AirconEnergyInfo> info) {
    if (info.isCache) return;

    final newHistoryInfo = List<ElectricityHistoryInfo>.from(
      energyHistoryInfoList,
    );
    final historyInfo = ElectricityHistoryInfo(
      fetchDay: info.data.stateTime,
      remain: info.data.electricAmount.toString(),
    );

    if (newHistoryInfo.isNotEmpty) {
      final last = newHistoryInfo.last;
      if (last.fetchDay.isAtSameDayAs(info.data.stateTime)) {
        if (last.remain == historyInfo.remain) return;

        newHistoryInfo[newHistoryInfo.length - 1] = historyInfo;
        AirconSession.saveEnergyHistory(newHistoryInfo);
        energyHistoryInfoList
          ..clear()
          ..addAll(newHistoryInfo);
        return;
      }
    }

    if (newHistoryInfo.length > 14) {
      newHistoryInfo.removeAt(0);
    }
    newHistoryInfo.add(historyInfo);
    AirconSession.saveEnergyHistory(newHistoryInfo);
    energyHistoryInfoList
      ..clear()
      ..addAll(newHistoryInfo);
  }

  Future<void> refreshEnergyInfo() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _isReloading) return;

    _isReloading = true;
    final previous = _lastValidInfo.value;
    energyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    try {
      final result = await getAirconEnergyInfo(imei);
      _lastValidInfo.value = result;
      _syncEnergyHistory(result);
      energyInfoStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      energyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshEnergyInfo] Have issue");
    } finally {
      _isReloading = false;
    }
  }

  Future<void> updateImei(String rawImei) async {
    final trimmed = rawImei.trim();
    if (trimmed.isEmpty) {
      await clearImei();
      return;
    }

    final imei = normalizeImei(trimmed);
    if (imeiSignal.value != imei) {
      AirconSession.clearCache();
      AirconSession.clearEnergyHistory();
      energyHistoryInfoList.clear();
      _lastValidInfo.value = null;
    }
    await preference.setString(preference.Preference.airconImei, imei);
    imeiSignal.value = imei;
    await refreshEnergyInfo();
  }

  Future<void> clearImei() async {
    await preference.remove(preference.Preference.airconImei);
    imeiSignal.value = "";
    _lastValidInfo.value = null;
    energyInfoStateSignal.value = const AsyncLoading();
    AirconSession.clearCache();
    AirconSession.clearEnergyHistory();
    energyHistoryInfoList.clear();
  }
}

class AirconImeiInvalidException implements Exception {
  final String raw;

  const AirconImeiInvalidException(this.raw);

  @override
  String toString() => "Invalid aircon IMEI: $raw";
}
*/
