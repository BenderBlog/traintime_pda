// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/energy/electricity_usage_graph.dart';
import 'package:watermeter/page/energy/water_usage_list.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class ElectricityReadyView extends StatelessWidget {
  final EnergyInfo displayInfo;
  final List<ElectricityHistoryInfo> historyElectricityInfoList;
  final VoidCallback onRefresh;

  const ElectricityReadyView({
    super.key,
    required this.displayInfo,
    required this.onRefresh,
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

          WaterUsageList(
            usages: displayInfo.waterMeterList,
          ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth).center(),

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
