// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_edit_sheet.dart';
import 'package:watermeter/repository/preference.dart' as preference;

Future<bool?> showElectricityThresholdSheet(BuildContext context) {
  return showSettingSheet<bool>(
    context: context,
    builder: (context) => SettingTextEditSheet(
      title: FlutterI18n.translate(
        context,
        'setting.low_electricity_threshold_dialog.title',
      ),
      initialValue: EnergyController.i.electricityThreshold.peek().toString(),
      label: FlutterI18n.translate(
        context,
        'setting.low_electricity_threshold_dialog.input_hint',
      ),
      suffixText: FlutterI18n.translate(
        context,
        'setting.editor.electricity_unit',
      ),
      saveLabel: FlutterI18n.translate(context, 'setting.editor.save'),
      cancelLabel: FlutterI18n.translate(context, 'cancel'),
      failureMessage: FlutterI18n.translate(context, 'error_detected'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => (int.tryParse(value) ?? 0) <= 0
          ? FlutterI18n.translate(context, 'setting.editor.positive_number')
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
      title: FlutterI18n.translate(
        context,
        'setting.change_swift_dialog.title',
      ),
      initialValue: preference.getInt(preference.Preference.swift).toString(),
      label: FlutterI18n.translate(
        context,
        'setting.change_swift_dialog.input_hint',
      ),
      description: FlutterI18n.translate(
        context,
        'setting.class_swift_explain',
      ),
      saveLabel: FlutterI18n.translate(context, 'setting.editor.save'),
      cancelLabel: FlutterI18n.translate(context, 'cancel'),
      failureMessage: FlutterI18n.translate(context, 'error_detected'),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      signToggleLabel: FlutterI18n.translate(
        context,
        'setting.editor.toggle_sign',
      ),
      validator: (value) => int.tryParse(value) == null
          ? FlutterI18n.translate(
              context,
              'setting.change_swift_dialog.invalid_number',
            )
          : null,
      onSave: (value) => WeekSwiftController.i.setWeekSwift(int.parse(value)),
    ),
  );
}
