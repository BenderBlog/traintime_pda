// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/font_setting.dart';

class FontWeightSettingView extends StatelessWidget {
  const FontWeightSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        double fontWeight = ThemeController.i.fontWeightSignal.value;
        return ListTile(
          leading: const Icon(Icons.format_bold),
          title: Text(
            "${FlutterI18n.translate(context, "setting.font_size_page.weight_title")} ${FlutterI18n.translate(context, "setting.font_size_page.weight_"
            "${fontWeightLabels[fontWeightLabelIndex(fontWeight)]}")}",
          ),
          subtitle: SizedBox(
            height: 48,
            child: Transform.translate(
              offset: const Offset(-10, 0),
              child: M3ESlider(
                value: ThemeController.i.fontWeightSignal.value,
                min: minFontWeight,
                max: maxFontWeight,
                divisions: 12,
                onChanged: (value) {
                  ThemeController.i.fontWeightSignal.value = value;
                },
                onChangeEnd: (value) async {
                  await preference.setDouble(
                    preference.Preference.fontWeight,
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
