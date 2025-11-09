// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Exact Alarm Permission Handler

import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:watermeter/repository/logger.dart' show log;
import 'package:watermeter/repository/permission_handler/permission_handler_base.dart';

/// Exact Alarm Permission Handler
/// 
/// This class handles the permission requests for scheduling exact alarms on Android devices.
/// You can use this to check, request, and manage exact alarm permissions by injecting the
/// [ExactAlarmPermissionHandler] as a dependency (parameter).
class ExactAlarmPermissionHandler implements PermissionHandlerBase {
  @override
  /// Request schedule exact alarm permission (Android only).
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms

    try {
      final status = await perm.Permission.scheduleExactAlarm.request();
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

  @override
  /// Check exact alarm permission (Android only).
  Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return true; // Not applicable on other platforms

    try {
      return await perm.Permission.scheduleExactAlarm.isGranted;
    } catch (e, stackTrace) {
      log.error(
        'Failed to check exact alarm permission',
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