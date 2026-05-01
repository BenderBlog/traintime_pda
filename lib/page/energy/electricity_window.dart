// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/energy/energy_ready_view.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class ElectricityWindow extends StatelessWidget {
  const ElectricityWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "electricity.title")),
      ),
      body: Watch((context) {
        final c = EnergyController.i;
        final state = c.energyInfoStateSignal.value;
        final displayInfo = c.displayEnergyInfo.value;
        final isFromCache = c.isEnergyInfoFromCache.value;
        final fetchTime = c.energyInfoFetchTime.value;
        final cacheHintKey = c.energyInfoCacheHintKey.value;
        final historyElectricityInfoList = c.historyElectricityInfoList;
        final hasValidData = displayInfo != null;
        final isFatalError = state is AsyncError && !hasValidData;

        if (hasValidData) {
          final content = ElectricityReadyView(
            displayInfo: displayInfo,
            historyElectricityInfoList: historyElectricityInfoList,
            onRefresh: () => c.refreshElectricityInfo(force: true),
          );

          final body = Column(
            children: [
              if (isFromCache && fetchTime != null)
                CacheAlerter(
                  dataType: FlutterI18n.translate(context, "electricity.title"),
                  hint: FlutterI18n.translate(
                    context,
                    cacheHintKey == null || cacheHintKey == "local_cache_hint"
                        ? "cache_reason_default"
                        : cacheHintKey,
                  ),
                  placeOfCache: PlaceOfCache.device,
                  fetchTime: fetchTime,
                ),
              Expanded(child: content),
            ],
          );

          if (!state.isLoading) return body;

          return Stack(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    height: kTextTabBarHeight,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  Expanded(child: body),
                ],
              ),
              LoadingAlerter(
                isLoading: true,
                hint: FlutterI18n.translate(
                  context,
                  "electricity.fetching_hint",
                ),
                opacity: 0.15,
                showOverlay: true,
              ),
            ],
          );
        }

        if (isFatalError) {
          final errorState = state as AsyncError;
          return ReloadWidget(
            errorStatus: errorState.error,
            stackTrace: errorState.stackTrace,
            function: () async {
              if (context.mounted) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.successful_setting",
                  ),
                );
              }
              await c.refreshElectricityInfo(force: true);
            },
          ).center();
        }

        return const CircularProgressIndicator().center();
      }),
    );
  }
}
