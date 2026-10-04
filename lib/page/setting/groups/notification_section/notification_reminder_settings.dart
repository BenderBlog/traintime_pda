// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class NotificationReminderSettings extends StatelessWidget {
  const NotificationReminderSettings({
    super.key,
    required this.isLoading,
    required this.experimentNotificationsEnabled,
    required this.minutesBefore,
    required this.daysToSchedule,
    required this.onExperimentNotificationsChanged,
    required this.onMinutesBeforeChanged,
    required this.onDaysToScheduleChanged,
    required this.minutesBeforeOptions,
    required this.daysToScheduleOptions,
  });

  final bool isLoading;
  final bool experimentNotificationsEnabled;
  final int minutesBefore;
  final int daysToSchedule;
  final ValueChanged<bool> onExperimentNotificationsChanged;
  final ValueChanged<int> onMinutesBeforeChanged;
  final ValueChanged<int> onDaysToScheduleChanged;
  final List<int> minutesBeforeOptions;
  final List<int> daysToScheduleOptions;

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: context.t.setting.notificationPage.reminderSection,
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(context.t.setting.notificationPage.experimentReminder),
            subtitle: Text(
              context.t.setting.notificationPage.experimentReminderHint,
            ),
            value: experimentNotificationsEnabled,
            onChanged: isLoading ? null : onExperimentNotificationsChanged,
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(context.t.setting.notificationPage.minutesBefore),
            subtitle: Text(
              context.t.setting.notificationPage.minutesBeforeHint,
            ),
            trailing: DropdownButton<int>(
              value: minutesBefore,
              items: minutesBeforeOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        '$value ${context.t.setting.notificationPage.minutesUnit}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) onMinutesBeforeChanged(value);
                    },
            ),
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(context.t.setting.notificationPage.daysToSchedule),
            subtitle: Text(
              context.t.setting.notificationPage.daysToScheduleHint,
            ),
            trailing: DropdownButton<int>(
              value: daysToSchedule,
              items: daysToScheduleOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        '$value ${context.t.setting.notificationPage.daysUnit}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) onDaysToScheduleChanged(value);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
