// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// SchoolNet password dialog.

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/generated/l10n.dart';

class SchoolNetPasswordDialog extends StatefulWidget {
  const SchoolNetPasswordDialog({super.key});

  @override
  State<SchoolNetPasswordDialog> createState() =>
      _SchoolNetPasswordDialogState();
}

class _SchoolNetPasswordDialogState extends State<SchoolNetPasswordDialog> {
  late final TextEditingController _schoolNetPasswordController;

  bool _couldView = true;

  @override
  void initState() {
    super.initState();
    final pwd = preference.getString(
      preference.Preference.schoolNetQueryPassword,
    );
    _schoolNetPasswordController = TextEditingController.fromValue(
      TextEditingValue(
        text: pwd,
        selection: TextSelection.collapsed(offset: pwd.length),
      ),
    );
  }

  @override
  void dispose() {
    _schoolNetPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        I18n.of(context)!.settingChangeSchoolnetPasswordTitle,
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
          hintText: I18n.of(context)!.settingChangePasswordDialogInputHint,
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
          child: Text(I18n.of(context)!.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(I18n.of(context)!.confirm),
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
                msg: I18n.of(context)!.settingChangePasswordDialogBlankInput,
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
