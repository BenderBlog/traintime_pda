// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Change class table swift dialog.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: const Text('课程偏移设置'),
      content: TextField(
        autofocus: true,
        controller: _getNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[-+]?[0-9]*'))
        ],
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: "请在此输入数字",
          border: OutlineInputBorder(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('提交'),
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
