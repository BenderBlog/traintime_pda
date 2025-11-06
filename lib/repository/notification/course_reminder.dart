// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification module

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/notification_base.dart';
import 'package:watermeter/repository/preference.dart' as preference;

import 'package:watermeter/page/classtable/classtable.dart';

/// Course Reminder
class CourseReminder {
  static final CourseReminder _instance = CourseReminder._internal();
  factory CourseReminder() => _instance;
  CourseReminder._internal();

  final NotificationBase _notificationBase = NotificationBase();

  static const int _notificationIdPrefix = 10000;

  /// Initiate Notification Base
  Future<void> initialize() async {
    await _notificationBase.initialize(
      onNotificationTap: _handleNotificationTap,
    );
  }

  /// Handle notification tap event
  void _handleNotificationTap(NotificationResponse response) {
    log.info('[CourseReminder] Notification tapped');
    
    if (response.payload == null || response.payload!.isEmpty) {
      log.warning('[CourseReminder] No payload in notification');
      return;
    }

    try {
      final Map<String, dynamic> payload = jsonDecode(response.payload!);
      final String? type = payload['type'];

      if (type != 'course_reminder') {
        log.warning('[CourseReminder] Unknown notification type: $type');
        return;
      }

      // Extract course information from payload
      final int weekIndex = payload['weekIndex'] ?? 0;

      // Jump to class table page with the week of the notified course
      // Note: We don't have BuildContext and BoxConstraints here,
      // so we use Get.to() with a placeholder that will be replaced by the actual layout
      Get.to(() => LayoutBuilder(
        builder: (context, constraints) => ClassTableWindow(
          parentContext: context,
          currentWeek: weekIndex,
          constraints: constraints,
        ),
      ));
      
      log.info('[CourseReminder] Navigated to class table, week: $weekIndex');
    } catch (e, stackTrace) {
      log.error(
        '[CourseReminder] Failed to parse notification payload',
        e,
        stackTrace,
      );
    }
  }

  /// Generate the notification ID
  /// 
  /// format: prefix(10000) + day of the week(1 number) + course count(2 numbers) + week count(2 numbers)
  /// 
  /// example: 10000 + 1 + 01 + 01 = 1000110101 (Monday, the first class, the first week of the term)
  int _generateNotificationId(int weekday, int startClass, int weekIndex) {
    return _notificationIdPrefix * 10000 +
        weekday * 10000 +
        startClass * 100 +
        weekIndex;
  }

  /// Parse Notification ID
  /// 
  /// return [weekday, startClass, weekIndex]
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
    // Calculate the start time of the week
    DateTime weekStart = semesterStartDate.add(Duration(days: weekIndex * 7));
    // Calculate the specific time
    DateTime classDate = weekStart.add(Duration(days: weekday - 1));

