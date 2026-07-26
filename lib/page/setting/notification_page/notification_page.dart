// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Course reminder notification settings page

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/generated/l10n.dart';

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
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          msg: I18n.of(context)!.settingNotificationPageLoadFailed(e.toString()),
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
          msg: I18n.of(context)!.settingNotificationPagePermissionGrantedMsg,
        );
      } else {
        showToast(
          context: context,
          msg: I18n.of(context)!.settingNotificationPagePermissionDeniedMsg,
        );
      }
    }
  }

  void _showNotificationSettingsGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18n.of(context)!.settingNotificationPageSettingsGuideTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.of(context)!.settingNotificationPageSettingsGuideContent1,
            ),
            Divider(),
            Text(
              I18n.of(context)!.settingNotificationPageSettingsGuideContent2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              I18n.of(context)!.settingNotificationPageGotIt,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _courseReminder.openNotificationSettings();
            },
            child: Text(
              I18n.of(context)!.settingNotificationPageOpenSettings,
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
              msg: I18n.of(context)!.settingNotificationPageNoClasstableData,
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
            msg: I18n.of(context)!.settingNotificationPageScheduleSuccess(_pendingCount.toString()),
          );
        }
      } catch (e) {
        if (mounted) {
          showToast(
            context: context,
            msg: I18n.of(context)!.settingNotificationPageScheduleFailed(e.toString()),
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
          msg: I18n.of(context)!.settingNotificationPageCancelAllSuccess,
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
        msg: I18n.of(context)!.settingNotificationPageRescheduleSuccess(_pendingCount.toString()),
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
          msg: I18n.of(context)!.settingNotificationPageRescheduleSuccess(_pendingCount.toString()),
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          msg: I18n.of(context)!.settingNotificationPageRescheduleFailed(e.toString()),
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
        msg: I18n.of(context)!.settingNotificationPageDeleteAllSuccess,
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
          I18n.of(context)!.settingNotificationPageTitle,
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
              I18n.of(context)!.settingNotificationPageFunctionSection,
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageEnableNotification,
                  ),
                  subtitle: Text(
                    _isEnabled
                        ? I18n.of(context)!.settingNotificationPageNotificationScheduled(_pendingCount.toString())
                        : I18n.of(context)!.settingNotificationPageNotificationDisabledHint,
                  ),
                  trailing: Switch(
                    value: _isEnabled,
                    onChanged: _toggleNotification,
                  ),
                ),
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageViewTheInstructions,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingNotificationPageViewTheInstructionsHint,
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => _showNotificationSettingsGuide(),
                ),
                if (_isEnabled)
                  ListTile(
                    title: Text(
                      I18n.of(context)!.settingNotificationPageUpdateSchedule,
                    ),
                    subtitle: Text(
                      I18n.of(context)!.settingNotificationPageUpdateScheduleHint,
                    ),
                    trailing: const Icon(Icons.refresh),
                    onTap: _rescheduleNotifications,
                  ),
                if (_isEnabled && _pendingCount > 0)
                  ListTile(
                    title: Text(
                      I18n.of(context)!.settingNotificationPageDeleteAllSchedule,
                    ),
                    subtitle: Text(
                      I18n.of(context)!.settingNotificationPageDeleteAllScheduleHint,
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
              I18n.of(context)!.settingNotificationPageReminderSection,
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageExperimentReminder,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingNotificationPageExperimentReminderHint,
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
                    I18n.of(context)!.settingNotificationPageMinutesBefore,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingNotificationPageMinutesBeforeHint,
                  ),
                  trailing: DropdownButton<int>(
                    value: _minutesBefore,
                    items: kDefaultMinutesBeforeOptions
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              '$value ${I18n.of(context)!.settingNotificationPageMinutesUnit}',
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
                    I18n.of(context)!.settingNotificationPageDaysToSchedule,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingNotificationPageDaysToScheduleHint,
                  ),
                  trailing: DropdownButton<int>(
                    value: _daysToSchedule,
                    items: kDefaultDaysToScheduleOptions
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              '$value ${I18n.of(context)!.settingNotificationPageDaysUnit}',
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
              I18n.of(context)!.settingNotificationPagePermissionSection,
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageNotificationPermission,
                  ),
                  subtitle: Text(
                    _hasNotificationPermission
                        ? I18n.of(context)!.settingNotificationPagePermissionGranted
                        : I18n.of(context)!.settingNotificationPagePermissionDenied,
                  ),
                  trailing: _hasNotificationPermission
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : TextButton(
                          onPressed: _requestPermission,
                          child: Text(
                            I18n.of(context)!.settingNotificationPageRequestPermission,
                          ),
                        ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageExactAlarmPermission,
                  ),
                  subtitle: Text(
                    _hasExactAlarmPermission
                        ? I18n.of(context)!.settingNotificationPagePermissionGranted
                        : I18n.of(context)!.settingNotificationPagePermissionDenied,
                  ),
                  trailing: _hasExactAlarmPermission
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : TextButton(
                          onPressed: _requestPermission,
                          child: Text(
                            I18n.of(context)!.settingNotificationPageRequestPermission,
                          ),
                        ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    I18n.of(context)!.settingNotificationPageSystemSettings,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingNotificationPageSystemSettingsHint,
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
