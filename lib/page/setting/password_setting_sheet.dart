// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/translation_key.dart';
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
      title: context.t.resolveKey(titleKey),
      initialValue: preference.getString(preferenceKey),
      label: context.t.setting.changePasswordDialog.inputHint,
      saveLabel: context.t.setting.editor.save,
      cancelLabel: context.t.common.cancel,
      failureMessage: context.t.common.errorDetected,
      isPassword: true,
      visibilityLabel: context.t.setting.editor.passwordVisibility,
      validator: (value) => value.isEmpty
          ? context.t.setting.changePasswordDialog.blankInput
          : null,
      onSave: (value) => preference.setString(preferenceKey, value),
    ),
  );
}
