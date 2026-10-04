// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_dropdown_button.dart';
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

        return ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: Text(FlutterI18n.translate(context, 'setting.color_setting')),
          trailing: SizedBox(
            width: 180,
            child: SettingDropdownButton<int>(
              value: selectedColor,
              items: List.generate(ColorSeed.values.length, (index) {
                final colorSeed = ColorSeed.values[index];
                return DropdownMenuItem<int>(
                  value: index,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: index == selectedColor
                                ? currentColor
                                : pdaColorScheme[index * 2].primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FlutterI18n.translate(
                          context,
                          'setting.change_color_dialog.${colorSeed.label}',
                        ),
                      ),
                    ],
                  ),
                );
              }),
              onChanged: (value) async {
                if (value == null) return;
                await preference.setInt(preference.Preference.color, value);
                ThemeController.i.updateTheme();
              },
            ),
          ),
        );
      },
    );
  }
}
