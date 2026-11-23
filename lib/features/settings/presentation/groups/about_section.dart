// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/shared/widgets/settings/section_scaffold.dart';
import 'package:watermeter/core/shared/widgets/settings/segmented_list.dart';
import 'package:watermeter/features/settings/presentation/about_page/about_page.dart';
import 'package:watermeter/generated/application_version.g.dart';
import 'package:watermeter/generated/translations.g.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      //title: context.t.setting.aboutInfo,
      //icon: Icons.info,
      items: SettingSegmentedList(
        items: [
          ListTile(
            leading: const Icon(MingCuteIcons.mgc_information_line),
            title: Text(context.t.settings.aboutThisProgram),
            subtitle: Text(
              context.t.settings.version(
                version: "$kApplicationVersion + $kApplicationBuildNumber",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => AppShell.of(context).pushDetail(AboutPage()),
          ),
        ],
      ),
    );
  }
}

