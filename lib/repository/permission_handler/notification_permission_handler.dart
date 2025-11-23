// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Notification Permission Handler

import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:watermeter/repository/logger.dart' show log;
import 'package:watermeter/repository/permission_handler/permission_handler_base.dart';

/// Notification Permission Handler
/// 
/// This class handles the permission requests for managing notifications on Android devices.
/// You can use this to check, request, and manage notification permissions by injecting the
/// [NotificationPermissionHandler] as a dependency (parameter).
class NotificationPermissionHandler implements PermissionHandlerBase {
  /// Request notification permission.
  @override
  Future<bool> requestPermission() async {
    try {
      final status = await perm.Permission.notification.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to request notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  /// Check notification permission.
  Future<bool> checkPermission() async {
    try {
      return await perm.Permission.notification.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to check notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  /// Open app settings.
  /// 
  /// returns [true] if the app settings were opened successfully, otherwise [false].
  Future<bool> openAppSettings() async {
    return await perm.openAppSettings();
  }
}