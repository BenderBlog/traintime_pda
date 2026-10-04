// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_choice_control.dart';
import 'package:watermeter/page/public_widget/setting/setting_control_tile.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class BrightnessSettingView extends StatelessWidget {
  const BrightnessSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    const icons = [
      MingCuteIcons.mgc_brightness_line,
      MingCuteIcons.mgc_sun_line,
      MingCuteIcons.mgc_moon_line,
    ];

    return SignalBuilder(
      builder: (context) {
        final themeMode = ThemeController.i.colorStateSignal.value;
        final leadingIcon = switch (themeMode) {
          ThemeMode.light => icons[1],
          ThemeMode.dark => icons[2],
          _ => icons[0],
        };

        return SettingControlTile(
          leading: leadingIcon,
          title: FlutterI18n.translate(context, 'setting.brightness_setting'),
          child: SettingChoiceControl<int>(
            value: preference.getInt(preference.Preference.brightness),
            options: List.generate(BrightnessSeed.values.length, (index) {
              final brightnessSeed = BrightnessSeed.values[index];
              return SettingChoiceOption<int>(
                value: index,
                icon: icons[index],
                label: FlutterI18n.translate(
                  context,
                  'setting.change_brightness_dialog.${brightnessSeed.label}',
                ),
              );
            }),
            onChanged: (value) async {
              await preference.setInt(preference.Preference.brightness, value);
              ThemeController.i.updateTheme();
            },
          ),
        );
      },
    );
  }
}
