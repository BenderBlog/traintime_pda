// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/setting/numeric_setting_sheet.dart';

class LowElectricityThresholdSettingView extends StatelessWidget {
  const LowElectricityThresholdSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final enabled = EnergyController.i.lowElectricityWarningEnabled.value;

        return ListTile(
          leading: const Icon(MingCuteIcons.mgc_alert_line),
          enabled: enabled,
          title: Text(context.t.setting.lowElectricityThreshold),
          subtitle: Text(
            context.t.setting.lowElectricityThresholdDescription(
              threshold: EnergyController.i.electricityThreshold.toString(),
            ),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: enabled
              ? () async {
                  await showElectricityThresholdSheet(context);
                }
              : null,
        );
      },
    );
  }
}
