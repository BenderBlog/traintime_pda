// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/groups/classtable_section/classtable_style_page/class_table_style_page.dart';

class ClassTableStyleTile extends StatelessWidget {
  const ClassTableStyleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MingCuteIcons.mgc_layout_grid_line),
      title: Text(context.t.setting.classTableStyleSetting),
      subtitle: Text(context.t.setting.classTableStyleDescription),
      trailing: const Icon(Icons.navigate_next),
      onTap: () => context.push(const ClassTableStylePage()),
    );
  }
}
