// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:styled_widget/styled_widget.dart';

class WaterUsageList extends StatelessWidget {
  final List<MeterInfo> usages;
  const WaterUsageList({super.key, required this.usages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onPrimary,
    );
    final cellStyle = theme.textTheme.bodyMedium;

    return [
      [
            Text(
              FlutterI18n.translate(
                context,
                "electricity.water_usage_fetch_date",
              ),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),

            Text(
              FlutterI18n.translate(context, "electricity.water_usage"),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),

            Text(
              FlutterI18n.translate(
                context,
                "electricity.water_usage_read_now",
              ),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),

            Text(
              FlutterI18n.translate(
                context,
                "electricity.water_usage_read_before",
              ),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ]
          .toRow()
          .padding(vertical: 10)
          .backgroundColor(theme.colorScheme.primary),

      ...List<Widget>.generate(usages.length, (index) {
        final d = usages[index];
        return [
          const Divider(height: 1),
          [
            Text(
              DateFormat("yyyy-MM-dd").format(d.ReadTime),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
            Text(
              d.ReadNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              d.EndNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              d.StartNum.toString(),
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ].toRow().padding(vertical: 10),
        ].toColumn();
      }),
    ].toColumn().card(elevation: 0);
  }
}
