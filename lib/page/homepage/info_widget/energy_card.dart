// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/routing/routes.dart';

class EnergyCard extends StatelessWidget {
  const EnergyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EnergyController.i;
    return SignalBuilder(
      builder: (context) {
        final state = controller.energyInfoStateSignal.value;
        final displayInfo = controller.displayEnergyInfo.value;
        final electricityWarning = controller.electricityWarning.value;
        final firstElectricityMeter =
            displayInfo?.electricityMeterList.values.first;
        final lowElectricityWarning =
            firstElectricityMeter != null &&
            electricityWarning >= 0 &&
            /// TODO: Currently we just assume that there's only one electric meter in a dorm.
            firstElectricityMeter.remain < electricityWarning;

        return MainPageCard(
          onPressed: () async {
            context.pushReplacementNamed(Routes.electricity);
          },
          isLoad: state.isLoading && displayInfo == null,
          icon: MingCuteIcons.mgc_flash_line,
          type: lowElectricityWarning
              ? HomeCardType.warning
              : HomeCardType.plain,
          text: context.t.homepage.electricityCard.title,
          infoText: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 20),
            child: displayInfo != null
                ? Text(
                    firstElectricityMeter != null
                        ? context.t.homepage.electricityCard.currentElectricity(
                            amount: firstElectricityMeter.remain.toString(),
                          )
                        : context.t.electricityStatus.noElectricityInfo,
                  )
                : state.map(
                    data: (_) => const Text(""),
                    error: () =>
                        Text(context.t.electricityStatus.remainNotFound),
                    loading: () =>
                        Text(context.t.electricityStatus.remainFetching),
                  ),
          ),
          bottomText: displayInfo != null
              ? Text(
                  firstElectricityMeter != null
                      ? context.t.homepage.electricityCard
                            .cacheNotice(
                              date: DateFormat(
                                "yyyy-MM-dd",
                              ).format(firstElectricityMeter.fetchDay),
                            )
                            .replaceAll("\n", "")
                      : context.t.electricityStatus.noElectricityInfo,
                )
              : state.map(
                  data: (_) => const Text(""),
                  error: () => Text(context.t.electricityStatus.oweIssue),
                  loading: () => Text(context.t.electricityStatus.oweFetching),
                ),
        );
      },
    );
  }
}
