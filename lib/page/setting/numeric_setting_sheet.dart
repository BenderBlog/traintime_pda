// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_edit_sheet.dart';
import 'package:watermeter/repository/preference.dart' as preference;

Future<bool?> showElectricityThresholdSheet(BuildContext context) {
  return showSettingSheet<bool>(
    context: context,
    builder: (context) => SettingTextEditSheet(
      title: context.t.setting.lowElectricityThresholdDialog.title,
      initialValue: EnergyController.i.electricityThreshold.peek().toString(),
      label: context.t.setting.lowElectricityThresholdDialog.inputHint,
      suffixText: context.t.setting.editor.electricityUnit,
      saveLabel: context.t.setting.editor.save,
      cancelLabel: context.t.common.cancel,
      failureMessage: context.t.common.errorDetected,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => (int.tryParse(value) ?? 0) <= 0
          ? context.t.setting.editor.positiveNumber
          : null,
      onSave: (value) => EnergyController.i.setLowElectricityWarningThreshold(
        int.parse(value),
      ),
    ),
  );
}

Future<bool?> showWeekOffsetSheet(BuildContext context) {
  return showSettingSheet<bool>(
    context: context,
    builder: (context) => SettingTextEditSheet(
      title: context.t.setting.changeSwiftDialog.title,
      initialValue: preference.getInt(preference.Preference.swift).toString(),
      label: context.t.setting.changeSwiftDialog.inputHint,
      description: context.t.setting.classSwiftExplain,
      saveLabel: context.t.setting.editor.save,
      cancelLabel: context.t.common.cancel,
      failureMessage: context.t.common.errorDetected,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      signToggleLabel: context.t.setting.editor.toggleSign,
      validator: (value) => int.tryParse(value) == null
          ? context.t.setting.changeSwiftDialog.invalidNumber
          : null,
      onSave: (value) => WeekSwiftController.i.setWeekSwift(int.parse(value)),
    ),
  );
}
