// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class NotificationFunctionSettings extends StatelessWidget {
  const NotificationFunctionSettings({
    super.key,
    required this.isLoading,
    required this.isEnabled,
    required this.pendingCount,
    required this.onEnabledChanged,
    required this.onShowInstructions,
    required this.onUpdateSchedule,
    required this.onDeleteSchedules,
  });

  final bool isLoading;
  final bool isEnabled;
  final int pendingCount;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onShowInstructions;
  final VoidCallback onUpdateSchedule;
  final VoidCallback onDeleteSchedules;

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(
        context,
        'setting.notification_page.function_section',
      ),
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.enable_notification',
              ),
            ),
            subtitle: Text(
              isEnabled
                  ? FlutterI18n.translate(
                      context,
                      'setting.notification_page.notification_scheduled',
                      translationParams: {'count': pendingCount.toString()},
                    )
                  : FlutterI18n.translate(
                      context,
                      'setting.notification_page.notification_disabled_hint',
                    ),
            ),
            value: isEnabled,
            onChanged: isLoading ? null : onEnabledChanged,
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.view_the_instructions',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.view_the_instructions_hint',
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            // The guide is the only action intentionally left available while
            // another notification operation is in progress.
            onTap: onShowInstructions,
          ),
          if (isEnabled)
            ListTile(
              enabled: !isLoading,
              title: Text(
                FlutterI18n.translate(
                  context,
                  'setting.notification_page.update_schedule',
                ),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  'setting.notification_page.update_schedule_hint',
                ),
              ),
              trailing: const Icon(Icons.refresh),
              onTap: isLoading ? null : onUpdateSchedule,
            ),
          if (isEnabled && pendingCount > 0)
            ListTile(
              enabled: !isLoading,
              title: Text(
                FlutterI18n.translate(
                  context,
                  'setting.notification_page.delete_all_schedule',
                ),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  'setting.notification_page.delete_all_schedule_hint',
                ),
              ),
              trailing: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: isLoading ? null : onDeleteSchedules,
            ),
        ],
      ),
    );
  }
}
