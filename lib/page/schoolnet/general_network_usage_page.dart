// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/model/network_usage.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/schoolnet_session.dart';
import 'package:watermeter/generated/l10n.dart';

class GeneralNetworkUsagePage extends StatefulWidget {
  const GeneralNetworkUsagePage({super.key});

  @override
  State<GeneralNetworkUsagePage> createState() =>
      _GeneralNetworkUsagePageState();
}

class _GeneralNetworkUsagePageState extends State<GeneralNetworkUsagePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<FetchResult<GeneralNetworkUsage>> state;
  final SchoolnetSession session = SchoolnetSession();
  bool _initialized = false;

  Future<void> _reload(BuildContext context) =>
      state = session.getGeneralNetworkUsage(
        captchaFunction: (image, onRefresh) => showDialog<String>(
          context: context,
          builder: (context) => CaptchaInputDialog(
            image: image,
            onRefresh: onRefresh,
          ),
        ).then((value) => value ?? ""),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _reload(context);
    }
  }

  Widget _buildUsageBody(
    BuildContext context,
    FetchResult<GeneralNetworkUsage> result,
  ) =>
      [
        if (result.isCache)
          CacheAlerter(
            dataType: I18n.of(context)!.schoolNetTitle,
            hint: _schoolnetCacheHint(context, result.cacheHint),
            placeOfCache: PlaceOfCache.inapp,
            fetchTime: result.fetchTime,
          ).center(),
        [
              // 注意事项
              Text(
                    I18n.of(context)!.schoolNetIdsAccountNetNotice,
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
                    title: I18n.of(context)!.schoolNetIdsAccountNetOverview,
                    children: [
                      InfoItem(
                        icon: Icons.person,
                        label: I18n.of(context)!.schoolNetIdsAccountNetAccount,
                        value: pref.getString(pref.Preference.idsAccount),
                      ),
                      InfoItem(
                        icon: Icons.data_usage,
                        label: I18n.of(context)!.schoolNetIdsAccountNetUsed,
                        value: result.data.used,
                        valueColor: Colors.green,
                      ),
                      InfoItem(
                        icon: Icons.account_balance_wallet,
                        label: I18n.of(context)!.schoolNetIdsAccountNetRemain,
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
                    onPressed: () => setState(() {
                      _reload(context);
                    }),
                    child: Text(
                      I18n.of(context)!.schoolNetRefresh,
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
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: state,
      builder: (context, snapshot) {
        // 首次加载，无数据且正在加载 → 全屏转圈
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // 有缓存数据 + 正在后台刷新 → 显示旧数据 + LoadingAlerter 提示条
        if (snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return Stack(
            children: [
              _buildUsageBody(context, snapshot.data!),
              LoadingAlerter(
                isLoading: true,
                hint: I18n.of(context)!.schoolNetFetching,
                opacity: 0.15,
              ),
            ],
          );
        }

        if (snapshot.hasData) {
          return _buildUsageBody(context, snapshot.data!);
        }
        if (snapshot.hasError) {
          if (snapshot.error is NoPasswordException &&
              (snapshot.error as NoPasswordException).type ==
                  PasswordType.schoolnet) {
            return ReloadWidget(
              errorStatus: I18n.of(context)!.schoolNetEmptyPassword,
              buttonName: I18n.of(context)!.settingChangeSchoolnetPasswordTitle,
              function: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const SchoolNetPasswordDialog(),
                );
                if (!context.mounted) return;
                if (pref
                    .getString(pref.Preference.schoolNetQueryPassword)
                    .isNotEmpty) {
                  setState(() {
                    _reload(context);
                  });
                }
              },
            );
          }

          if (snapshot.error is WrongPasswordException &&
              (snapshot.error as WrongPasswordException).type ==
                  PasswordType.schoolnet) {
            return ReloadWidget(
              errorStatus: I18n.of(context)!.schoolNetWrongPassword,
              buttonName: I18n.of(context)!.settingChangeSchoolnetPasswordTitle,
              function: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const SchoolNetPasswordDialog(),
                );
                if (!context.mounted) return;
                if (pref
                    .getString(pref.Preference.schoolNetQueryPassword)
                    .isNotEmpty) {
                  setState(() {
                    _reload(context);
                  });
                }
              },
            );
          }

          return ReloadWidget(
            errorStatus: snapshot.error is String
                ? (snapshot.error as String)
                : snapshot.error,
            stackTrace: snapshot.stackTrace,
            function: () => setState(() {
              _reload(context);
            }),
          );
        }
        // Fallback: 不应到达此处
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
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
              I18n.of(context)!.schoolNetDeviceListIp,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),

            Text(
              I18n.of(context)!.schoolNetDeviceListTime,
              style: headerStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),

            Text(
              I18n.of(context)!.schoolNetDeviceListRemain,
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
              d.$2,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 4),
            Text(
              d.$3,
              style: cellStyle,
              textAlign: TextAlign.center,
            ).expanded(flex: 3),
          ].toRow().padding(vertical: 10),
        ].toColumn();
      }),
    ].toColumn().card(elevation: 0);
  }
}

String _schoolnetCacheHint(BuildContext context, Object? hint) {
  if (hint == null) {
    return I18n.of(context)!.cacheReasonDefault;
  }
  return switch (hint) {
    SchoolnetCacheHint.captchaFailed =>
      I18n.of(context)!.schoolNetCacheHintCaptchaFailed,
    SchoolnetCacheHint.requestFailed =>
      I18n.of(context)!.schoolNetCacheHintRequestFailed,
    _ => I18n.of(context)!.cacheReasonDefault,
  };
}
