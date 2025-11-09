// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification settings page

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/notification_page/notification_test_widget.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _courseMinder = CourseReminderService();

  bool _isEnabled = false;
  bool _hasNotificationPermission = false;
  bool _hasExactAlarmPermission = false;
  int _minutesBefore = 5;
  int _daysToSchedule = 7;
  bool _isLoading = true;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initiation
      await _courseMinder.initialize();

      // Load settings
      _isEnabled = preference.prefs.getBool('notification_enabled') ?? false;
      _minutesBefore =
          preference.prefs.getInt('notification_minutes_before') ?? 5;
      _daysToSchedule =
          preference.prefs.getInt('notification_days_to_schedule') ?? 7;

      // Check permission
      _hasNotificationPermission = await _courseMinder
          .checkNotificationPermission();
      _hasExactAlarmPermission = await _courseMinder
          .checkExactAlarmPermission();
      if (Platform.isAndroid) {
      }

      // Get the number of notifications to be sent
      _pendingCount = await _courseMinder.getPendingCourseNotificationsCount();
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    final notificationPermissionGranted = await _courseMinder.requestNotificationPermission();
    final exactAlarmGranted = await _courseMinder.requestExactAlarmPermission();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = notificationPermissionGranted;
        _hasExactAlarmPermission = exactAlarmGranted;
      });

      if (notificationPermissionGranted && exactAlarmGranted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.permission_granted_msg',
          ),
        );
      } else {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.permission_denied_msg',
          ),
        );
      }
    }
  }

  void _showNotificationSettingsGuide() {
    showDialog(
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
            Divider(),
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
              _courseMinder.openNotificationSettings();
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
    if (value) {
      if (!_hasNotificationPermission) {
        await _requestPermission();
        return;
      }

      _showNotificationSettingsGuide();

      // Arrange notification
      setState(() {
        _isLoading = true;
      });

      try {
        // Check whether class table data is available
        final ClassTableController controller =
            Get.find<ClassTableController>();
        if (controller.classTableData.termStartDay.isEmpty) {
          if (mounted) {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                'setting.notification_page.no_classtable_data',
              ),
            );
          }
          return;
        }

        await _courseMinder.scheduleNotificationsFromCourseData(
          daysToSchedule: _daysToSchedule,
          minutesBefore: _minutesBefore,
        );

        await preference.prefs.setBool('notification_enabled', true);
        _pendingCount = await _courseMinder
            .getPendingCourseNotificationsCount();

        if (mounted) {
          setState(() {
            _isEnabled = true;
          });
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              'setting.notification_page.schedule_success',
              translationParams: {'count': _pendingCount.toString()},
            ),
          );
        }
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      await _courseMinder.cancelAllCourseNotifications();
      await preference.prefs.setBool('notification_enabled', false);

      if (mounted) {
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
      }
    }
  }

  Future<void> _changeMinutesBefore(int value) async {
    setState(() {
      _minutesBefore = value;
    });

    await preference.prefs.setInt('notification_minutes_before', value);

    // If the notification has been enabled, reschedule
    if (_isEnabled) {
      await _rescheduleNotifications();
    }
  }

  Future<void> _changeDaysToSchedule(int value) async {
    setState(() {
      _daysToSchedule = value;
    });

    await preference.prefs.setInt('notification_days_to_schedule', value);

    // If the notification has been enabled, reschedule
    if (_isEnabled) {
      await _rescheduleNotifications();
    }
  }

  Future<void> _rescheduleNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _courseMinder.cancelAllCourseNotifications();
      await _courseMinder.scheduleNotificationsFromCourseData(
        daysToSchedule: _daysToSchedule,
        minutesBefore: _minutesBefore,
      );

      _pendingCount = await _courseMinder.getPendingCourseNotificationsCount();

      if (mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.reschedule_success',
            translationParams: {'count': _pendingCount.toString()},
          ),
        );
      }
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildListSubtitle(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ).padding(bottom: 8).center();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, 'setting.notification_page.title'),
        ),
        actions: [
          if (_isLoading)
            Container(
              margin: EdgeInsets.only(right: 16),
              width: 24,
              height: 24,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Function switch
          ReXCard(
            title: _buildListSubtitle(
              FlutterI18n.translate(
                context,
                'setting.notification_page.function_section',
              ),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.enable_notification',
                    ),
                  ),
                  subtitle: Text(
                    _isEnabled
                        ? FlutterI18n.translate(
                            context,
                            'setting.notification_page.notification_scheduled',
                            translationParams: {
                              'count': _pendingCount.toString(),
                            },
                          )
                        : FlutterI18n.translate(
                            context,
                            'setting.notification_page.notification_disabled_hint',
                          ),
                  ),
                  trailing: Switch(
                    value: _isEnabled,
                    onChanged: _toggleNotification,
                  ),
                ),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.view_the_instructions',
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.view_the_instructions_hint',
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => _showNotificationSettingsGuide(),
                ),
                if (_isEnabled && _pendingCount > 0)
                  ListTile(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.update_schedule',
                      ),
                    ),
                    subtitle: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.update_schedule_hint',
                      ),
                    ),
                    trailing: const Icon(Icons.refresh),
                    onTap: _rescheduleNotifications,
                  ),
              ],
            ),
          ),

          // Reminder setting
          ReXCard(
            title: _buildListSubtitle(
              FlutterI18n.translate(
                context,
                'setting.notification_page.reminder_section',
              ),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.minutes_before',
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.minutes_before_hint',
                    ),
                  ),
                  trailing: DropdownButton<int>(
                    value: _minutesBefore,
                    items: [5, 10, 15, 20, 30]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              '$value ${FlutterI18n.translate(context, "setting.notification_page.minutes_unit")}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _changeMinutesBefore(value);
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.days_to_schedule',
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.days_to_schedule_hint',
                    ),
                  ),
                  trailing: DropdownButton<int>(
                    value: _daysToSchedule,
                    items: [3, 7, 14, 30]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              '$value ${FlutterI18n.translate(context, "setting.notification_page.days_unit")}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _changeDaysToSchedule(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Permission state
          ReXCard(
            title: _buildListSubtitle(
              FlutterI18n.translate(
                context,
                'setting.notification_page.permission_section',
              ),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.notification_permission',
                    ),
                  ),
                  subtitle: Text(
                    _hasNotificationPermission
                        ? FlutterI18n.translate(
                            context,
                            'setting.notification_page.permission_granted',
                          )
                        : FlutterI18n.translate(
                            context,
                            'setting.notification_page.permission_denied',
                          ),
                  ),
                  trailing: _hasNotificationPermission
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : TextButton(
                          onPressed: _requestPermission,
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.request_permission',
                            ),
                          ),
                        ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.exact_alarm_permission',
                    ),
                  ),
                  subtitle: Text(
                    _hasExactAlarmPermission
                        ? FlutterI18n.translate(
                            context,
                            'setting.notification_page.permission_granted',
                          )
                        : FlutterI18n.translate(
                            context,
                            'setting.notification_page.permission_denied',
                          ),
                  ),
                  trailing: _hasExactAlarmPermission
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : TextButton(
                          onPressed: _requestPermission,
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.request_permission',
                            ),
                          ),
                        ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.system_settings',
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.system_settings_hint',
                    ),
                  ),
                  trailing: const Icon(Icons.settings),
                  onTap: () => _courseMinder.openNotificationSettings(),
                ),
              ],
            ),
          ),
          if (kDebugMode) const NotificationTestWidget(),
        ],
      ),
    );
  }
}
