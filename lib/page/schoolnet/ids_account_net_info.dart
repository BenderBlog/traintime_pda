// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/schoolnet/device_list.dart';
import 'package:watermeter/page/schoolnet/info_card.dart';
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
                .padding(all: 4),
            const SizedBox(height: 4),
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
            ),
            const SizedBox(height: 4),
            // 在线设备列表卡片
            InfoCard(
              title: FlutterI18n.translate(
                context,
                "school_net.ids_account_net.current_online",
                translationParams: {
                  "length": networkInfo.value!.ipList.length.toString(),
                },
              ),
              children: [
                networkInfo.value!.ipList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          FlutterI18n.translate(
                            context,
                            "school_net.ids_account_net.no_device_online",
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : DeviceList(devices: networkInfo.value!.ipList),
              ],
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () => update(),
              child: Text(
                FlutterI18n.translate(
                  context,
                  "school_net.refresh",
                ),
              ),
            ).padding(all: 4),
          ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
              .constrained(maxWidth: 480)
              .padding(all: 12)
              .scrollable();
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
            function: () => showDialog(
              context: context,
              builder: (context) => const SchoolNetPasswordDialog(),
            ).then(
              (value) {
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
              },
            ),
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
