// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/repository/experiment_session.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/repository/pda_service_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/setting/dialogs/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/electricity_session.dart'
    as electricity_session;
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';
import 'package:watermeter/themes/color_seed.dart';

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

  void restart() {
    if (Platform.isAndroid || Platform.isIOS) {
      Restart.restartApp();
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            FlutterI18n.translate(context, "setting.need_close_dialog.title"),
          ),
          content: Text(
            FlutterI18n.translate(context, "setting.need_close_dialog.content"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> demoBlueModeName = [
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
            title: _buildListSubtitle(
              FlutterI18n.translate(context, "setting.about"),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.about_this_program",
                    ),
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
                  onTap: () => context.pushReplacement(const AboutPage()),
                  trailing: const Icon(Icons.navigate_next),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.check_update"),
                  ),
                  subtitle: Obx(
                    () => Text(
                      FlutterI18n.translate(
                        context,
                        "setting.latest_version",
                        translationParams: {
                          "latest":
                              updateMessage.value?.code ??
                              FlutterI18n.translate(context, "setting.waiting"),
                        },
                      ),
                    ),
                  ),
                  onTap: () {
                    showToast(
                      context: context,
                      msg: FlutterI18n.translate(
                        context,
                        "setting.fetching_update",
                      ),
                    );
                    checkUpdate().then(
                      (value) async {
                        if (context.mounted) {
                          if ((value ?? false) && updateMessage.value != null) {
                            await showDialog(
                              context: context,
                              builder: (context) => Obx(
                                () => UpdateDialog(
                                  updateMessage: updateMessage.value!,
                                ),
                              ),
                            );
                          } else {
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                value == null
                                    ? "setting.current_testing"
                                    : "setting.current_stable",
                              ),
                            );
                          }
                        }
                      },
                      onError: (e, s) {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              "setting.fetch_failed",
                            ),
                          );
                        }
                      },
                    );
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
          ReXCard(
            title: _buildListSubtitle(
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
                      "setting.change_color_dialog.${ColorSeed.values[preference.getInt(preference.Preference.color)].label}",
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
                    FlutterI18n.translate(
                      context,
                      "setting.brightness_setting",
                    ),
                  ),
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
                              ThemeController toChange = Get.put(
                                ThemeController(),
                              );
                              toChange.updateTheme();
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
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.localization_dialog.title",
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
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
            title: _buildListSubtitle(
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
                      "setting.electricity_account_setting",
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    showDialog<bool>(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ElectricityAccountDialog(
                        onSaveAccount: (accountNumber) async {
                          await preference.setString(
                            preference.Preference.electricityAccount,
                            accountNumber,
                          );
                        },
                        initialAccountNumber: preference.getString(
                          preference.Preference.electricityAccount,
                        ),
                        onFetchFromNetwork: () async {
                          String dorm = await PersonalInfoSession()
                              .getDormInfoEhall();
                          return electricity_session
                              .ElectricitySession.parseElectricityAccountFromIDS(
                            dorm,
                          );
                        },
                      ),
                    ).then((value) async {
                      if (value != true) {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              "setting.change_electricity_account.no_setting",
                            ),
                          );
                          return;
                        }
                      }

                      electricity_session
                          .ElectricitySession.clearElectricityHistory();

                      if (context.mounted) {
                        showToast(
                          context: context,
                          msg: FlutterI18n.translate(
                            context,
                            "setting.change_electricity_account.successful_setting",
                          ),
                        );
                        electricity_session.update(force: true);
                        return;
                      }
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.electricity_password_setting",
                    ),
                  ),
                  subtitle: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.electricity_password_description",
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const ElectricityPasswordDialog(),
                    );
                  },
                ),
                const Divider(),
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
          ),
          ReXCard(
            title: _buildListSubtitle(
              FlutterI18n.translate(context, "setting.classtable_setting"),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.background"),
                  ),
                  trailing: Switch(
                    value: preference.getBool(preference.Preference.decorated),
                    onChanged: (bool value) {
                      if (value == true &&
                          !preference.getBool(
                            preference.Preference.decoration,
                          )) {
                        showToast(
                          context: context,
                          msg: FlutterI18n.translate(
                            context,
                            "setting.no_background",
                          ),
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
                  title: Text(
                    FlutterI18n.translate(context, "setting.choose_background"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () async {
                    FilePickerResult? result;
                    try {
                      result = await pickFile(type: FileType.image);
                    } on MissingStoragePermissionException {
                      if (context.mounted) {
                        showToast(
                          context: context,
                          msg: FlutterI18n.translate(
                            context,
                            "setting.no_permission",
                          ),
                        );
                      }
                    }
                    if (mounted) {
                      if (result != null) {
                        File(result.files.single.path!).copySync(
                          "${supportPath.path}/${ClassTableFile.decorationName}",
                        );
                        preference.setBool(
                          preference.Preference.decoration,
                          true,
                        );
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              "setting.successful_setting",
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              "setting.failure_setting",
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.clear_user_class"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.clear_user_class_title",
                        ),
                      ),
                      content: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.clear_user_class_content",
                        ),
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
                          child: Text(FlutterI18n.translate(context, "cancel")),
                        ),
                        TextButton(
                          onPressed: () {
                            var file = File(
                              "${supportPath.path}/"
                              "${ClassTableFile.userDefinedClassName}",
                            );
                            if (file.existsSync()) {
                              file.deleteSync();
                            }
                            Get.find<ClassTableController>().updateClassTable();
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                "setting.clear_user_class_clear",
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            FlutterI18n.translate(context, "confirm"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.class_refresh"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.class_refresh_title",
                        ),
                      ),
                      content: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.class_refresh_content",
                        ),
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
                          child: Text(FlutterI18n.translate(context, "cancel")),
                        ),
                        TextButton(
                          onPressed: () {
                            Future.wait([
                              Get.put(
                                ClassTableController(),
                              ).updateClassTable(isForce: true),
                              Get.put(ExamController()).get(),
                              Get.put(ExperimentController()).get(),
                            ]).then((value) => value.first);
                            Navigator.pop(context);
                          },
                          child: Text(
                            FlutterI18n.translate(context, "confirm"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.class_swift"),
                  ),
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
                    ).then((value) {
                      Get.put(ClassTableController()).update();
                      updateCurrentData();
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
          ReXCard(
            title: _buildListSubtitle(
              FlutterI18n.translate(context, "setting.core_setting"),
            ),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.check_logger"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => context.push(TalkerScreen(talker: log)),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "测试实验系统功能", //FlutterI18n.translate(context, "setting.check_logger"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => SysjSession().getDataFromSysj().onError((e, s) {
                    if (context.mounted) {
                      showToast(context: context, msg: "实验系统功能测试失败");
                      log.error("Failed to test experiment crawlers", e, s);
                    }
                    return (
                      ExperimentFetchStatus.notSchoolNetwork,
                      <ExperimentData>[],
                    );
                  }),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    FlutterI18n.translate(context, "setting.clear_and_restart"),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
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
                          child: Text(FlutterI18n.translate(context, "cancel")),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd = ProgressDialog(
                              context: context,
                            );
                            pd.show(
                              msg: FlutterI18n.translate(
                                context,
                                "setting.clear_and_restart_dialog.cleaning",
                              ),
                            );
                            try {
                              await NetworkSession().clearCookieJar();
                            } on PathNotFoundException {
                              log.debug(
                                "[setting][ClearAllCache]"
                                "No cookies.",
                              );
                            }

                            /// Clean cache.
                            _removeCache();
                            if (context.mounted) {
                              showToast(
                                context: context,
                                msg: FlutterI18n.translate(
                                  context,
                                  "setting.clear_and_restart_dialog.clear",
                                ),
                              );
                              restart();
                            }
                          },
                          child: Text(
                            FlutterI18n.translate(context, "confirm"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(FlutterI18n.translate(context, "setting.logout")),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.logout_dialog.title",
                        ),
                      ),
                      content: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.logout_dialog.content",
                        ),
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
                          child: Text(FlutterI18n.translate(context, "cancel")),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd = ProgressDialog(
                              context: context,
                            );
                            pd.show(
                              msg: FlutterI18n.translate(
                                context,
                                "setting.logout_dialog.logging_out",
                              ),
                            );

                            /// Clean Cookie
                            try {
                              await NetworkSession().clearCookieJar();
                              // I don't care.
                              // ignore: empty_catches
                            } on Exception {}

                            /// Clean all.
                            _removeAll();

                            /// Clean user information
                            await preference.prefrenceClear();

                            /// Theme back to default
                            ThemeController toChange = Get.put(
                              ThemeController(),
                            );
                            toChange.updateTheme();

                            /// Restart app
                            if (mounted) {
                              pd.close();
                              restart();
                            }
                          },
                          child: Text(
                            FlutterI18n.translate(context, "confirm"),
                          ),
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

void _removeCache() {
  for (var value in [
    ClassTableFile.schoolClassName,
    ExamController.examDataCacheName,
    ExperimentController.physicsCacheName,
    ExperimentController.otherCacheName,
    ScoreSession.scoreListCacheName,
    electricity_session.ElectricitySession.electricityCache,
    electricity_session.ElectricitySession.electricityHistory,
  ]) {
    var file = File("${supportPath.path}/$value");
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}

void _removeAll() {
  for (var value in [
    ClassTableFile.schoolClassName,
    ClassTableFile.userDefinedClassName,
    ClassTableFile.decorationName,
    ExamController.examDataCacheName,
    ExperimentController.physicsCacheName,
    ExperimentController.otherCacheName,
    ScoreSession.scoreListCacheName,
    electricity_session.ElectricitySession.electricityCache,
    electricity_session.ElectricitySession.electricityHistory,
  ]) {
    var file = File("${supportPath.path}/$value");
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
