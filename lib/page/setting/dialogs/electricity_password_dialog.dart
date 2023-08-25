// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Electricity password dialog.

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ElectricityPasswordDialog extends StatefulWidget {
  const ElectricityPasswordDialog({Key? key}) : super(key: key);

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
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 20),
        controller: _sportPasswordController,
        obscureText: _couldView,
        decoration: InputDecoration(
          fillColor: Colors.grey.withOpacity(0.4),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          hintText: "请在此输入密码",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("输入空白!")));
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
