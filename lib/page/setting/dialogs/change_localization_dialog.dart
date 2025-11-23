// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Change app brightness.
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/theme_controller.dart';

import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
        FlutterI18n.translate(context, "setting.localization_dialog.title"),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      content: SingleChildScrollView(
        child: RadioGroup(
          groupValue: Localization.values
              .firstWhere(
                (index) =>
                    index.string ==
                    preference.getString(preference.Preference.localization),
              )
              .index,
          onChanged: (int? value) async {
            if (value == null) return;
            await preference
                .setString(
                  preference.Preference.localization,
                  Localization.values[value].string,
                )
                .then((value) {
                  ThemeController toChange = Get.put(ThemeController());
                  toChange.updateTheme();
                });
            
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
                title: Text(
                  FlutterI18n.translate(
                    context,
                    Localization.values[index].toShow,
                  ),
                ),
                value: index,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(context, "confirm")),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    );
  }
}
