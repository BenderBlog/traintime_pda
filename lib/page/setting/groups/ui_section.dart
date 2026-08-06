// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/low_electricity_threshold_dialog.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class UiSection extends StatefulWidget {
  const UiSection({super.key});

  @override
  State<UiSection> createState() => _UiSectionState();
}

class _UiSectionState extends State<UiSection> {
  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, "setting.ui_setting"),
      items: [
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.color_setting")),
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
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.brightness_setting"),
          ),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              [
                "setting.change_brightness_dialog.follow_setting",
                "setting.change_brightness_dialog.day_mode",
                "setting.change_brightness_dialog.night_mode",
              ][preference.getInt(preference.Preference.brightness)],
            ),
          ),
          trailing: ToggleButtons(
            isSelected: List<bool>.generate(
              3,
              (index) =>
                  index == preference.getInt(preference.Preference.brightness),
            ),
            onPressed: (int value) async {
              preference.setInt(preference.Preference.brightness, value).then((
                value,
              ) {
                ThemeController.i.updateTheme();
                setState(() {});
              });
            },
            children: const [
              Icon(Icons.phone_android_rounded),
              Icon(Icons.light_mode_rounded),
              Icon(Icons.dark_mode_rounded),
            ],
          ),
        ),
        ListTile(
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
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.low_electricity_warning"),
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
              enabled: EnergyController.i.lowElectricityWarningEnabled.value,
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
                        builder: (context) => LowElectricityThresholdDialog(),
                      );
                    }
                  : null,
            );
          },
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.localization_dialog.title"),
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
    );
  }
}
