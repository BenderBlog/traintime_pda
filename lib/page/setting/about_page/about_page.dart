// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/setting/setting_expandable_section.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/about_page/about_app_header.dart';
import 'package:watermeter/page/setting/about_page/about_contributors_section.dart';
import 'package:watermeter/page/setting/about_page/film_component.dart';
import 'package:watermeter/page/setting/settings_category_page.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final applicationName =
        Platform.isIOS || Platform.isMacOS || Platform.isAndroid
        ? 'XDYou'
        : 'Traintime PDA';
    final applicationVersion =
        'v${preference.packageInfo.version}+'
        '${preference.packageInfo.buildNumber}';

    return SettingsCategoryPage(
      titleKey: 'setting.about_page.title',
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AboutAppHeader(
              applicationName: applicationName,
              applicationVersion: applicationVersion,
            ),
            const SizedBox(height: 8),
            SectionSettingScaffold(
              title: context.t.setting.aboutInfo,
              icon: Icons.info_outline_rounded,
              items: SettingSegmentedList(
                items: [
                  ListTile(
                    leading: const Icon(Icons.balance_rounded),
                    title: Text(context.t.setting.aboutPage.licenses),
                    trailing: const Icon(Icons.navigate_next_rounded),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: applicationName,
                      applicationVersion: applicationVersion,
                      applicationIcon: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: AppIconWidget(),
                      ),
                      applicationLegalese:
                          context.t.setting.aboutPage.copyrightNotice,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copyright_rounded),
                    title: Text(
                      context.t.setting.aboutPage.copyrightRegisterCode,
                    ),
                    subtitle: const SelectableText('2026SR0738647'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(context.t.setting.aboutPage.beian),
                    subtitle: const SelectableText('陕ICP备2024026116号-1A'),
                  ),
                  if (Platform.isAndroid)
                    ListTile(
                      leading: const Icon(Icons.fingerprint_rounded),
                      title: Text(context.t.setting.aboutPage.signAndroid),
                      subtitle: SelectableText(
                        preference.packageInfo.buildSignature,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const AboutContributorsSection(),
            const SizedBox(height: 8),
            SectionSettingScaffold(
              title: context.t.setting.aboutPage.extras,
              icon: Icons.auto_awesome_outlined,
              items: SettingExpandableSection(
                childPadding: const EdgeInsets.all(8),
                header: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.movie_outlined),
                  title: Text('Noel herself is miracle'),
                ),
                children: const [FilmComponent()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
