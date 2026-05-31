// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/schedule_snapshot.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';
import 'package:watermeter/routing/routes.dart';

ScheduleSnapshot currentScheduleSnapshot() => ScheduleSnapshot(
  classTableData: ClassTableController.i.classTableComputedSignal.value,
  subjects: ExamController.i.subjects.value,
  experiments: [
    ...PhysicsExperimentController.i.physicsExperiments.value,
    ...OtherExperimentController.i.otherExperiments.value,
  ],
  getCurrentWeek: ClassTableController.i.getCurrentWeek,
);

void configureCourseReminderApplicationBindings() {
  CourseReminderService().configureApplicationBindings(
    scheduleSnapshotProvider: currentScheduleSnapshot,
    onCourseReminderTap: _openClassTableFromCourseReminder,
  );
}

void _openClassTableFromCourseReminder(NotificationResponse response) {
  final navigator = preference.debuggerKey.currentState;
  if (navigator == null) {
    log.warning(
      '[CourseReminderApplication] Navigator not available for notification tap',
    );
    return;
  }

  navigator.push(Routes.resolveRoute(Routes.classTable));
  log.info('[CourseReminderApplication] Navigated to class table');
}

Future<void> maybeAutoSyncSystemCalendar() async {
  try {
    final service = SystemCalendarSyncService(
      snapshot: currentScheduleSnapshot(),
    );
    if (!service.canAutoSync) {
      return;
    }

    await service.syncSystemCalendar(
      requestPermissionsIfNeeded: false,
      onlyIfCalendarExists: true,
    );
  } catch (e, s) {
    log.handle(e, s);
  }
}
