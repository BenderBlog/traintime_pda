// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

class ElectricityController {
  static final ElectricityController i = ElectricityController._();
  bool _isReloading = false;

  ElectricityController._() {
    // Load last successful fetched electricity info
    final cache = ElectricitySession.getCache();
    if (cache != null) {
      _lastValidElectricityInfo.value = cache;
      electricityInfoStateSignal.value = AsyncState.data(cache);
    }

    // Load last updated electricity info
    historyElectricityInfoList
      ..clear()
      ..addAll(ElectricitySession.getHistory());
  }

  final _lastValidElectricityInfo = signal<FetchResult<ElectricityInfo>?>(null);
  final electricityInfoStateSignal =
      signal<AsyncState<FetchResult<ElectricityInfo>>>(const AsyncLoading());
  final historyElectricityInfoList = <ElectricityInfo>[];

  void _syncLastValidElectricity(FetchResult<ElectricityInfo> result) {
    _lastValidElectricityInfo.value = result;

    if (result.isCache) return;

    final info = result.data;

    final newHistoryInfo = List<ElectricityInfo>.from(
      historyElectricityInfoList,
    );
    if (newHistoryInfo.isNotEmpty) {
      final last = newHistoryInfo.last;
      if (last.fetchDay.isAtSameDayAs(info.fetchDay)) {
        return;
      }
    }

    if (newHistoryInfo.length > 14) {
      newHistoryInfo.removeAt(0);
    }
    newHistoryInfo.add(info);
    ElectricitySession.saveHistory(newHistoryInfo);
    batch(() {
      historyElectricityInfoList.clear();
      historyElectricityInfoList.addAll(newHistoryInfo);
    });
  }

  Future<void> refreshElectricityInfo({bool force = false}) async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = _lastValidElectricityInfo.value;
    electricityInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await getElectricityInfo();
      _syncLastValidElectricity(result);
      electricityInfoStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      electricityInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(
        e,
        s,
        "[ElectricityController][refreshElectricityInfo] Have issue",
      );
    } finally {
      _isReloading = false;
    }
  }

  void clearElectricityHistory() {
    ElectricitySession.clearElectricityHistory();
    historyElectricityInfoList.clear();
  }

  late final displayElectricityInfo = computed(
    () => _lastValidElectricityInfo.value?.data,
  );

  late final hasValidElectricityInfo = computed(
    () => _lastValidElectricityInfo.value != null,
  );

  late final isElectricityFromCache = computed(
    () => _lastValidElectricityInfo.value?.isCache ?? false,
  );

  late final electricityFetchTime = computed<DateTime?>(
    () => _lastValidElectricityInfo.value?.fetchTime,
  );

  late final electricityCacheHintKey = computed<String?>(
    () => _lastValidElectricityInfo.value?.hintKey,
  );
}
