// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AirconController {
  static final AirconController i = AirconController._();

  final session = AirconSession();
  bool _isEnergyReloading = false;
  bool _isDeviceReloading = false;

  AirconController._() {
    final imei = imeiSignal.peek();
    final cache = session.getCache(imei: imei);
    if (cache != null) {
      _lastValidInfo.value = cache;
      energyInfoStateSignal.value = AsyncState.data(cache);
    }

    energyHistoryInfoList
      ..clear()
      ..addAll(session.getEnergyHistory());

    if (imei.isNotEmpty) {
      Future.microtask(refreshEnergyInfo);
      Future.microtask(refreshDeviceState);
    }
  }

  final imeiSignal = signal<String>(
    preference.getString(preference.Preference.airconImei),
  );
  final _lastValidInfo = signal<FetchResult<AirconEnergyInfo>?>(null);
  final energyInfoStateSignal =
      signal<AsyncState<FetchResult<AirconEnergyInfo>>>(const AsyncLoading());
  final deviceStateSignal = signal<AsyncState<AirconState>>(
    const AsyncLoading(),
  );
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
    if (imei.isEmpty || _isEnergyReloading) return;

    _isEnergyReloading = true;
    final previous = _lastValidInfo.value;
    energyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    try {
      final result = await session.getAirconEnergyInfo(imei);
      if (imei != imeiSignal.value) return;
      _lastValidInfo.value = result;
      _syncEnergyHistory(result);
      energyInfoStateSignal.set(AsyncState.data(result), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value) return;
      energyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshEnergyInfo] Have issue");
    } finally {
      _isEnergyReloading = false;
      if (imeiSignal.value.isNotEmpty && imei != imeiSignal.value) {
        Future.microtask(refreshEnergyInfo);
      }
    }
  }

  Future<void> refreshDeviceState() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _isDeviceReloading) return;

    _isDeviceReloading = true;
    final previous = deviceStateSignal.peek().value;
    deviceStateSignal.value = previous == null
        ? const AsyncLoading()
        : AsyncState.dataRefreshing(previous);
    try {
      final state = await session.getDeviceState(imei);
      if (imei != imeiSignal.value) return;
      deviceStateSignal.set(AsyncState.data(state), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value) return;
      deviceStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshDeviceState] Have issue");
    } finally {
      _isDeviceReloading = false;
      if (imeiSignal.value.isNotEmpty && imei != imeiSignal.value) {
        Future.microtask(refreshDeviceState);
      }
    }
  }

  void setDeviceState(AirconState state) {
    deviceStateSignal.set(AsyncState.data(state), force: true);
  }

  Future<void> updateImei(String rawImei) async {
    final trimmed = rawImei.trim();
    if (trimmed.isEmpty) {
      await clearImei();
      return;
    }

    final imei = normalizeImei(trimmed);
    if (imeiSignal.value != imei) {
      session.clearCache();
      AirconSession.clearEnergyHistory();
      energyHistoryInfoList.clear();
      _lastValidInfo.value = null;
      deviceStateSignal.value = const AsyncLoading();
    }
    await preference.setString(preference.Preference.airconImei, imei);
    imeiSignal.value = imei;
    await refreshEnergyInfo();
    await refreshDeviceState();
  }

  Future<void> clearImei() async {
    await preference.remove(preference.Preference.airconImei);
    imeiSignal.value = "";
    _lastValidInfo.value = null;
    energyInfoStateSignal.value = const AsyncLoading();
    deviceStateSignal.value = const AsyncLoading();
    session.clearCache();
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
