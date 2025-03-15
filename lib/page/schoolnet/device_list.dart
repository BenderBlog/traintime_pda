// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

class DeviceList extends StatelessWidget {
  final List<(String, String, String)> devices;
  const DeviceList({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(
            label: Text(FlutterI18n.translate(
          context,
          "school_net.device_list.ip",
        ))),
        DataColumn(
            label: Text(FlutterI18n.translate(
          context,
          "school_net.device_list.time",
        ))),
        DataColumn(
            label: Text(FlutterI18n.translate(
          context,
          "school_net.device_list.remain",
        ))),
      ],
      rows: devices.map((device) {
        return DataRow(cells: [
          DataCell(Text(device.$1)),
          DataCell(Text(device.$3)),
          DataCell(Text(device.$2)),
        ]);
      }).toList(),
    ).scrollable(
      scrollDirection: Axis.horizontal,
    );
  }
}
