// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
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
        return ListTile(
          leading: const Icon(MingCuteIcons.mgc_timeline_line),
          title: Text(
            FlutterI18n.translate(context, 'setting.simplify_timeline'),
          ),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              'setting.simplify_timeline_description',
            ),
          ),
          trailing: Switch(
            value: simplifiedMode,
            onChanged: (value) async {
              await preference.setBool(
                preference.Preference.simplifiedClassTimeline,
                value,
              );
              ClassTableCard.reloadSettingsFromPref();
            },
          ),
        );
      },
    );
  }
}
