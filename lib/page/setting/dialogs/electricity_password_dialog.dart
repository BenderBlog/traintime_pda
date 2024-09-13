// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Electricity password dialog.

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ElectricityPasswordDialog extends StatefulWidget {
  const ElectricityPasswordDialog({super.key});

  @override
  State<ElectricityPasswordDialog> createState() =>
      _ElectricityPasswordDialogState();
}

class _ElectricityPasswordDialogState extends State<ElectricityPasswordDialog> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController =
      TextEditingController.fromValue(TextEditingValue(
    text: preference.getString(preference.Preference.electricityPassword),
    selection: TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: preference
          .getString(preference.Preference.electricityPassword)
          .length,
    )),
  ));

  bool _couldView = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改电费帐号密码'),
      content: TextField(
        autofocus: true,
        controller: _sportPasswordController,
        obscureText: _couldView,
        decoration: InputDecoration(
          hintText: "请在此输入密码",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
              icon: Icon(_couldView ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _couldView = !_couldView;
                });
              }),
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
            if (_sportPasswordController.text.isNotEmpty) {
              preference.setString(
                preference.Preference.electricityPassword,
                _sportPasswordController.text,
              );
              Navigator.of(context).pop();
            } else {
              showToast(context: context, msg: "输入空白!");
            }
          },
        ),
      ],
    );
  }
}
