// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
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
      title: context.t.electricity.powerMetidTitle(code: metID),
      children: [
        InfoItem(
          icon: Icons.cached,
          label: context.t.electricity.cacheNotice,
          value: DateFormat("yyyy-MM-dd").format(meterInfo.fetchDay),
        ),
        InfoItem(
          icon: Icons.electric_meter,
          label: context.t.electricity.remainPower,
          value: "${meterInfo.remain} kWh",
        ),
        InfoItem(icon: Icons.history, label: context.t.electricity.history),
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
          label: context.t.electricity.dailyUsage,
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
