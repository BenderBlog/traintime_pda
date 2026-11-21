// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/core/interfaces/theme_store_interface.dart';
import 'package:watermeter/core/themes/presentation/app_theme.dart';
import 'package:watermeter/core/widgets/settings/choice_control.dart';
import 'package:watermeter/core/widgets/settings/color_choices.dart';
import 'package:watermeter/core/widgets/settings/control_tile.dart';
import 'package:watermeter/core/widgets/settings/section_scaffold.dart';
import 'package:watermeter/core/widgets/settings/segmented_list.dart';
import 'package:watermeter/core/widgets/settings/slider_tile.dart';
import 'package:watermeter/generated/translations.g.dart';

class ThemeSettingsCard extends StatefulWidget {
  const ThemeSettingsCard({super.key});

  @override
  State<ThemeSettingsCard> createState() => _ThemeSettingsCardState();
}

class _ThemeSettingsCardState extends State<ThemeSettingsCard> {
  double? _fontScaleDraft;
  double? _fontWeightDraft;

  Future<void> _save(Future<void> Function() change) async {
    try {
      await change();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t.core.theme.saveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ThemeStoreInterface>();
    return SignalBuilder(
      builder: (context) {
        final settings = store.settings.value;
        final strings = context.t.core.theme;
        const brightnessIcons = [
          MingCuteIcons.mgc_brightness_line,
          MingCuteIcons.mgc_sun_line,
          MingCuteIcons.mgc_moon_line,
        ];
        final fontScale = _fontScaleDraft ?? settings.fontScale;
        final fontWeight = _fontWeightDraft ?? settings.fontWeight;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionSettingScaffold(
              icon: Icons.color_lens,
              title: strings.display,
              items: SettingSegmentedList(
                items: [
                  SettingControlTile(
                    leading: Icons.color_lens_outlined,
                    title: strings.colorSetting,
                    child: SettingColorChoices<ThemePalette>(
                      value: settings.palette,
                      options: [
                        for (final palette in ThemePalette.values)
                          SettingColorChoice(
                            value: palette,
                            label: switch (palette) {
                              ThemePalette.indigo => strings.palette.indigo,
                              ThemePalette.blue => strings.palette.blue,
                              ThemePalette.deepPurple =>
                                strings.palette.deepPurple,
                              ThemePalette.green => strings.palette.green,
                              ThemePalette.orange => strings.palette.orange,
                              ThemePalette.pink => strings.palette.pink,
                            },
                            color: palette == settings.palette
                                ? Theme.of(context).colorScheme.primary
                                : AppTheme.paletteColor(palette),
                          ),
                      ],
                      onChanged: (value) =>
                          _save(() => store.setPalette(value)),
                    ),
                  ),
                  SettingControlTile(
                    leading: brightnessIcons[settings.brightness.index],
                    title: strings.brightnessSetting,
                    child: SettingChoiceControl<ThemeBrightness>(
                      value: settings.brightness,
                      options: [
                        for (final brightness in ThemeBrightness.values)
                          SettingChoiceOption(
                            value: brightness,
                            icon: brightnessIcons[brightness.index],
                            label: switch (brightness) {
                              ThemeBrightness.system =>
                                strings.brightness.system,
                              ThemeBrightness.light => strings.brightness.light,
                              ThemeBrightness.dark => strings.brightness.dark,
                            },
                          ),
                      ],
                      onChanged: (value) =>
                          _save(() => store.setBrightness(value)),
                    ),
                  ),
                ],
              ),
            ),
            SectionSettingScaffold(
              icon: Icons.translate,
              title: strings.languageAndText,
              items: SettingSegmentedList(
                items: [
                  SettingSliderTile(
                    leading: Icons.text_fields,
                    title: strings.sizeTitle,
                    formatValue: (value) => '${(value * 100).round()}%',
                    value: fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 12,
                    onChanged: (value) async {
                      setState(() => _fontScaleDraft = value);
                      await _save(() => store.setFontScale(value));
                      if (mounted) setState(() => _fontScaleDraft = null);
                    },
                  ),
                  SettingSliderTile(
                    leading: Icons.format_bold,
                    title: strings.weightTitle,
                    formatValue: (value) => switch ((value * 4).round()) {
                      0 => strings.weight.thin,
                      1 => strings.weight.regular,
                      2 => strings.weight.medium,
                      3 => strings.weight.semibold,
                      _ => strings.weight.bold,
                    },
                    value: fontWeight,
                    min: 0,
                    max: 1,
                    divisions: 4,
                    onChanged: (value) async {
                      setState(() => _fontWeightDraft = value);
                      await _save(() => store.setFontWeight(value));
                      if (mounted) setState(() => _fontWeightDraft = null);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
