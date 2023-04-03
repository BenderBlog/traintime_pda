/*
Change app color pattern.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/widget.dart';

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
                groupValue: int.parse(user["color"] ?? "0"),
                onChanged: (int? value) {
                  setState(() {
                    addUser("color", value.toString());
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
