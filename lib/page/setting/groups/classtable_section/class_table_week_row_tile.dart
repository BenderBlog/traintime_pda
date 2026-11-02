// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/class_page/class_table_week_row_config.dart';

/// Shows or hides the week choice row of the classtable, so the cards of the
/// evening classes get the room the row would take.
class ClassTableWeekRowTile extends StatelessWidget {
  const ClassTableWeekRowTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClassTableWeekRowConfig.visible,
      builder: (context, visible, _) => SwitchListTile(
        secondary: const Icon(Icons.view_week_outlined),
        title: Text(context.t.setting.classTableWeekRowShow),
        subtitle: Text(context.t.setting.classTableWeekRowDescription),
        value: visible,
        onChanged: ClassTableWeekRowConfig.setVisible,
      ),
    );
  }
}
