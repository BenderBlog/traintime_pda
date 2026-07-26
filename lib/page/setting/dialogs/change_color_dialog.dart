// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change app color pattern.

import 'package:flutter/material.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';
import 'package:watermeter/generated/l10n.dart';

class ChangeColorDialog extends StatefulWidget {
  const ChangeColorDialog({super.key});

  @override
  State<ChangeColorDialog> createState() => _ChangeColorDialogState();
}

class _ChangeColorDialogState extends State<ChangeColorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        I18n.of(context)!.settingChangeColorDialogTitle,
      ),
      content: SingleChildScrollView(
        child: RadioGroup(
          groupValue: preference.getInt(preference.Preference.color),
          onChanged: (int? value) {
            preference
                .setInt(preference.Preference.color, value!)
                .then(
                  (value) => setState(() {
                    ThemeController.i.updateTheme();
                  }),
                );
          },
          child: Column(
            children: List.generate(
              ColorSeed.values.length,
              (index) => RadioListTile<int>(
                title: Row(
                  children: [
                    Text(
                      _colorSeedToI18n(context, ColorSeed.values[index]),
                    ),
                    const SizedBox(width: 10),
                    ClipOval(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: pdaColorScheme[index * 2].primary,
                        ),
                      ),
                    ),
                  ],
                ),
                value: ColorSeed.values[index].index,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(I18n.of(context)!.confirm),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    );
  }
}

String _colorSeedToI18n(BuildContext context, ColorSeed seed) {
  return switch (seed) {
    ColorSeed.indigo => I18n.of(context)!.settingChangeColorDialogDefault,
    ColorSeed.blue => I18n.of(context)!.settingChangeColorDialogBlue,
    ColorSeed.deepPurple =>
      I18n.of(context)!.settingChangeColorDialogDeeppurple,
    ColorSeed.green => I18n.of(context)!.settingChangeColorDialogGreen,
    ColorSeed.orange => I18n.of(context)!.settingChangeColorDialogOrange,
    ColorSeed.pink => I18n.of(context)!.settingChangeColorDialogPink,
  };
}
