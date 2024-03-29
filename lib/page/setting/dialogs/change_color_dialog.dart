// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Change app color pattern.
// Omit from release temporarity.
/*
import 'package:flutter/material.dart';
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
      title: const Text('颜色设置'),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            for (int i = 0; i < ColorSeed.values.length; ++i)
              RadioListTile<int>(
                title: Row(
                  children: [
                    Text(ColorSeed.values[i].label),
                    const SizedBox(
                      width: 10,
                    ),
                    ClipOval(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorSeed.values[i].color,
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
            const Divider(),
          ],
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
*/