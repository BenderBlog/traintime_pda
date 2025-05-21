// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change class table swift dialog.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ChangeSwiftDialog extends StatelessWidget {
  final TextEditingController _getNumberController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: preference.getInt(preference.Preference.swift).toString(),
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset:
              preference.getInt(preference.Preference.swift).toString().length,
        ),
      ),
    ),
  );

  ChangeSwiftDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "setting.change_swift_dialog.title",
      )),
      content: TextField(
        autofocus: true,
        controller: _getNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[-+]?[0-9]*'))
        ],
        maxLines: 1,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(
            context,
            "setting.change_swift_dialog.input_hint",
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(context, "cancel")),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(FlutterI18n.translate(context, "confirm")),
          onPressed: () async {
            if (_getNumberController.text.isEmpty) {
              await preference.setInt(preference.Preference.swift, 0);
            } else {
              await preference.setInt(
                preference.Preference.swift,
                int.parse(_getNumberController.text),
              );
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
