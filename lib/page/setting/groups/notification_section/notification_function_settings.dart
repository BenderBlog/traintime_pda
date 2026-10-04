// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
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
      title: context.t.setting.notificationPage.functionSection,
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(context.t.setting.notificationPage.enableNotification),
            subtitle: Text(
              isEnabled
                  ? context.t.setting.notificationPage.notificationScheduled(
                      count: pendingCount.toString(),
                    )
                  : context.t.setting.notificationPage.notificationDisabledHint,
            ),
            value: isEnabled,
            onChanged: isLoading ? null : onEnabledChanged,
          ),
          ListTile(
            title: Text(context.t.setting.notificationPage.viewTheInstructions),
            subtitle: Text(
              context.t.setting.notificationPage.viewTheInstructionsHint,
            ),
            trailing: const Icon(Icons.navigate_next),
            // The guide is the only action intentionally left available while
            // another notification operation is in progress.
            onTap: onShowInstructions,
          ),
          if (isEnabled)
            ListTile(
              enabled: !isLoading,
              title: Text(context.t.setting.notificationPage.updateSchedule),
              subtitle: Text(
                context.t.setting.notificationPage.updateScheduleHint,
              ),
              trailing: const Icon(Icons.refresh),
              onTap: isLoading ? null : onUpdateSchedule,
            ),
          if (isEnabled && pendingCount > 0)
            ListTile(
              enabled: !isLoading,
              title: Text(context.t.setting.notificationPage.deleteAllSchedule),
              subtitle: Text(
                context.t.setting.notificationPage.deleteAllScheduleHint,
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
