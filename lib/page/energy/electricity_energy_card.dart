// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/energy/electricity_usage_graph.dart';
import 'package:watermeter/page/public_widget/info_card.dart';

class ElectricityEnergyCard extends StatelessWidget {
  final String metID;
  final ElectricityHistoryInfo meterInfo;
  final List<ElectricityHistoryInfo> historyElectricityInfo;

  const ElectricityEnergyCard({
    super.key,
    required this.metID,
    required this.meterInfo,
    required this.historyElectricityInfo,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      iconData: Icons.electric_meter,
      title: FlutterI18n.translate(
        context,
        "electricity.power_metid_title",
        translationParams: {"code": metID},
      ),
      children: [
        InfoItem(
          icon: Icons.cached,
          label: FlutterI18n.translate(context, "electricity.cache_notice"),
          value: DateFormat("yyyy-MM-dd").format(meterInfo.fetchDay),
        ),
        InfoItem(
          icon: Icons.electric_meter,
          label: FlutterI18n.translate(context, "electricity.remain_power"),
          value: "${meterInfo.remain} kWh",
        ),
        InfoItem(
          icon: Icons.history,
          label: FlutterI18n.translate(context, "electricity.history"),
        ),
        LayoutBuilder(
              builder: (context, constraints) => ElectricityUsageGraph(
                graphHeight: 240,
                graphWidth: constraints.maxWidth,
                historyElectricityInfo: historyElectricityInfo,
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
              builder: (context, constraints) => ElectricityAverageUsageGraph(
                graphWidth: constraints.maxWidth,
                historyElectricityInfo: meterInfo.historyInfo,
              ),
            )
            .padding(vertical: 12, horizontal: 16)
            .decorated(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
            )
            .padding(horizontal: 12),
      ],
    );
  }
}
