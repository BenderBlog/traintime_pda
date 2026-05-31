// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:restart_app/restart_app.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/setting_actions_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/semester_switch_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/setting/notification_page/notification_debug_page.dart';
import 'package:watermeter/page/setting/notification_page/notification_page.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/themes/color_seed.dart';

Widget buildSettingSectionTitle(String text) => Text(
  text,
  style: const TextStyle(fontWeight: FontWeight.bold),
).padding(bottom: 8).center();

class SettingHeader extends StatelessWidget {
  const SettingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                ? "XDYou"
                : 'Traintime PDA',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\nWritten by BenderBlog Rodriguez and contributors',
          ),
        ],
      ),
    ).padding(horizontal: 8.0);
  }
}

class SettingAboutSection extends StatelessWidget {
  const SettingAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.about"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.about_this_program"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.version",
                translationParams: {
                  "version":
                      "${preference.packageInfo.version}+"
                      "${preference.packageInfo.buildNumber}",
                },
              ),
            ),
            onTap: () => context.pushReplacementNamed(Routes.about),
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.check_update")),
            subtitle: Watch((context) {
              final updateState =
                  UpdateNoticeController.i.updateMessageStateSignal.value;
              return Text(
                FlutterI18n.translate(
                  context,
                  "setting.latest_version",
                  translationParams: {
                    "latest":
                        updateState.value?.code ??
                        FlutterI18n.translate(context, "setting.waiting"),
                  },
                ),
              );
            }),
            onTap: () => _checkUpdate(context),
            trailing: const Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "setting.fetching_update"),
    );
    await UpdateNoticeController.i.reloadUpdateNoticeInfo();
    if (!context.mounted) return;
    if (UpdateNoticeController.i.updateMessageStateSignal.value.hasError) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.fetch_failed"),
      );
      return;
    }
    switch (UpdateNoticeController.i.isNewVersionAvaliableComputed.value) {
      case null:
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.current_testing"),
        );
      case true:
        await showDialog(
          context: context,
          builder: (context) => Watch(
            (context) => UpdateDialog(
              updateMessage: UpdateNoticeController
                  .i
                  .updateMessageStateSignal
                  .value
                  .value!,
            ),
          ),
        );
      case false:
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.current_stable"),
        );
    }
  }
}

class SettingUiSection extends StatelessWidget {
  final VoidCallback onChanged;

  const SettingUiSection({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightnessModeName = [
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.follow_setting",
      ),
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.day_mode",
      ),
      FlutterI18n.translate(
        context,
        "setting.change_brightness_dialog.night_mode",
      ),
    ];
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.ui_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.color_setting"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.change_color_dialog."
                "${ColorSeed.values[preference.getInt(preference.Preference.color)].label}",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangeColorDialog(),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.brightness_setting"),
            ),
            subtitle: Text(
              brightnessModeName[preference.getInt(
                preference.Preference.brightness,
              )],
            ),
            trailing: ToggleButtons(
              isSelected: List<bool>.generate(
                3,
                (index) =>
                    index ==
                    preference.getInt(preference.Preference.brightness),
              ),
              onPressed: (int value) async {
                await preference.setInt(
                  preference.Preference.brightness,
                  value,
                );
                ThemeController.i.updateTheme();
                onChanged();
              },
              children: const [
                Icon(Icons.phone_android_rounded),
                Icon(Icons.light_mode_rounded),
                Icon(Icons.dark_mode_rounded),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.simplify_timeline"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.simplify_timeline_description",
              ),
            ),
            trailing: Switch(
              value: preference.getBool(
                preference.Preference.simplifiedClassTimeline,
              ),
              onChanged: (bool value) async {
                await preference.setBool(
                  preference.Preference.simplifiedClassTimeline,
                  value,
                );
                ClassTableCard.reloadSettingsFromPref();
                onChanged();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.localization_dialog.title",
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                Localization.values
                    .firstWhere(
                      (value) =>
                          value.string ==
                          preference.getString(
                            preference.Preference.localization,
                          ),
                    )
                    .toShow,
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => const ChangeLanguageDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingAccountSection extends StatelessWidget {
  const SettingAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.account_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          if (!preference.getBool(preference.Preference.role)) ...[
            ListTile(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.sport_password_setting",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const SportPasswordDialog(),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.experiment_password_setting",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const ExperimentPasswordDialog(),
                );
              },
            ),
            const Divider(),
          ],
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.schoolnet_password_setting",
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.schoolnet_password_description",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const SchoolNetPasswordDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingNotificationSection extends StatelessWidget {
  const SettingNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SizedBox.shrink();
    }
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.notification_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.course_reminder_setting"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.course_reminder_description",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              context.push(const NotificationSettingsPage());
            },
          ),
        ],
      ),
    );
  }
}

