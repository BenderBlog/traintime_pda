// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/schoolnet_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/model/network_usage.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class GeneralNetworkUsagePage extends StatelessWidget {
  const GeneralNetworkUsagePage({super.key});

  Future<void> _reload(BuildContext context) =>
      SchoolnetController.i.reloadSchoolnetInfo(
        captchaFunction: (image) => showDialog<String>(
          context: context,
          builder: (context) => CaptchaInputDialog(image: image),
        ).then((value) => value ?? ""),
      );

  Widget _buildUsageBody(
    BuildContext context,
    FetchResult<GeneralNetworkUsage> result, {
    required bool isLoading,
  }) => Stack(
    children: [
      [
        if (result.isCache)
          CacheAlerter(
            hint:
                (result.hintKey != null
                    ? FlutterI18n.translate(context, result.hintKey!)
                    : null) ??
                FlutterI18n.translate(
                  context,
                  "inapp_cache_hint",
                  translationParams: {"datetime": result.fetchTime.toString()},
                ),
          ).center(),
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
                        value: result.data.used,
                        valueColor: Colors.green,
                      ),
                      InfoItem(
                        icon: Icons.account_balance_wallet,
                        label: FlutterI18n.translate(
                          context,
                          "school_net.ids_account_net.remain",
                        ),
                        value: result.data.rest,
                        valueColor: Colors.green,
                      ),
                    ],
                  )
                  .padding(vertical: 4)
                  .constrained(maxWidth: sheetMaxWidth)
                  .center(),

              if (result.data.ipList.isNotEmpty)
                _DeviceListLite(devices: result.data.ipList)
                    .padding(vertical: 4)
                    .constrained(maxWidth: sheetMaxWidth)
                    .center(),

              FilledButton(
                    onPressed: () => _reload(context),
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
            .scrollable(padding: EdgeInsets.symmetric(horizontal: 12))
            .expanded(),
      ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      LoadingAlerter(
        isLoading: isLoading,
        hint: FlutterI18n.translate(context, "school_net.fetching"),
        showOverlay: false,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Watch((context) {
    final state = SchoolnetController.i.schoolNetUsageSignal.watch(context);
    return state.map(
      data: (result) =>
          _buildUsageBody(context, result, isLoading: state.isLoading),
      loading: () => const Center(child: CircularProgressIndicator()),
      refreshing: () => state.value == null
          ? const Center(child: CircularProgressIndicator())
          : _buildUsageBody(context, state.value!, isLoading: true),
      reloading: () => state.value == null
          ? const Center(child: CircularProgressIndicator())
          : _buildUsageBody(context, state.value!, isLoading: true),
      error: (errorStatus, stackTrace) {
        if (errorStatus is NoPasswordException &&
            errorStatus.type == PasswordType.schoolnet) {
          ReloadWidget(
            errorStatus: FlutterI18n.translate(
              context,
              "school_net.empty_password",
            ),
            buttonName: FlutterI18n.translate(
              context,
              "setting.change_schoolnet_password_title",
            ),
            function: () async {
              await showDialog(
                context: context,
                builder: (context) => const SchoolNetPasswordDialog(),
              );
              if (!context.mounted) return;
              if (pref
                  .getString(pref.Preference.schoolNetQueryPassword)
                  .isNotEmpty) {
                await _reload(context);
              }
            },
          );
        }

        if (errorStatus is WrongPasswordException &&
            errorStatus.type == PasswordType.schoolnet) {
          ReloadWidget(
            errorStatus: FlutterI18n.translate(
              context,
              "school_net.wrong_password",
            ),
            buttonName: FlutterI18n.translate(
              context,
              "setting.change_schoolnet_password_title",
            ),
            function: () async {
              await showDialog(
                context: context,
                builder: (context) => const SchoolNetPasswordDialog(),
              );
              if (!context.mounted) return;
              if (pref
                  .getString(pref.Preference.schoolNetQueryPassword)
                  .isNotEmpty) {
                await _reload(context);
              }
            },
          );
        }

        return ReloadWidget(
          errorStatus: errorStatus is String
              ? FlutterI18n.translate(context, errorStatus)
              : errorStatus,
          stackTrace: stackTrace,
          function: () => _reload(context),
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
