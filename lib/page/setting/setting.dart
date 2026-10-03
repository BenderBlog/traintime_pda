// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:watermeter/page/setting/groups/about_section.dart';
import 'package:watermeter/page/setting/groups/account_section.dart';
import 'package:watermeter/page/setting/groups/classtable_section.dart';
import 'package:watermeter/page/setting/groups/core_section.dart';
import 'package:watermeter/page/setting/groups/notification_section.dart';
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
        'setting.notification_setting',
        MingCuteIcons.mgc_notification_line,
        NotificationSection(),
      ),
    const _SettingsCategory(
      'core',
      'setting.core_setting',
      MingCuteIcons.mgc_storage_line,
      CoreSection(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(FlutterI18n.translate(context, 'homepage.setting')),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        physics: ClampingScrollPhysics(),
        children: [
          const AboutSection(),
          const SizedBox(height: 16),
          M3ESegmentedList(
            itemCount: categories.length,
            padding: EdgeInsets.zero,
            gap: 4,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                key: ValueKey('settings-category-${category.id}'),
                leading: Icon(category.icon),
                title: Text(FlutterI18n.translate(context, category.titleKey)),
                subtitle: Text(
                  FlutterI18n.translate(
                    context,
                    'setting.navigation.${category.id}_description',
                  ),
                ),
                onTap: () => context.pushReplacement(
                  SettingsCategoryPage(
                    titleKey: category.titleKey,
                    child: category.child,
                  ),
                ),
              );
            },
          ),
        ],
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
