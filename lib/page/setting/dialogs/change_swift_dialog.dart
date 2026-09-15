// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change class table swift dialog.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ChangeSwiftDialog extends StatelessWidget {
  final TextEditingController _getNumberController =
      TextEditingController.fromValue(
        TextEditingValue(
          text: preference.getInt(preference.Preference.swift).toString(),
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: preference
                  .getInt(preference.Preference.swift)
                  .toString()
                  .length,
            ),
          ),
        ),
      );

  ChangeSwiftDialog({super.key});

  void _toggleSign() {
    final currentText = _getNumberController.text;
    final updatedText = currentText.startsWith('-')
        ? currentText.substring(1)
        : '-$currentText';
    _getNumberController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: updatedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(context, "setting.change_swift_dialog.title"),
      ),
      content: TextField(
        autofocus: true,
        controller: _getNumberController,
        keyboardType: TextInputType.number,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(
            context,
            "setting.change_swift_dialog.input_hint",
          ),
          suffixIcon: IconButton(
            onPressed: _toggleSign,
            icon: const Text("±", style: TextStyle(fontSize: 20)),
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
            final value = int.tryParse(_getNumberController.text) ?? 0;
            await WeekSwiftController.i.setWeekSwift(value);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
