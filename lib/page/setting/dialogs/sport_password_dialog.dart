// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Sport password dialog.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;

class SportPasswordDialog extends StatefulWidget {
  const SportPasswordDialog({super.key});

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
      title: const Text('修改体育系统密码'),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
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
            Navigator.of(context).pop<bool>(false);
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
              Navigator.of(context).pop<bool>(true);
            } else {
              Fluttertoast.showToast(msg: "输入空白!");
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
