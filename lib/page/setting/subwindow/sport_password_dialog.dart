/*
Sport password dialog.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;

class SportPasswordDialog extends StatefulWidget {
  const SportPasswordDialog({Key? key}) : super(key: key);

  @override
  State<SportPasswordDialog> createState() => _SportPasswordDialogState();
}

class _SportPasswordDialogState extends State<SportPasswordDialog> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: user_perference.getString(user_perference.Preference.sportPassword),
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: user_perference
              .getString(user_perference.Preference.sportPassword)
              .length,
        ),
      ),
    ),
  );

  bool _couldView = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改体适能密码'),
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
              user_perference.setString(
                user_perference.Preference.sportPassword,
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
