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

  ElectricityController._() {
    // Load last successful fetched electricity info
    final cache = ElectricitySession.getCache();
    if (cache != null) {
      _lastValidElectricityInfo.value = cache;
    }

    // Load last updated electricity info
    historyElectricityInfoList
      ..clear()
      ..addAll(ElectricitySession.getHistory());

    _initEffects();
  }

  late final electricityInfoSignal = futureSignal<FetchResult<ElectricityInfo>>(
    () async {
      return await getElectricityInfo();
    },
    debugLabel: "ElectricityInfoSignal",
  );

  final _lastValidElectricityInfo = signal<FetchResult<ElectricityInfo>?>(null);
  final historyElectricityInfoList = <ElectricityInfo>[];

  void _initEffects() {
    effect(() {
      final state = electricityInfoSignal.value;
      if (state is AsyncData<FetchResult<ElectricityInfo>>) {
        _lastValidElectricityInfo.value = state.value;

        // Sync to cache
        if (state.value.isCache) return;

        final info = state.value.data;
        if (double.tryParse(info.remain) == null) return;

        final newHistoryInfo = List<ElectricityInfo>.from(
          historyElectricityInfoList,
        );
        if (newHistoryInfo.isNotEmpty) {
          final last = newHistoryInfo.last;
          if (last.fetchDay.isAtSameDayAs(info.fetchDay) &&
              last.remain == info.remain) {
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
    }, debugLabel: "HistorySyncEffect");
  }

  Future<void> refreshElectricityInfo({bool force = false}) async {
    if (electricityInfoSignal.value.isLoading) return;
    await electricityInfoSignal.reload().catchError(
      (e, s) => log.handle(
        e,
        s,
        "[ElectricityController][refreshElectricityInfo] Have issue",
      ),
    );
  }

  void clearElectricityHistory() {
    ElectricitySession.clearElectricityHistory();
    historyElectricityInfoList.clear();
  }

  // Get electricity account
  Future<String> getElectricityAccount() async {
    String dorm = await PersonalInfoSession().getDormInfoEhall();
    return ElectricitySession.parseElectricityAccountFromIDS(dorm);
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
