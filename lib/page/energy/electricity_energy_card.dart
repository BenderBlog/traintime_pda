// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/energy/electricity_usage_graph.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/info_card.dart';

class ElectricityEnergyCard extends StatelessWidget {
  const ElectricityEnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final c = EnergyController.i;
        final state = c.energyInfoStateSignal.value;
        final displayInfo = c.displayEnergyInfo.value;
        final historyElectricityInfoList = c.historyElectricityInfoList;

        if (displayInfo == null) {
          return InfoCard(
            iconData: Icons.electric_meter,
            title: FlutterI18n.translate(context, "electricity.power_title"),
            children: [
              if (state is AsyncError)
                Text(
                  FlutterI18n.translate(context, "electricity.fetch_error"),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ).padding(vertical: 8, horizontal: 12)
              else
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        FlutterI18n.translate(
                          context,
                          "electricity.fetching_hint",
                        ),
                      ),
                    ),
                  ],
                ).padding(vertical: 8, horizontal: 12),
              if (state is AsyncError)
                _retryButton(context, c.refreshElectricityInfo),
            ],
          );
        }

        final isLoading = state.isLoading;
        final isFromCache = c.isEnergyInfoFromCache.value;
        final fetchTime = c.energyInfoFetchTime.value;
        final cacheHintKey = c.energyInfoCacheHintKey.value;

        return InfoCard(
          iconData: Icons.electric_meter,
          title: FlutterI18n.translate(context, "electricity.power_title"),
          icon: state is AsyncData<FetchResult<EnergyInfo>>
              ? Icons.refresh
              : null,
          buttonText: state is AsyncData<FetchResult<EnergyInfo>>
              ? FlutterI18n.translate(context, "electricity.update")
              : null,
          onTap: state is AsyncData<FetchResult<EnergyInfo>>
              ? c.refreshElectricityInfo
              : null,
          children: [
            if (isLoading)
              const LinearProgressIndicator().padding(
                bottom: 8,
                horizontal: 12,
              ),
            SizedBox(height: 4),
            if (state is AsyncError)
              Text(
                FlutterI18n.translate(context, "electricity.fetch_error"),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ).padding(bottom: 8, horizontal: 12),
            if (isFromCache && fetchTime != null)
              CacheAlerter(
                dataType: FlutterI18n.translate(
                  context,
                  "electricity.power_title",
                ),
                hint: FlutterI18n.translate(
                  context,
                  cacheHintKey == null || cacheHintKey == "local_cache_hint"
                      ? "cache_reason_default"
                      : cacheHintKey,
                ),
                placeOfCache: PlaceOfCache.device,
                fetchTime: fetchTime,
              ).padding(bottom: 8, horizontal: 12),
            InfoItem(
              icon: Icons.cached,
              label: FlutterI18n.translate(context, "electricity.cache_notice"),
              value: DateFormat(
                "yyyy-MM-dd",
              ).format(displayInfo.electricityMeterList.first.ReadTime),
            ),
            InfoItem(
              icon: Icons.electric_meter,
              label: FlutterI18n.translate(context, "electricity.remain_power"),
              value: "${displayInfo.electricityRemain} kWh",
            ),
            InfoItem(
              icon: Icons.history,
              label: FlutterI18n.translate(context, "electricity.history"),
            ),
            LayoutBuilder(
                  builder: (context, constraints) => ElectricityUsageGraph(
                    graphHeight: 240,
                    graphWidth: constraints.maxWidth,
                    historyElectricityInfo: historyElectricityInfoList,
                  ),
                )
                .padding(vertical: 12, horizontal: 16)
                .decorated(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                )
                .padding(horizontal: 12),
            InfoItem(
              icon: Icons.bar_chart,
              label: FlutterI18n.translate(context, "electricity.daily_usage"),
            ),
            LayoutBuilder(
                  builder: (context, constraints) =>
                      ElectricityAverageUsageGraph(
                        graphWidth: constraints.maxWidth,
                        historyElectricityInfo:
                            displayInfo.electricityMeterList,
                      ),
                )
                .padding(vertical: 12, horizontal: 16)
                .decorated(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                )
                .padding(horizontal: 12),
            if (state is AsyncError)
              _retryButton(context, c.refreshElectricityInfo),
          ],
        );
      },
    );
  }

  Widget _retryButton(BuildContext context, VoidCallback onRefresh) {
    return FilledButton.icon(
      onPressed: onRefresh,
      icon: const Icon(Icons.refresh),
      label: Text(FlutterI18n.translate(context, "electricity.update")),
    ).padding(top: 12, horizontal: 12).width(double.infinity);
  }
}
