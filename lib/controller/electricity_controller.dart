// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

class ElectricityController {
  static final ElectricityController i = ElectricityController._();

  ElectricityController._() {
    _initEffects();
  }

  bool _isElectricityForceToLoad = false;

  // bool is a flag about cache info, whether it is today's data
  late final electricityInfoSignal = futureSignal<(bool, ElectricityInfo)>(
    () async {
      final isForce = _isElectricityForceToLoad;
      _isElectricityForceToLoad = false;

      return await getElectricityInfo(force: isForce);
    },
    debugLabel: "ElectricityInfoSignal",
  );

  final historyElectricityInfoList = <ElectricityInfo>[];

  void _initEffects() {
    effect(() {
      final state = electricityInfoSignal.value;
      if (state is AsyncData<(bool, ElectricityInfo)>) {
        List<ElectricityInfo> newHistoryInfo =
            ElectricitySession.refreshElectricityHistory(state.value.$2);
        batch(() {
          historyElectricityInfoList.clear();
          historyElectricityInfoList.addAll(newHistoryInfo);
        });
      }
    }, debugLabel: "HistorySyncEffect");
  }

  Future<void> refreshElectricityInfo({bool force = false}) async {
    if (electricityInfoSignal.value.isLoading) return;
    _isElectricityForceToLoad = force;
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
}
