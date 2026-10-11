// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

class SettingColorChoice<T> {
  const SettingColorChoice({
    required this.value,
    required this.label,
    required this.color,
  });
  final T value;
  final String label;
  final Color color;
}

class SettingColorChoices<T> extends StatelessWidget {
  const SettingColorChoices({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<SettingColorChoice<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (option) => ChoiceChip(
              avatar: CircleAvatar(backgroundColor: option.color),
              label: Text(option.label),
              selected: option.value == value,
              showCheckmark: true,
              onSelected: (selected) {
                if (selected) onChanged(option.value);
              },
            ),
          )
          .toList(),
    );
  }
}
