// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/public_widget/info_card.dart';
import 'package:watermeter/page/setting/dialogs/aircon_imei_dialog.dart';

class AirconEnergyCard extends StatelessWidget {
  const AirconEnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final controller = AirconController.i;
        final imei = controller.imeiSignal.value;
        if (imei.isEmpty) {
          return _buildMissingImeiCard(context);
        }

        return _buildEnergyCard(
          context,
          imei: imei,
          state: controller.energyInfoStateSignal.value,
          historyElectricityInfoList: controller.energyHistoryInfoList,
          onRefresh: controller.refreshEnergyInfo,
        );
      },
    );
  }

  Widget _buildMissingImeiCard(BuildContext context) {
    return InfoCard(
      iconData: Icons.ac_unit,
      title: FlutterI18n.translate(context, "electricity.aircon_title"),
      children: [
        Text(
          FlutterI18n.translate(context, "electricity.aircon_imei_missing"),
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ).padding(vertical: 8, horizontal: 12),
        FilledButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => const AirconImeiDialog(),
          ),
          icon: const Icon(Icons.add),
          label: Text(
            FlutterI18n.translate(context, "electricity.aircon_add_imei"),
          ),
        ).padding(horizontal: 12).width(double.infinity),
      ],
    );
  }

  Widget _buildEnergyCard(
    BuildContext context, {
    required String imei,
    required AsyncState<FetchResult<AirconEnergyInfo>> state,
    required List<ElectricityHistoryInfo> historyElectricityInfoList,
    required VoidCallback onRefresh,
  }) {
    return InfoCard(
      iconData: Icons.ac_unit,
      title: FlutterI18n.translate(context, "electricity.aircon_title"),
      icon: state is AsyncData<FetchResult<AirconEnergyInfo>>
          ? Icons.refresh
          : null,
      buttonText: state is AsyncData<FetchResult<AirconEnergyInfo>>
          ? FlutterI18n.translate(context, "electricity.update")
          : null,
      onTap: state is AsyncData<FetchResult<AirconEnergyInfo>>
          ? onRefresh
          : null,
      children: [
        state.map(
          data: (result) => Column(
            children: [
              if (result.isCache)
                Row(
                      children: [
                        Icon(Icons.cached, size: 18, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              "electricity.aircon_cache_notice",
                              translationParams: {
                                "time": DateFormat(
                                  "yyyy-MM-dd HH:mm",
                                ).format(result.fetchTime),
                              },
                            ),
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                    .padding(all: 12)
                    .decorated(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    )
                    .padding(bottom: 8, horizontal: 12),
              SizedBox(height: 8),
              InfoItem(
                icon: Icons.qr_code_2,
                label: FlutterI18n.translate(
                  context,
                  "electricity.aircon_imei",
                ),
                value: imei,
              ),
              InfoItem(
                icon: Icons.electric_bolt,
                label: FlutterI18n.translate(
                  context,
                  "electricity.aircon_amount",
                ),
                value: result.data.electricAmount.toString(),
              ),
              InfoItem(
                icon: Icons.update,
                label: FlutterI18n.translate(
                  context,
                  "electricity.aircon_update_time",
                ),
                value: DateFormat(
                  "yyyy-MM-dd HH:mm",
                ).format(result.data.stateTime),
              ),
              LayoutBuilder(
                    builder: (context, constraints) =>
                        ElectricityAverageUsageGraph(
                          graphWidth: constraints.maxWidth,
                          historyElectricityInfo: _airconDailyUsageInfo(
                            historyElectricityInfoList,
                          ),
                        ),
                  )
                  .padding(vertical: 12, horizontal: 16)
                  .decorated(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                  )
                  .padding(top: 4)
                  .width(double.infinity)
                  .padding(horizontal: 12),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ).padding(vertical: 12, horizontal: 12),
          refreshing: () => const Center(
            child: CircularProgressIndicator(),
          ).padding(vertical: 12, horizontal: 12),
          reloading: () => const Center(
            child: CircularProgressIndicator(),
          ).padding(vertical: 12, horizontal: 12),
          error: (err, stack) => Row(
            children: [
              Expanded(
                child: Text(
                  FlutterI18n.translate(context, "electricity.aircon_error"),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: onRefresh,
                child: Text(
                  FlutterI18n.translate(context, "electricity.aircon_retry"),
                ),
              ),
            ],
          ).padding(horizontal: 12),
        ),
      ],
    );
  }

  List<MeterInfo> _airconDailyUsageInfo(List<ElectricityHistoryInfo> history) {
    final data = <MeterInfo>[];
    if (history.isEmpty) return data;

    data.add(
      MeterInfo(
        ReadTime: history.first.fetchDay,
        ReadNum: 0,
        StartNum: 0,
        EndNum: 0,
      ),
    );

    for (var i = 1; i < history.length; i++) {
      final previous = num.tryParse(history[i - 1].remain);
      final current = num.tryParse(history[i].remain);
      if (previous == null || current == null) continue;
      final usage = current - previous;
      if (usage < 0) continue;

      data.add(
        MeterInfo(
          ReadTime: history[i].fetchDay,
          ReadNum: usage,
          StartNum: previous,
          EndNum: current,
        ),
      );
    }

    return data;
  }
}
