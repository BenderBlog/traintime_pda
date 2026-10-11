// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:watermeter/page/public_widget/setting/setting_control_tile.dart';

class SettingSliderTile extends StatelessWidget {
  const SettingSliderTile({
    super.key,
    required this.title,
    required this.formatValue,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.divisions,
    this.leading,
    this.description,
    this.preview,
  });

  final String title;
  final String Function(double value) formatValue;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final int? divisions;
  final IconData? leading;
  final String? description;
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final valueLabel = formatValue(value);

    return SettingControlTile(
      title: title,
      valueLabel: valueLabel,
      leading: leading,
      description: description,
      enabled: onChanged != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          M3ESlider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            enabled: onChanged != null,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),

          if (preview != null) ...[const SizedBox(height: 8), preview!],
        ],
      ),
    );
  }
}
