// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';
import 'package:watermeter/repository/xidian_ids/electricity_session.dart'
    as electricity_session;
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';
import 'package:graphic/graphic.dart' as graphic;

class ElectricityWindow extends StatelessWidget {
  const ElectricityWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "electricity.title")),
      ),
      body: Obx(() {
        if (isLoad.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!electricityInfo.value.remain.contains(RegExp(r'[0-9]'))) {
          return ReloadWidget(
            errorStatus: FlutterI18n.translate(
              context,
              electricityInfo.value.remain,
            ),
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

              electricity_session.ElectricitySession.clearElectricityHistory();

              if (context.mounted) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.successful_setting",
                  ),
                );
                electricity_session.update(force: true);
                return;
              }
            },
          ).center();
        }
        return [
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
                  .padding(all: 4),
              InfoCard(
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
                    value: prefs.getString(prefs.Preference.electricityAccount),
                  ),
                  InfoItem(
                    icon: Icons.cached,
                    label: FlutterI18n.translate(
                      context,
                      "electricity.cache_notice",
                    ),
                    value: DateFormat(
                      "yyyy-MM-dd HH:mm",
                    ).format(electricityInfo.value.fetchDay),
                  ),
                  InfoItem(
                    icon: Icons.electric_meter,
                    label: FlutterI18n.translate(
                      context,
                      "electricity.remain_power",
                    ),
                    value:
                        "${FlutterI18n.translate(context, electricityInfo.value.remain)}"
                        "${electricityInfo.value.remain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}",
                  ),
                  InfoItem(
                    icon: Icons.wallet,
                    label: FlutterI18n.translate(
                      context,
                      "electricity.owe_info",
                    ),
                    value: FlutterI18n.translate(
                      context,
                      electricityInfo.value.owe,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              InfoCard(
                title: FlutterI18n.translate(context, "electricity.history"),
                children: [
                  Builder(
                        builder: (context) {
                          final SplayTreeMap<DateTime, double> daily =
                              SplayTreeMap();
                          // Parsing number, store the latest data.
                          // Notice that the historyElectricityInfo have sorted.
                          for (final info in historyElectricityInfo) {
                            final v = double.tryParse(info.remain);
                            if (v == null) continue;

                            final dayTime = DateTime(
                              info.fetchDay.year,
                              info.fetchDay.month,
                              info.fetchDay.day,
                            );
                            // If historyElectricityInfo have not sorted,
                            // This line should be rewrite to ensure that the
                            // latest data have been fetched.
                            daily[dayTime] = v;
                          }

                          return graphic.Chart<Map<DateTime, double>>(
                            data: daily.entries
                                .map((entry) => {entry.key: entry.value})
                                .toList(),
                            variables: {
                              'day': graphic.Variable(
                                accessor: (Map<DateTime, double> map) =>
                                    map.keys.first,
                                scale: graphic.TimeScale(
                                  formatter: (v) => "${v.month}.${v.day}",
                                  min: daily.keys.length <= 1
                                      ? null
                                      : daily.keys.first,
                                  max: daily.keys.length <= 1
                                      ? null
                                      : daily.keys.last,
                                ),
                              ),
                              'power': graphic.Variable(
                                accessor: (Map<DateTime, double> map) =>
                                    map.values.first,
                                scale: graphic.LinearScale(),
                              ),
                            },
                            axes: [
                              graphic.Defaults.horizontalAxis,
                              graphic.Defaults.verticalAxis,
                            ],
                            marks: [
                              graphic.LineMark(
                                position:
                                    graphic.Varset('day') *
                                    graphic.Varset('power'),
                                shape: graphic.ShapeEncode(
                                  value: graphic.BasicLineShape(),
                                ),
                                color: graphic.ColorEncode(
                                  value: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              graphic.PointMark(
                                position:
                                    graphic.Varset('day') *
                                    graphic.Varset('power'),
                                size: graphic.SizeEncode(value: 2),
                                color: graphic.ColorEncode(
                                  value: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                            selections: {
                              'pointMouse': graphic.PointSelection(
                                on: {graphic.GestureType.hover},
                                //devices: {PointerDeviceKind.mouse},
                              ),
                              'pointTouch': graphic.PointSelection(
                                on: {
                                  graphic.GestureType.tapDown,
                                  graphic.GestureType.tapUp,
                                },
                                //devices: {graphic.PointerDeviceKind.touch},
                              ),
                            },
                            tooltip: graphic.TooltipGuide(
                              selections: {'pointMouse', 'pointTouch'},
                            ),
                            coord: graphic.RectCoord(
                              horizontalRange: [0.1, 0.9],
                            ),
                          ).constrained(height: 300);
                        },
                      )
                      .padding(vertical: 12, horizontal: 16)
                      .decorated(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(12),
                      )
                      .padding(top: 4),
                ],
              ),
              InfoCard(
                title: FlutterI18n.translate(
                  context,
                  "electricity.daily_usage",
                ),
                children: [
                  Builder(
                        builder: (context) {
                          // Record the smallest record of the day.
                          final SplayTreeMap<DateTime, double> dayMin =
                              SplayTreeMap();
                          for (final info in historyElectricityInfo) {
                            final v = double.tryParse(info.remain);
                            if (v == null) continue;
                            final dayTime = DateTime(
                              info.fetchDay.year,
                              info.fetchDay.month,
                              info.fetchDay.day,
                            );
                            if (!dayMin.containsKey(dayTime) ||
                                v < dayMin[dayTime]!) {
                              dayMin[dayTime] = v;
                            }
                          }
                          // If only one day, unable to parse.
                          if (dayMin.keys.length <= 1) {
                            return Text(
                              FlutterI18n.translate(
                                context,
                                "electricity.not_enough_data",
                              ),
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ).width(double.infinity);
                          }

                          // Daily usage of the electricity
                          final keys = dayMin.keys.toList();
                          final List<Map<String, double>> plotData = [];
                          double max = 0.0;
                          double min = double.maxFinite;
                          for (int i = 1; i < keys.length; i++) {
                            final dt = keys[i];
                            final dtPrev = keys[i - 1];
                            final curr = dayMin[keys[i]]!;
                            final prev = dayMin[keys[i - 1]]!;
                            final dayDiff = DateTime(dt.year, dt.month, dt.day)
                                .difference(
                                  DateTime(
                                    dtPrev.year,
                                    dtPrev.month,
                                    dtPrev.day,
                                  ),
                                )
                                .inDays;
                            final diff = (prev - curr) / dayDiff;
                            if (diff < 0) continue;
                            if (diff > max) max = diff;
                            if (diff < min) min = diff;
                            plotData.add({
                              "${dtPrev.month}.${dtPrev.day}~${dt.month}.${dt.day} ":
                                  diff,
                            });
                          }

                          return graphic.Chart<Map<String, double>>(
                            data: plotData,
                            variables: {
                              'range': graphic.Variable(
                                accessor: (map) => map.keys.first,
                              ),
                              'consPlot': graphic.Variable(
                                accessor: (map) => map.values.first,
                                scale: graphic.LinearScale(
                                  min: min * 0.6,
                                  max: max * 1.15,
                                  formatter: (v) => v.toStringAsFixed(2),
                                ),
                              ),
                            },
                            axes: [
                              graphic.Defaults.horizontalAxis,
                              graphic.Defaults.verticalAxis,
                            ],
                            marks: [
                              graphic.IntervalMark(
                                label: graphic.LabelEncode(
                                  encoder: (tuple) => graphic.Label(
                                    (tuple['consPlot'] as double)
                                        .toStringAsFixed(2),
                                  ),
                                ),
                                position:
                                    graphic.Varset('range') *
                                    graphic.Varset('consPlot'),
                                color: graphic.ColorEncode(
                                  value: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                            selections: {
                              'barHover': graphic.PointSelection(
                                on: {
                                  graphic.GestureType.hover,
                                  graphic.GestureType.tapDown,
                                  graphic.GestureType.tapUp,
                                  graphic.GestureType.longPressMoveUpdate,
                                  graphic.GestureType.scaleUpdate,
                                },
                              ),
                            },
                            tooltip: graphic.TooltipGuide(
                              selections: {'barHover'},
                            ),
                            coord: graphic.RectCoord(transposed: true),
                          ).constrained(height: 220);
                        },
                      )
                      .padding(vertical: 12, left: 28, right: 20)
                      .decorated(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(12),
                      )
                      .padding(top: 4),
                ],
              ),
              const SizedBox(height: 4),
              FilledButton(
                onPressed: () => update(force: true),
                child: Text(
                  FlutterI18n.translate(context, "electricity.update"),
                ),
              ).padding(all: 4),
              Image.asset("assets/art/pda_girl_default.png"),
            ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
            .constrained(maxWidth: 480)
            .padding(left: 12, right: 12, top: 12, bottom: 28)
            .scrollable()
            .center();
      }),
    );
  }
}
