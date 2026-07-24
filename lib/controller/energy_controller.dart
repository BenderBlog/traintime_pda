// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/aircon_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/energy_session.dart';

class EnergyController {
  static final EnergyController i = EnergyController._();
  static const int defaultLowElectricityWarningThreshold = 20;
  bool _isReloading = false;
  bool _isAirconReloading = false;

  EnergyController._() {
    updateElectricityWarning();

    // Load last successful fetched electricity info
    final cache = EnergySession.getCache();
    if (cache != null) {
      _lastValidEnergyInfo.value = cache;
      energyInfoStateSignal.value = AsyncState.data(cache);
    }

    // Load last updated electricity info
    historyElectricityInfoList
      ..clear()
      ..addAll(EnergySession.getElectricityHistory());
    airconEnergyHistoryInfoList
      ..clear()
      ..addAll(AirconSession.getEnergyHistory());

    if (airconImeiSignal.peek().isNotEmpty) {
      Future.microtask(refreshAirconEnergyInfo);
    }
  }

  final _lastValidEnergyInfo = signal<FetchResult<EnergyInfo>?>(null);
  final energyInfoStateSignal = signal<AsyncState<FetchResult<EnergyInfo>>>(
    const AsyncLoading(),
  );
  
  final airconImeiSignal = signal<String>(
    preference.getString(preference.Preference.airconImei),
  );
  final airconEnergyInfoStateSignal = signal<AsyncState<AirconEnergyInfo>?>(
    null,
  );
  
  final electricityWarning = signal<int>(defaultLowElectricityWarningThreshold);
  
  final historyElectricityInfoList = <ElectricityHistoryInfo>[];
  final airconEnergyHistoryInfoList = <ElectricityHistoryInfo>[];

  void updateElectricityWarning() {
    final isEnabled =
        !preference.contains(
          preference.Preference.lowElectricityWarningEnabled,
        ) ||
        preference.getBool(preference.Preference.lowElectricityWarningEnabled);
    if (!isEnabled) {
      electricityWarning.value = -1;
      return;
    }

    if (!preference.contains(
      preference.Preference.lowElectricityWarningThreshold,
    )) {
      electricityWarning.value = defaultLowElectricityWarningThreshold;
      return;
    }

    final threshold = preference.getInt(
      preference.Preference.lowElectricityWarningThreshold,
    );
    electricityWarning.value = threshold > 0
        ? threshold
        : defaultLowElectricityWarningThreshold;
  }

  Future<void> setLowElectricityWarningEnabled(bool value) async {
    await preference.setBool(
      preference.Preference.lowElectricityWarningEnabled,
      value,
    );
    updateElectricityWarning();
  }

  Future<void> setLowElectricityWarningThreshold(int value) async {
    await preference.setInt(
      preference.Preference.lowElectricityWarningThreshold,
      value > 0 ? value : defaultLowElectricityWarningThreshold,
    );
    updateElectricityWarning();
  }

  void _syncLastValidElectricity(FetchResult<EnergyInfo> result) {
    _lastValidEnergyInfo.value = result;

    if (result.isCache) return;

    final info = result.data;

    final newHistoryInfo = List<ElectricityHistoryInfo>.from(
      historyElectricityInfoList,
    );
    if (newHistoryInfo.isNotEmpty) {
      final last = newHistoryInfo.last;
      if (last.fetchDay.isAtSameDayAs(info.lastReadDate)) {
        return;
      }
    }

    if (newHistoryInfo.length > 14) {
      newHistoryInfo.removeAt(0);
    }
    newHistoryInfo.add(
      ElectricityHistoryInfo(
        fetchDay: info.lastReadDate,
        remain: info.electricityRemain.toString(),
      ),
    );
    EnergySession.saveElectricityHistory(newHistoryInfo);
    historyElectricityInfoList.clear();
    historyElectricityInfoList.addAll(newHistoryInfo);
  }

  void _syncAirconEnergyHistory(AirconEnergyInfo info) {
    final newHistoryInfo = List<ElectricityHistoryInfo>.from(
      airconEnergyHistoryInfoList,
    );
    final historyInfo = ElectricityHistoryInfo(
      fetchDay: info.stateTime,
      remain: info.electricAmount.toString(),
    );

    if (newHistoryInfo.isNotEmpty) {
      final last = newHistoryInfo.last;
      if (last.fetchDay.isAtSameDayAs(info.stateTime)) {
        newHistoryInfo[newHistoryInfo.length - 1] = historyInfo;
        AirconSession.saveEnergyHistory(newHistoryInfo);
        airconEnergyHistoryInfoList.clear();
        airconEnergyHistoryInfoList.addAll(newHistoryInfo);
        return;
      }
    }

    if (newHistoryInfo.length > 14) {
      newHistoryInfo.removeAt(0);
    }
    newHistoryInfo.add(historyInfo);
    AirconSession.saveEnergyHistory(newHistoryInfo);
    airconEnergyHistoryInfoList.clear();
    airconEnergyHistoryInfoList.addAll(newHistoryInfo);
  }

  Future<void> refreshElectricityInfo({bool force = false}) async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = _lastValidEnergyInfo.value;
    energyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await getElectricityInfo();
      _syncLastValidElectricity(result);
      energyInfoStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      energyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[EnergyController][refreshElectricityInfo] Have issue");
    } finally {
      _isReloading = false;
    }
  }

  Future<void> refreshAirconEnergyInfo() async {
    final imei = airconImeiSignal.value;
    if (imei.isEmpty || _isAirconReloading) return;

    _isAirconReloading = true;
    final previous = airconEnergyInfoStateSignal.peek()?.value;
    airconEnergyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    try {
      final result = await AirconSession().getEnergyInfo(imei);
      _syncAirconEnergyHistory(result);
      airconEnergyInfoStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      airconEnergyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(
        e,
        s,
        "[EnergyController][refreshAirconEnergyInfo] Have issue",
      );
    } finally {
      _isAirconReloading = false;
    }
  }

  Future<void> updateAirconImei(String rawImei) async {
    final trimmed = rawImei.trim();
    if (trimmed.isEmpty) {
      await clearAirconImei();
      return;
    }

    final imei = AirconSession.normalizeImei(trimmed);
    if (airconImeiSignal.value != imei) {
      AirconSession.clearEnergyHistory();
      airconEnergyHistoryInfoList.clear();
    }
    await preference.setString(preference.Preference.airconImei, imei);
    airconImeiSignal.value = imei;
    await refreshAirconEnergyInfo();
  }

  Future<void> clearAirconImei() async {
    await preference.remove(preference.Preference.airconImei);
    airconImeiSignal.value = "";
    airconEnergyInfoStateSignal.value = null;
    AirconSession.clearEnergyHistory();
    airconEnergyHistoryInfoList.clear();
  }

  void clearElectricityHistory() {
    EnergySession.clearElectricityHistory();
    historyElectricityInfoList.clear();
  }

  late final displayEnergyInfo = computed(
    () => _lastValidEnergyInfo.value?.data,
  );

  late final hasValidEnergyInfo = computed(
    () => _lastValidEnergyInfo.value != null,
  );

  late final isEnergyInfoFromCache = computed(
    () => _lastValidEnergyInfo.value?.isCache ?? false,
  );

  late final energyInfoFetchTime = computed<DateTime?>(
    () => _lastValidEnergyInfo.value?.fetchTime,
  );

  late final energyInfoCacheHintKey = computed<String?>(
    () => _lastValidEnergyInfo.value?.hintKey,
  );
}
