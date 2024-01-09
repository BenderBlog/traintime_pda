// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/setting/about_page.dart';
import 'package:watermeter/page/setting/dialogs/change_brightness_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/repository/experiment/experiment_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/setting/dialogs/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/themes/demo_blue.dart';
import 'dart:developer' as developer;

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});

  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.background,
        ),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text("关于 ${preference.packageInfo.appName}"),
                value: Text(
                    '版本号：${preference.packageInfo.version}+${preference.packageInfo.buildNumber}'),
                onPressed: (context) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                ),
              ),
              SettingsTile(
                title: const Text('用户信息'),
                value: Text(
                    "${preference.getString(preference.Preference.name)} ${preference.getString(preference.Preference.execution)}\n"
                    "${preference.getString(preference.Preference.institutes)} ${preference.getString(preference.Preference.subject)}"),
              ),
            ],
          ),
          // SettingsSection(
          //   title: const Text('颜色设置'),
          //   tiles: <SettingsTile>[
          //     SettingsTile.navigation(
          //         title: const Text('设置程序主题色'),
          //         value: Text(ColorSeed
          //             .values[preference.getInt(preference.Preference.color)]
          //             .label),
          //         onPressed: (content) {
          //           showDialog(
          //             context: context,
          //             builder: (context) => const ChangeColorDialog(),
          //           );
          //         }),
          //   ],
          // ),
          SettingsSection(
            title: const Text('主题设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: const Text('设置深浅色'),
                  value: Text(
                    demoBlueModeName[
                        preference.getInt(preference.Preference.brightness)],
                  ),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const ChangeBrightnessDialog(),
                    );
                  }),
            ],
          ),
          SettingsSection(
            title: const Text('帐号设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: const Text('体适能密码设置'),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const SportPasswordDialog(),
                    );
                  }),
              SettingsTile.navigation(
                  title: const Text('物理实验系统密码'),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const ExperimentPasswordDialog(),
                    );
                  }),
              SettingsTile.navigation(
                  title: const Text('电费帐号密码设置'),
                  description: const Text('非 123456 请设置'),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const ElectricityPasswordDialog(),
                    );
                  }),
            ],
          ),
          SettingsSection(
            title: const Text('课表相关设置'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                title: const Text("开启课表背景图"),
                initialValue:
                    preference.getBool(preference.Preference.decorated),
                onToggle: (bool value) {
                  if (value == true &&
                      !preference.getBool(preference.Preference.decoration)) {
                    Fluttertoast.showToast(msg: '你先选个图片罢，就在下面');
                  } else {
                    setState(() {
                      preference.setBool(
                          preference.Preference.decorated, value);
                    });
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('课表背景图选择'),
                onPressed: (content) async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (mounted) {
                    if (result != null) {
                      File(result.files.single.path!)
                          .copySync("${supportPath.path}/decoration.jpg");
                      preference.setBool(
                          preference.Preference.decoration, true);
                      if (mounted) {
                        Fluttertoast.showToast(msg: '设定成功');
                      }
                    } else {
                      Fluttertoast.showToast(msg: '你没有选图片捏');
                    }
                  }
                },
              ),
              SettingsTile(
                title: const Text("清除所有用户添加课程"),
                onPressed: (context) async {
                  var file = File(
                    "${supportPath.path}/${ClassTableFile.userDefinedClassName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  Get.find<ClassTableController>().updateClassTable();
                  Fluttertoast.showToast(msg: "已经清除完毕");
                },
              ),
              SettingsTile(
                title: const Text("强制刷新课表"),
                onPressed: (context) => Get.put(ClassTableController())
                    .updateClassTable(isForce: true),
              ),
              SettingsTile.navigation(
                title: const Text('课程偏移设置'),
                description: const Text('正数错后开学日期，负数提前开学日期'),
                value: Text(
                    "目前为 ${preference.getInt(preference.Preference.swift)}"),
                onPressed: (content) {
                  showDialog(
                    context: context,
                    builder: (context) => ChangeSwiftDialog(),
                  ).then((value) {
                    Get.put(ClassTableController()).updateCurrent();
                    setState(() {});
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('缓存登录设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('查看网络拦截器'),
                onPressed: (context) => alice.showInspector(),
              ),
              SettingsTile.navigation(
                title: const Text('清除缓存后重启'),
                onPressed: (context) async {
                  try {
                    await NetworkSession().clearCookieJar();
                  } on PathNotFoundException {
                    developer.log(
                      "No cookies at present",
                      name: "Setting ClearAllCache",
                    );
                  }

                  /// Clean Classtable cache.
                  var file = File(
                    "${supportPath.path}/${ClassTableFile.schoolClassName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  file = File(
                    "${supportPath.path}/${ExamController.examDataCacheName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  file = File(
                    "${supportPath.path}/${ExperimentSession.experimentCacheName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  if (mounted) {
                    Fluttertoast.showToast(msg: 'Cookie 已被清除');
                    Restart.restartApp();
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('退出登录并重启应用'),
                onPressed: (context) async {
                  ProgressDialog pd = ProgressDialog(context: context);
                  pd.show(msg: '正在退出登录');

                  /// Clean Cookie
                  try {
                    await NetworkSession().clearCookieJar();
                    // I don't care.
                    // ignore: empty_catches
                  } on Exception {}

                  /// Clean Classtable cache.
                  var file = File(
                    "${supportPath.path}/${ClassTableFile.schoolClassName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  file = File(
                    "${supportPath.path}/${ClassTableFile.userDefinedClassName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  file = File(
                    "${supportPath.path}/${ExamController.examDataCacheName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  file = File(
                    "${supportPath.path}/${ExperimentSession.experimentCacheName}",
                  );
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  /// Clean user information
                  preference.prefrenceClear();

                  /// Theme back to default
                  ThemeController toChange = Get.put(ThemeController());
                  toChange.onUpdate();

                  /// Restart app
                  if (mounted) {
                    pd.close();
                    Restart.restartApp();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
