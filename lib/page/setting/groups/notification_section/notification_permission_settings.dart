// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
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
      title: FlutterI18n.translate(
        context,
        'setting.notification_page.permission_section',
      ),
      items: SettingSegmentedList(
        items: [
          ListTile(
            enabled: !isLoading,
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.notification_permission',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
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
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.request_permission',
                      ),
                    ),
                  ),
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.exact_alarm_permission',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
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
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.request_permission',
                      ),
                    ),
                  ),
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.system_settings',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.system_settings_hint',
              ),
            ),
            trailing: const Icon(Icons.settings),
            onTap: isLoading ? null : onOpenSystemSettings,
          ),
          ListTile(
            enabled: !isLoading,
            leading: const Icon(MingCuteIcons.mgc_settings_2_line),
            title: Text(
              FlutterI18n.translate(context, 'setting.notification_debug_page'),
            ),
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
