// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/features/settings/presentation/about/about_page.widget.dart';
import 'package:watermeter/generated/application_version.g.dart';
import 'package:watermeter/generated/translations.g.dart';

ListTile aboutTile(BuildContext context, PackageApplicationInfo appInfo) {
  return ListTile(
    leading: const Icon(MingCuteIcons.mgc_information_line),
    title: Text(context.t.settings.aboutThisProgram),
    subtitle: Text(
      context.t.settings.version(
        version: PackageApplicationInfo.versionWithBuildNumber,
      ),
    ),
    trailing: const Icon(Icons.navigate_next),
    onTap: () => AppShell.of(context).pushDetail(AboutPage(appInfo: appInfo)),
  );
}
