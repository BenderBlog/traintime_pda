// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'dart:io';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/groups/about_section.dart';
import 'package:watermeter/page/setting/groups/account_section.dart';
import 'package:watermeter/page/setting/groups/classtable_section/classtable_section.dart';
import 'package:watermeter/page/setting/groups/core_section.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_section.dart';
import 'package:watermeter/page/setting/groups/ui_section/ui_section.dart';
import 'package:watermeter/page/setting/settings_category_page.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});
  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow>
    with AutomaticKeepAliveClientMixin {
  // The home PageView may scroll this directory offscreen while the detail
  // navigator still displays its category. Preserve the matching selection.
  @override
  bool get wantKeepAlive => true;

  final categories = [
    const _SettingsCategory(
      'ui',
      'setting.ui_setting',
      MingCuteIcons.mgc_palette_line,
      UiSection(),
    ),
    const _SettingsCategory(
      'classtable',
      'setting.classtable_setting',
      MingCuteIcons.mgc_calendar_month_line,
      ClasstableSection(),
    ),
    const _SettingsCategory(
      'account',
      'setting.account_setting',
      MingCuteIcons.mgc_user_2_line,
      AccountSection(),
    ),
    if (Platform.isAndroid || Platform.isIOS)
      const _SettingsCategory(
        'notifications',
        'setting.course_reminder_setting',
        MingCuteIcons.mgc_notification_line,
        NotificationSection(),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.t.homepage.setting),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            physics: ClampingScrollPhysics(),
            children: [
              const AboutSection(),
              SectionSettingScaffold(
                items: SettingSegmentedList(
                  items: categories
                      .map(
                        (category) => ListTile(
                          key: ValueKey('settings-category-${category.id}'),
                          leading: Icon(category.icon),
                          title: Text(context.t.resolveKey(category.titleKey)),
                          subtitle: Text(
                            context.t.resolveKey(
                              'setting.navigation.${category.id}_description',
                            ),
                          ),
                          trailing: const Icon(Icons.navigate_next),
                          onTap: () => context.pushReplacement(
                            SettingsCategoryPage(
                              titleKey: category.titleKey,
                              child: category.child,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const CoreSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCategory {
  final String id;
  final String titleKey;
  final IconData icon;
  final Widget child;

  const _SettingsCategory(this.id, this.titleKey, this.icon, this.child);
}
