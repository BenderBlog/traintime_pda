// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/setting/numeric_setting_sheet.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ClassWeekOffsetTile extends StatefulWidget {
  const ClassWeekOffsetTile({super.key});

  @override
  State<ClassWeekOffsetTile> createState() => _ClassWeekOffsetTileState();
}

class _ClassWeekOffsetTileState extends State<ClassWeekOffsetTile> {
  Future<void> _editWeekOffset() async {
    await showWeekOffsetSheet(context);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MingCuteIcons.mgc_calendar_week_line),
      title: Text(context.t.setting.classSwift),
      subtitle: Text(
        context.t.setting.classSwiftDescription(
          swift: preference.getInt(preference.Preference.swift).toString(),
        ),
      ),
      trailing: const Icon(Icons.navigate_next),
      onTap: _editWeekOffset,
    );
  }
}
