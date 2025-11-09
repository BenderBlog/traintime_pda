// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification service implementation

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/notification_service.dart';
import 'package:watermeter/repository/permission_handler/exact_alarm_permission_handler.dart';
import 'package:watermeter/repository/permission_handler/notification_permission_handler.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/generated/non_ui_i18n.g.dart';

/// Course Reminder Service implementation
class CourseReminderService extends NotificationService {
  static final CourseReminderService _instance =
      CourseReminderService._internal(
        notificationPermissionHandler: NotificationPermissionHandler(),
        exactAlarmPermissionHandler: ExactAlarmPermissionHandler(),
      );
  factory CourseReminderService() => _instance;
  CourseReminderService._internal({
    required super.notificationPermissionHandler,
    required super.exactAlarmPermissionHandler,
  });

  static const int _notificationIdPrefix = 10000;

  @override
  void handleNotificationTap(NotificationResponse response) {
    log.info('[CourseReminderService] Notification tapped');

    if (response.payload == null || response.payload!.isEmpty) {
      log.warning('[CourseReminderService] No payload in notification');
      return;
    }

    try {
      final Map<String, dynamic> payload = jsonDecode(response.payload!);
      final String? type = payload['type'];

      if (type != 'course_reminder') {
        log.warning('[CourseReminderService] Unknown notification type: $type');
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
          '[CourseReminderService] Navigated to class table, week: $weekIndex',
        );
      } else {
        log.warning('[CourseReminderService] Navigator not available');
      }
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminderService] Failed to parse notification payload',
        e,
        stackTrace,
      );
    }
  }

  /// Schedule a course reminder notification.
  /// This method is an override and provides the specific implementation for course reminders.
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!initialized) {
      throw StateError('Notification service not initialized');
    }

    try {
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      if (Platform.isAndroid) {
        final androidDetails = AndroidNotificationDetails(
          'course_reminder',
          'Course Reminder',
          channelDescription:
              'Course reminder notifications for upcoming classes',
          importance: Importance.max,
          priority: Priority.max,
          audioAttributesUsage: AudioAttributesUsage.notification,
          playSound: true,
          enableVibration: true,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } else if (Platform.isIOS) {
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        );

        const notificationDetails = NotificationDetails(iOS: iosDetails);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }

      log.info('Scheduled course notification $id at $scheduledTime');
    } catch (e, stackTrace) {
      log.error('Failed to schedule course notification', e, stackTrace);
      rethrow;
    }
  }

  /// Generate the notification ID
  int _generateNotificationId(int weekday, int startClass, int weekIndex) {
    return _notificationIdPrefix * 10000 +
        weekday * 10000 +
        startClass * 100 +
        weekIndex;
  }

  /// Parse Notification ID
  List<int> _parseNotificationId(int id) {
    if (id < _notificationIdPrefix * 10000) {
      return [-1, -1, -1];
    }

    int remaining = id - _notificationIdPrefix * 10000;
    int weekday = remaining ~/ 10000;
    remaining = remaining % 10000;
    int startClass = remaining ~/ 100;
    int weekIndex = remaining % 100;

    return [weekday, startClass, weekIndex];
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

  /// Schedule notification by the course data
  Future<void> scheduleNotificationsFromCourseData({
    int daysToSchedule = 7,
    int minutesBefore = 5,
  }) async {
    try {
      final ClassTableController controller = Get.find<ClassTableController>();
      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning('Course data not available, cannot schedule notifications');
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

          var locale = preference.prefs.getString('locale') ?? 'zh_CN';

          String title = NonUII18n.translate(
            locale,
            'course_reminder.title',
            translateParams: {'name': classDetail.name},
          );

          String body = NonUII18n.translate(
            locale,
            'course_reminder.body',
            translateParams: {'time': minutesBefore},
          );

          if (timeArrangement.classroom != null &&
              timeArrangement.classroom!.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.location')}${timeArrangement.classroom}';
          }
          if (timeArrangement.teacher != null &&
              timeArrangement.teacher!.isNotEmpty) {
            body +=
                '\n${NonUII18n.translate(locale, 'course_reminder.teacher')}${timeArrangement.teacher}';
          }

          Map<String, dynamic> payload = {
            'type': 'course_reminder',
            'className': classDetail.name,
            'weekIndex': weekIndex,
            'weekday': timeArrangement.day,
            'startClass': timeArrangement.start,
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

      log.info('Scheduled $scheduledCount course reminder notifications');
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

  /// Validate and update the scheduled notification
  Future<void> validateAndUpdateNotifications() async {
    try {
      final ClassTableController controller = Get.find<ClassTableController>();
      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning('Course data not available, cannot validate notifications');
        return;
      }

      final pendingNotifications = await getPendingNotifications();
      final courseNotifications = pendingNotifications.where((n) {
        final parsed = _parseNotificationId(n.id);
        return parsed[0] != -1;
      }).toList();

      log.info(
        'Found ${courseNotifications.length} pending course reminder notifications',
      );

      DateTime now = DateTime.now();
      DateTime semesterStartDate = DateTime.parse(data.termStartDay);

      List<int> invalidNotificationIds = [];
      for (var notification in courseNotifications) {
        List<int> parsed = _parseNotificationId(notification.id);
        int weekday = parsed[0];
        int startClass = parsed[1];
        int weekIndex = parsed[2];

        bool found = data.timeArrangement.any((ta) {
          if (ta.day == weekday &&
              ta.start == startClass &&
              weekIndex < ta.weekList.length &&
              ta.weekList[weekIndex]) {
            DateTime classStartTime = _calculateClassStartTime(
              semesterStartDate,
              weekIndex,
              weekday,
              startClass,
            );
            return classStartTime.isAfter(now);
          }
          return false;
        });

        if (!found) {
          invalidNotificationIds.add(notification.id);
        }
      }

      for (var id in invalidNotificationIds) {
        await cancelNotification(id);
      }

      if (invalidNotificationIds.isNotEmpty) {
        log.info(
          'Cancelled ${invalidNotificationIds.length} invalid notifications',
        );
      }

      final config = await _loadScheduleConfig();
      if (config != null) {
        int daysToSchedule = config['daysToSchedule'] ?? 7;
        DateTime endDate = now.add(Duration(days: daysToSchedule));
        int endWeek = controller.getCurrentWeek(endDate);

        int maxWeekInNotifications = courseNotifications
            .where((n) => !invalidNotificationIds.contains(n.id))
            .map((n) => _parseNotificationId(n.id)[2])
            .fold(-1, (max, week) => week > max ? week : max);

        if (maxWeekInNotifications < endWeek) {
          log.info(
            'Scheduling additional notifications to reach week $endWeek',
          );
          await scheduleNotificationsFromCourseData(
            daysToSchedule: daysToSchedule,
            minutesBefore: config['minutesBefore'] ?? 5,
          );
        }
      }
    } catch (e, stackTrace) {
      log.error('Failed to validate and update notifications', e, stackTrace);
    }
  }

  /// Cancel all the course reminder notification
  Future<void> cancelAllCourseNotifications() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      final courseNotifications = pendingNotifications.where((n) {
        final parsed = _parseNotificationId(n.id);
        return parsed[0] != -1;
      });

      for (var notification in courseNotifications) {
        await cancelNotification(notification.id);
      }

      log.info(
        'Cancelled ${courseNotifications.length} course reminder notifications',
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
    await preference.prefs.setInt(
      'notification_days_to_schedule',
      daysToSchedule,
    );
    await preference.prefs.setInt('notification_minutes_before', minutesBefore);
  }

  /// Load the config
  Future<Map<String, dynamic>?> _loadScheduleConfig() async {
    final daysToSchedule = preference.prefs.getInt(
      'notification_days_to_schedule',
    );
    final minutesBefore = preference.prefs.getInt(
      'notification_minutes_before',
    );
    final modeStr = preference.prefs.getString('notification_mode');

    if (daysToSchedule == null || minutesBefore == null || modeStr == null) {
      return null;
    }

    return {'daysToSchedule': daysToSchedule, 'minutesBefore': minutesBefore};
  }

  /// Get the number of scheduled course reminder notifications
  Future<int> getPendingCourseNotificationsCount() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      return pendingNotifications.where((n) {
        final parsed = _parseNotificationId(n.id);
        return parsed[0] != -1;
      }).length;
    } catch (e, stackTrace) {
      log.error('Failed to get pending notifications count', e, stackTrace);
      return 0;
    }
  }
}
