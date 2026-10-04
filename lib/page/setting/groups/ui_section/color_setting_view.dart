// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_color_choices.dart';
import 'package:watermeter/page/public_widget/setting/setting_control_tile.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class ColorSettingView extends StatelessWidget {
  const ColorSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final currentColor = ThemeController.i.colorSignal.value.first.primary;
        final selectedColor = preference.getInt(preference.Preference.color);

        return SettingControlTile(
          leading: Icons.color_lens_outlined,
          title: FlutterI18n.translate(context, 'setting.color_setting'),
          child: SettingColorChoices<int>(
            value: selectedColor,
            options: List.generate(ColorSeed.values.length, (index) {
              final colorSeed = ColorSeed.values[index];
              return SettingColorChoice<int>(
                value: index,
                label: FlutterI18n.translate(
                  context,
                  'setting.change_color_dialog.${colorSeed.label}',
                ),
                color: index == selectedColor
                    ? currentColor
                    : pdaColorScheme[index * 2].primary,
              );
            }),
            onChanged: (value) async {
              await preference.setInt(preference.Preference.color, value);
              ThemeController.i.updateTheme();
            },
          ),
        );
      },
    );
  }
}
