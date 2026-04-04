// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/network_usage.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/schoolnet/net_data_row.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class CurrentNetInfoPage extends StatefulWidget {
  const CurrentNetInfoPage({super.key});

  @override
  State<CurrentNetInfoPage> createState() => _CurrentNetInfoState();
}

class _CurrentNetInfoState extends State<CurrentNetInfoPage> {
  late Future<CurrentUserNetInfo> _currentUserNetInfoFuture;

  @override
  void initState() {
    super.initState();
    _currentUserNetInfoFuture = SchoolnetSession().getCurrentUserNetInfo();
  }

  void _reload() {
    setState(() {
      _currentUserNetInfoFuture = SchoolnetSession().getCurrentUserNetInfo();
    });
  }

  static String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1000)).floor();
    return '${(bytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentUserNetInfo>(
      future: _currentUserNetInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final currentUserNetInfo = snapshot.data!;
          final totalBytes =
              currentUserNetInfo.sumBytes + currentUserNetInfo.remainBytes;
          final usedPercentage = totalBytes > 0
              ? currentUserNetInfo.sumBytes / totalBytes
              : 0;
          return [
                // 注意事项
                Text(
                      FlutterI18n.translate(
                        context,
                        "school_net.current_login_net.notice",
                      ),
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

                // 用户信息卡片
                InfoCard(
                      title: FlutterI18n.translate(
                        context,
                        "school_net.current_login_net.overview",
                      ),
                      children: [
                        InfoItem(
                          icon: Icons.person,
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.account",
                          ),
                          value: currentUserNetInfo.userName,
                        ),
                        InfoItem(
                          icon: Icons.assignment,
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.plan_type",
                          ),
                          value: currentUserNetInfo.productsName,
                          valueColor: Colors.green,
                        ),
                        InfoItem(
                          icon: Icons.account_balance_wallet,
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.remain",
                          ),
                          value:
                              '¥'
                              '${currentUserNetInfo.userBalance.toStringAsFixed(2)}',
                          valueColor: Colors.green,
                        ),
                      ],
                    )
                    .padding(vertical: 4)
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),

                // 流量使用卡片
                InfoCard(
                      title: FlutterI18n.translate(
                        context,
                        "school_net.current_login_net.usage_situation",
                      ),
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: usedPercentage.clamp(0.0, 1.0).toDouble(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.used_percent",
                            translationParams: {
                              "percent": (usedPercentage * 100).toStringAsFixed(
                                1,
                              ),
                            },
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        NetDataRow(
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.used",
                          ),
                          value: _formatBytes(currentUserNetInfo.sumBytes),
                          color: Colors.redAccent,
                        ),
                        NetDataRow(
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.remain_count",
                          ),
                          value: _formatBytes(currentUserNetInfo.remainBytes),
                          color: Colors.green,
                        ),
                        NetDataRow(
                          label: FlutterI18n.translate(
                            context,
                            "school_net.current_login_net.total",
                          ),
                          value: _formatBytes(totalBytes),
                          color: Colors.blue,
                        ),
                      ],
                    )
                    .padding(vertical: 4)
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),

                FilledButton(
                      onPressed: _reload,
                      child: Text(
                        FlutterI18n.translate(context, "school_net.refresh"),
                      ),
                    )
                    .padding(horizontal: 4, vertical: 8)
                    .width(double.infinity)
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),
              ]
              .toColumn(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
              )
              .scrollable(padding: EdgeInsets.all(12));
        }

        final errorStatus = snapshot.error;
        return ReloadWidget(
          errorStatus: errorStatus == CurrentUserNetInfoState.notSchool
              ? FlutterI18n.translate(
                  context,
                  "school_net.current_login_net.non_schoolnet",
                )
              : errorStatus is String
              ? FlutterI18n.translate(context, errorStatus)
              : errorStatus,
          stackTrace: snapshot.stackTrace,
          function: _reload,
        );
      },
    );
  }
}