    // Get the start time of the class
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
  /// 
  /// [daysToSchedule] Arrange notifications for the next many days, with a default of 7 days
  /// [minutesBefore] Arrange notifications ahead how much time before the class start, with a default of 5 minutes
  /// [mode] Notification mode
  Future<void> scheduleNotificationsFromCourseData({
    int daysToSchedule = 7,
    int minutesBefore = 5,
    NotificationMode mode = NotificationMode.normal,
  }) async {
    try {
      final ClassTableController controller = Get.find<ClassTableController>();
      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning('Course data not available, cannot schedule notifications');
        return;
      }

      // parse the start date of the semester
      DateTime semesterStartDate = DateTime.parse(data.termStartDay);
      DateTime now = DateTime.now();

      // calculate the current week
      int currentWeek = controller.getCurrentWeek(now);
      if (currentWeek < 0) currentWeek = 0;

      // calculate the last day needed to schedule
      DateTime endDate = now.add(Duration(days: daysToSchedule));
      int endWeek = controller.getCurrentWeek(endDate);
      if (endWeek >= data.semesterLength) {
        endWeek = data.semesterLength - 1;
      }

      int scheduledCount = 0;

      for (int weekIndex = currentWeek; weekIndex <= endWeek; weekIndex++) {
        for (var timeArrangement in data.timeArrangement) {
          // Check whether need to take a class in the week
          if (weekIndex >= timeArrangement.weekList.length ||
              !timeArrangement.weekList[weekIndex]) {
            continue;
          }

          // calculate the start time of the class
          DateTime classStartTime = _calculateClassStartTime(
            semesterStartDate,
            weekIndex,
            timeArrangement.day,
            timeArrangement.start,
          );

          // Only arrange the future class notification
          if (classStartTime.isBefore(now)) {
            continue;
          }

          // Only arrange the course within the specific time span
          if (classStartTime.isAfter(endDate)) {
            continue;
          }

          // Calculate the time of the notification
          DateTime notificationTime =
              classStartTime.subtract(Duration(minutes: minutesBefore));

          // If the time of the notification has passed, pass
          if (notificationTime.isBefore(now)) {
            continue;
          }

          // Get course detail
          ClassDetail classDetail = data.getClassDetail(timeArrangement);

          // Generate the notification ID
          int notificationId = _generateNotificationId(
            timeArrangement.day,
            timeArrangement.start,
            weekIndex,
          );

          // Build notification body
          // TODO: i18n
          String title = '课前提醒：${classDetail.name}';
          String body = '$minutesBefore分钟后开始上课';
          if (timeArrangement.classroom != null &&
              timeArrangement.classroom!.isNotEmpty) {
            body += '\n地点：${timeArrangement.classroom}';
          }
          if (timeArrangement.teacher != null &&
              timeArrangement.teacher!.isNotEmpty) {
            body += '\n教师：${timeArrangement.teacher}';
          }

          // Build payload（Used for the click event）
          Map<String, dynamic> payload = {
            'type': 'course_reminder',
            'className': classDetail.name,
            'weekIndex': weekIndex,
            'weekday': timeArrangement.day,
            'startClass': timeArrangement.start,
          };

          // Arrange notification
          await _notificationBase.scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: notificationTime,
            mode: mode,
            payload: jsonEncode(payload),
          );

          scheduledCount++;
        }
      }

      log.info('Scheduled $scheduledCount course reminder notifications');

