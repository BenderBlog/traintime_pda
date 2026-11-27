// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:math';

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/about_page/about_app_header.dart';
import 'package:watermeter/page/setting/about_page/about_contributors_section.dart';
import 'package:watermeter/page/setting/about_page/film_component.dart';
import 'package:watermeter/page/setting/settings_category_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _eggVisible = false;

  final List<String> emoji = ["😨", "😭", "😋", "😡", "🤔", "🤣", "🥹"];
  final Random random = Random();

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
                children: [
                  FilmComponent(
                    description: [
                      "呜哇～",
                      "哇，好可爱啊",
                      "诺艾尔不是在等待奇迹——她本身就是七年前那个愿望留下的奇迹",
                    ],
                    pics: List.generate(3, (i) => "assets/art/noel_$i.jpg"),
                    remainingWidget: [
                      M3ETextButton(
                        child: Text("按下本按钮以进行迫害操作"),
                        onPressed: () {
                          log.info(
                            "你迫害了 Lolicon 一次，${emoji[random.nextInt(emoji.length)]}",
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
