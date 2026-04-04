// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/schoolnet_controller.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class GeneralNetworkUsagePage extends StatelessWidget {
  const GeneralNetworkUsagePage({super.key});

  @override
  Widget build(BuildContext context) => Watch((context) {
    final state = SchoolnetController.i.schoolNetUsageSignal.watch(context);
    return state.map(
      data: (usage) =>
          [
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
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),

                // 用户信息卡片
                InfoCard(
                      iconData: Icons.info,
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
                          value: usage.used,
                          valueColor: Colors.green,
                        ),
                        InfoItem(
                          icon: Icons.account_balance_wallet,
                          label: FlutterI18n.translate(
                            context,
                            "school_net.ids_account_net.remain",
                          ),
                          value: usage.rest,
                          valueColor: Colors.green,
                        ),
                      ],
                    )
                    .padding(vertical: 4)
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),

                if (usage.ipList.isNotEmpty)
                  _DeviceListLite(devices: usage.ipList)
                      .padding(vertical: 4)
                      .constrained(maxWidth: sheetMaxWidth)
                      .center(),

                FilledButton(
                      onPressed: () =>
                          SchoolnetController.i.reloadSchoolnetInfo(
                            captchaFunction: (image) => showDialog<String>(
                              context: context,
                              builder: (context) =>
                                  CaptchaInputDialog(image: image),
                            ).then((value) => value ?? ""),
                          ),
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
              .scrollable(padding: EdgeInsets.all(12)),
      loading: () => const Center(child: CircularProgressIndicator()),
      refreshing: () => const Center(child: CircularProgressIndicator()),
      reloading: () => const Center(child: CircularProgressIndicator()),
      error: (errorStatus, stackTrace) {
        if (errorStatus == "school_net.empty_password") {
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
                    SchoolnetController.i.reloadSchoolnetInfo(
                      captchaFunction: (image) => showDialog<String>(
                        context: context,
                        builder: (context) => CaptchaInputDialog(image: image),
                      ).then((value) => value ?? ""),
                    );
                  }
                }),
          );
        }

        return ReloadWidget(
          errorStatus: errorStatus is String
              ? FlutterI18n.translate(context, errorStatus)
              : errorStatus,
          stackTrace: stackTrace,
          function: () => SchoolnetController.i.reloadSchoolnetInfo(
            captchaFunction: (image) => showDialog<String>(
              context: context,
              builder: (context) => CaptchaInputDialog(image: image),
            ).then((value) => value ?? ""),
          ),
        );
      },
    );
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
            ).expanded(flex: 3),

            Text(
              FlutterI18n.translate(context, "school_net.device_list.time"),
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),

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
            ).expanded(flex: 3),
            Text(
              d.$3,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
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
