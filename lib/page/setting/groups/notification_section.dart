// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/page/setting/notification_page/notification_debug_page.dart';
import 'package:watermeter/page/setting/notification_page/notification_page.dart';
import 'package:watermeter/generated/translations.g.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: context.t.setting.notificationSetting,
      items: [
        ListTile(
          title: Text(
            context.t.setting.courseReminderSetting,
          ),
          subtitle: Text(
            context.t.setting.courseReminderDescription,
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            context.pushReplacement(const NotificationSettingsPage());
          },
        ),
        ListTile(
          title: Text(
            context.t.setting.notificationDebugPage,
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => context.push(NotificationDebugPage()),
        ),
      ],
    );
  }
}
