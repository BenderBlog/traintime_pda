// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/page/energy/aircon_remote_page.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class AirconCard extends StatelessWidget {
  const AirconCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AirconController.i;
    return SignalBuilder(
      builder: (context) {
        final imei = controller.imeiSignal.value;
        final state = controller.deviceStateSignal.value;
        final openRemote = context.t.homepage.airconCard.openRemote;
        final waiting = (
          status: context.t.homepage.airconCard.fetching,
          detail: openRemote,
        );
        final display = imei.isEmpty
            ? (
                status: context.t.homepage.airconCard.notConfigured,
                detail: context.t.homepage.airconCard.configureHint,
              )
            : state.map(
                data: (aircon) => (
                  status: aircon.isOn
                      ? context.t.homepage.airconCard.running(
                          mode: context.t.resolveKey(aircon.mode.labelKey),
                          temperature: aircon.targetTemperature.toString(),
                        )
                      : context.t.homepage.airconCard.powerOff,
                  detail: aircon.indoorTemperature == null
                      ? context.t.homepage.airconCard.wind(
                          wind: context.t.resolveKey(aircon.windSpeed.labelKey),
                        )
                      : context.t.homepage.airconCard.indoorAndWind(
                          temperature: aircon.indoorTemperature.toString(),
                          wind: context.t.resolveKey(aircon.windSpeed.labelKey),
                        ),
                ),
                loading: () => waiting,
                refreshing: () => waiting,
                reloading: () => waiting,
                error: (_, _) => (
                  status: context.t.homepage.airconCard.error,
                  detail: openRemote,
                ),
              );

        return MainPageCard(
          onPressed: () => context.push(const AirconRemotePage()),
          isLoad: imei.isNotEmpty && state.isLoading,
          icon: Icons.ac_unit,
          text: context.t.homepage.airconCard.title,
          infoText: Text(display.status, style: const TextStyle(fontSize: 20)),
          bottomText: Text(display.detail, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
