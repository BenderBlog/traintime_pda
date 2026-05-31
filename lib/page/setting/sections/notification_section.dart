// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingNotificationSection extends StatelessWidget {
  const SettingNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SizedBox.shrink();
    }
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.notification_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
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
              context.push(const NotificationSettingsPage());
            },
          ),
        ],
      ),
    );
  }
}
