// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Experiment password dialog.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;

class ExperimentPasswordDialog extends StatefulWidget {
  const ExperimentPasswordDialog({super.key});

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
      title: Text(FlutterI18n.translate(
        context,
        "setting.change_experiment_title",
      )),
      content: TextField(
        autofocus: true,
        controller: _experimentPasswordController,
        obscureText: _couldView,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(
            context,
            "setting.change_password_dialog.input_hint",
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
          child: Text(FlutterI18n.translate(
            context,
            "cancel",
          )),
          onPressed: () {
            Navigator.pop<bool>(context, false);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "confirm",
          )),
          onPressed: () async {
            if (_experimentPasswordController.text.isNotEmpty) {
              user_perference.setString(
                user_perference.Preference.experimentPassword,
                _experimentPasswordController.text,
              );
              Navigator.of(context).pop<bool>(true);
            } else {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "setting.change_password_dialog.blank_input",
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
