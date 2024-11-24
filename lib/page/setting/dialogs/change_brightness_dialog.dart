// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Change app brightness.
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ChangeBrightnessDialog extends StatefulWidget {
  const ChangeBrightnessDialog({super.key});

  @override
  State<ChangeBrightnessDialog> createState() => _ChangeBrightnessDialogState();
}

class _ChangeBrightnessDialogState extends State<ChangeBrightnessDialog> {
  @override
  Widget build(BuildContext context) {
    List<String> demoBlueModeName = [
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

    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.title",
      )),
      content: SingleChildScrollView(
        child: Column(
          children: List<Widget>.generate(
            demoBlueModeName.length,
            (index) => RadioListTile<int>(
              title: Text(demoBlueModeName[index]),
              value: index,
              groupValue: preference.getInt(preference.Preference.brightness),
              onChanged: (int? value) {
                setState(() {
                  preference
                      .setInt(preference.Preference.brightness, value!)
                      .then((value) {
                    ThemeController toChange = Get.put(ThemeController());
                    toChange.onUpdate();
                  });
                });
              },
            ),
          ),
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
    );
  }
}
