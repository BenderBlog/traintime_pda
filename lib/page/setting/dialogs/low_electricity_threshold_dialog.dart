// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/energy_controller.dart';

class LowElectricityThresholdDialog extends StatelessWidget {
  final TextEditingController _inputTextController =
      TextEditingController.fromValue(
        TextEditingValue(
          text: EnergyController.i.electricityThreshold.peek().toString(),
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: EnergyController.i.electricityThreshold
                  .peek()
                  .toString()
                  .length,
            ),
          ),
        ),
      );

  LowElectricityThresholdDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(
          context,
          "setting.low_electricity_threshold_dialog.title",
        ),
      ),
      content: TextFormField(
        autofocus: true,
        controller: _inputTextController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLines: 1,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(
            context,
            "setting.low_electricity_threshold_dialog.input_hint",
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterI18n.translate(context, "cancel")),
        ),
        TextButton(
          onPressed: () async {
            int? parsed = int.tryParse(_inputTextController.text);
            if (parsed == null || parsed <= 0) {
              parsed = EnergyController.defaultLowElectricityWarningThreshold;
            }
            await EnergyController.i.setLowElectricityWarningThreshold(parsed);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(FlutterI18n.translate(context, "confirm")),
        ),
      ],
    );
  }
}
