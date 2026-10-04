// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/setting/setting_edit_sheet.dart';
import 'package:watermeter/repository/preference.dart' as preference;

Future<bool?> showPasswordSettingSheet({
  required BuildContext context,
  required preference.Preference preferenceKey,
  required String titleKey,
}) {
  return showSettingSheet<bool>(
    context: context,
    builder: (context) => SettingTextEditSheet(
      title: FlutterI18n.translate(context, titleKey),
      initialValue: preference.getString(preferenceKey),
      label: FlutterI18n.translate(
        context,
        'setting.change_password_dialog.input_hint',
      ),
      saveLabel: FlutterI18n.translate(context, 'setting.editor.save'),
      cancelLabel: FlutterI18n.translate(context, 'cancel'),
      failureMessage: FlutterI18n.translate(context, 'error_detected'),
      isPassword: true,
      visibilityLabel: FlutterI18n.translate(
        context,
        'setting.editor.password_visibility',
      ),
      validator: (value) => value.isEmpty
          ? FlutterI18n.translate(
              context,
              'setting.change_password_dialog.blank_input',
            )
          : null,
      onSave: (value) => preference.setString(preferenceKey, value),
    ),
  );
}
