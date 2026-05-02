// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/energy_session.dart';

class EnergyController {
  static final EnergyController i = EnergyController._();
  bool _isReloading = false;

  EnergyController._() {
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
  }

  final _lastValidEnergyInfo = signal<FetchResult<EnergyInfo>?>(null);
  final energyInfoStateSignal = signal<AsyncState<FetchResult<EnergyInfo>>>(
    const AsyncLoading(),
  );
  final historyElectricityInfoList = <ElectricityHistoryInfo>[];

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
