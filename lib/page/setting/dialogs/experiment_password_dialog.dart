// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Experiment password dialog.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;

class ExperimentPasswordDialog extends StatefulWidget {
  const ExperimentPasswordDialog({Key? key}) : super(key: key);

  @override
  State<ExperimentPasswordDialog> createState() =>
      _ExperimentPasswordDialogState();
}

class _ExperimentPasswordDialogState extends State<ExperimentPasswordDialog> {
  /// Experiment Password Text Editing Controller
  final TextEditingController _experimentPasswordController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: user_perference
          .getString(user_perference.Preference.experimentPassword),
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: user_perference
              .getString(user_perference.Preference.experimentPassword)
              .length,
        ),
      ),
    ),
  );

  bool _couldView = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改物理实验系统密码'),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      content: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 20),
        controller: _experimentPasswordController,
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
            if (_experimentPasswordController.text.isNotEmpty) {
              user_perference.setString(
                user_perference.Preference.experimentPassword,
                _experimentPasswordController.text,
              );
              Navigator.of(context).pop();
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
