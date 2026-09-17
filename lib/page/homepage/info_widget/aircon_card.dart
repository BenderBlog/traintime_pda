// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/page/energy/aircon_remote_page.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';

class AirconCard extends StatelessWidget {
  const AirconCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AirconController.i;
    return SignalBuilder(
      builder: (context) {
        final imei = controller.imeiSignal.value;
        final state = controller.deviceStateSignal.value;
        final openRemote = FlutterI18n.translate(
          context,
          "homepage.aircon_card.open_remote",
        );
        final waiting = (
          status: FlutterI18n.translate(
            context,
            "homepage.aircon_card.fetching",
          ),
          detail: openRemote,
        );
        final display = imei.isEmpty
            ? (
                status: FlutterI18n.translate(
                  context,
                  "homepage.aircon_card.not_configured",
                ),
                detail: FlutterI18n.translate(
                  context,
                  "homepage.aircon_card.configure_hint",
                ),
              )
            : state.map(
                data: (aircon) => (
                  status: aircon.isOn
                      ? FlutterI18n.translate(
                          context,
                          "homepage.aircon_card.running",
                          translationParams: {
                            "mode": FlutterI18n.translate(
                              context,
                              aircon.mode.labelKey,
                            ),
                            "temperature": aircon.targetTemperature.toString(),
                          },
                        )
                      : FlutterI18n.translate(
                          context,
                          "homepage.aircon_card.power_off",
                        ),
                  detail: FlutterI18n.translate(
                    context,
                    aircon.indoorTemperature == null
                        ? "homepage.aircon_card.wind"
                        : "homepage.aircon_card.indoor_and_wind",
                    translationParams: {
                      "temperature": aircon.indoorTemperature.toString(),
                      "wind": FlutterI18n.translate(
                        context,
                        aircon.windSpeed.labelKey,
                      ),
                    },
                  ),
                ),
                loading: () => waiting,
                refreshing: () => waiting,
                reloading: () => waiting,
                error: (_, _) => (
                  status: FlutterI18n.translate(
                    context,
                    "homepage.aircon_card.error",
                  ),
                  detail: openRemote,
                ),
              );

        return MainPageCard(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const AirconRemotePage(),
            ),
          ),
          isLoad: imei.isNotEmpty && state.isLoading,
          icon: Icons.ac_unit,
          text: FlutterI18n.translate(context, "homepage.aircon_card.title"),
          infoText: Text(display.status, style: const TextStyle(fontSize: 20)),
          bottomText: Text(display.detail, overflow: TextOverflow.ellipsis),
          rightButton: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
