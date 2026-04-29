// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/energy/electricity_window.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class EnergyCard extends StatelessWidget {
  const EnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EnergyController.i;
    final state = controller.energyInfoStateSignal.watch(context);
    final displayInfo = controller.displayEnergyInfo.value;

    return MainPageCard(
      onPressed: () async {
        context.push(ElectricityWindow());
      },
      isLoad: state.isLoading && displayInfo == null,
      icon: MingCuteIcons.mgc_flash_line,
      text: FlutterI18n.translate(context, "homepage.electricity_card.title"),
      infoText: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 20),
        child: displayInfo != null
            ? Text(
                FlutterI18n.translate(
                  context,
                  "homepage.electricity_card.current_electricity",
                  translationParams: {
                    "amount": displayInfo.electricityRemain.toString(),
                  },
                ),
              )
            : state.map(
                data: (_) => const Text(""),
                error: () => Text(
                  FlutterI18n.translate(
                    context,
                    "electricity_status.remain_not_found",
                  ),
                ),
                loading: () => Text(
                  FlutterI18n.translate(
                    context,
                    "electricity_status.remain_fetching",
                  ),
                ),
              ),
      ),
      bottomText: displayInfo != null
          ? Text(
              FlutterI18n.translate(
                context,
                "homepage.electricity_card.cache_notice",
                translationParams: {
                  "date": DateFormat(
                    "yyyy-MM-dd",
                  ).format(displayInfo.electricityMeterList.first.ReadTime),
                },
              ).replaceAll("\n", ""),
            )
          : state.map(
              data: (_) => const Text(""),
              error: () => Text(
                FlutterI18n.translate(context, "electricity_status.owe_issue"),
              ),
              loading: () => Text(
                FlutterI18n.translate(
                  context,
                  "electricity_status.owe_fetching",
                ),
              ),
            ),
    );
  }
}
