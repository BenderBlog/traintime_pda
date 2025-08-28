// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// SchoolNet password dialog.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class SchoolNetPasswordDialog extends StatefulWidget {
  const SchoolNetPasswordDialog({super.key});

  @override
  State<SchoolNetPasswordDialog> createState() =>
      _SchoolNetPasswordDialogState();
}

class _SchoolNetPasswordDialogState extends State<SchoolNetPasswordDialog> {
  final TextEditingController _schoolNetPasswordController =
      TextEditingController.fromValue(
        TextEditingValue(
          text: preference.getString(
            preference.Preference.schoolNetQueryPassword,
          ),
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: preference
                  .getString(preference.Preference.electricityPassword)
                  .length,
            ),
          ),
        ),
      );

  bool _couldView = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(
          context,
          "setting.change_schoolnet_password_title",
        ),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      content: TextField(
        autofocus: true,
        controller: _schoolNetPasswordController,
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
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(context, "cancel")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(context, "confirm")),
          onPressed: () async {
            if (_schoolNetPasswordController.text.isNotEmpty) {
              preference.setString(
                preference.Preference.schoolNetQueryPassword,
                _schoolNetPasswordController.text,
              );
              Navigator.of(context).pop();
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
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
