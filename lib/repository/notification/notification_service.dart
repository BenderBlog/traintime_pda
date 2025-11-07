// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Abstract base class for notification services using flutter_local_notifications

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:watermeter/repository/logger.dart';

/// Abstract base class for managing notifications.
///
/// This class provides a common interface and basic implementation for
/// notification functionalities, intended to be extended by specific
/// notification services (e.g., course reminders).
abstract class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  @protected
  bool initialized = false;

  /// Initializes the notification service.
  ///
  /// This must be called before any other methods. It sets up the
  /// notification plugin, time zones, and platform-specific settings.
  Future<void> initialize({String? timeZone}) async {
    if (initialized) return;

    try {
      // Initialize time zone data
      tz.initializeTimeZones();
      final effectiveTimeZone = timeZone ?? 'Asia/Shanghai';
      tz.setLocalLocation(tz.getLocation(effectiveTimeZone));

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

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: handleNotificationTap,
      );

      initialized = true;
      log.info('Notification service initialized successfully for ${runtimeType.toString()}');
    } catch (e, stackTrace) {
      log.error(
        'Failed to initialize notification service for ${runtimeType.toString()}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Abstract method to handle notification tap events.
  ///
  /// Subclasses must implement this to define behavior when a user
  /// taps on a notification.
  void handleNotificationTap(NotificationResponse response);

  /// Abstract method to schedule a notification.
  ///
  /// Subclasses must implement this to provide specific details for
  /// scheduling, such as channel information and payload structure.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  });

  /// Requests notification permissions from the user.
  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status.isGranted;
      } else if (Platform.isIOS) {
        final bool? result = await flutterLocalNotificationsPlugin
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

  /// Checks if notification permissions have been granted.
  Future<bool> checkNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
        final bool? result = await flutterLocalNotificationsPlugin
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

  // /// Requests Do Not Disturb (DND) permission (Android only).
  // Future<bool> requestDndPermission() async {
  //   if (!Platform.isAndroid) return false;

  //   try {
  //     final status = await Permission.accessNotificationPolicy.request();
  //     return status.isGranted;
  //   } catch (e, stackTrace) {
  //     log.error(
  //       'Failed to request DND permission',
  //       e,
  //       stackTrace,
  //     );
  //     return false;
  //   }
  // }

  // /// Checks if Do Not Disturb (DND) permission has been granted (Android only).
  // Future<bool> checkDndPermission() async {
  //   if (!Platform.isAndroid) return false;

  //   try {
  //     return await Permission.accessNotificationPolicy.isGranted;
  //   } catch (e, stackTrace) {
  //     log.error(
  //       'Failed to check DND permission',
  //       e,
  //       stackTrace,
  //     );
  //     return false;
  //   }
  // }

  /// Requests schedule exact alarm permission (Android only).
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms

    try {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to request exact alarm permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Checks if schedule exact alarm permission has been granted (Android only).
  Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms

    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to check exact alarm permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Retrieves a list of all pending (scheduled) notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!initialized) {
      throw StateError('Notification service not initialized');
    }

    try {
      final results = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
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

  /// Cancels a specific notification by its [id].
  Future<void> cancelNotification(int id) async {
    if (!initialized) {
      throw StateError('Notification service not initialized');
    }

    try {
      await flutterLocalNotificationsPlugin.cancel(id);
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

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    if (!initialized) {
      throw StateError('Notification service not initialized');
    }

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
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

  /// Opens the app's notification settings page.
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
