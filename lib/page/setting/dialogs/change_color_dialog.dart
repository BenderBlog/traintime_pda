// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change app color pattern.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class ChangeColorDialog extends StatefulWidget {
  const ChangeColorDialog({super.key});

  @override
  State<ChangeColorDialog> createState() => _ChangeColorDialogState();
}

class _ChangeColorDialogState extends State<ChangeColorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "setting.change_color_dialog.title",
      )),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < ColorSeed.values.length; ++i)
              RadioListTile<int>(
                title: Row(
                  children: [
                    Text(FlutterI18n.translate(
                      context,
                      "setting.change_color_dialog.${ColorSeed.values[i].label}",
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    ClipOval(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: pdaColorScheme[i * 2].primary,
                        ),
                      ),
                    ),
                  ],
                ),
                value: ColorSeed.values[i].index,
                groupValue: preference.getInt(preference.Preference.color),
                onChanged: (int? value) {
                  setState(() {
                    preference.setInt(preference.Preference.color, value!);
                    ThemeController toChange = Get.put(ThemeController());
                    toChange.onUpdate();
                  });
                },
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "confirm",
          )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    );
  }
}
