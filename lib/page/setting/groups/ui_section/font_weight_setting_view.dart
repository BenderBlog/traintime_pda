// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
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
        return SettingSliderTile(
          leading: Icons.format_bold,
          title: context.t.setting.fontSizePage.weightTitle,
          formatValue: (value) => context.t.resolveKey(
            'setting.font_size_page.weight_${fontWeightLabels[fontWeightLabelIndex(value)]}',
          ),
          value: fontWeight,
          min: minFontWeight,
          max: maxFontWeight,
          divisions: fontWeightSliderDivisions,
          onChanged: (value) {
            ThemeController.i.fontWeightSignal.value = value;
          },
          onChangeEnd: (value) async {
            await preference.setDouble(preference.Preference.fontWeight, value);
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
