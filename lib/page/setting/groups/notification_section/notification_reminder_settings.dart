// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
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
      title: FlutterI18n.translate(
        context,
        'setting.notification_page.reminder_section',
      ),
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.experiment_reminder',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.experiment_reminder_hint',
              ),
            ),
            value: experimentNotificationsEnabled,
            onChanged: isLoading ? null : onExperimentNotificationsChanged,
          ),
          ListTile(
            enabled: !isLoading,
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.minutes_before',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.minutes_before_hint',
              ),
            ),
            trailing: DropdownButton<int>(
              value: minutesBefore,
              items: minutesBeforeOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        '$value ${FlutterI18n.translate(context, "setting.notification_page.minutes_unit")}',
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
            title: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.days_to_schedule',
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.days_to_schedule_hint',
              ),
            ),
            trailing: DropdownButton<int>(
              value: daysToSchedule,
              items: daysToScheduleOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        '$value ${FlutterI18n.translate(context, "setting.notification_page.days_unit")}',
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
