// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification service implementation

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/notification_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/generated/non_ui_i18n.g.dart';

/// Course Reminder Service implementation
class CourseReminderService extends NotificationService
    with WidgetsBindingObserver {
  static final CourseReminderService _instance =
      CourseReminderService._internal(
        androidNotificationDetails: const AndroidNotificationDetails(
          'course_reminder',
          'Course Reminder',
          channelDescription:
              'Course reminder notifications for upcoming classes',
          importance: Importance.max,
          priority: Priority.max,
          audioAttributesUsage: AudioAttributesUsage.notification,
          playSound: true,
          enableVibration: true,
        ),
        darwinNotificationDetails: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );
  factory CourseReminderService() => _instance;
  CourseReminderService._internal({
    super.androidNotificationDetails,
    super.darwinNotificationDetails,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const int _notificationIdPrefix = 10;
  static const int _notificationIdBase = 10000000;
  static const int _notificationRandomMin = 10;
  static const int _notificationRandomRange = 90;
  final Random _random = Random();

  // Configuration getters - encapsulate preference access
  bool get isEnabled =>
      preference.getBool(preference.Preference.enableCourseReminder);

  int get minutesBefore =>
      preference.getInt(preference.Preference.courseReminderMinutesBefore);

  int get daysToSchedule =>
      preference.getInt(preference.Preference.courseReminderDaysToSchedule);

  bool get enableExperimentNotifications => preference.getBool(
    preference.Preference.courseReminderEnableExperimentNotifications,
  );

  String get lastLocale =>
      preference.getString(preference.Preference.notificationLastLocale);

  // Configuration setters with automatic notification update
  Future<void> setEnabled(bool value) async {
    if (value) { 
      // Check permissions before enabling
      final hasNotificationPermission = await checkNotificationPermission();
      final hasExactAlarmPermission = await checkExactAlarmPermission();

      if (!hasNotificationPermission || !hasExactAlarmPermission) {
        log.info('[CourseReminderService] Failed to enable due to no permission');
        throw Exception("[CourseReminderService] Failed to enable due to no permission");
      }
    }
    await preference.setBool(preference.Preference.enableCourseReminder, value);
    if (value) {
      log.info('[CourseReminderService] Enabled, scheduling notifications');
      await scheduleNotificationsFromCourseData(
        daysToSchedule: daysToSchedule,
        minutesBefore: minutesBefore,
      );
    } else {
      log.info(
        '[CourseReminderService] Disabled, cancelling all notifications',
      );
      await cancelAllCourseNotifications();
    }
  }

  Future<void> setMinutesBefore(int value) async {
    await preference.setInt(
      preference.Preference.courseReminderMinutesBefore,
      value,
    );
    if (isEnabled) {
      log.info(
        '[CourseReminderService] Minutes before changed to $value, updating notifications',
      );
      await validateAndUpdateNotifications();
    }
  }

  Future<void> setDaysToSchedule(int value) async {
    await preference.setInt(
      preference.Preference.courseReminderDaysToSchedule,
      value,
    );
    if (isEnabled) {
      log.info(
        '[CourseReminderService] Days to schedule changed to $value, updating notifications',
      );
      await validateAndUpdateNotifications();
    }
  }

  Future<void> setEnableExperimentNotifications(bool value) async {
    await preference.setBool(
      preference.Preference.courseReminderEnableExperimentNotifications,
      value,
    );
    if (isEnabled) {
      log.info(
        '[CourseReminderService] Experiment notifications ${value ? "enabled" : "disabled"}, updating notifications',
      );
      await validateAndUpdateNotifications();
    }
  }

  Future<void> _setLastLocale(String value) async {
    await preference.setString(
      preference.Preference.notificationLastLocale,
      value,
    );
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // When system locale changes while app is running, reschedule notifications
    // Note: This won't trigger on cold start, but scheduleNotificationsFromCourseData
    // already handles locale dynamically on each call
    log.info(
      '[CourseReminderService] [didChangeLocales] System locale changed, rescheduling notifications...',
    );

    // Check if notifications are enabled
    if (!isEnabled) {
      log.info(
        '[CourseReminderService] [didChangeLocales] Notifications not enabled, skipping reschedule',
      );
      return;
    }

    // Reschedule notifications with new locale (run asynchronously)
    _rescheduleNotificationsOnLocaleChange();
  }

  /// Internal method to reschedule notifications when locale changes
  Future<void> _rescheduleNotificationsOnLocaleChange() async {
    log.info(
      '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Starting locale change reschedule...',
    );
    try {
      log.info(
        '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Config: daysToSchedule=$daysToSchedule, minutesBefore=$minutesBefore',
      );

      log.info(
        '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Cancelling all notifications...',
      );
      await cancelAllCourseNotifications();

      log.info(
        '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Rescheduling notifications with new locale...',
      );
      await scheduleNotificationsFromCourseData(
        daysToSchedule: daysToSchedule,
        minutesBefore: minutesBefore,
      );

      log.info(
        '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Locale change reschedule completed successfully',
      );
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] [_rescheduleNotificationsOnLocaleChange] Failed to reschedule notifications on locale change',
        e,
        stackTrace,
      );
    }
  }

  @override
  void handleNotificationTap(NotificationResponse response) {
    log.info(
      '[CourseReminderService] [handleNotificationTap] Notification tapped',
    );

    if (response.payload == null || response.payload!.isEmpty) {
      log.warning(
        '[CourseReminderService] [handleNotificationTap] No payload in notification',
      );
      return;
    }

    try {
      final Map<String, dynamic> payload = jsonDecode(response.payload!);
      final String? type = payload['type'];

      if (type != 'course_reminder') {
        log.warning(
          '[CourseReminderService] [handleNotificationTap] Unknown notification type: $type',
        );
        return;
      }

      final int weekIndex = payload['weekIndex'] ?? 0;

      final navigator = preference.debuggerKey.currentState;
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => LayoutBuilder(
              builder: (context, constraints) => ClassTableWindow(
                parentContext: context,
                currentWeek: weekIndex,
                constraints: constraints,
              ),
            ),
          ),
        );
        log.info(
          '[CourseReminderService] [handleNotificationTap] Navigated to class table, week: $weekIndex',
        );
      } else {
        log.warning(
          '[CourseReminderService] [handleNotificationTap] Navigator not available',
        );
      }
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] [handleNotificationTap] Failed to parse notification payload',
        e,
        stackTrace,
      );
    }
  }

  /// Generate the notification ID for course
  int _generateNotificationId(int weekday, int startClass, int weekIndex) {
    // return _notificationIdPrefix * 10000 +
    //     weekday * 10000 +
    //     startClass * 100 +
    //     weekIndex;
    final randomSuffix =
        _random.nextInt(_notificationRandomRange) + _notificationRandomMin;
    return _notificationIdPrefix * _notificationIdBase +
        weekIndex * 100000 +
        weekday * 10000 +
        startClass * 100 +
        randomSuffix;
  }

  static bool isCourseReminderNotificationId(int id) {
    final int minId = _notificationIdPrefix * _notificationIdBase;
    final int maxId = (_notificationIdPrefix + 1) * _notificationIdBase;
    return id >= minId && id < maxId;
  }

  /// Calculate the start time of the class
  DateTime _calculateClassStartTime(
    DateTime semesterStartDate,
    int weekIndex,
    int weekday,
    int startClass,
  ) {
    DateTime weekStart = semesterStartDate.add(Duration(days: weekIndex * 7));
    DateTime classDate = weekStart.add(Duration(days: weekday - 1));

    String timeStr = timeList[(startClass - 1) * 2];
    List<String> timeParts = timeStr.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      hour,
      minute,
    );
  }

  /// Calculate which class period the time corresponds to
  /// Returns the class index (1-based), or 1 if no match found
  int _calculateClassPeriodFromTime(DateTime time) {
    final timeInMinutes = time.hour * 60 + time.minute;

    // Find the closest matching class start time
    int closestClass = 1;
    int minDifference = 999999;

    for (int i = 0; i < timeList.length; i += 2) {
      final classIndex = (i ~/ 2) + 1; // Convert to 1-based class number
      final timeStr = timeList[i];
      final parts = timeStr.split(':');
      final classStartMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

      final difference = (timeInMinutes - classStartMinutes).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestClass = classIndex;
      }
    }

    return closestClass;
  }

  String _getCurrentLocale() {
    // Get current locale from preference
    String locale = preference.getString(preference.Preference.localization);
    // If localization is not set or empty, get system locale
    if (locale.isEmpty) {
      String systemLocale = Platform.localeName;
      log.info(
        "[CourseReminderService] [getCurrentLocale] Using system locale: $systemLocale",
      );
      if (systemLocale.contains("zh")) {
        if (Platform.isIOS || Platform.isMacOS) {
          if (systemLocale.contains("Hans")) {
            locale = "zh_CN";
          } else {
            locale = "zh_TW";
          }
        } else {
          if (systemLocale.contains("CN") || systemLocale.contains("SG")) {
            locale = "zh_CN";
          } else {
            locale = "zh_TW";
          }
        }
      } else {
        locale = "en_US";
      }
    }
    return locale;
  }

  Future<void> _scheduleNotificationFromCourseData({
    int daysToSchedule = 7,
    int minutesBefore = 5,
  }) async {
    log.info(
      '[CourseReminderService] [scheduleNotificationsFromCourseData] Starting to schedule notifications (daysToSchedule: $daysToSchedule, minutesBefore: $minutesBefore)...',
    );
    try {
      // Try to get ClassTableController with better error handling
      ClassTableController controller;
      try {
        controller = Get.find<ClassTableController>();
      } catch (e) {
        log.error(
          '[CourseReminderService] [scheduleNotificationsFromCourseData] ClassTableController not found',
          e,
        );
        return;
      }

      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning(
          '[CourseReminderService] [scheduleNotificationsFromCourseData] Course data not available, cannot schedule notifications',
        );
        return;
      }

      DateTime semesterStartDate = DateTime.parse(data.termStartDay);
      DateTime now = DateTime.now();

      int currentWeek = controller.getCurrentWeek(now);
      if (currentWeek < 0) currentWeek = 0;

      DateTime endDate = now.add(Duration(days: daysToSchedule));
      int endWeek = controller.getCurrentWeek(endDate);
      if (endWeek >= data.semesterLength) {
        endWeek = data.semesterLength - 1;
      }

      log.info(
        '[CourseReminderService] [scheduleNotificationsFromCourseData] Scheduling from week $currentWeek to week $endWeek',
      );

      int scheduledCount = 0;

      for (int weekIndex = currentWeek; weekIndex <= endWeek; weekIndex++) {
        for (var timeArrangement in data.timeArrangement) {
          if (weekIndex >= timeArrangement.weekList.length ||
              !timeArrangement.weekList[weekIndex]) {
            continue;
          }

          DateTime classStartTime = _calculateClassStartTime(
            semesterStartDate,
            weekIndex,
            timeArrangement.day,
            timeArrangement.start,
          );

          if (classStartTime.isBefore(now) || classStartTime.isAfter(endDate)) {
            continue;
          }

          DateTime notificationTime = classStartTime.subtract(
            Duration(minutes: minutesBefore),
          );

          if (notificationTime.isBefore(now)) {
            continue;
          }

          ClassDetail classDetail = data.getClassDetail(timeArrangement);

          int notificationId = _generateNotificationId(
            timeArrangement.day,
            timeArrangement.start,
            weekIndex,
          );

          String locale = _getCurrentLocale();

          String title = NonUII18n.translate(
            locale,
            'course_reminder.title',
            translateParams: {'name': classDetail.name},
          );

          String body = NonUII18n.translate(
            locale,
            'course_reminder.body',
            translateParams: {'time': minutesBefore.toString()},
          );

          if (timeArrangement.classroom != null &&
              timeArrangement.classroom!.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.location', translateParams: {"location": timeArrangement.classroom!})}';
          }
          if (timeArrangement.teacher != null &&
              timeArrangement.teacher!.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.teacher', translateParams: {"teacher": timeArrangement.teacher!})}';
          }

          Map<String, dynamic> payload = {
            'type': 'course_reminder',
            'className': classDetail.name,
            'weekIndex': weekIndex,
          };

          await scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: notificationTime,
            payload: jsonEncode(payload),
          );

          scheduledCount++;
        }
      }

      log.info(
        '[CourseReminderService] [scheduleNotificationsFromCourseData] Scheduled $scheduledCount course reminder notifications',
      );
      await _saveScheduleConfig(daysToSchedule, minutesBefore);
    } catch (e, stackTrace) {
      log.error(
        'Failed to schedule course reminder notifications',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _scheduleNotificationFromExperimentData({
    int daysToSchedule = 7,
    int minutesBefore = 5,
  }) async {
    log.info(
      '[CourseReminderService] [scheduleNotificationsFromExperimentData] Starting to schedule notifications (daysToSchedule: $daysToSchedule, minutesBefore: $minutesBefore)...',
    );
    try {
      ExperimentController experimentController;
      try {
        experimentController = Get.find<ExperimentController>();
      } catch (e) {
        log.error(
          '[CourseReminderService] [scheduleNotificationsFromExperimentData] ExperimentController not found',
          e,
        );
        return;
      }

      // Get ClassTableController to calculate week index
      ClassTableController? classTableController;
      try {
        classTableController = Get.find<ClassTableController>();
      } catch (e) {
        log.warning(
          '[CourseReminderService] [scheduleNotificationsFromExperimentData] ClassTableController not found, week index will not be calculated',
        );
      }

      final List<ExperimentData> experiments = experimentController.data;

      if (experiments.isEmpty) {
        log.warning(
          '[CourseReminderService] [scheduleNotificationsFromExperimentData] Experiment data not available, cannot schedule notifications',
        );
        return;
      }

      DateTime now = DateTime.now();
      DateTime endDate = now.add(Duration(days: daysToSchedule));

      log.info(
        '[CourseReminderService] [scheduleNotificationsFromExperimentData] Scheduling experiments from now until ${endDate.toString()}',
      );

      int scheduledCount = 0;

      for (
        int experimentIndex = 0;
        experimentIndex < experiments.length;
        experimentIndex++
      ) {
        final experiment = experiments[experimentIndex];

        for (
          int timeRangeIndex = 0;
          timeRangeIndex < experiment.timeRanges.length;
          timeRangeIndex++
        ) {
          final timeRange = experiment.timeRanges[timeRangeIndex];
          final experimentStartTime = timeRange.$1;

          // Skip if experiment is in the past or beyond the schedule range
          if (experimentStartTime.isBefore(now) ||
              experimentStartTime.isAfter(endDate)) {
            continue;
          }

          DateTime notificationTime = experimentStartTime.subtract(
            Duration(minutes: minutesBefore),
          );

          // Skip if notification time is in the past
          if (notificationTime.isBefore(now)) {
            continue;
          }

          // Calculate week index based on experiment start time
          int weekIndex = 0;
          if (classTableController != null) {
            weekIndex = classTableController.getCurrentWeek(
              experimentStartTime,
            );
            if (weekIndex < 0) weekIndex = 0;
          }

          int weekday = experimentStartTime.weekday; // 1=Mon, 7=Sun

          // Calculate which class period this experiment corresponds to
          int startClass = _calculateClassPeriodFromTime(experimentStartTime);

          // Use a unique ID based on experiment start time to avoid conflicts
          int notificationId = _generateNotificationId(
            weekday,
            startClass,
            weekIndex,
          );

          String locale = _getCurrentLocale();

          // Use course_reminder translation keys to treat experiments as courses
          String title = NonUII18n.translate(
            locale,
            'course_reminder.title',
            translateParams: {'name': experiment.name},
          );

          String body = NonUII18n.translate(
            locale,
            'course_reminder.body',
            translateParams: {'time': minutesBefore.toString()},
          );

          if (experiment.classroom.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.location', translateParams: {"location": experiment.classroom})}';
          }
          if (experiment.teacher.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.teacher', translateParams: {"teacher": experiment.teacher})}';
          }

          Map<String, dynamic> payload = {
            'type': 'course_reminder',
            'className': experiment.name,
            'weekIndex': weekIndex,
          };

          await scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: notificationTime,
            payload: jsonEncode(payload),
          );

          scheduledCount++;
        }
      }

      log.info(
        '[CourseReminderService] [scheduleNotificationsFromExperimentData] Scheduled $scheduledCount experiment reminder notifications',
      );
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] [scheduleNotificationsFromExperimentData] Failed to schedule experiment reminder notifications',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Schedule notification by the course data (includes experiments)
  Future<void> scheduleNotificationsFromCourseData({
    int daysToSchedule = 7,
    int minutesBefore = 5,
  }) async {
    try {
      // Schedule course and experiment notifications in parallel
      await Future.wait([
        _scheduleNotificationFromCourseData(
          daysToSchedule: daysToSchedule,
          minutesBefore: minutesBefore,
        ),
        if (enableExperimentNotifications)
          _scheduleNotificationFromExperimentData(
            daysToSchedule: daysToSchedule,
            minutesBefore: minutesBefore,
          ),
      ]);
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] [scheduleNotificationsFromCourseData] Failed to schedule notifications from course data',
        e,
        stackTrace,
      );
    }
  }

  /// Validate and update the scheduled notification
  Future<void> validateAndUpdateNotifications() async {
    log.info(
      '[CourseReminderService] [validateAndUpdateNotifications] Validating scheduled notifications...',
    );
    try {
      // Check if notifications are enabled first
      if (!isEnabled) {
        log.info(
          '[CourseReminderService] [validateAndUpdateNotifications] Notifications not enabled, skipping validation',
        );
        return;
      }

      // Try to get ClassTableController, return if not available
      ClassTableController controller;
      try {
        controller = Get.find<ClassTableController>();
      } catch (e) {
        log.warning(
          '[CourseReminderService] [validateAndUpdateNotifications] ClassTableController not initialized yet',
        );
        return;
      }

      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning(
          '[CourseReminderService] [validateAndUpdateNotifications] Course data not available, cannot validate notifications',
        );
        return;
      }

      // Load configuration
      final config = await _loadScheduleConfig();
      final int daysToSchedule = config?['daysToSchedule'] ?? 7;
      final int minutesBefore = config?['minutesBefore'] ?? 5;

      // Check if locale has changed
      final currentLocale = _getCurrentLocale();
      final lastLocale = config?['lastLocale'] as String?;

      if (lastLocale != null && lastLocale != currentLocale) {
        log.info(
          '[CourseReminderService] [validateAndUpdateNotifications] Locale changed from $lastLocale to $currentLocale',
        );
      }

      // Simplified approach: cancel all and reschedule
      // This handles all cases: locale change, course updates, expired notifications, etc.
      log.info(
        '[CourseReminderService] [validateAndUpdateNotifications] Cancelling all existing notifications...',
      );
      await cancelAllCourseNotifications();

      log.info(
        '[CourseReminderService] [validateAndUpdateNotifications] Rescheduling notifications (daysToSchedule: $daysToSchedule, minutesBefore: $minutesBefore)...',
      );
      await scheduleNotificationsFromCourseData(
        daysToSchedule: daysToSchedule,
        minutesBefore: minutesBefore,
      );

      final newCount = await getPendingCourseNotificationsCount();
      log.info(
        '[CourseReminderService] [validateAndUpdateNotifications] Successfully rescheduled $newCount notifications',
      );
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] [validateAndUpdateNotifications] Failed to validate and update notifications',
        e,
        stackTrace,
      );
    }
  }

  /// Cancel all the course reminder notification (includes experiments)
  Future<void> cancelAllCourseNotifications() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      final courseNotifications = pendingNotifications.where(
        (n) => CourseReminderService.isCourseReminderNotificationId(n.id),
      );

      for (var notification in courseNotifications) {
        await cancelNotification(notification.id);
      }

      log.info(
        'Cancelled ${courseNotifications.length} course reminder notifications (includes experiments)',
      );
    } catch (e, stackTrace) {
      log.error('Failed to cancel course notifications', e, stackTrace);
      rethrow;
    }
  }

  /// Save the config
  Future<void> _saveScheduleConfig(
    int daysToSchedule,
    int minutesBefore,
  ) async {
    await preference.setInt(
      preference.Preference.courseReminderDaysToSchedule,
      daysToSchedule,
    );
    await preference.setInt(
      preference.Preference.courseReminderMinutesBefore,
      minutesBefore,
    );

    String currentLocale = _getCurrentLocale();
    await _setLastLocale(currentLocale);
  }

  /// Load the config
  Future<Map<String, dynamic>?> _loadScheduleConfig() async {
    // Return null only if essential config is missing (0 means not configured yet)
    if (daysToSchedule == 0 || minutesBefore == 0) {
      return null;
    }

    return {
      'daysToSchedule': daysToSchedule,
      'minutesBefore': minutesBefore,
      'lastLocale': lastLocale,
    };
  }

  /// Get the number of scheduled course reminder notifications (includes experiments)
  Future<int> getPendingCourseNotificationsCount() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      return pendingNotifications
          .where(
            (n) => CourseReminderService.isCourseReminderNotificationId(n.id),
          )
          .length;
    } catch (e, stackTrace) {
      log.error('Failed to get pending notifications count', e, stackTrace);
      return 0;
    }
  }
}
