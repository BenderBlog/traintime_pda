// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// School card log list.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class NetworkCardWindow extends StatefulWidget {
  const NetworkCardWindow({super.key});

  @override
  State<NetworkCardWindow> createState() => _NetworkCardWindowState();
}

class _NetworkCardWindowState extends State<NetworkCardWindow> {
  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1000)).floor();
    return '${(bytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    // 保证总流量不为0，避免除0错误
    return Scaffold(
      appBar: AppBar(
        title: const Text("校园网流量用量"),
        elevation: 0,
      ),
      body: Obx(() {
        if (schoolNetStatus.value == SessionState.fetched) {
          var networkinfoValue = networkInfo.value!.networkInfo;
          final totalBytes =
              networkinfoValue.sumBytes + networkinfoValue.remainBytes;
          final usedPercentage =
              totalBytes > 0 ? networkinfoValue.sumBytes / totalBytes : 0;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 用户信息卡片
              _buildInfoCard(
                context,
                title: '账户概览',
                children: [
                  _buildInfoItem(Icons.person, '账号', networkinfoValue.userName),
                  _buildInfoItem(
                      Icons.assignment, '套餐类型', networkinfoValue.productsName),
                  _buildInfoItem(Icons.account_balance_wallet, '余额',
                      '¥${networkinfoValue.userBalance.toStringAsFixed(2)}',
                      valueColor: Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              // 流量使用卡片
              _buildInfoCard(
                context,
                title: '流量使用情况',
                children: [
                  CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 15.0,
                    animation: true,
                    percent: usedPercentage.clamp(0.0, 1.0) as double,
                    center: Text(
                      "${(usedPercentage * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[200] ?? Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  _buildDataRow('已使用流量', formatBytes(networkinfoValue.sumBytes),
                      Colors.redAccent),
                  _buildDataRow('剩余流量',
                      formatBytes(networkinfoValue.remainBytes), Colors.green),
                  _buildDataRow('总流量', formatBytes(totalBytes), Colors.blue),
                ],
              ),

              const SizedBox(height: 20),

              // 在线设备列表卡片
              _buildInfoCard(
                context,
                title: '在线设备（${networkInfo.value!.ipList.length}台）',
                children: [
                  networkInfo.value!.ipList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text("当前没有在线设备",
                              style: TextStyle(color: Colors.grey)),
                        )
                      : _buildDeviceList(context, networkInfo.value!.ipList),
                ],
              ),

              const SizedBox(height: 20),

              // 注意事项
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!)),
                child: Text(
                  "注意: 流量计费采用GB单位（1000进制）",
                  style: TextStyle(
                      fontSize: 14, color: Colors.orange[800], height: 1.4),
                ),
              )
            ],
          );
        } else if (schoolNetStatus.value == SessionState.fetching) {
          return const Center(child: CircularProgressIndicator());
        } else {
          /// TODO: Rewrite it with reload widget.
          return Text(isError.value);
        }
      }),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            "$label：",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          )
        ],
      ),
    );
  }

  Widget _buildDeviceList(
      BuildContext context, List<(String, String, String)> devices) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("在线设备IP")),
              DataColumn(label: Text("上线时间")),
              DataColumn(label: Text("流量用量")),
            ],
            rows: devices.map((device) {
              return DataRow(cells: [
                DataCell(Text(device.$1)),
                DataCell(Text(device.$3)),
                DataCell(Text(device.$2)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 设备信息标签组件
  Widget _buildDeviceTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}

class RecordData extends DataTableSource {
  late List<PaidRecord> data;

  RecordData({required this.data});

  @override
  DataRow? getRow(int index) => DataRow(
        cells: <DataCell>[
          DataCell(Center(child: Text(data[index].place))),
          DataCell(Center(child: Text(data[index].money))),
          DataCell(Center(child: Text(data[index].date))),
        ],
      );

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
