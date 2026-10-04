// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification settings page.

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_function_settings.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_permission_settings.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_reminder_settings.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';

const kDefaultMinutesBeforeOptions = [5, 10, 15, 20, 30];
const kDefaultDaysToScheduleOptions = [3, 7, 14, 30];

class NotificationSection extends StatefulWidget {
  const NotificationSection({super.key});

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  final _courseReminder = CourseReminderService();

  bool _isEnabled = false;
  bool _hasNotificationPermission = false;
  bool _hasExactAlarmPermission = false;
  int _minutesBefore = 5;
  int _daysToSchedule = 7;
  bool _isLoading = true;
  int _pendingCount = 0;
  bool _enableExperimentNotifications = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = _courseReminder.isEnabled;
    _enableExperimentNotifications =
        _courseReminder.enableExperimentNotifications;
    _minutesBefore = _courseReminder.minutesBefore;
    _daysToSchedule = _courseReminder.daysToSchedule;

    if (!kDefaultMinutesBeforeOptions.contains(_minutesBefore)) {
      _minutesBefore = kDefaultMinutesBeforeOptions.first;
    }
    if (!kDefaultDaysToScheduleOptions.contains(_daysToSchedule)) {
      _daysToSchedule = kDefaultDaysToScheduleOptions[1];
    }

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      await _courseReminder.initialize();
      _hasNotificationPermission = await _courseReminder
          .checkNotificationPermission();
      _hasExactAlarmPermission = await _courseReminder
          .checkExactAlarmPermission();

      if (!_hasExactAlarmPermission || !_hasNotificationPermission) {
        await _courseReminder.setEnabled(false);
        _isEnabled = false;
      }

      _pendingCount = await _courseReminder
          .getPendingCourseNotificationsCount();
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.load_failed',
            translationParams: {'error': e.toString()},
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Prevent overlapping mutations and keep all settings controls locked
  /// until the operation has completed.
  Future<void> _runWhileLoading(Future<void> Function() operation) async {
    if (_isLoading || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermission() async {
    if (_isLoading) return;
    await _runWhileLoading(_requestPermissions);
  }

  Future<void> _requestPermissions() async {
    final notificationPermissionGranted = await _courseReminder
        .requestNotificationPermission();
    final exactAlarmGranted = await _courseReminder
        .requestExactAlarmPermission();

    if (!mounted) return;
    setState(() {
      _hasNotificationPermission = notificationPermissionGranted;
      _hasExactAlarmPermission = exactAlarmGranted;
    });

    showToast(
      context: context,
      msg: FlutterI18n.translate(
        context,
        notificationPermissionGranted && exactAlarmGranted
            ? 'setting.notification_page.permission_granted_msg'
            : 'setting.notification_page.permission_denied_msg',
      ),
    );
  }

  void _showNotificationSettingsGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(
            context,
            'setting.notification_page.settings_guide_title',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.settings_guide_content_1',
              ),
            ),
            const Divider(),
            Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.settings_guide_content_2',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.got_it',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _courseReminder.openNotificationSettings();
            },
            child: Text(
              FlutterI18n.translate(
                context,
                'setting.notification_page.open_settings',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotification(bool value) async {
    if (_isLoading) return;
    await _runWhileLoading(() async {
      if (!value) {
        await _courseReminder.setEnabled(false);
        if (!mounted) return;
        setState(() {
          _isEnabled = false;
          _pendingCount = 0;
        });
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.cancel_all_success',
          ),
        );
        return;
      }

      if (!_hasNotificationPermission) await _requestPermissions();
      if (!mounted) return;

      // Keep the information guide available even while controls are locked.
      _showNotificationSettingsGuide();

      if (!_courseReminder.hasSchedulableReminderSourceData) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.no_classtable_data',
          ),
        );
        return;
      }

