// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingUiSection extends StatelessWidget {
  final VoidCallback onChanged;

  const SettingUiSection({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightnessModeName = [
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.follow_setting",
      ),
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.day_mode",
      ),
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.night_mode",
      ),
    ];
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.ui_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
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
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.brightness_setting"),
            ),
            subtitle: Text(
              brightnessModeName[preference.getInt(
                preference.Preference.brightness,
              )],
            ),
            trailing: ToggleButtons(
              isSelected: List<bool>.generate(
                3,
                (index) =>
                    index ==
                    preference.getInt(preference.Preference.brightness),
              ),
              onPressed: (int value) async {
                await preference.setInt(
                  preference.Preference.brightness,
                  value,
                );
                ThemeController.i.updateTheme();
                onChanged();
              },
              children: const [
                Icon(Icons.phone_android_rounded),
                Icon(Icons.light_mode_rounded),
                Icon(Icons.dark_mode_rounded),
              ],
            ),
          ),
          const Divider(),
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
                onChanged();
              },
            ),
          ),
          const Divider(),
          ListTile(
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
    );
  }
}
