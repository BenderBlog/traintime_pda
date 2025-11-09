// This file is used to register all the children class of NotificationService in the project.
// It ensures that they can handle notifications click events properly.

import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/notification/notification_service.dart';

/// List of all registered notification services.
/// Each service in this list will be able to initialize and handle notification tap events.
final registeredNotificationServices = <NotificationService>[CourseReminderService()];