      try {
        await _courseReminder.setEnabled(true);
        final pendingCount = await _courseReminder
            .getPendingCourseNotificationsCount();
        if (!mounted) return;
        setState(() {
          _isEnabled = true;
          _pendingCount = pendingCount;
        });
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.schedule_success',
            translationParams: {'count': pendingCount.toString()},
          ),
        );
      } catch (e) {
        if (mounted) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              'setting.notification_page.schedule_failed',
              translationParams: {'error': e.toString()},
            ),
          );
        }
      }
    });
  }

  Future<void> _updatePendingCountAndNotify() async {
    final pendingCount = await _courseReminder
        .getPendingCourseNotificationsCount();
    if (!mounted) return;
    setState(() => _pendingCount = pendingCount);
    showToast(
      context: context,
      msg: FlutterI18n.translate(
        context,
        'setting.notification_page.reschedule_success',
        translationParams: {'count': pendingCount.toString()},
      ),
    );
  }

  Future<void> _changeMinutesBefore(int value) async {
    if (_isLoading) return;
    await _runWhileLoading(() async {
      setState(() => _minutesBefore = value);
      await _courseReminder.setMinutesBefore(value);
      if (_isEnabled) await _updatePendingCountAndNotify();
    });
  }

  Future<void> _changeDaysToSchedule(int value) async {
    if (_isLoading) return;
    await _runWhileLoading(() async {
      setState(() => _daysToSchedule = value);
      await _courseReminder.setDaysToSchedule(value);
      if (_isEnabled) await _updatePendingCountAndNotify();
    });
  }

  Future<void> _rescheduleNotifications() async {
    if (_isLoading) return;
    await _runWhileLoading(() async {
      try {
        await _courseReminder.cancelAllCourseNotifications();
        await _courseReminder.scheduleNotificationsFromCourseData(
          daysToSchedule: _daysToSchedule,
          minutesBefore: _minutesBefore,
        );
        final pendingCount = await _courseReminder
            .getPendingCourseNotificationsCount();
        if (!mounted) return;
        setState(() => _pendingCount = pendingCount);
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.reschedule_success',
            translationParams: {'count': pendingCount.toString()},
          ),
        );
      } catch (e) {
        if (mounted) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              'setting.notification_page.reschedule_failed',
              translationParams: {'error': e.toString()},
            ),
          );
        }
      }
    });
  }

  Future<void> _deleteAllSchedules() async {
    if (_isLoading) return;
    await _runWhileLoading(() async {
      await _courseReminder.cancelAllCourseNotifications();
      if (!mounted) return;
      setState(() => _pendingCount = 0);
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          'setting.notification_page.delete_all_success',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        NotificationFunctionSettings(
          isLoading: _isLoading,
          isEnabled: _isEnabled,
          pendingCount: _pendingCount,
          onEnabledChanged: _toggleNotification,
          onShowInstructions: _showNotificationSettingsGuide,
          onUpdateSchedule: _rescheduleNotifications,
          onDeleteSchedules: _deleteAllSchedules,
        ),
        NotificationReminderSettings(
          isLoading: _isLoading,
          experimentNotificationsEnabled: _enableExperimentNotifications,
          minutesBefore: _minutesBefore,
          daysToSchedule: _daysToSchedule,
          onExperimentNotificationsChanged: (value) async {
            if (_isLoading) return;
            await _runWhileLoading(() async {
              setState(() => _enableExperimentNotifications = value);
              await _courseReminder.setEnableExperimentNotifications(value);
              if (_isEnabled) await _updatePendingCountAndNotify();
            });
          },
          onMinutesBeforeChanged: _changeMinutesBefore,
          onDaysToScheduleChanged: _changeDaysToSchedule,
          minutesBeforeOptions: kDefaultMinutesBeforeOptions,
          daysToScheduleOptions: kDefaultDaysToScheduleOptions,
        ),
        NotificationPermissionSettings(
          isLoading: _isLoading,
          hasNotificationPermission: _hasNotificationPermission,
          hasExactAlarmPermission: _hasExactAlarmPermission,
          onRequestPermission: _requestPermission,
          onOpenSystemSettings: _courseReminder.openNotificationSettings,
        ),
      ],
    );
  }
}
