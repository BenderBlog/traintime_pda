// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/schoolnet_session.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class IdsAccountNetInfo extends StatelessWidget {
  const IdsAccountNetInfo({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (schoolNetStatus.value == SessionState.fetched) {
      return [
            // 注意事项
            Text(
                  FlutterI18n.translate(
                    context,
                    "school_net.ids_account_net.notice",
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
                .constrained(maxWidth: sheetMaxWidth),

            // 用户信息卡片
            InfoCard(
              title: FlutterI18n.translate(
                context,
                "school_net.ids_account_net.overview",
              ),
              children: [
                InfoItem(
                  icon: Icons.person,
                  label: FlutterI18n.translate(
                    context,
                    "school_net.ids_account_net.account",
                  ),
                  value: pref.getString(pref.Preference.idsAccount),
                ),
                InfoItem(
                  icon: Icons.data_usage,
                  label: FlutterI18n.translate(
                    context,
                    "school_net.ids_account_net.used",
                  ),
                  value: networkInfo.value!.used,
                  valueColor: Colors.green,
                ),
                InfoItem(
                  icon: Icons.account_balance_wallet,
                  label: FlutterI18n.translate(
                    context,
                    "school_net.ids_account_net.remain",
                  ),
                  value: networkInfo.value!.rest,
                  valueColor: Colors.green,
                ),
              ],
            ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth),

            if (networkInfo.value?.ipList.isNotEmpty ?? false)
              _DeviceListLite(
                devices: networkInfo.value!.ipList,
              ).padding(vertical: 4).constrained(maxWidth: sheetMaxWidth),

            FilledButton(
                  onPressed: () => update(),
                  child: Text(
                    FlutterI18n.translate(context, "school_net.refresh"),
                  ),
                )
                .padding(horizontal: 4, vertical: 8)
                .width(double.infinity)
                .constrained(maxWidth: sheetMaxWidth),
          ]
          .toColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
          )
          .scrollable(padding: EdgeInsets.all(12));
    } else if (schoolNetStatus.value == SessionState.fetching) {
      return const Center(child: CircularProgressIndicator());
    } else if (schoolNetStatus.value == SessionState.error &&
        isError.value == "school_net.empty_password") {
      return ReloadWidget(
        errorStatus: FlutterI18n.translate(
          context,
          "school_net.empty_password",
        ),
        buttonName: FlutterI18n.translate(
          context,
          "setting.change_schoolnet_password_title",
        ),
        function: () =>
            showDialog(
              context: context,
              builder: (context) => const SchoolNetPasswordDialog(),
            ).then((value) {
              if (pref
                  .getString(pref.Preference.schoolNetQueryPassword)
                  .isNotEmpty) {
                update(
                  captchaFunction: (image) => showDialog<String>(
                    context: context,
                    builder: (context) => CaptchaInputDialog(image: image),
                  ).then((value) => value ?? ""),
                );
              }
            }),
      );
    } else {
      return ReloadWidget(
        function: () => update(
          captchaFunction: (image) => showDialog<String>(
            context: context,
            builder: (context) => CaptchaInputDialog(image: image),
          ).then((value) => value ?? ""),
        ),
      );
    }
  });
}

class _DeviceListLite extends StatelessWidget {
  final List<(String, String, String)> devices;
  const _DeviceListLite({required this.devices});

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
              FlutterI18n.translate(context, "school_net.device_list.ip"),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),

            Text(
              FlutterI18n.translate(context, "school_net.device_list.time"),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),

            Text(
              FlutterI18n.translate(context, "school_net.device_list.remain"),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ]
          .toRow()
          .padding(vertical: 10)
          .backgroundColor(theme.colorScheme.primary),

      ...List<Widget>.generate(devices.length, (index) {
        final d = devices[index];
        return [
          const Divider(height: 1),
          [
            Text(
              d.$1,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
            Text(
              d.$3,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
            Text(
              d.$2,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ].toRow().padding(vertical: 10),
        ].toColumn();
      }),
    ].toColumn().card(elevation: 0);
  }
}
