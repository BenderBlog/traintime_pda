// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Change app brightness.
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:watermeter/themes/demo_blue.dart';
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
    return AlertDialog(
      title: const Text('颜色设置'),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
          child: const Text('改完了'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    );
  }
}
