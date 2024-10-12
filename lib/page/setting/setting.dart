// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/page/setting/dialogs/change_brightness_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/setting/dialogs/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_score_session.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});
  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  Widget _buildListSubtitle(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
          .padding(
            bottom: 8,
          )
          .center();

  void restart() {
    if (Platform.isAndroid || Platform.isIOS) {
      Restart.restartApp();
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(FlutterI18n.translate(
            context,
            "setting.need_close_dialog.title",
          )),
          content: Text(FlutterI18n.translate(
            context,
            "setting.need_close_dialog.content",
          )),
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
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: Platform.isIOS || Platform.isMacOS
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
            // 功能1
            const SizedBox(height: 20),
            ReXCard(
                title: _buildListSubtitle(FlutterI18n.translate(
                  context,
                  "setting.about",
                )),
                remaining: const [],
                bottomRow: Column(
                  children: [
                    ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.about_this_program",
                      )),
                      subtitle: Text(FlutterI18n.translate(
                        context,
                        "setting.version",
                        translationParams: {
                          "version_code":
                              '${preference.packageInfo.version}+${preference.packageInfo.buildNumber}',
                        },
                      )),
                      onTap: () => context.pushReplacement(const AboutPage()),
                      trailing: const Icon(Icons.navigate_next),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.user_info",
                      )),
                      subtitle: Text(
                        "${preference.getString(preference.Preference.name)} ${preference.getString(preference.Preference.execution)}\n"
                        "${preference.getString(preference.Preference.institutes)} ${preference.getString(preference.Preference.subject)}",
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            // ReXCard(
            //   title: _buildListSubtitle('颜色设置'),
            //   remaining: [],
            //   bottomRow: Column(
            //     children: [
            //       ListTile(
            //           title: const Text('设置程序主题色'),
            //           subtitle: Text(ColorSeed
            //               .values[
            //                   preference.getInt(preference.Preference.color)]
            //               .label),
            //           onTap: () {
            //             showDialog(
            //               context: context,
            //               builder: (context) => const ChangeColorDialog(),
            //             );
            //           }),
            //     ],
            //   ),
            // ),
            ReXCard(
                title: _buildListSubtitle(FlutterI18n.translate(
                  context,
                  "setting.ui_setting",
                )),
                remaining: const [],
                bottomRow: Column(children: [
                  ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.brightness_setting",
                      )),
                      subtitle: Text(demoBlueModeName[
                          preference.getInt(preference.Preference.brightness)]),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const ChangeBrightnessDialog());
                      }),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.simplify_timeline",
                    )),
                    subtitle: Text(FlutterI18n.translate(
                      context,
                      "setting.simplify_timeline_description",
                    )),
                    trailing: Switch(
                      value: preference.getBool(
                          preference.Preference.simplifiedClassTimeline),
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
                ])),
            ReXCard(
              title: _buildListSubtitle(FlutterI18n.translate(
                context,
                "setting.account_setting",
              )),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.sport_password_setting",
                      )),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const SportPasswordDialog(),
                        );
                      }),
                  const Divider(),
                  ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.experiment_password_setting",
                      )),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) =>
                              const ExperimentPasswordDialog(),
                        );
                      }),
                  const Divider(),
                  ListTile(
                      title: Text(FlutterI18n.translate(
                        context,
                        "setting.electricity_password_setting",
                      )),
                      subtitle: Text(FlutterI18n.translate(
                        context,
                        "setting.electricity_password_description",
                      )),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const ElectricityPasswordDialog(),
                        );
                      }),
                ],
              ),
            ),
            ReXCard(
              title: _buildListSubtitle(FlutterI18n.translate(
                context,
                "setting.classtable_setting",
              )),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.background",
                    )),
                    trailing: Switch(
                      value:
                          preference.getBool(preference.Preference.decorated),
                      onChanged: (bool value) {
                        if (value == true &&
                            !preference
                                .getBool(preference.Preference.decoration)) {
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
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.choose_background",
                    )),
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
                          File(result.files.single.path!)
                              .copySync("${supportPath.path}/decoration.jpg");
                          preference.setBool(
                              preference.Preference.decoration, true);
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
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.clear_user_class",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(FlutterI18n.translate(
                          context,
                          "setting.clear_user_class_dialog.title",
                        )),
                        content: Text(FlutterI18n.translate(
                          context,
                          "setting.clear_user_class_dialog.content",
                        )),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(FlutterI18n.translate(
                              context,
                              "cancel",
                            )),
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
                              Get.find<ClassTableController>()
                                  .updateClassTable();
                              showToast(
                                context: context,
                                msg: FlutterI18n.translate(
                                  context,
                                  "setting.clear_user_class_dialog.clear",
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(FlutterI18n.translate(
                              context,
                              "confirm",
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.class_refresh",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(FlutterI18n.translate(
                          context,
                          "setting.class_refresh_dialog.title",
                        )),
                        content: Text(FlutterI18n.translate(
                          context,
                          "setting.class_refresh_dialog.content",
                        )),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(FlutterI18n.translate(
                              context,
                              "cancel",
                            )),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.put(ClassTableController())
                                  .updateClassTable(isForce: true);
                              Navigator.pop(context);
                            },
                            child: Text(FlutterI18n.translate(
                              context,
                              "confirm",
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.class_swift",
                    )),
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
              title: _buildListSubtitle(FlutterI18n.translate(
                context,
                "setting.core_setting",
              )),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.check_catcher",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => Catcher2.sendTestException(),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.check_logger",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => context.push(TalkerScreen(talker: log)),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.clear_and_restart",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(FlutterI18n.translate(
                          context,
                          "setting.clear_and_restart_dialog.title",
                        )),
                        content: Text(FlutterI18n.translate(
                          context,
                          "setting.clear_and_restart_dialog.content",
                        )),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(FlutterI18n.translate(
                              context,
                              "cancel",
                            )),
                          ),
                          TextButton(
                            onPressed: () async {
                              ProgressDialog pd =
                                  ProgressDialog(context: context);
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
                                Restart.restartApp();
                              }
                            },
                            child: Text(FlutterI18n.translate(
                              context,
                              "confirm",
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(FlutterI18n.translate(
                      context,
                      "setting.logout",
                    )),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(FlutterI18n.translate(
                          context,
                          "setting.logout_dialog.title",
                        )),
                        content: Text(FlutterI18n.translate(
                          context,
                          "setting.logout_dialog.content",
                        )),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(FlutterI18n.translate(
                              context,
                              "cancel",
                            )),
                          ),
                          TextButton(
                            onPressed: () async {
                              ProgressDialog pd =
                                  ProgressDialog(context: context);
                              pd.show(
                                msg: FlutterI18n.translate(
                                  context,
                                  "logging_out",
                                ),
                              );

                              /// Clean Cookie
                              try {
                                await NetworkSession().clearCookieJar();
                                // I don't care.
                                // ignore: empty_catches
                              } on Exception {}

                              /// Clean cache.
                              _removeCache();

                              /// Clean user information
                              await preference.prefrenceClear();

                              /// Theme back to default
                              ThemeController toChange =
                                  Get.put(ThemeController());
                              toChange.onUpdate();

                              /// Restart app
                              if (mounted) {
                                pd.close();
                                Restart.restartApp();
                              }
                            },
                            child: Text(FlutterI18n.translate(
                              context,
                              "confirm",
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).constrained(maxWidth: 600).center(),
      ),
    );
  }
}

void _removeCache() {
  for (var value in [
    ClassTableFile.schoolClassName,
    ExamController.examDataCacheName,
    ExperimentController.experimentCacheName,
    ScoreSession.scoreListCacheName
  ]) {
    var file = File(
      "${supportPath.path}/$value",
    );
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
