// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

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
                      final Map<String, Map<String, dynamic>> daily = {};
                      for (final info in historyElectricityInfo) {
                        final numStr = info.remain.replaceAll(
                          RegExp(r'[^0-9\.\-]'),
                          '',
                        );
                        final v = double.tryParse(numStr);
                        if (v == null) continue;
                        final dayKey = DateFormat(
                          'yyyy-MM-dd',
                        ).format(info.fetchDay);
                        final dayTime = DateTime(
                          info.fetchDay.year,
                          info.fetchDay.month,
                          info.fetchDay.day,
                        );
                        final existing = daily[dayKey];
                        if (existing == null ||
                            v > (existing['power'] as num)) {
                          daily[dayKey] = {
                            'time': dayTime,
                            'day': DateFormat('MM-dd').format(dayTime),
                            'power': v,
                          };
                        }
                      }
                      final list = daily.values.toList()
                        ..sort(
                          (a, b) => (a['time'] as DateTime).compareTo(
                            b['time'] as DateTime,
                          ),
                        );
                      return graphic.Chart(
                            data: list,
                            variables: {
                              'day': graphic.Variable(
                                accessor: (Map map) => map['day'] as String,
                              ),
                              'power': graphic.Variable(
                                accessor: (Map map) => map['power'] as num,
                                scale: graphic.LinearScale(
                                  //nice: true,
                                ),
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
                                  value: graphic.BasicLineShape(smooth: true),
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
                              'hover': graphic.PointSelection(
                                on: {graphic.GestureType.hover},
                                dim: graphic.Dim.x,
                              ),
                            },
                            tooltip: graphic.TooltipGuide(
                              selections: {'hover'},
                            ),
                            crosshair: graphic.CrosshairGuide(
                              selections: {'hover'},
                            ),
                          )
                          .decorated(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                          )
                          .padding(top: 4)
                          .constrained(height: 220);
                    },
                  ),
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
                      // 以“每天最小读数”代表该日（遇到一天多次记录时取最小值）
                      final Map<String, double> dayMin = {};
                      for (final info in historyElectricityInfo) {
                        final numStr = info.remain.replaceAll(
                          RegExp(r'[^0-9\.\-]'),
                          '',
                        );
                        final v = double.tryParse(numStr);
                        if (v == null) continue;
                        final key = DateFormat(
                          'yyyy-MM-dd',
                        ).format(info.fetchDay);
                        if (!dayMin.containsKey(key) || v < dayMin[key]!) {
                          dayMin[key] = v;
                        }
                      }
                      // 计算“每日用电量”（相邻两天的正向消耗差），生成逐日柱状数据
                      final keys = dayMin.keys.toList()
                        ..sort((a, b) => a.compareTo(b));
                      final List<Map<String, dynamic>> barData = [];
                      for (int i = 1; i < keys.length; i++) {
                        final prev = dayMin[keys[i - 1]]!;
                        final curr = dayMin[keys[i]]!;
                        final diff = prev - curr; // 前一日最小读数 - 当日最小读数（允许为负）
                        final dt = DateFormat('yyyy-MM-dd').parse(keys[i]);
                        final dtPrev = DateFormat(
                          'yyyy-MM-dd',
                        ).parse(keys[i - 1]);
                        final range =
                            "${DateFormat('M-d').format(DateTime(dtPrev.year, dtPrev.month, dtPrev.day))}~\n${DateFormat('M-d').format(DateTime(dt.year, dt.month, dt.day))}";
                        barData.add({'range': range, 'cons': diff});
                      }
                      // 统一容器，内部内容根据数据量切换
                      late final Widget content;
                      late final double? height;
                      if (barData.length <= 1) {
                        height = null;
                        content = Text(
                          FlutterI18n.translate(
                            context,
                            "electricity.not_enough_data",
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        );
                      } else {
                        height = 220.0;
                        // 使用分段归一化：将原始 cons 映射到 [-0.3, 0.7]（负区 30%、正区 70%）
                        num minCons = barData.first['cons'] as num;
                        num maxCons = barData.first['cons'] as num;
                        for (final e in barData) {
                          final c = e['cons'] as num;
                          if (c < minCons) minCons = c;
                          if (c > maxCons) maxCons = c;
                        }
                        final num posMax = maxCons > 0 ? maxCons : 0;
                        final num negAbs = minCons < 0 ? -minCons : 0;
                        final List<Map<String, dynamic>> plotData = barData.map(
                          (e) {
                            final cons = e['cons'] as num;
                            final double consPlot = cons >= 0
                                ? (posMax == 0 ? 0 : (cons / posMax) * 0.7)
                                : (negAbs == 0 ? 0 : (cons / negAbs) * 0.3);
                            return {
                              'range': e['range'],
                              'cons': cons,
                              'consPlot': consPlot,
                            };
                          },
                        ).toList();

                        content = graphic.Chart(
                          data: plotData,
                          variables: {
                            'range': graphic.Variable(
                              accessor: (Map map) => map['range'] as String,
                            ),
                            'consPlot': graphic.Variable(
                              accessor: (Map map) => map['consPlot'] as num,
                              scale: graphic.LinearScale(
                                min: -0.3,
                                max: 0.7,
                                tickCount: 6,
                                // 轴标签映射回原始用量值，使读数与计算一致
                                formatter: (num v) {
                                  if (v == 0) return '0';
                                  if (v > 0) {
                                    final num orig = (posMax == 0)
                                        ? 0
                                        : (v / 0.7) * posMax;
                                    return orig.toStringAsFixed(2);
                                  } else {
                                    final num orig = (negAbs == 0)
                                        ? 0
                                        : (v / 0.3) * negAbs;
                                    return orig.toStringAsFixed(2);
                                  }
                                },
                              ),
                            ),
                          },
                          axes: [
                            graphic.Defaults.horizontalAxis,
                            graphic.Defaults.verticalAxis,
                          ],
                          marks: [
                            // 竖向柱状图：类目在 X 轴，数值在 Y 轴
                            graphic.IntervalMark(
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
                              on: {graphic.GestureType.hover},
                              dim: graphic.Dim.x,
                            ),
                          },
                          tooltip: graphic.TooltipGuide(
                            selections: {'barHover'},
                          ),
                        );
                      }
                      return Container(
                        height: height,
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(
                          8,
                          8,
                          8,
                          height == null ? 8 : 24,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: content,
                      );
                    },
                  ).padding(top: 4),
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