class SettingClassTableSection extends StatelessWidget {
  final SettingActionsController actions;
  final VoidCallback onChanged;

  const SettingClassTableSection({
    super.key,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.classtable_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.background")),
            trailing: Switch(
              value: preference.getBool(preference.Preference.decorated),
              onChanged: (bool value) {
                if (value &&
                    !preference.getBool(preference.Preference.decoration)) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "setting.no_background",
                    ),
                  );
                  return;
                }
                preference.setBool(preference.Preference.decorated, value);
                onChanged();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.choose_background"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _chooseBackground(context),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.clear_user_class"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmClearUserClass(context),
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.class_refresh"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmRefreshClassData(context),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.class_swift")),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.class_swift_description",
                translationParams: {
                  "swift": preference
                      .getInt(preference.Preference.swift)
                      .toString(),
                },
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ChangeSwiftDialog(),
              ).then((value) => onChanged());
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.semester_change"),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.semester_change_description",
                translationParams: {
                  "semester": preference.getString(
                    preference.Preference.currentSemester,
                  ),
                },
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _changeSemester(context),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseBackground(BuildContext context) async {
    PlatformFile? result;
    try {
      result = await pickFile(type: FileType.image);
    } on MissingStoragePermissionException {
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.no_permission"),
        );
      }
    }
    if (result != null) {
      File(
        result.path!,
      ).copySync("${supportPath.path}/${ClassTableController.decorationName}");
      preference.setBool(preference.Preference.decoration, true);
      if (context.mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.successful_setting"),
        );
      }
      return;
    }
    if (context.mounted) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.failure_setting"),
      );
    }
  }

  Future<void> _confirmClearUserClass(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.clear_user_class_title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.clear_user_class_content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () {
              actions.clearUserDefinedClasses();
              onChanged();
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "setting.clear_user_class_clear",
                ),
              );
              Navigator.pop(context);
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRefreshClassData(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.class_refresh_title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.class_refresh_content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              await actions.refreshSemesterAwareData();
              onChanged();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  Future<void> _changeSemester(BuildContext context) async {
    final changed = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => SemesterSwitchDialog(),
    );
    if (changed != true) return;
    onChanged();
    if (context.mounted) {
      showToast(context: context, msg: "Updating data");
    }
    await actions.waitForSemesterAwareReloads();
    await actions.autoSyncSystemCalendarIfNeeded();
    onChanged();
  }
}

class SettingCoreSection extends StatelessWidget {
  final SettingActionsController actions;

  const SettingCoreSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.core_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.check_logger")),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.push(TalkerScreen(talker: log)),
          ),
          const Divider(),
          if (Platform.isAndroid || Platform.isIOS) ...[
            ListTile(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.notification_debug_page",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => context.push(NotificationDebugPage()),
            ),
            const Divider(),
          ],
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.clear_and_restart"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmClearAndRestart(context),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.logout")),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAndRestart(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(
            context,
            "setting.clear_and_restart_dialog.title",
          ),
        ),
        content: Text(
          FlutterI18n.translate(
            context,
            "setting.clear_and_restart_dialog.content",
          ),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              final pd = ProgressDialog(context: context);
              pd.show(
                msg: FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.cleaning",
                ),
              );
              await actions.clearAppCache();
              if (!context.mounted) return;
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.clear",
                ),
              );
              _restartApp(
                context,
                iosTitleKey: "restart_app.title_cache_cleared",
              );
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.logout_dialog.title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.logout_dialog.content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              final pd = ProgressDialog(context: context);
              pd.show(
                msg: FlutterI18n.translate(
                  context,
                  "setting.logout_dialog.logging_out",
                ),
              );
              await actions.logoutAndClearLocalState();
              if (!context.mounted) return;
              pd.close();
              _restartApp(context, iosTitleKey: "restart_app.title_logged_out");
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  void _restartApp(BuildContext context, {required String iosTitleKey}) {
    if (Platform.isIOS) {
      Restart.restartApp(
        mode: RestartMode.notificationFallback,
        notificationTitle: FlutterI18n.translate(context, iosTitleKey),
        notificationBody: FlutterI18n.translate(context, "restart_app.content"),
      );
    } else {
      Restart.restartApp();
    }
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: () => Navigator.pop(context),
      child: Text(FlutterI18n.translate(context, "cancel")),
    );
  }
}
