// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// School card log list.
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:watermeter/model/xidian_ids/network_usage.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class NetworkInfo {
  late int serverFlag;
  late int addTime;
  late int allBytes;
  late String billingName;
  late int bytesIn;
  late int bytesOut;
  late int checkoutDate;
  late String domain;
  late String error;
  late String groupId;
  late int keepaliveTime;
  late String onlineDeviceDetail;
  late String onlineDeviceTotal;
  late String onlineIp;
  late String onlineIp6;
  late String packageId;
  late String pppoeDial;
  late String productsId;
  late String productsName;
  late String realName;
  late int remainBytes;
  late int remainSeconds;
  late int sumBytes;
  late int sumSeconds;
  late String sysver;
  late int userBalance;
  late int userCharge;
  late String userMac;
  late String userName;
  late int walletBalance;

  NetworkInfo(
      {required this.serverFlag,
      required this.addTime,
      required this.allBytes,
      required this.billingName,
      required this.bytesIn,
      required this.bytesOut,
      required this.checkoutDate,
      required this.domain,
      required this.error,
      required this.groupId,
      required this.keepaliveTime,
      required this.onlineDeviceDetail,
      required this.onlineDeviceTotal,
      required this.onlineIp,
      required this.onlineIp6,
      required this.packageId,
      required this.pppoeDial,
      required this.productsId,
      required this.productsName,
      required this.realName,
      required this.remainBytes,
      required this.remainSeconds,
      required this.sumBytes,
      required this.sumSeconds,
      required this.sysver,
      required this.userBalance,
      required this.userCharge,
      required this.userMac,
      required this.userName,
      required this.walletBalance});

  NetworkInfo.fromJson(Map<String, dynamic> json) {
    serverFlag = json['ServerFlag'];
    addTime = json['add_time'];
    allBytes = json['all_bytes'];
    billingName = json['billing_name'];
    bytesIn = json['bytes_in'];
    bytesOut = json['bytes_out'];
    checkoutDate = json['checkout_date'];
    domain = json['domain'];
    error = json['error'];
    groupId = json['group_id'];
    keepaliveTime = json['keepalive_time'];
    onlineDeviceDetail = json['online_device_detail'];
    onlineDeviceTotal = json['online_device_total'];
    onlineIp = json['online_ip'];
    onlineIp6 = json['online_ip6'];
    packageId = json['package_id'];
    pppoeDial = json['pppoe_dial'];
    productsId = json['products_id'];
    productsName = json['products_name'];
    realName = json['real_name'];
    remainBytes = json['remain_bytes'];
    remainSeconds = json['remain_seconds'];
    sumBytes = json['sum_bytes'];
    sumSeconds = json['sum_seconds'];
    sysver = json['sysver'];
    userBalance = json['user_balance'];
    userCharge = json['user_charge'];
    userMac = json['user_mac'];
    userName = json['user_name'];
    walletBalance = json['wallet_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ServerFlag'] = serverFlag;
    data['add_time'] = addTime;
    data['all_bytes'] = allBytes;
    data['billing_name'] = billingName;
    data['bytes_in'] = bytesIn;
    data['bytes_out'] = bytesOut;
    data['checkout_date'] = checkoutDate;
    data['domain'] = domain;
    data['error'] = error;
    data['group_id'] = groupId;
    data['keepalive_time'] = keepaliveTime;
    data['online_device_detail'] = onlineDeviceDetail;
    data['online_device_total'] = onlineDeviceTotal;
    data['online_ip'] = onlineIp;
    data['online_ip6'] = onlineIp6;
    data['package_id'] = packageId;
    data['pppoe_dial'] = pppoeDial;
    data['products_id'] = productsId;
    data['products_name'] = productsName;
    data['real_name'] = realName;
    data['remain_bytes'] = remainBytes;
    data['remain_seconds'] = remainSeconds;
    data['sum_bytes'] = sumBytes;
    data['sum_seconds'] = sumSeconds;
    data['sysver'] = sysver;
    data['user_balance'] = userBalance;
    data['user_charge'] = userCharge;
    data['user_mac'] = userMac;
    data['user_name'] = userName;
    data['wallet_balance'] = walletBalance;
    return data;
  }
}

class NetworkCardWindow extends StatefulWidget {
  const NetworkCardWindow({super.key});

  @override
  State<NetworkCardWindow> createState() => _NetworkCardWindowState();
}

class _NetworkCardWindowState extends State<NetworkCardWindow> {
  late NetworkInfo networkInfo = NetworkInfo(
    productsId: '',
    serverFlag: 0,
    addTime: 0,
    allBytes: 0,
    billingName: '',
    bytesIn: 0,
    bytesOut: 0,
    checkoutDate: 0,
    domain: '',
    error: '',
    groupId: '',
    keepaliveTime: 0,
    onlineDeviceDetail: '',
    onlineDeviceTotal: '',
    onlineIp: '',
    onlineIp6: '',
    packageId: '',
    pppoeDial: '',
    productsName: '',
    realName: '',
    remainBytes: 0,
    remainSeconds: 0,
    sumBytes: 0,
    sumSeconds: 0,
    sysver: '',
    userBalance: 0,
    userCharge: 0,
    userMac: '',
    userName: '',
    walletBalance: 0,
  );
  late NetworkUsage usage;
  late Dio dio;
  bool isLoading = true;

  Future<void> fetchNetworkInfo() async {
    try {
      final response = await dio.get(
        'https://w.xidian.edu.cn/cgi-bin/rad_user_info',
        queryParameters: {
          'callback': 'jsonp',
          '_': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        options: Options(
          responseType: ResponseType.plain,
        ),
      );
      final jsonString = response.data.substring(6, response.data.length - 1);
      final response2 = await SchoolnetSession().getNetworkUsage(
          captchaFunction: (memoryImage) => showDialog<String>(
                context: context,
                builder: (context) => CaptchaInputDialog(image: memoryImage),
              ).then((value) => value ?? ""));
      setState(() {
        networkInfo = NetworkInfo.fromJson(jsonDecode(jsonString));
        usage = response2;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching network info: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1000)).floor();
    return '${(bytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  void initState() {
    super.initState();
    dio = Dio();
    fetchNetworkInfo();
  }

  @override
  Widget build(BuildContext context) {
    // 保证总流量不为0，避免除0错误
    final totalBytes = networkInfo.sumBytes + networkInfo.remainBytes;
    final usedPercentage =
        totalBytes > 0 ? networkInfo.sumBytes / totalBytes : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("校园网流量用量"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户信息卡片
                    _buildInfoCard(
                      context,
                      title: '账户概览',
                      children: [
                        _buildInfoItem(
                            Icons.person, '账号', networkInfo.userName),
                        _buildInfoItem(
                            Icons.assignment, '套餐类型', networkInfo.productsName),
                        _buildInfoItem(Icons.account_balance_wallet, '余额',
                            '¥${networkInfo.userBalance.toStringAsFixed(2)}',
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
                        _buildDataRow(
                            '已使用流量',
                            formatBytes(networkInfo.sumBytes),
                            Colors.redAccent),
                        _buildDataRow('剩余流量',
                            formatBytes(networkInfo.remainBytes), Colors.green),
                        _buildDataRow(
                            '总流量', formatBytes(totalBytes), Colors.blue),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 在线设备列表卡片
                    _buildInfoCard(
                      context,
                      title: '在线设备（${usage.ipList.length}台）',
                      children: [
                        usage.ipList.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text("当前没有在线设备",
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : _buildDeviceList(context, usage.ipList),
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
                            fontSize: 14,
                            color: Colors.orange[800],
                            height: 1.4),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      child: Card(
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
