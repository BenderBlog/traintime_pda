// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Abstract base class for notification services using flutter_local_notifications

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/permission_handler/permission_handler_base.dart';

/// Abstract base class for managing notifications.
///
/// This class provides a common interface and basic implementation for
/// notification functionalities, intended to be extended by specific
/// notification services (e.g., course reminders).
/// 
/// Attention: Every Subclass inherits from this should add the subclass 
/// in the [NotificationRegistrar](./notification_registrar.dart)
/// to make sure the initialization and event handle.
abstract class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final PermissionHandlerBase notificationPermissionHandler;
  final PermissionHandlerBase exactAlarmPermissionHandler;

  NotificationService({
    required this.notificationPermissionHandler,
    required this.exactAlarmPermissionHandler,
  });
  
  @protected
  bool initialized = false;

  bool get isInitialized => initialized;

  /// Initializes the notification service.
  ///
  /// This must be called before any other methods. It sets up the
  /// notification plugin, time zones, and platform-specific settings.
  Future<void> initialize({String? timeZone}) async {
    if (initialized) return;

    try {
      // Check and request notification permission before initializing.
      // We don't abort initialization if permission is denied, but we log
      // warnings so callers can react accordingly.
      try {
        final hasPermission = await checkNotificationPermission();
        if (!hasPermission) {
          final granted = await requestNotificationPermission();
          if (!granted) {
            log.warning(
              'Notification permission not granted for ${runtimeType.toString()}',
            );
          } else {
            log.info(
              'Notification permission granted for ${runtimeType.toString()}',
            );
          }
        }
      } catch (e, st) {
        log.error(
          'Failed to check/request notification permission for ${runtimeType.toString()}',
          e,
          st,
        );
      }

      // On Android, also check/request the exact alarm permission which may
      // be required for exact scheduling while idle.
      if (Platform.isAndroid) {
        try {
          final hasExact = await checkExactAlarmPermission();
          if (!hasExact) {
            final grantedExact = await requestExactAlarmPermission();
            if (!grantedExact) {
              log.warning(
                'Exact alarm permission not granted for ${runtimeType.toString()}',
              );
            } else {
              log.info(
                'Exact alarm permission granted for ${runtimeType.toString()}',
              );
            }
          }
        } catch (e, st) {
          log.error(
            'Failed to check/request exact alarm permission for ${runtimeType.toString()}',
            e,
            st,
          );
        }
      }

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
  /// 
  /// If you wanna use this method, please call
  /// [handleAppLaunchFromNotification] of your instance to make it work.
  void handleNotificationTap(NotificationResponse response);

  /// Handle app launch from notification tap.
  /// 
  /// This should be called during app startup to process any notification
  /// that launched the app.
  Future<void> handleAppLaunchFromNotification() async {
    final NotificationAppLaunchDetails? launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      handleNotificationTap(launchDetails.notificationResponse!);
    }
  }

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
    return await notificationPermissionHandler.requestPermission();
  }

  /// Checks if notification permissions have been granted.
  Future<bool> checkNotificationPermission() async {
    return await notificationPermissionHandler.checkPermission();
  }

  /// Requests schedule exact alarm permission (Android only).
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms
    return await exactAlarmPermissionHandler.requestPermission();
  }

  /// Checks if schedule exact alarm permission has been granted (Android only).
  Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms
    return await exactAlarmPermissionHandler.checkPermission();
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
    await notificationPermissionHandler.openAppSettings();
  }
}
