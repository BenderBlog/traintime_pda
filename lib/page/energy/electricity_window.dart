// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/energy/electricity_energy_card.dart';
import 'package:watermeter/page/energy/energy_ready_view.dart';
import 'package:watermeter/page/energy/water_energy_card.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/info_card.dart';

class ElectricityWindow extends StatelessWidget {
  const ElectricityWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final controller = EnergyController.i;
        final state = controller.energyInfoStateSignal.value;
        final displayInfo = controller.displayEnergyInfo.value;
        final isLoading = state.isLoading;
        final hasError = state is AsyncError;
        final isFromCache = controller.isEnergyInfoFromCache.value;
        final fetchTime = controller.energyInfoFetchTime.value;
        final cacheHintKey = controller.energyInfoCacheHintKey.value;

        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "electricity.title")),
            actions: [
              IconButton(
                onPressed: isLoading ? null : controller.refreshElectricityInfo,
                icon: const Icon(Icons.refresh),
                tooltip: FlutterI18n.translate(context, "electricity.update"),
              ),
            ],
          ),
          body: ElectricityReadyView(
            notices: [
              if (displayInfo != null && isLoading) LinearProgressIndicator(),
              if (displayInfo != null && hasError)
                Text(
                      FlutterI18n.translate(context, "electricity.fetch_error"),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .padding(vertical: 8, horizontal: 12)
                    .width(double.maxFinite)
                    .backgroundColor(Theme.of(context).colorScheme.error),
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
            ],
            electricityCards: [
              if (displayInfo == null)
                _statusCard(
                  context,
                  icon: Icons.electric_meter,
                  titleKey: "electricity.power_title",
                  messageKey: hasError
                      ? "electricity.fetch_error"
                      : "electricity.fetching_hint",
                  isLoading: !hasError,
                  hasError: hasError,
                )
              else if (displayInfo.electricityMeterList.isEmpty)
                _statusCard(
                  context,
                  icon: Icons.electric_meter,
                  titleKey: "electricity.power_title",
                  messageKey: "electricity_status.no_electricity_info",
                )
              else
                for (final meter in displayInfo.electricityMeterList.entries)
                  ElectricityEnergyCard(
                    key: ValueKey(meter.key),
                    metID: meter.key,
                    meterInfo: meter.value,
                    historyElectricityInfo:
                        controller.historyElectricityInfoList[meter.key] ?? [],
                  ),
            ],
            waterCards: [
              if (displayInfo == null)
                _statusCard(
                  context,
                  icon: Icons.water_drop,
                  titleKey: "electricity.water_title",
                  messageKey: hasError
                      ? "electricity.water_unavailable"
                      : "electricity.water_loading",
                  isLoading: !hasError,
                  hasError: hasError,
                )
              else if (displayInfo.waterMeterList.isEmpty)
                _statusCard(
                  context,
                  icon: Icons.water_drop,
                  titleKey: "electricity.water_title",
                  messageKey: "electricity.water_empty",
                )
              else
                for (final meter in displayInfo.waterMeterList.entries)
                  WaterEnergyCard(
                    key: ValueKey(meter.key),
                    metID: meter.key,
                    usages: meter.value,
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String messageKey,
    bool isLoading = false,
    bool hasError = false,
  }) {
    final message = Text(
      FlutterI18n.translate(context, messageKey),
      style: TextStyle(
        color: hasError
            ? Theme.of(context).colorScheme.error
            : isLoading
            ? null
            : Theme.of(context).colorScheme.outline,
      ),
    );

    return InfoCard(
      iconData: icon,
      title: FlutterI18n.translate(context, titleKey),
      children: [
        if (isLoading)
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: message),
            ],
          ).padding(vertical: 8, horizontal: 12)
        else
          message.padding(vertical: 8, horizontal: 12),
      ],
    );
  }
}
