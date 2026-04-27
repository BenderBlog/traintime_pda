// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/page/electricity/electricity_average_usage_graph.dart';
import 'package:watermeter/page/electricity/electricity_usage_graph.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

class ElectricityReadyView extends StatelessWidget {
  final ElectricityInfo displayInfo;
  final List<ElectricityInfo> historyElectricityInfo;
  final VoidCallback onRefresh;

  const ElectricityReadyView({
    super.key,
    required this.displayInfo,
    required this.historyElectricityInfo,
    required this.onRefresh,
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
                icon: Icons.account_balance,
                label: FlutterI18n.translate(context, "electricity.account"),
                value: prefs.getString(prefs.Preference.electricityAccount),
              ),
              InfoItem(
                icon: Icons.cached,
                label: FlutterI18n.translate(
                  context,
                  "electricity.cache_notice",
                ),
                value: DateFormat(
                  "yyyy-MM-dd HH:mm",
                ).format(displayInfo.fetchDay),
              ),
              InfoItem(
                icon: Icons.electric_meter,
                label: FlutterI18n.translate(
                  context,
                  "electricity.remain_power",
                ),
                value:
                    "${FlutterI18n.translate(context, displayInfo.electricityRemain)}"
                    "${displayInfo.electricityRemain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}",
              ),
              InfoItem(
                icon: Icons.wallet,
                label: FlutterI18n.translate(context, "electricity.owe_info"),
                value: displayInfo.waterRemain.contains(RegExp(r'[0-9]'))
                    ? FlutterI18n.translate(
                        context,
                        "electricity_status.owe_need_pay",
                        translationParams: {"due": displayInfo.waterRemain},
                      )
                    : FlutterI18n.translate(context, displayInfo.waterRemain),
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
                      historyElectricityInfo: historyElectricityInfo,
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
                          historyElectricityInfo: historyElectricityInfo,
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
