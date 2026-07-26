// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/external/ruisi_flutter/lib/controller/ruisi_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/aircon_imei_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/semester_switch_dialog.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/setting/notification_page/notification_debug_page.dart';
import 'package:watermeter/page/setting/notification_page/notification_page.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/repository/custom_class_service.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/energy_session.dart';
import 'package:watermeter/repository/xidian_ids/exam_session.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';
import 'package:watermeter/repository/physics_experiment_session.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'package:watermeter/repository/widget_state_sync.dart';
import 'package:watermeter/themes/color_seed.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/l10n.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});
  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  Widget _buildListSubtitle(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ).padding(bottom: 8).center();

  bool get _isSemesterAwareControllerLoading =>
      ClassTableController.i.schoolClassTableStateSignal.value.isLoading ||
      ExamController.i.examInfoStateSignal.value.isLoading ||
      PhysicsExperimentController
          .i
          .physicsExperimentStateSignal
          .value
          .isLoading ||
      OtherExperimentController.i.otherExperimentStateSignal.value.isLoading;

  Future<void> _waitForSemesterAwareReloads() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final stopwatch = Stopwatch()..start();
    while (_isSemesterAwareControllerLoading &&
        stopwatch.elapsed < const Duration(seconds: 30)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  bool get _lowElectricityWarningEnabled =>
      EnergyController.i.electricityWarning.value >= 0;

  int get _lowElectricityWarningThreshold =>
      EnergyController.i.electricityWarning.value > 0
      ? EnergyController.i.electricityWarning.value
      : EnergyController.defaultLowElectricityWarningThreshold;

  Future<void> _showLowElectricityThresholdDialog() async {
    var inputText = _lowElectricityWarningThreshold.toString();

    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18n.of(context)!.settingLowElectricityThresholdDialogTitle,
        ),
        content: TextFormField(
          autofocus: true,
          initialValue: inputText,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLines: 1,
          onChanged: (value) => inputText = value,
          decoration: InputDecoration(
            hintText: I18n.of(
              context,
            )!.settingLowElectricityThresholdDialogInputHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(I18n.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(inputText);
              Navigator.pop(
                context,
                parsed == null || parsed <= 0
                    ? EnergyController.defaultLowElectricityWarningThreshold
                    : parsed,
              );
            },
            child: Text(I18n.of(context)!.confirm),
          ),
        ],
      ),
    );

    if (value == null) return;
    await EnergyController.i.setLowElectricityWarningThreshold(value);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> demoBlueModeName = [
      I18n.of(context)!.settingChangeBrightnessDialogFollowSetting,
      I18n.of(context)!.settingChangeBrightnessDialogDayMode,
      I18n.of(context)!.settingChangeBrightnessDialogNightMode,
    ];
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                      ? "XDYou"
                      : 'Traintime PDA',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: '\nWritten by BenderBlog Rodriguez and contributors',
                ),
              ],
            ),
          ).padding(horizontal: 8.0),
          const SizedBox(height: 20),
          ReXCard(
            title: _buildListSubtitle(I18n.of(context)!.settingAbout),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(I18n.of(context)!.settingAboutThisProgram),
                  subtitle: Text(
                    I18n.of(
                      context,
                    )!.settingVersion("${preference.packageInfo.version}+"),
                  ),
                  onTap: () => context.pushReplacementNamed(Routes.about),
                  trailing: const Icon(Icons.navigate_next),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingCheckUpdate),
                  subtitle: SignalBuilder(
                    builder: (context) {
                      final updateState = UpdateNoticeController
                          .i
                          .updateMessageStateSignal
                          .value;
                      return Text(
                        I18n.of(context)!.settingLatestVersion(
                          updateState.value?.code ??
                              I18n.of(context)!.settingWaiting,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    showToast(
                      context: context,
                      msg: I18n.of(context)!.settingFetchingUpdate,
                    );
                    UpdateNoticeController.i.reloadUpdateNoticeInfo().then((
                      value,
                    ) async {
                      if (context.mounted) {
                        if (UpdateNoticeController
                            .i
                            .updateMessageStateSignal
                            .value
                            .hasError) {
                          showToast(
                            context: context,
                            msg: I18n.of(context)!.settingFetchFailed,
                          );
                          return;
                        }
                        switch (UpdateNoticeController
                            .i
                            .isNewVersionAvaliableComputed
                            .value) {
                          case null:
                            showToast(
                              context: context,
                              msg: I18n.of(context)!.settingCurrentTesting,
                            );
                          case true:
                            await showDialog(
                              context: context,
                              builder: (context) => SignalBuilder(
                                builder: (context) => UpdateDialog(
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
                              msg: I18n.of(context)!.settingCurrentStable,
                            );
                        }
                      }
                    });
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
          ReXCard(
            title: _buildListSubtitle(I18n.of(context)!.settingUiSetting),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(I18n.of(context)!.settingColorSetting),
                  subtitle: Text(
                    _colorSeedToI18n(
                      context,
                      ColorSeed.values[preference.getInt(
                        preference.Preference.color,
                      )],
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
                  title: Text(I18n.of(context)!.settingBrightnessSetting),
                  subtitle: Text(
                    demoBlueModeName[preference.getInt(
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
                    onPressed: (int value) {
                      preference
                          .setInt(preference.Preference.brightness, value)
                          .then((value) {
                            setState(() {
                              ThemeController.i.updateTheme();
                            });
                          });
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
                  title: Text(I18n.of(context)!.settingSimplifyTimeline),
                  subtitle: Text(
                    I18n.of(context)!.settingSimplifyTimelineDescription,
                  ),
                  trailing: Switch(
                    value: preference.getBool(
                      preference.Preference.simplifiedClassTimeline,
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        preference
                            .setBool(
                              preference.Preference.simplifiedClassTimeline,
                              value,
                            )
                            .then(
                              (value) =>
                                  ClassTableCard.reloadSettingsFromPref(),
                            );
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingLowElectricityWarning),
                  subtitle: Text(
                    I18n.of(context)!.settingLowElectricityWarningDescription,
                  ),
                  trailing: Switch(
                    value: _lowElectricityWarningEnabled,
                    onChanged: (bool value) async {
                      await EnergyController.i.setLowElectricityWarningEnabled(
                        value,
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  enabled: _lowElectricityWarningEnabled,
                  title: Text(I18n.of(context)!.settingLowElectricityThreshold),
                  subtitle: Text(
                    I18n.of(context)!.settingLowElectricityThresholdDescription(
                      _lowElectricityWarningThreshold.toString(),
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: _lowElectricityWarningEnabled
                      ? _showLowElectricityThresholdDialog
                      : null,
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingLocalizationDialogTitle),
                  subtitle: Text(
                    Localization.values
                          .firstWhere(
                            (value) =>
                                value.string ==
                                preference.getString(
                                  preference.Preference.localization,
                                ),
                          )
                          .displayName(I18n.of(context)!),
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
          ),
          ReXCard(
            title: _buildListSubtitle(I18n.of(context)!.settingAccountSetting),
            remaining: const [],
            bottomRow: Column(
              children: [
                if (!preference.getBool(preference.Preference.role)) ...[
                  ListTile(
                    title: Text(I18n.of(context)!.settingSportPasswordSetting),
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
                      I18n.of(context)!.settingExperimentPasswordSetting,
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
                    I18n.of(context)!.settingSchoolnetPasswordSetting,
                  ),
                  subtitle: Text(
                    I18n.of(context)!.settingSchoolnetPasswordDescription,
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SchoolNetPasswordDialog(),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingAirconImeiTitle),
                  subtitle: Text(
                    preference
                            .getString(preference.Preference.airconImei)
                            .isEmpty
                        ? I18n.of(context)!.settingAirconImeiNotSet
                        : I18n.of(context)!.settingAirconImeiCurrent(
                            preference.getString(
                              preference.Preference.airconImei,
                            ),
                          ),
                  ),
                  trailing: const Icon(Icons.qr_code_scanner),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AirconImeiDialog(),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            ReXCard(
              title: _buildListSubtitle(
                I18n.of(context)!.settingNotificationSetting,
              ),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: Text(I18n.of(context)!.settingCourseReminderSetting),
                    subtitle: Text(
                      I18n.of(context)!.settingCourseReminderDescription,
                    ),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      context.push(const NotificationSettingsPage());
                    },
                  ),
                ],
              ),
            ),
          ReXCard(
            title: _buildListSubtitle(
              I18n.of(context)!.settingClasstableSetting,
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(I18n.of(context)!.settingBackground),
                  trailing: Switch(
                    value: preference.getBool(preference.Preference.decorated),
                    onChanged: (bool value) {
                      if (value == true &&
                          !preference.getBool(
                            preference.Preference.decoration,
                          )) {
                        showToast(
                          context: context,
                          msg: I18n.of(context)!.settingNoBackground,
                        );
                      } else {
                        setState(() {
                          preference.setBool(
                            preference.Preference.decorated,
                            value,
                          );
                        });
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingChooseBackground),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () async {
                    PlatformFile? result;
                    try {
                      result = await pickFile(type: FileType.image);
                    } on MissingStoragePermissionException {
                      if (context.mounted) {
                        showToast(
                          context: context,
                          msg: I18n.of(context)!.settingNoPermission,
                        );
                      }
                    }
                    if (mounted) {
                      if (result != null) {
                        File(result.path!).copySync(
                          "${supportPath.path}/${ClassTableController.decorationName}",
                        );
                        preference.setBool(
                          preference.Preference.decoration,
                          true,
                        );
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: I18n.of(context)!.settingSuccessfulSetting,
                          );
                        }
                      } else {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: I18n.of(context)!.settingFailureSetting,
                          );
                        }
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingClearUserClass),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(I18n.of(context)!.settingClearUserClassTitle),
                      content: Text(
                        I18n.of(context)!.settingClearUserClassContent,
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(I18n.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            await CustomClassController.i.clearAll();
                            if (mounted) {
                              setState(() {});
                            }
                            showToast(
                              context: context,
                              msg: I18n.of(context)!.settingClearUserClassClear,
                            );
                            Navigator.pop(context);
                          },
                          child: Text(I18n.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingClassRefresh),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(I18n.of(context)!.settingClassRefreshTitle),
                      content: Text(
                        I18n.of(context)!.settingClassRefreshContent,
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(I18n.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Future.wait([
                              ClassTableController.i.reloadClassTable(),
                              ExamController.i.reloadExamInfo(),
                              PhysicsExperimentController.i
                                  .reloadPhysicsExperiment(),
                              OtherExperimentController.i
                                  .reloadOtherExperiment(),
                            ]);
                            await maybeAutoSyncSystemCalendar();
                            if (mounted) {
                              setState(() {});
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(I18n.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingClassSwift),
                  subtitle: Text(
                    I18n.of(context)!.settingClassSwiftDescription(
                      preference.getInt(preference.Preference.swift).toString(),
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ChangeSwiftDialog(),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingSemesterChange),
                  subtitle: Text(
                    I18n.of(context)!.settingSemesterChangeDescription(
                      preference.getString(
                        preference.Preference.currentSemester,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    showDialog<bool>(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => SemesterSwitchDialog(),
                    ).then((value) async {
                      if (value == true) {
                        setState(() {});
                        if (context.mounted) {
                          showToast(context: context, msg: "Updating data");
                        }
                        await _waitForSemesterAwareReloads();
                        await maybeAutoSyncSystemCalendar();
                        if (mounted) {
                          setState(() {});
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          ReXCard(
            title: _buildListSubtitle(I18n.of(context)!.settingCoreSetting),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(I18n.of(context)!.settingCheckLogger),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => context.push(TalkerScreen(talker: log)),
                ),
                const Divider(),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  ListTile(
                    title: Text(I18n.of(context)!.settingNotificationDebugPage),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => context.push(NotificationDebugPage()),
                  ),
                  const Divider(),
                ],
                ListTile(
                  title: Text(I18n.of(context)!.settingClearAndRestart),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        I18n.of(context)!.settingClearAndRestartDialogTitle,
                      ),
                      content: Text(
                        I18n.of(context)!.settingClearAndRestartDialogContent,
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(I18n.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd = ProgressDialog(
                              context: context,
                            );
                            pd.show(
                              msg: I18n.of(
                                context,
                              )!.settingClearAndRestartDialogCleaning,
                            );

                            /// Clean Cookie
                            try {
                              await NetworkSession().clearCookieJar();
                              // I don't care.
                              // ignore: empty_catches
                            } on Exception {}

                            /// Clean sport cookie.
                            try {
                              await SportSession().sportCookieJar.deleteAll();
                              // I don't care.
                              // ignore: empty_catches
                            } on Exception {}

                            /// Clean cache.
                            EnergySession.clearCache();
                            EnergySession.clearElectricityHistory();
                            for (var value in [
                              ClassTableSession.schoolClassName,
                              ExamSession.examDataCacheName,
                              ExperimentSession.physicsExperimentCacheName,
                              SysjSession.otherExperimentCacheName,
                              ScoreSession.scoreListCacheName,
                            ]) {
                              var file = File("${supportPath.path}/$value");
                              if (file.existsSync()) {
                                file.deleteSync();
                              }
                            }

                            if (context.mounted) {
                              showToast(
                                context: context,
                                msg: I18n.of(
                                  context,
                                )!.settingClearAndRestartDialogClear,
                              );
                              if (Platform.isIOS) {
                                Restart.restartApp(
                                  mode: RestartMode.notificationFallback,
                                  notificationTitle: I18n.of(
                                    context,
                                  )!.restartAppTitleCacheCleared,
                                  notificationBody: I18n.of(
                                    context,
                                  )!.restartAppContent,
                                );
                              } else {
                                Restart.restartApp();
                              }
                            }
                          },
                          child: Text(I18n.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(I18n.of(context)!.settingLogout),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(I18n.of(context)!.settingLogoutDialogTitle),
                      content: Text(
                        I18n.of(context)!.settingLogoutDialogContent,
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(I18n.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd = ProgressDialog(
                              context: context,
                            );
                            pd.show(
                              msg: I18n.of(
                                context,
                              )!.settingLogoutDialogLoggingOut,
                            );

                            /// Clean Cookie
                            try {
                              await NetworkSession().clearCookieJar();
                              // I don't care.
                              // ignore: empty_catches
                            } on Exception {}

                            /// Clean sport cookie.
                            try {
                              await SportSession().sportCookieJar.deleteAll();
                              // I don't care.
                              // ignore: empty_catches
                            } on Exception {}

                            /// Clean all.
                            EnergySession.clearCache();
                            EnergySession.clearElectricityHistory();
                            for (var value in [
                              ClassTableSession.schoolClassName,
                              CustomClassRepository.fileName,
                              ClassTableController.decorationName,
                              ExamSession.examDataCacheName,
                              ExperimentSession.physicsExperimentCacheName,
                              SysjSession.otherExperimentCacheName,
                              ScoreSession.scoreListCacheName,
                            ]) {
                              var file = File("${supportPath.path}/$value");
                              if (file.existsSync()) {
                                file.deleteSync();
                              }
                            }
                            try {
                              await GetIt.instance<RuisiService>().logout();
                            } catch (e, s) {
                              log.error(e, s);
                            }

                            /// Clean user information
                            await preference.prefrenceClear();

                            /// Theme back to default
                            ThemeController.i.updateTheme();

                            /// Sync widget login state
                            await syncWidgetLoginState(false);

                            /// Clean iOS widget data files
                            await clearWidgetFiles();

                            /// Restart app
                            if (context.mounted) {
                              pd.close();
                              if (Platform.isIOS) {
                                Restart.restartApp(
                                  mode: RestartMode.notificationFallback,
                                  notificationTitle: I18n.of(
                                    context,
                                  )!.restartAppTitleLoggedOut,
                                  notificationBody: I18n.of(
                                    context,
                                  )!.restartAppContent,
                                );
                              } else {
                                Restart.restartApp();
                              }
                            }
                          },
                          child: Text(I18n.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).constrained(maxWidth: 600).center().safeArea(top: true),
    );
  }
}



String _colorSeedToI18n(BuildContext context, ColorSeed seed) {
  return switch (seed) {
    ColorSeed.indigo => I18n.of(context)!.settingChangeColorDialogDefault,
    ColorSeed.blue => I18n.of(context)!.settingChangeColorDialogBlue,
    ColorSeed.deepPurple => I18n.of(
      context,
    )!.settingChangeColorDialogDeeppurple,
    ColorSeed.green => I18n.of(context)!.settingChangeColorDialogGreen,
    ColorSeed.orange => I18n.of(context)!.settingChangeColorDialogOrange,
    ColorSeed.pink => I18n.of(context)!.settingChangeColorDialogPink,
  };
}
