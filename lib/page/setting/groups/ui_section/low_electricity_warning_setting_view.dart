// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';

class LowElectricityWarningSettingView extends StatelessWidget {
  const LowElectricityWarningSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final enabled = EnergyController.i.lowElectricityWarningEnabled.value;
        return SwitchListTile(
          secondary: const Icon(MingCuteIcons.mgc_flash_line),
          title: Text(context.t.setting.lowElectricityWarning),
          subtitle: Text(context.t.setting.lowElectricityWarningDescription),
          value: enabled,
          onChanged: EnergyController.i.setLowElectricityWarningEnabled,
        );
      },
    );
  }
}
