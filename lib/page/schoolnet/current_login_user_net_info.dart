// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/schoolnet/data_row.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class CurrentLoginUserNetInfo extends StatelessWidget {
  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1000)).floor();
    return '${(bytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  const CurrentLoginUserNetInfo({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (currentUserNetInfoStatus.value == CurrentUserNetInfoState.fetched) {
      final totalBytes =
          currentUserNetInfo.value!.sumBytes +
          currentUserNetInfo.value!.remainBytes;
      final usedPercentage = totalBytes > 0
          ? currentUserNetInfo.value!.sumBytes / totalBytes
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
                .padding(all: 4),
            const SizedBox(height: 4),

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
                  value: currentUserNetInfo.value!.userName,
                ),
                InfoItem(
                  icon: Icons.assignment,
                  label: FlutterI18n.translate(
                    context,
                    "school_net.current_login_net.plan_type",
                  ),
                  value: currentUserNetInfo.value!.productsName,
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
                      '${currentUserNetInfo.value!.userBalance.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 4),

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
                      "percent": (usedPercentage * 100).toStringAsFixed(1),
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
                  value: formatBytes(currentUserNetInfo.value!.sumBytes),
                  color: Colors.redAccent,
                ),
                NetDataRow(
                  label: FlutterI18n.translate(
                    context,
                    "school_net.current_login_net.remain_count",
                  ),
                  value: formatBytes(currentUserNetInfo.value!.remainBytes),
                  color: Colors.green,
                ),
                NetDataRow(
                  label: FlutterI18n.translate(
                    context,
                    "school_net.current_login_net.total",
                  ),
                  value: formatBytes(totalBytes),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () => SchoolnetSession.getCurrentUserLogin(),
              child: Text(FlutterI18n.translate(context, "school_net.refresh")),
            ).padding(all: 4),
          ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .constrained(maxWidth: 480)
          .padding(all: 12)
          .scrollable()
          .center();
    } else if (currentUserNetInfoStatus.value ==
        CurrentUserNetInfoState.fetching) {
      return const Center(child: CircularProgressIndicator());
    } else if (currentUserNetInfoStatus.value == CurrentUserNetInfoState.none) {
      SchoolnetSession.getCurrentUserLogin();
      return const Center(child: CircularProgressIndicator());
    } else {
      return ReloadWidget(
        errorStatus:
            currentUserNetInfoStatus.value == CurrentUserNetInfoState.notSchool
            ? FlutterI18n.translate(
                context,
                "school_net.current_login_net.non_schoolnet",
              )
            : null,
        function: () => SchoolnetSession.getCurrentUserLogin(),
      );
    }
  });
}
