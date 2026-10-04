// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

/// A labeled M3 selection field that fills the available control width.
class SettingDropdownButton<T> extends StatelessWidget {
  const SettingDropdownButton({
    super.key,
    required this.value,
    required this.entries,
    required this.label,
    required this.onChanged,
  });

  final T? value;
  final List<DropdownMenuEntry<T>> entries;
  final String label;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      initialSelection: value,
      dropdownMenuEntries: entries,
      label: Text(label),
      expandedInsets: EdgeInsets.zero,
      enabled: onChanged != null,
      requestFocusOnTap: false,
      enableSearch: false,
      selectOnly: true,
      onSelected: onChanged,
    );
  }
}
