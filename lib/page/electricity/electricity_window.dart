// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/electricity_controller.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/page/electricity/electricity_average_usage_graph.dart';
import 'package:watermeter/page/electricity/electricity_usage_graph.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

class ElectricityWindow extends StatelessWidget {
  const ElectricityWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "electricity.title")),
      ),
      body: Watch((context) {
        final state = ElectricityController.i.electricityInfoSignal.value;
        return state.map(
          data: ((bool, ElectricityInfo) value) =>
              [
                    Text(
                          FlutterI18n.translate(context, "electricity.info"),
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

                    InfoCard(
                          iconData: Icons.info,
                          title: FlutterI18n.translate(
                            context,
                            "electricity.power_title",
                          ),
                          children: [
                            InfoItem(
                              icon: Icons.account_balance,
                              label: FlutterI18n.translate(
                                context,
                                "electricity.account",
                              ),
                              value: prefs.getString(
                                prefs.Preference.electricityAccount,
                              ),
                            ),
                            InfoItem(
                              icon: Icons.cached,
                              label: FlutterI18n.translate(
                                context,
                                "electricity.cache_notice",
                              ),
                              value: DateFormat(
                                "yyyy-MM-dd HH:mm",
                              ).format(value.$2.fetchDay),
                            ),
                            InfoItem(
                              icon: Icons.electric_meter,
                              label: FlutterI18n.translate(
                                context,
                                "electricity.remain_power",
                              ),
                              value:
                                  "${FlutterI18n.translate(context, value.$2.remain)}"
                                  "${value.$2.remain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}",
                            ),
                            InfoItem(
                              icon: Icons.wallet,
                              label: FlutterI18n.translate(
                                context,
                                "electricity.owe_info",
                              ),
                              value: FlutterI18n.translate(
                                context,
                                value.$2.owe,
                              ),
                            ),
                          ],
                        )
                        .padding(vertical: 4)
                        .constrained(maxWidth: sheetMaxWidth)
                        .center(),

                    InfoCard(
                          iconData: Icons.history,
                          title: FlutterI18n.translate(
                            context,
                            "electricity.history",
                          ),

                          children: [
                            LayoutBuilder(
                                  builder: (context, constraints) =>
                                      ElectricityUsageGraph(
                                        graphHeight: 240,
                                        graphWidth: constraints.maxWidth,
                                        historyElectricityInfo:
                                            ElectricityController
                                                .i
                                                .historyElectricitySignal,
                                      ),
                                )
                                .padding(vertical: 12, horizontal: 16)
                                .decorated(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                )
                                .padding(top: 4),
                          ],
                        )
                        .padding(vertical: 4)
                        .constrained(maxWidth: sheetMaxWidth)
                        .center(),

                    InfoCard(
                          iconData: Icons.bar_chart,
                          title: FlutterI18n.translate(
                            context,
                            "electricity.daily_usage",
                          ),
                          children: [
                            LayoutBuilder(
                                  builder: (context, constraints) =>
                                      ElectricityAverageUsageGraph(
                                        graphWidth: constraints.maxWidth,
                                        historyElectricityInfo:
                                            ElectricityController
                                                .i
                                                .historyElectricitySignal,
                                      ),
                                )
                                .padding(vertical: 12, horizontal: 16)
                                .decorated(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                )
                                .padding(top: 4),
                          ],
                        )
                        .padding(vertical: 4)
                        .constrained(maxWidth: sheetMaxWidth)
                        .center(),

                    FilledButton(
                          onPressed: () => ElectricityController.i
                              .refreshElectricityInfo(force: true),
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              "electricity.update",
                            ),
                          ),
                        )
                        .padding(horizontal: 4, vertical: 8)
                        .width(double.infinity)
                        .constrained(maxWidth: sheetMaxWidth)
                        .center(),

                    Image.asset(
                      "assets/art/pda_girl_default.png",
                    ).padding(bottom: 16),
                  ]
                  .toColumn(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                  )
                  .scrollable(padding: EdgeInsets.all(12)),
          error: (e, s) => ReloadWidget(
            errorStatus: e,
            stackTrace: s,
            function: () async {
              if (prefs
                  .getString(prefs.Preference.electricityAccount)
                  .isEmpty) {
                bool? isSaved = await showDialog<bool?>(
                  context: context,
                  builder: (context) => ElectricityAccountDialog(
                    onSaveAccount: (accountNumber) async {
                      await prefs.setString(
                        prefs.Preference.electricityAccount,
                        accountNumber,
                      );
                    },
                    initialAccountNumber: prefs.getString(
                      prefs.Preference.electricityAccount,
                    ),
                    onFetchFromNetwork: () async {
                      String dorm = await PersonalInfoSession()
                          .getDormInfoEhall();
                      return ElectricitySession.parseElectricityAccountFromIDS(
                        dorm,
                      );
                    },
                  ),
                );

                if (isSaved != true) {
                  if (context.mounted) {
                    showToast(
                      context: context,
                      msg: FlutterI18n.translate(
                        context,
                        "setting.change_electricity_account.no_setting",
                      ),
                    );
                    return;
                  }
                }
              }

              ElectricityController.i.clearElectricityHistory();

              if (context.mounted) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.successful_setting",
                  ),
                );
                ElectricityController.i.refreshElectricityInfo(force: true);
                return;
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          refreshing: () => const CircularProgressIndicator().center(),
          reloading: () => const CircularProgressIndicator().center(),
        );
      }),
    );
  }
}
