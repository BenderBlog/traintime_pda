// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Electricity account dialog.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ElectricityAccountDialog extends StatelessWidget {
  final TextEditingController _controller =
      TextEditingController.fromValue(TextEditingValue(
    text: preference.getString(preference.Preference.dorm),
    selection: TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: preference.getString(preference.Preference.dorm).length,
    )),
  ));

  ElectricityAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "setting.change_electricity_account.title",
      )),
      content: TextField(
        autofocus: true,
        controller: _controller,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(
            context,
            "setting.change_electricity_account.input_hint",
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "cancel",
          )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "confirm",
          )),
          onPressed: () async {
            if (_controller.text.isNotEmpty) {
              preference.setString(
                preference.Preference.dorm,
                _controller.text,
              );
              Navigator.of(context).pop();
            } else {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "setting.change_electricity_account.blank_input",
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
