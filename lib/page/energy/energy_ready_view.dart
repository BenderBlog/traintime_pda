// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/energy/electricity_usage_graph.dart';
import 'package:watermeter/page/energy/water_usage_list.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class ElectricityReadyView extends StatelessWidget {
  final EnergyInfo displayInfo;
  final List<ElectricityHistoryInfo> historyElectricityInfoList;
  final List<ElectricityHistoryInfo> airconEnergyHistoryInfoList;
  final String airconImei;
  final AsyncState<AirconEnergyInfo>? airconEnergyInfoState;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshAircon;

  const ElectricityReadyView({
    super.key,
    required this.displayInfo,
    required this.onRefresh,
    required this.airconImei,
    required this.airconEnergyHistoryInfoList,
    required this.airconEnergyInfoState,
    required this.onRefreshAircon,
    required this.historyElectricityInfoList,
  });

  @override
  Widget build(BuildContext context) {
    return [
          Text(
                FlutterI18n.translate(context, "electricity.info"),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                  height: 1.4,
                ),
              )
              .padding(all: 16)
              .decorated(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              )
              .padding(vertical: 8, horizontal: 4)
              .width(double.infinity)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          InfoCard(
            iconData: Icons.info,
            title: FlutterI18n.translate(context, "electricity.power_title"),
            children: [
              InfoItem(
                icon: Icons.cached,
                label: FlutterI18n.translate(
                  context,
                  "electricity.cache_notice",
                ),
                value: DateFormat(
                  "yyyy-MM-dd",
                ).format(displayInfo.electricityMeterList.first.ReadTime),
              ),
              InfoItem(
                icon: Icons.electric_meter,
                label: FlutterI18n.translate(
                  context,
                  "electricity.remain_power",
                ),
                value: "${displayInfo.electricityRemain} kWh",
              ),
            ],
          ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth).center(),

          InfoCard(
            iconData: Icons.history,
            title: FlutterI18n.translate(context, "electricity.history"),
            children: [
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
                  .padding(top: 4),
            ],
          ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth).center(),

          InfoCard(
            iconData: Icons.bar_chart,
            title: FlutterI18n.translate(context, "electricity.daily_usage"),
            children: [
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
                  .padding(top: 4),
            ],
          ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth).center(),

          if (displayInfo.waterMeterList != null)
            WaterUsageList(usages: displayInfo.waterMeterList!)
                .padding(vertical: 4)
                .constrained(maxWidth: sheetMaxWidth)
                .center(),

          if (airconImei.isNotEmpty)
            _AirconEnergyCard(
                  imei: airconImei,
                  state: airconEnergyInfoState,
                  historyElectricityInfoList: airconEnergyHistoryInfoList,
                  onRefresh: onRefreshAircon,
                )
                .padding(vertical: 4)
                .constrained(maxWidth: sheetMaxWidth)
                .center(),

          FilledButton(
                onPressed: onRefresh,
                child: Text(
                  FlutterI18n.translate(context, "electricity.update"),
                ),
              )
              .padding(horizontal: 4, vertical: 8)
              .width(double.infinity)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          Image.asset("assets/art/pda_girl_default.png").padding(bottom: 16),
        ]
        .toColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
        )
        .scrollable(padding: const EdgeInsets.all(12));
  }
}

class _AirconEnergyCard extends StatelessWidget {
  final String imei;
  final AsyncState<AirconEnergyInfo>? state;
  final List<ElectricityHistoryInfo> historyElectricityInfoList;
  final VoidCallback onRefresh;

  const _AirconEnergyCard({
    required this.imei,
    required this.state,
    required this.historyElectricityInfoList,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      iconData: Icons.ac_unit,
      title: FlutterI18n.translate(context, "electricity.aircon_title"),
      children: [
        InfoItem(
          icon: Icons.qr_code_2,
          label: FlutterI18n.translate(context, "electricity.aircon_imei"),
          value: imei,
        ),
        if (state == null)
          Text(
            FlutterI18n.translate(context, "electricity.aircon_waiting"),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ).padding(vertical: 8)
        else
          state!.map(
            data: (info) => Column(
              children: [
                InfoItem(
                  icon: Icons.electric_bolt,
                  label: FlutterI18n.translate(
                    context,
                    "electricity.aircon_amount",
                  ),
                  value: info.electricAmount.toString(),
                ),
                InfoItem(
                  icon: Icons.update,
                  label: FlutterI18n.translate(
                    context,
                    "electricity.aircon_update_time",
                  ),
                  value: DateFormat("yyyy-MM-dd HH:mm").format(info.stateTime),
                ),
                LayoutBuilder(
                      builder: (context, constraints) =>
                          ElectricityAverageUsageGraph(
                            graphWidth: constraints.maxWidth,
                            historyElectricityInfo: _airconDailyUsageInfo(
                              historyElectricityInfoList,
                            ),
                          ),
                    )
                    .padding(vertical: 12, horizontal: 16)
                    .decorated(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                    )
                    .padding(top: 4)
                    .width(double.infinity),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ).padding(vertical: 12),
            refreshing: () => const Center(
              child: CircularProgressIndicator(),
            ).padding(vertical: 12),
            reloading: () => const Center(
              child: CircularProgressIndicator(),
            ).padding(vertical: 12),
            error: (err, stack) => Row(
              children: [
                Expanded(
                  child: Text(
                    FlutterI18n.translate(context, "electricity.aircon_error"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRefresh,
                  child: Text(
                    FlutterI18n.translate(context, "electricity.aircon_retry"),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(FlutterI18n.translate(context, "electricity.update")),
          ),
        ),
      ],
    );
  }

  List<MeterInfo> _airconDailyUsageInfo(List<ElectricityHistoryInfo> history) {
    final data = <MeterInfo>[];
    if (history.isEmpty) return data;

    data.add(
      MeterInfo(
        ReadTime: history.first.fetchDay,
        ReadNum: 0,
        StartNum: 0,
        EndNum: 0,
      ),
    );

    for (var i = 1; i < history.length; i++) {
      final previous = num.tryParse(history[i - 1].remain);
      final current = num.tryParse(history[i].remain);
      if (previous == null || current == null) continue;
      final usage = current - previous;
      if (usage < 0) continue;

      data.add(
        MeterInfo(
          ReadTime: history[i].fetchDay,
          ReadNum: usage,
          StartNum: previous,
          EndNum: current,
        ),
      );
    }

    return data;
  }
}
