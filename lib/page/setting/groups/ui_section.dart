// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/low_electricity_threshold_dialog.dart';
import 'package:watermeter/page/setting/font_size_page.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';
import 'package:watermeter/themes/font_setting.dart';

class UiSection extends StatefulWidget {
  const UiSection({super.key});

  @override
  State<UiSection> createState() => _UiSectionState();
}

class _UiSectionState extends State<UiSection> {
  Widget _brightnessSetting(BuildContext context) {
    final labels = ['follow_setting', 'day_mode', 'night_mode']
        .map(
          (label) => FlutterI18n.translate(
            context,
            'setting.change_brightness_dialog.$label',
          ),
        )
        .toList();
    final selected = preference.getInt(preference.Preference.brightness);
    const icons = [
      MingCuteIcons.mgc_brightness_line,
      MingCuteIcons.mgc_sun_line,
      MingCuteIcons.mgc_moon_line,
    ];
    return ListTile(
      leading: Icon(icons[selected]),
      title: Text(FlutterI18n.translate(context, 'setting.brightness_setting')),
      subtitle: Text(labels[selected]),
      trailing: const Icon(Icons.navigate_next),
      onTap: () async {
        final value = await showDialog<int>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(
              FlutterI18n.translate(context, 'setting.brightness_setting'),
            ),
            children: [
              RadioGroup<int>(
                groupValue: selected,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < labels.length; index++)
                      RadioListTile<int>(
                        value: index,
                        title: Text(labels[index]),
                        secondary: Icon(icons[index]),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (value == null || value == selected) return;
        await preference.setInt(preference.Preference.brightness, value);
        ThemeController.i.updateTheme();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      items: [
        SectionSettingScaffold(
          title: FlutterI18n.translate(context, 'setting.sections.display'),
          items: [
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_palette_line),
              title: Text(
                FlutterI18n.translate(context, "setting.color_setting"),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  "setting.change_color_dialog."
                  "${ColorSeed.values[preference.getInt(preference.Preference.color)].label}",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ChangeColorDialog(),
                );
              },
            ),
            _brightnessSetting(context),
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_font_size_line),
              title: Text(
                FlutterI18n.translate(context, "setting.font_size_setting"),
              ),
              subtitle: SignalBuilder(
                builder: (context) => Text(
                  FlutterI18n.translate(
                    context,
                    "setting.font_size_page.summary",
                    translationParams: {
                      "scale":
                          "${(ThemeController.i.fontScaleSignal.value * 100).round()}",
                      "weight": FlutterI18n.translate(
                        context,
                        "setting.font_size_page.weight_"
                        "${fontWeightLabels[fontWeightLabelIndex(ThemeController.i.fontWeightSignal.value)]}",
                      ),
                    },
                  ),
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                context.push(const FontSizePage());
              },
            ),
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_translate_line),
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.localization_dialog.title",
                ),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  Localization.values
                      .firstWhere(
                        (value) =>
                            value.string ==
                            preference.getString(
                              preference.Preference.localization,
                            ),
                      )
                      .toShow,
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const ChangeLanguageDialog(),
                );
              },
            ),
          ],
        ),
        SectionSettingScaffold(
          title: FlutterI18n.translate(context, 'setting.sections.home'),
          items: [
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_timeline_line),
              title: Text(
                FlutterI18n.translate(context, "setting.simplify_timeline"),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  "setting.simplify_timeline_description",
                ),
              ),
              trailing: Switch(
                value: preference.getBool(
                  preference.Preference.simplifiedClassTimeline,
                ),
                onChanged: (bool value) async {
                  await preference.setBool(
                    preference.Preference.simplifiedClassTimeline,
                    value,
                  );
                  ClassTableCard.reloadSettingsFromPref();

                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
        SectionSettingScaffold(
          title: FlutterI18n.translate(context, 'setting.sections.electricity'),
          items: [
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_flash_line),
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.low_electricity_warning",
                ),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  "setting.low_electricity_warning_description",
                ),
              ),
              trailing: SignalBuilder(
                builder: (context) {
                  return Switch(
                    value: EnergyController.i.electricityWarning.value >= 0,
                    onChanged: (bool value) async {
                      await EnergyController.i.setLowElectricityWarningEnabled(
                        value,
                      );
                    },
                  );
                },
              ),
            ),
            SignalBuilder(
              builder: (context) {
                return ListTile(
                  leading: const Icon(MingCuteIcons.mgc_alert_line),
                  enabled:
                      EnergyController.i.lowElectricityWarningEnabled.value,
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.low_electricity_threshold",
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.low_electricity_threshold_description",
                      translationParams: {
                        "threshold": EnergyController.i.electricityThreshold
                            .toString(),
                      },
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: EnergyController.i.lowElectricityWarningEnabled.value
                      ? () async {
                          await showDialog<int>(
                            context: context,
                            builder: (context) =>
                                LowElectricityThresholdDialog(),
                          );
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
