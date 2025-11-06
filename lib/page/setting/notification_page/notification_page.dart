// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification settings page

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/notification/course_reminder.dart';
import 'package:watermeter/repository/notification/notification_base.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationBase _notificationBase = NotificationBase();
  final CourseReminder _courseMinder = CourseReminder();

  bool _isEnabled = false;
  bool _hasNotificationPermission = false;
  bool _hasDndPermission = false;
  NotificationMode _mode = NotificationMode.normal;
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
      await _notificationBase.initialize();
      await _courseMinder.initialize();

      // Load settings
      _isEnabled = preference.prefs.getBool('notification_enabled') ?? false;
      _minutesBefore =
          preference.prefs.getInt('notification_minutes_before') ?? 5;
      _daysToSchedule =
          preference.prefs.getInt('notification_days_to_schedule') ?? 7;

      String modeStr =
          preference.prefs.getString('notification_mode') ?? 'normal';
      _mode = modeStr == 'enhanced'
          ? NotificationMode.enhanced
          : NotificationMode.normal;

      // If the platform is not Android, switch to normal mode
      if (!Platform.isAndroid && _mode == NotificationMode.enhanced) {
        _mode = NotificationMode.normal;
        await preference.prefs.setString('notification_mode', 'normal');
      }

      // Check permission
      _hasNotificationPermission = await _notificationBase
          .checkNotificationPermission();
      if (Platform.isAndroid) {
        _hasDndPermission = await _notificationBase.checkDndPermission();
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

  Future<void> _requestNotificationPermission() async {
    final granted = await _notificationBase.requestNotificationPermission();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = granted;
      });

      if (granted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.permission_granted_msg',
          ),
        );
        // Guide users to enable relevant Settings
        _showNotificationSettingsGuide();
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

  Future<void> _requestDndPermission() async {
    if (!Platform.isAndroid) return;

    final granted = await _notificationBase.requestDndPermission();
    if (mounted) {
      setState(() {
        _hasDndPermission = granted;
      });

      if (granted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.dnd_permission_granted_msg',
          ),
        );
      } else {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            'setting.notification_page.dnd_permission_denied_msg',
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
        content: Text(
          FlutterI18n.translate(
            context,
            'setting.notification_page.settings_guide_content',
          ),
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
              _notificationBase.openNotificationSettings();
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
        await _requestNotificationPermission();
        return;
      }

      // If it is in enhanced mode and there is no DnD permission, request permission
      if (_mode == NotificationMode.enhanced &&
          Platform.isAndroid &&
          !_hasDndPermission) {
        await _requestDndPermission();
      }

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
          mode: _mode,
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

  Future<void> _changeMode(NotificationMode? mode) async {
    if (mode == null || mode == _mode) return;

    // If it is not an Android platform, switching to the enhanced mode is not allowed
    if (!Platform.isAndroid && mode == NotificationMode.enhanced) {
      return;
    }

    // If you switch to enhanced mode and do not have DnD permissions, request permissions
    if (mode == NotificationMode.enhanced &&
        Platform.isAndroid &&
        !_hasDndPermission) {
      await _requestDndPermission();
      // Do not switch modes if no permission is obtained
      if (!_hasDndPermission) {
        return;
      }
    }

    setState(() {
      _mode = mode;
    });

    await preference.prefs.setString('notification_mode', mode.name);

    // If the notification has been enabled, reschedule
    if (_isEnabled) {
      await _rescheduleNotifications();
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
        mode: _mode,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                const SizedBox(height: 16),

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
                                onPressed: _requestNotificationPermission,
                                child: Text(
                                  FlutterI18n.translate(
                                    context,
                                    'setting.notification_page.request_permission',
                                  ),
                                ),
                              ),
                      ),
                      if (Platform.isAndroid) ...[
                        const Divider(),
                        ListTile(
                          title: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.dnd_permission',
                            ),
                          ),
                          subtitle: Text(
                            _hasDndPermission
                                ? FlutterI18n.translate(
                                    context,
                                    'setting.notification_page.dnd_permission_granted',
                                  )
                                : FlutterI18n.translate(
                                    context,
                                    'setting.notification_page.dnd_permission_denied',
                                  ),
                          ),
                          trailing: _hasDndPermission
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : TextButton(
                                  onPressed: _requestDndPermission,
                                  child: Text(
                                    FlutterI18n.translate(
                                      context,
                                      'setting.notification_page.request_permission',
                                    ),
                                  ),
                                ),
                        ),
                      ],
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
                        onTap: () =>
                            _notificationBase.openNotificationSettings(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notification mode
                ReXCard(
                  title: _buildListSubtitle(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.mode_section',
                    ),
                  ),
                  remaining: const [],
                  bottomRow: RadioGroup<NotificationMode>(
                    groupValue: _mode,
                    onChanged: _changeMode,
                    child: Column(
                      children: [
                        RadioListTile<NotificationMode>(
                          title: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.normal_mode',
                            ),
                          ),
                          subtitle: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.normal_mode_hint',
                            ),
                          ),
                          value: NotificationMode.normal,
                        ),
                        const Divider(),
                        RadioListTile<NotificationMode>(
                          title: Text(
                            FlutterI18n.translate(
                              context,
                              'setting.notification_page.enhanced_mode',
                            ),
                            style: Platform.isAndroid
                                ? null
                                : TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.38),
                                  ),
                          ),
                          subtitle: Text(
                            Platform.isAndroid
                                ? FlutterI18n.translate(
                                    context,
                                    'setting.notification_page.enhanced_mode_hint_android',
                                  )
                                : FlutterI18n.translate(
                                    context,
                                    'setting.notification_page.enhanced_mode_hint_ios',
                                  ),
                            style: Platform.isAndroid
                                ? null
                                : TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.38),
                                  ),
                          ),
                          value: NotificationMode.enhanced,
                          enabled: Platform.isAndroid,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                // Hinter
                ReXCard(
                  title: _buildListSubtitle(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.instruction_section',
                    ),
                  ),
                  remaining: const [],
                  bottomRow: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FlutterI18n.translate(
                            context,
                            'setting.notification_page.instruction_1',
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FlutterI18n.translate(
                            context,
                            'setting.notification_page.instruction_2',
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FlutterI18n.translate(
                            context,
                            'setting.notification_page.instruction_3',
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FlutterI18n.translate(
                            context,
                            'setting.notification_page.instruction_4',
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
