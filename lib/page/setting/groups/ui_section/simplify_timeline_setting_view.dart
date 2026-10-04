// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class SimplifyTimelineSettingView extends StatelessWidget {
  const SimplifyTimelineSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClassTableCard.simplifiedMode,
      builder: (context, simplifiedMode, _) {
        return SwitchListTile(
          secondary: const Icon(MingCuteIcons.mgc_timeline_line),
          title: Text(context.t.setting.simplifyTimeline),
          subtitle: Text(context.t.setting.simplifyTimelineDescription),
          value: simplifiedMode,
          onChanged: (value) async {
            await preference.setBool(
              preference.Preference.simplifiedClassTimeline,
              value,
            );
            ClassTableCard.reloadSettingsFromPref();
          },
        );
      },
    );
  }
}