      // Save the configuration into Preference
      await _saveScheduleConfig(daysToSchedule, minutesBefore, mode);
    } catch (e, stackTrace) {
      log.error('Failed to schedule course reminder notifications', e, stackTrace);
      rethrow;
    }
  }

  /// Validate and update the scheduled notification
  /// 
  /// Check whether the scheduled notifications are consistent with the current course data. If not, update them
  Future<void> validateAndUpdateNotifications() async {
    try {
      final ClassTableController controller = Get.find<ClassTableController>();
      final ClassTableData data = controller.classTableData;

      if (data.termStartDay.isEmpty) {
        log.warning('Course data not available, cannot validate notifications');
        return;
      }

      // Get the scheduled notifications
      final pendingNotifications = await _notificationBase.getPendingNotifications();

      // Filter out the course reminder notifications
      final int minId = _notificationIdPrefix * 10000;
      final int maxId = minId + 100000;
      
      final courseNotifications = pendingNotifications.where((notification) {
        return notification.id >= minId && notification.id < maxId;
      }).toList();

      log.info('Found ${courseNotifications.length} pending course reminder notifications');

      DateTime now = DateTime.now();
      DateTime semesterStartDate = DateTime.parse(data.termStartDay);

      // Validate 
      List<int> invalidNotificationIds = [];
      for (var notification in courseNotifications) {
        List<int> parsed = _parseNotificationId(notification.id);
        int weekday = parsed[0];
        int startClass = parsed[1];
        int weekIndex = parsed[2];

        // Search for the corresponding course schedule
        bool found = false;
        for (var timeArrangement in data.timeArrangement) {
          if (timeArrangement.day == weekday &&
              timeArrangement.start == startClass &&
              weekIndex < timeArrangement.weekList.length &&
              timeArrangement.weekList[weekIndex]) {
            // Verify whether the course time has passed
            DateTime classStartTime = _calculateClassStartTime(
              semesterStartDate,
              weekIndex,
              weekday,
              startClass,
            );

            if (classStartTime.isBefore(now)) {
              // The time-out course
              invalidNotificationIds.add(notification.id);
            } else {
              found = true;
            }
            break;
          }
        }

        if (!found) {
          // The canceled course
          invalidNotificationIds.add(notification.id);
        }
      }

      // Cancel the invalid notification
      for (var id in invalidNotificationIds) {
        await _notificationBase.cancelNotification(id);
      }

      if (invalidNotificationIds.isNotEmpty) {
        log.info('Cancelled ${invalidNotificationIds.length} invalid notifications');
      }

      // Check whether need to append new notifications
      final config = await _loadScheduleConfig();
      if (config != null) {
        int daysToSchedule = config['daysToSchedule'] ?? 7;
        DateTime endDate = now.add(Duration(days: daysToSchedule));
        int endWeek = controller.getCurrentWeek(endDate);

        // Find the farthest notification date
        int maxWeekInNotifications = -1;
        for (var notification in courseNotifications) {
          if (!invalidNotificationIds.contains(notification.id)) {
            List<int> parsed = _parseNotificationId(notification.id);
            int weekIndex = parsed[2];
            if (weekIndex > maxWeekInNotifications) {
              maxWeekInNotifications = weekIndex;
            }
          }
        }

        // If the farthest notification week is less than the 7th day, supplementary notifications will be given
        if (maxWeekInNotifications < endWeek) {
          log.info('Scheduling additional notifications to reach week $endWeek');
          await scheduleNotificationsFromCourseData(
            daysToSchedule: daysToSchedule,
            minutesBefore: config['minutesBefore'] ?? 5,
            mode: config['mode'] ?? NotificationMode.normal,
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
      final pendingNotifications = await _notificationBase.getPendingNotifications();

      // Filter out the course reminder notifications
      final int minId = _notificationIdPrefix * 10000;
      final int maxId = minId + 100000;
      
      final courseNotifications = pendingNotifications.where((notification) {
        return notification.id >= minId && notification.id < maxId;
      }).toList();

      // Cancel all the course reminder notification
      for (var notification in courseNotifications) {
        await _notificationBase.cancelNotification(notification.id);
      }

      log.info('Cancelled ${courseNotifications.length} course reminder notifications');
    } catch (e, stackTrace) {
      log.error('Failed to cancel course notifications', e, stackTrace);
      rethrow;
    }
  }

  /// Save the config
  Future<void> _saveScheduleConfig(
    int daysToSchedule,
    int minutesBefore,
    NotificationMode mode,
  ) async {
    await preference.prefs.setInt(
      'notification_days_to_schedule',
      daysToSchedule,
    );
    await preference.prefs.setInt(
      'notification_minutes_before',
      minutesBefore,
    );
    await preference.prefs.setString(
      'notification_mode',
      mode.name,
    );
  }

  /// Load the config
  Future<Map<String, dynamic>?> _loadScheduleConfig() async {
    final daysToSchedule = preference.prefs.getInt('notification_days_to_schedule');
    final minutesBefore = preference.prefs.getInt('notification_minutes_before');
    final modeStr = preference.prefs.getString('notification_mode');

    if (daysToSchedule == null || minutesBefore == null || modeStr == null) {
      return null;
    }

    NotificationMode mode = modeStr == 'enhanced'
        ? NotificationMode.enhanced
        : NotificationMode.normal;

    return {
      'daysToSchedule': daysToSchedule,
      'minutesBefore': minutesBefore,
      'mode': mode,
    };
  }

  /// Get the number of scheduled course reminder notifications
  Future<int> getPendingCourseNotificationsCount() async {
    try {
      final pendingNotifications = await _notificationBase.getPendingNotifications();
      final int minId = _notificationIdPrefix * 10000;
      final int maxId = minId + 100000;
      
      return pendingNotifications
          .where((notification) =>
              notification.id >= minId &&
              notification.id < maxId)
          .length;
    } catch (e, stackTrace) {
      log.error('Failed to get pending notifications count', e, stackTrace);
      return 0;
    }
  }
}
