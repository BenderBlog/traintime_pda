// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
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
        return SettingSliderTile(
          leading: Icons.text_fields,
          title: context.t.setting.fontSizePage.sizeTitle,
          formatValue: (value) => "${(value * 100).round()}%",
          value: fontScale,
          min: minFontScale,
          max: maxFontScale,
          divisions: 12,
          onChanged: (value) {
            ThemeController.i.fontScaleSignal.value = value;
          },
          onChangeEnd: (value) async {
            await preference.setDouble(preference.Preference.fontScale, value);
            ThemeController.i.updateTheme();
          },
          preview: Text(
            context.t.setting.editor.textPreview,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}
