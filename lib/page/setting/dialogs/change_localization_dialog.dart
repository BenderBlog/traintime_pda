// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change app brightness.
import 'package:flutter/material.dart';
import 'package:watermeter/controller/theme_controller.dart';

import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/generated/translations.g.dart';

class ChangeLanguageDialog extends StatefulWidget {
  const ChangeLanguageDialog({super.key});

  @override
  State<ChangeLanguageDialog> createState() => _ChangeLanguageDialogState();
}

class _ChangeLanguageDialogState extends State<ChangeLanguageDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.t.setting.localizationDialog.title,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      content: SingleChildScrollView(
        child: RadioGroup(
          groupValue: ThemeController.i.savedLocale.value.index,
          onChanged: (int? value) async {
            if (value == null) return;
            await ThemeController.i.setLocale(
              Localization.values[value],
            );

            // To update course reminders according to new localization
            await CourseReminderService().cancelAllCourseNotifications();
            await CourseReminderService().scheduleNotificationsFromCourseData(
              daysToSchedule:
                  preference.prefs.getInt('notification_days_to_schedule') ?? 7,
              minutesBefore:
                  preference.prefs.getInt('notification_minutes_before') ?? 5,
            );
          },
          child: Column(
            children: List<Widget>.generate(
              Localization.values.length,
              (index) => RadioListTile<int>(
                title: Text(Localization.values[index].displayName(context.t)),
                value: index,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(context.t.common.confirm),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    );
  }
}
