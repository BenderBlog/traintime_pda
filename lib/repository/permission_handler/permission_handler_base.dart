// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Permission Handler basic interface class

/// Permission Handler basic interface class
abstract class PermissionHandlerBase {
  /// Check permission status
  Future<bool> checkPermission();

  /// Request permission
  Future<bool> requestPermission();

  /// Open app permission settings page
  Future<void> openAppSettings();
}