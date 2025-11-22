// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The registrar for NotificationServices used for initiation or event handle

import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/notification/notification_service.dart';

/// A registrar that keeps track of all registered [NotificationService]
/// instances and helps initializing or managing them as a group.
///
/// This class is implemented as a singleton; use the default constructor
/// `NotificationServiceRegistrar()` to obtain the shared instance.
class NotificationServiceRegistrar {
  // Singleton Mode
  static final NotificationServiceRegistrar _instance =
      NotificationServiceRegistrar._internal();
  factory NotificationServiceRegistrar() => _instance;
  NotificationServiceRegistrar._internal() {
    _registerDefaultServices();
  }

  final List<NotificationService> _notificationServices = [];

  /// The function for registering new NotificationServices
  void register(NotificationService notificationService) {
    if (!_notificationServices.contains(notificationService)) {
      _notificationServices.add(notificationService);
    }
    log.info("[NotificationRegistrar][register] Register a NotificationService <${notificationService.runtimeType}>");
  }

  /// The function for unregistering NotificationServices
  /// 
  /// That [return] is [false] means there is no NotificationService you want to unregister.
  /// That [return] is [true] means unregister successfully.
  bool unregister(NotificationService notificationService) {
    final isSuccess = _notificationServices.remove(notificationService);
    if (isSuccess) {
      log.info("[NotificationRegistrar][unregister] Unregister a NotificationService <${notificationService.runtimeType}> successfully");
    } else {
      log.warning("[NotificationRegistrar][unregister] Fail to unregister a NotificationService <${notificationService.runtimeType}>");
    }
    return isSuccess;
  }

  /// Default Services in XDYou.
  /// 
  /// If you add a new Service in XDYou, plz register it here.
  void _registerDefaultServices() {
    register(CourseReminderService());
    log.info("[NotificationRegistrar][_registerDefaultServices] Register default NotificationServices successfully");
  }

  /// Initialize all registered notification services.
  ///
  /// This method awaits each service's `initialize` method in sequence and
  /// returns `true` when all services have been initialized successfully.
  /// If any service throws during initialization, the initialization process
  /// is aborted and a [NotificationRegistrarInitiationException] is thrown
  /// wrapping the original error.
  Future<bool> initializeAllServices() async {
    try {
      await Future.wait(
        _notificationServices
            .where((service) => !service.isInitialized)
            .map((service) => service.initialize()),
      );
      log.info("[NotificationRegistrar][initializeAllServices] Initialize all the default NotificationService successfully");
    } catch (e) {
      log.error("[NotificationRegistrar][initializeAllServices] Fail to initialize all the default NotificationService");
      throw NotificationRegistrarInitiationException(e);
    }
    return true;
  }

  /// Returns an unmodifiable view of all registered services.
  ///
  /// This prevents external callers from mutating the internal list.
  List<NotificationService> getAllServices() {
    return List<NotificationService>.unmodifiable(_notificationServices);
  }
}

/// Thrown when one of the registered notification services fails to
/// initialize during `NotificationServiceRegistrar.initializeAllServices()`.
///
/// The original error is available via the [message] field.
class NotificationRegistrarInitiationException implements Exception {
  /// The underlying error or message that caused the initiation to fail.
  final dynamic message;

  NotificationRegistrarInitiationException([this.message]);

  @override
  String toString() {
    final Object? message = this.message;
    if (message == null) return 'NotificationRegistrarInitiationException';
    return 'NotificationRegistrarInitiationException: $message';
  }
}
