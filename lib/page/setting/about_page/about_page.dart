// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/about_page/about_app_header.dart';
import 'package:watermeter/page/setting/about_page/about_contributors_section.dart';
import 'package:watermeter/page/setting/about_page/film_component.dart';
import 'package:watermeter/page/setting/settings_category_page.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _eggVisible = false;

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
              title: FlutterI18n.translate(context, 'setting.about_info'),
              icon: Icons.info_outline_rounded,
              items: SettingSegmentedList(
                items: [
                  ListTile(
                    leading: const Icon(Icons.balance_rounded),
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.about_page.licenses',
                      ),
                    ),
                    trailing: const Icon(Icons.navigate_next_rounded),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: applicationName,
                      applicationVersion: applicationVersion,
                      applicationIcon: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: AppIconWidget(),
                      ),
                      applicationLegalese: FlutterI18n.translate(
                        context,
                        'setting.about_page.copyright_notice',
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copyright_rounded),
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.about_page.copyright_register_code',
                      ),
                    ),
                    subtitle: const SelectableText('2026SR0738647'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.about_page.beian',
                      ),
                    ),
                    subtitle: const SelectableText('陕ICP备2024026116号-1A'),
                  ),
                  if (Platform.isAndroid)
                    ListTile(
                      leading: const Icon(Icons.fingerprint_rounded),
                      title: Text(
                        FlutterI18n.translate(
                          context,
                          'setting.about_page.sign_android',
                        ),
                      ),
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
              title: FlutterI18n.translate(
                context,
                'setting.about_page.extras',
              ),
              icon: Icons.auto_awesome_outlined,
              items: M3EExpandableSegmentedItem(
                index: 0,
                totalCount: 1,
                isExpanded: _eggVisible,
                onToggle: () => setState(() => _eggVisible = !_eggVisible),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                childPadding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surfaceContainer,
                childColor: Theme.of(context).colorScheme.surfaceContainer,
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
