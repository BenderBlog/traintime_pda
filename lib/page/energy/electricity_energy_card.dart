// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
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
import 'package:watermeter/generated/translations.g.dart';

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
            title: context.t.electricity.powerTitle,
            children: [
              if (state is AsyncError)
                Text(
                  context.t.electricity.fetchError,
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
                        context.t.electricity.fetchingHint,
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
          title: context.t.electricity.powerTitle,
          icon: state is AsyncData<FetchResult<EnergyInfo>>
              ? Icons.refresh
              : null,
          buttonText: state is AsyncData<FetchResult<EnergyInfo>>
              ? context.t.electricity.update
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
                context.t.electricity.fetchError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ).padding(bottom: 8, horizontal: 12),
            if (isFromCache && fetchTime != null)
              CacheAlerter(
                dataType: context.t.electricity.powerTitle,
                hint: cacheHintKey?.resolve(context.t) ?? context.t.common.cacheReasonDefault,
                placeOfCache: PlaceOfCache.device,
                fetchTime: fetchTime,
              ).padding(bottom: 8, horizontal: 12),
            InfoItem(
              icon: Icons.cached,
              label: context.t.electricity.cacheNotice,
              value: DateFormat(
                "yyyy-MM-dd",
              ).format(displayInfo.electricityMeterList.first.ReadTime),
            ),
            InfoItem(
              icon: Icons.electric_meter,
              label: context.t.electricity.remainPower,
              value: "${displayInfo.electricityRemain} kWh",
            ),
            InfoItem(
              icon: Icons.history,
              label: context.t.electricity.history,
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
              label: context.t.electricity.dailyUsage,
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
      label: Text(context.t.electricity.update),
    ).padding(top: 12, horizontal: 12).width(double.infinity);
  }
}

