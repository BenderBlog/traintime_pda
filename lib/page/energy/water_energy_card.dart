// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/public_widget/info_card.dart';

class WaterEnergyCard extends StatelessWidget {
  final String metID;
  final List<MeterInfo> usages;

  const WaterEnergyCard({super.key, required this.metID, required this.usages});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      iconData: Icons.water_drop,
      title: context.t.electricity.weterMetidTitle(code: metID),
      children: [
        if (usages.isEmpty)
          Text(
            context.t.electricity.waterEmpty,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ).padding(vertical: 8, horizontal: 12)
        else
          _buildUsageTable(context, usages),
      ],
    );
  }

  Widget _buildUsageTable(BuildContext context, List<MeterInfo> usages) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onPrimary,
    );
    final cellStyle = theme.textTheme.bodyMedium;

    return [
      [
            Text(
              context.t.electricity.waterUsageFetchDate,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
            Text(
              context.t.electricity.waterUsage,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              context.t.electricity.waterUsageReadNow,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              context.t.electricity.waterUsageReadBefore,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ]
          .toRow()
          .padding(vertical: 10)
          .backgroundColor(theme.colorScheme.primary),
      ...List<Widget>.generate(usages.length, (index) {
        final usage = usages[index];
        return [
          const Divider(height: 1),
          [
            Text(
              DateFormat("yyyy-MM-dd").format(usage.ReadTime),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
            Text(
              usage.ReadNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              usage.EndNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              usage.StartNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ].toRow().padding(vertical: 10),
        ].toColumn();
      }),
    ].toColumn();
  }
}
