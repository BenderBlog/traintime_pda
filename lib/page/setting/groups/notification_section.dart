// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/page/setting/notification_page/notification_debug_page.dart';
import 'package:watermeter/page/setting/notification_page/notification_page.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, "setting.notification_setting"),
      items: [
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.course_reminder_setting"),
          ),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              "setting.course_reminder_description",
            ),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            context.pushReplacement(const NotificationSettingsPage());
          },
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.notification_debug_page"),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => context.push(NotificationDebugPage()),
        ),
      ],
    );
  }
}
