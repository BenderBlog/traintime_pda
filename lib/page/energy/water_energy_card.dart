// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/generated/translations.g.dart';

class WaterEnergyCard extends StatelessWidget {
  const WaterEnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final controller = EnergyController.i;
        final state = controller.energyInfoStateSignal.value;
        final displayInfo = controller.displayEnergyInfo.value;
        final usages = displayInfo?.waterMeterList;

        return InfoCard(
          iconData: Icons.water_drop,
          title: context.t.electricity.waterTitle,
          children: [
            if (displayInfo == null)
              _buildUnavailableState(context, hasError: state is AsyncError)
            else if (usages == null || usages.isEmpty)
              Text(
                context.t.electricity.waterEmpty,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ).padding(vertical: 8, horizontal: 12)
            else
              _buildUsageTable(context, usages),
          ],
        );
      },
    );
  }

  Widget _buildUnavailableState(
    BuildContext context, {
    required bool hasError,
  }) {
    if (hasError) {
      return Text(
        context.t.electricity.waterUnavailable,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ).padding(vertical: 8, horizontal: 12);
    }

    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.t.electricity.waterLoading,
          ),
        ),
      ],
    ).padding(vertical: 8, horizontal: 12);
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
