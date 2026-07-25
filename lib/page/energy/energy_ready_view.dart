// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/energy/aircon_energy_card.dart';
import 'package:watermeter/page/energy/electricity_energy_card.dart';
import 'package:watermeter/page/energy/water_energy_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class ElectricityReadyView extends StatelessWidget {
  const ElectricityReadyView({super.key});

  @override
  Widget build(BuildContext context) {
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
              .padding(vertical: 8, horizontal: 4)
              .width(double.infinity)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          const ElectricityEnergyCard()
              .padding(vertical: 4)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          const AirconEnergyCard()
              .padding(vertical: 4)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          const WaterEnergyCard()
              .padding(vertical: 4)
              .constrained(maxWidth: sheetMaxWidth)
              .center(),

          Image.asset("assets/art/pda_girl_default.png").padding(bottom: 16),
        ]
        .toColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
        )
        .scrollable(padding: const EdgeInsets.all(12));
  }
}
