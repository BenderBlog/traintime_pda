// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_debug_page/notification_debug_page.dart';

class NotificationPermissionSettings extends StatelessWidget {
  const NotificationPermissionSettings({
    super.key,
    required this.isLoading,
    required this.hasNotificationPermission,
    required this.hasExactAlarmPermission,
    required this.onRequestPermission,
    required this.onOpenSystemSettings,
  });

  final bool isLoading;
  final bool hasNotificationPermission;
  final bool hasExactAlarmPermission;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSystemSettings;

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: context.t.setting.notificationPage.permissionSection,
      items: SettingSegmentedList(
        items: [
          ListTile(
            enabled: !isLoading,
            title: Text(
              context.t.setting.notificationPage.notificationPermission,
            ),
            subtitle: Text(
              context.t.resolveKey(
                hasNotificationPermission
                    ? 'setting.notification_page.permission_granted'
                    : 'setting.notification_page.permission_denied',
              ),
            ),
            trailing: hasNotificationPermission
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : TextButton(
                    onPressed: isLoading ? null : onRequestPermission,
                    child: Text(
                      context.t.setting.notificationPage.requestPermission,
                    ),
                  ),
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(
              context.t.setting.notificationPage.exactAlarmPermission,
            ),
            subtitle: Text(
              context.t.resolveKey(
                hasExactAlarmPermission
                    ? 'setting.notification_page.permission_granted'
                    : 'setting.notification_page.permission_denied',
              ),
            ),
            trailing: hasExactAlarmPermission
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : TextButton(
                    onPressed: isLoading ? null : onRequestPermission,
                    child: Text(
                      context.t.setting.notificationPage.requestPermission,
                    ),
                  ),
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(context.t.setting.notificationPage.systemSettings),
            subtitle: Text(
              context.t.setting.notificationPage.systemSettingsHint,
            ),
            trailing: const Icon(Icons.settings),
            onTap: isLoading ? null : onOpenSystemSettings,
          ),
          ListTile(
            enabled: !isLoading,
            leading: const Icon(MingCuteIcons.mgc_settings_2_line),
            title: Text(context.t.setting.notificationDebugPage),
            trailing: const Icon(Icons.navigate_next),
            onTap: isLoading
                ? null
                : () => context.push(const NotificationDebugPage()),
          ),
        ],
      ),
    );
  }
}
