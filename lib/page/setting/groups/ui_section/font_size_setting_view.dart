// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/font_setting.dart';

class FontSizeSettingView extends StatelessWidget {
  const FontSizeSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final fontScale = ThemeController.i.fontScaleSignal.value;
        return ListTile(
          leading: const Icon(Icons.text_fields),
          title: Text(
            "${FlutterI18n.translate(context, "setting.font_size_page.size_title")} ${(fontScale * 100).round()}%",
          ),
          subtitle: SizedBox(
            height: 48,
            child: Transform.translate(
              offset: const Offset(-10, 0),
              child: M3ESlider(
                value: fontScale,
                min: minFontScale,
                max: maxFontScale,
                divisions: 12,
                onChanged: (value) {
                  ThemeController.i.fontScaleSignal.value = value;
                },
                onChangeEnd: (value) async {
                  await preference.setDouble(
                    preference.Preference.fontScale,
                    value,
                  );
                  ThemeController.i.updateTheme();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
