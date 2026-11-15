// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/groups/classtable_section/class_refresh_tile.dart';
import 'package:watermeter/page/setting/groups/classtable_section/class_table_style_tile.dart';
import 'package:watermeter/page/setting/groups/classtable_section/class_week_offset_tile.dart';
import 'package:watermeter/page/setting/groups/classtable_section/clear_user_classes_tile.dart';
import 'package:watermeter/page/setting/groups/classtable_section/semester_change_tile.dart';

class ClasstableSection extends StatelessWidget {
  const ClasstableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSettingScaffold(
          icon: Icons.palette_outlined,
          title: context.t.setting.classTableStyleSetting,
          items: const SettingSegmentedList(items: [ClassTableStyleTile()]),
        ),
        SectionSettingScaffold(
          icon: Icons.calendar_month_outlined,
          title: context.t.setting.sections.semester,
          items: const SettingSegmentedList(
            items: [SemesterChangeTile(), ClassWeekOffsetTile()],
          ),
        ),
        SectionSettingScaffold(
          icon: Icons.sync,
          title: context.t.setting.sections.courseData,
          items: const SettingSegmentedList(
            items: [ClassRefreshTile(), ClearUserClassesTile()],
          ),
        ),
      ],
    );
  }
}
