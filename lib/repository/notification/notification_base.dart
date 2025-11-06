// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Notification base module for flutter_local_notifications

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:watermeter/repository/logger.dart';

enum NotificationMode {
  normal, // Normal Mode
  enhanced, // Enhanced Mode
}

/// Callback function type for handling notification tap events
typedef NotificationTapCallback = void Function(NotificationResponse response);

class NotificationBase {
  // Single Instance Mode
  static final NotificationBase _instance = NotificationBase._internal();
  factory NotificationBase() => _instance;
  NotificationBase._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationTapCallback? _onNotificationTapCallback;

  /// Initiate notification plugin
  /// 
  /// [onNotificationTap] Optional callback function to handle notification tap events
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    if (_initialized) return;

    // Store the callback
    _onNotificationTapCallback = onNotificationTap;

    try {
      // Initiate time zone data
      tz.initializeTimeZones();
      // Set time zone to 中国/上海
      // TODO: The time zone switch is temporarily locked and cannot be modified
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;
      log.info('Notification module initialized successfully');
    } catch (e, stackTrace) {
      log.error(
        'Failed to initialize notification module',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Handle notification click event
  void _onNotificationTap(NotificationResponse response) {
    log.info('Notification tapped: ${response.payload}');
    
    // Call the custom callback if provided
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(response);
    }
  }

  /// Require the permission for notification
  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        // Android 13+ need require for the permission
        final status = await Permission.notification.request();
        return status.isGranted;
      } else if (Platform.isIOS) {
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      log.error(
        'Failed to request notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Check the status of notification permission
  Future<bool> checkNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions()
            .then((settings) => settings?.isEnabled ?? false);
        return result ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      log.error(
        'Failed to check notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Require DnD permission（Only for Android）
  Future<bool> requestDndPermission() async {
    if (!Platform.isAndroid) return false;

    try {
      final status = await Permission.accessNotificationPolicy.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to request DnD permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Check DnD permission（Only for Android）
  Future<bool> checkDndPermission() async {
    if (!Platform.isAndroid) return false;

    try {
      return await Permission.accessNotificationPolicy.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to check DnD permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Schedule a notification
  /// 
  /// [id] The unique ID for the notification
  /// [title] Notification title
  /// [body] Notification body
  /// [scheduledTime] Scheduled time for the notification
  /// [mode] Notification Mode
  /// [payload] The attached data 
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationMode mode = NotificationMode.normal,
    String? payload,
  }) async {
    if (!_initialized) {
      throw StateError('Notification module not initialized');
    }

    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      if (Platform.isAndroid) {
        final androidDetails = AndroidNotificationDetails(
          mode == NotificationMode.enhanced
              ? 'course_reminder_enhanced'
              : 'course_reminder_normal',
          mode == NotificationMode.enhanced 
              ? 'Course Reminder (Enhanced)' 
              : 'Course Reminder',
          channelDescription: mode == NotificationMode.enhanced
              ? 'Course reminder notifications that can override Do Not Disturb mode'
              : 'Course reminder notifications for upcoming classes',
          importance: Importance.high,
          priority: Priority.high,
          // Skip DnD in the enhanced mode
          audioAttributesUsage: mode == NotificationMode.enhanced
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
          playSound: true,
          enableVibration: true,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        await _flutterLocalNotificationsPlugin.zonedSchedule(
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
          // iOS do not support to bypass DnD mode, the enhanced mode need critical alert permission.
          // But critical alert need special permission, this function is not implemented for the time being.
        );

        const notificationDetails = NotificationDetails(
          iOS: iosDetails,
        );

        await _flutterLocalNotificationsPlugin.zonedSchedule(
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

      log.info('Scheduled notification $id at $scheduledTime');
    } catch (e, stackTrace) {
      log.error(
        'Failed to schedule notification',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get all the notification waiting for triggering.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) {
      throw StateError('Notification module not initialized');
    }

    try {
      final results = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return results;
    } catch (e, stackTrace) {
      log.error(
        'Failed to get pending notifications',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Cancel the specific notification
  Future<void> cancelNotification(int id) async {
    if (!_initialized) {
      throw StateError('Notification module not initialized');
    }

    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      log.info('Cancelled notification $id');
    } catch (e, stackTrace) {
      log.error(
        'Failed to cancel notification',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Cancel all the notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) {
      throw StateError('Notification module not initialized');
    }

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      log.info('Cancelled all notifications');
    } catch (e, stackTrace) {
      log.error(
        'Failed to cancel all notifications',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Open the setting page of XDYou
  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e, stackTrace) {
      log.error(
        'Failed to open notification settings',
        e,
        stackTrace,
      );
    }
  }
}
