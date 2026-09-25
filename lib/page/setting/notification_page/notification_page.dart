// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification settings page

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/notification/course_live_update_service.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

const kDefaultMinutesBeforeOptions = [5, 10, 15, 20, 30];
const kDefaultDaysToScheduleOptions = [3, 7, 14, 30];

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _courseReminder = CourseReminderService();

  bool _isEnabled = false;
  bool _hasNotificationPermission = false;
  bool _hasExactAlarmPermission = false;
  int _minutesBefore = 5;
  int _daysToSchedule = 7;
  bool _isLoading = true;
  int _pendingCount = 0;
  bool _enableExperimentNotifications = false;

  /// 岛（实时更新 / 灵动岛）是另一件事：提醒响一下就走了，它是上课期间一直挂着的
  /// 状态，所以有自己的开关和提前量。
  bool _islandEnabled = true;
  bool _islandSupported = false;
  int _islandLead = kDefaultLiveUpdateLeadMinutes;

  @override
  void initState() {
    super.initState();
    // Load settings from service
    _isEnabled = _courseReminder.isEnabled;
    _enableExperimentNotifications =
        _courseReminder.enableExperimentNotifications;
    _minutesBefore = _courseReminder.minutesBefore;
    _daysToSchedule = _courseReminder.daysToSchedule;

    if (kDefaultMinutesBeforeOptions.contains(_minutesBefore) == false) {
      _minutesBefore = 5;
    }

    if (kDefaultDaysToScheduleOptions.contains(_daysToSchedule) == false) {
      _daysToSchedule = 7;
    }

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initiation
      await _courseReminder.initialize();

      // Check permission
      _hasNotificationPermission = await _courseReminder
          .checkNotificationPermission();
      _hasExactAlarmPermission = await _courseReminder
          .checkExactAlarmPermission();

      if (!_hasExactAlarmPermission || !_hasNotificationPermission) {
        _courseReminder.setEnabled(false);
        setState(() {
          _isEnabled = false;
        });
      }

      // Get the number of notifications to be sent
      _pendingCount = await _courseReminder
          .getPendingCourseNotificationsCount();

      await _loadIslandSettings();
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

  /// 岛的状态（有没有、开着没、提前多少）都在平台侧，这里读一次做镜像。
  Future<void> _loadIslandSettings() async {
    final service = CourseLiveUpdateService.instance;
    final supported = await service.isSupported();
    if (!supported) {
      if (mounted) {
        setState(() => _islandSupported = false);
      }
      return;
    }

    final diagnostics = await service.diagnostics();
    final lead =
        (diagnostics["leadMinutes"] as int?) ?? kDefaultLiveUpdateLeadMinutes;

    if (mounted) {
      setState(() {
        _islandSupported = true;
        _islandEnabled = diagnostics["enabled"] as bool? ?? true;
        _islandLead = kLiveUpdateLeadMinuteOptions.contains(lead)
            ? lead
            : kDefaultLiveUpdateLeadMinutes;
      });
    }
  }

  /// 岛的总开关。打开时顺手把接下来的课排上，关掉时把岛上那条也收走。
  Future<void> _toggleIsland(bool value) async {
    setState(() {
      _islandEnabled = value;
      _isLoading = true;
    });

    try {
      final service = CourseLiveUpdateService.instance;
      await service.setEnabled(value);
      if (value) {
        await service.scheduleFromCourseData(daysToSchedule: _daysToSchedule);
      } else {
        await service.cancelAll();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 提前多久上岛。和「提前提醒时间」是两个设置，各管各的。
  Future<void> _changeIslandLead(int value) async {
    setState(() {
      _islandLead = value;
      _isLoading = true;
    });

    try {
      final service = CourseLiveUpdateService.instance;
      await service.setLeadMinutes(value);
      if (_islandEnabled) {
        await service.scheduleFromCourseData(daysToSchedule: _daysToSchedule);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermission() async {
    final notificationPermissionGranted = await _courseReminder
        .requestNotificationPermission();
    final exactAlarmGranted = await _courseReminder
        .requestExactAlarmPermission();
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
    if (value) {
      if (!_hasNotificationPermission) {
        await _requestPermission();
      }

      _showNotificationSettingsGuide();

      // Arrange notification
      setState(() {
        _isLoading = true;
      });

      try {
        if (!_courseReminder.hasSchedulableReminderSourceData) {
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

        // Use service method to enable notifications
        await _courseReminder.setEnabled(true);

        _pendingCount = await _courseReminder
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
      // Use service method to disable notifications
      await _courseReminder.setEnabled(false);

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

  /// Helper method to update pending count and show success toast
  Future<void> _updatePendingCountAndNotify() async {
    _pendingCount = await _courseReminder.getPendingCourseNotificationsCount();
    if (mounted) {
      setState(() {});
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          'setting.notification_page.reschedule_success',
          translationParams: {'count': _pendingCount.toString()},
        ),
      );
    }
  }

  Future<void> _changeMinutesBefore(int value) async {
    setState(() {
      _minutesBefore = value;
      _isLoading = true;
    });

    try {
      // Use service setter - it will automatically update notifications if enabled
      await _courseReminder.setMinutesBefore(value);

      // Update pending count and notify if enabled
      if (_isEnabled) {
        await _updatePendingCountAndNotify();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeDaysToSchedule(int value) async {
    setState(() {
      _daysToSchedule = value;
      _isLoading = true;
    });

    try {
      // Use service setter - it will automatically update notifications if enabled
      await _courseReminder.setDaysToSchedule(value);

      // Update pending count and notify if enabled
      if (_isEnabled) {
        await _updatePendingCountAndNotify();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rescheduleNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _courseReminder.cancelAllCourseNotifications();
      await _courseReminder.scheduleNotificationsFromCourseData(
        daysToSchedule: _daysToSchedule,
        minutesBefore: _minutesBefore,
      );

      _pendingCount = await _courseReminder
          .getPendingCourseNotificationsCount();

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

  Future<void> _deleteAllSchedules() async {
    await _courseReminder.cancelAllCourseNotifications();

    if (mounted) {
      setState(() {
        _pendingCount = 0;
      });
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          'setting.notification_page.delete_all_success',
        ),
      );
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
        padding: const EdgeInsets.all(16).withSafeBottom(context),
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
                if (_isEnabled)
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
                if (_isEnabled && _pendingCount > 0)
                  ListTile(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.delete_all_schedule',
                      ),
                    ),
                    subtitle: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.delete_all_schedule_hint',
                      ),
                    ),
                    trailing: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: _deleteAllSchedules,
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
                      'setting.notification_page.experiment_reminder',
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      'setting.notification_page.experiment_reminder_hint',
                    ),
                  ),
                  trailing: Switch(
                    value: _enableExperimentNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _enableExperimentNotifications = value;
                        _isLoading = true;
                      });

                      try {
                        // Use service setter - it will automatically update notifications if enabled
                        await _courseReminder.setEnableExperimentNotifications(
                          value,
                        );

                        // Update pending count and notify if enabled
                        if (_isEnabled) {
                          await _updatePendingCountAndNotify();
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
                const Divider(),
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
                    items: kDefaultMinutesBeforeOptions
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
                    items: kDefaultDaysToScheduleOptions
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

          // The island of the ongoing class. It is not a reminder, so it is not
          // part of the card above.
          if (Platform.isAndroid && _islandSupported)
            ReXCard(
              title: _buildListSubtitle(
                FlutterI18n.translate(
                  context,
                  'setting.notification_page.live_update_section',
                ),
              ),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.live_update_enabled',
                      ),
                    ),
                    subtitle: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.live_update_enabled_hint',
                      ),
                    ),
                    trailing: Switch(
                      value: _islandEnabled,
                      onChanged: _toggleIsland,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.live_update_lead',
                      ),
                    ),
                    subtitle: Text(
                      FlutterI18n.translate(
                        context,
                        'setting.notification_page.live_update_lead_hint',
                      ),
                    ),
                    trailing: DropdownButton<int>(
                      value: _islandLead,
                      items: kLiveUpdateLeadMinuteOptions
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value == 0
                                    ? FlutterI18n.translate(
                                        context,
                                        'setting.notification_page.live_update_lead_at_class',
                                      )
                                    : '$value ${FlutterI18n.translate(context, "setting.notification_page.minutes_unit")}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _islandEnabled
                          ? (value) {
                              if (value != null) {
                                _changeIslandLead(value);
                              }
                            }
                          : null,
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
                  onTap: () => _courseReminder.openNotificationSettings(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
