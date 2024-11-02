// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

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
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
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
import 'package:watermeter/repository/message_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/setting/dialogs/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/themes/demo_blue.dart';

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
    return Scaffold(
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
              title: _buildListSubtitle('关于'),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: const Text("关于本程序"),
                    subtitle: Text(
                        '版本号：${preference.packageInfo.version}+${preference.packageInfo.buildNumber}'),
                    onTap: () => context.pushReplacement(const AboutPage()),
                    trailing: const Icon(Icons.navigate_next),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("检查软件更新"),
                    subtitle: Obx(
                      () => Text(
                        '最新版本: ${updateMessage.value?.code ?? "等待获取"}',
                      ),
                    ),
                    onTap: () {
                      ProgressDialog pd = ProgressDialog(context: context);
                      pd.show(msg: '正在获取更新信息');
                      checkUpdate().then((value) async {
                        pd.close();
                        if (context.mounted) {
                          if (value && updateMessage.value != null) {
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
                              msg: "目前您运行的是最新稳定版",
                            );
                          }
                        }
                      }, onError: (e, s) {
                        pd.close();
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: "获取更新信息失败",
                          );
                        }
                      });
                    },
                    trailing: const Icon(Icons.navigate_next),
                  ),
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
              bottomRow: Column(children: [
                ListTile(
                    title: const Text('设置深浅色'),
                    subtitle: Text(demoBlueModeName[
                        preference.getInt(preference.Preference.brightness)]),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => const ChangeBrightnessDialog());
                    }),
                const Divider(),
                ListTile(
                  title: const Text("简化日程时间轴"),
                  subtitle: const Text("没有日程时 减少空间占用"),
                  trailing: Switch(
                    value: preference
                        .getBool(preference.Preference.simplifiedClassTimeline),
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
            title: _buildListSubtitle('账号设置'),
            remaining: const [],
            bottomRow: Column(
              children: [
                if (!preference.getBool(preference.Preference.role)) ...[
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
                ],
                if (preference.getBool(preference.Preference.role)) ...[
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
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => ElectricityAccountDialog(),
                        );
                      }),
                ],
                const Divider(),
                ListTile(
                    title: const Text('电费帐号密码设置'),
                    subtitle: const Text('非 123456 请设置'),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const ElectricityPasswordDialog(),
                      );
                    }),
              ],
            ),
          ),
          ReXCard(
            title: _buildListSubtitle('课表相关设置'),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: const Text("开启课表背景图"),
                  trailing: Switch(
                    value: preference.getBool(preference.Preference.decorated),
                    onChanged: (bool value) {
                      if (value == true &&
                          !preference
                              .getBool(preference.Preference.decoration)) {
                        showToast(context: context, msg: '你先选个图片罢，就在下面');
                      } else {
                        setState(() {
                          preference.setBool(
                              preference.Preference.decorated, value);
                        });
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('课表背景图选择'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () async {
                    FilePickerResult? result;
                    try {
                      result = await pickFile(type: FileType.image);
                    } on MissingStoragePermissionException {
                      if (context.mounted) {
                        showToast(context: context, msg: "未获取存储权限，无法读取文件");
                      }
                    }
                    if (mounted) {
                      if (result != null) {
                        File(result.files.single.path!).copySync(
                            "${supportPath.path}/${ClassTableFile.decorationName}");
                        preference.setBool(
                            preference.Preference.decoration, true);
                        if (context.mounted) {
                          showToast(context: context, msg: '设定成功');
                        }
                      } else {
                        if (context.mounted) {
                          showToast(context: context, msg: '你没有选图片捏');
                        }
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("清除所有用户添加课程"),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("确认对话框"),
                      content: const Text(
                        "是否要清除所有用户添加课程？"
                        "这个功能对从学校获取的日程没有影响。",
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
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
                            showToast(context: context, msg: "已经清除完毕");
                            Navigator.pop(context);
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text("强制刷新课表"),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("确认对话框"),
                      content: const Text(
                        "是否要强制刷新课表？同意后，"
                        "将会从学校一站式后端重新获取课表，耗时会比较久。",
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.put(ClassTableController())
                                .updateClassTable(isForce: true);
                            Navigator.pop(context);
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('课程偏移设置'),
                  subtitle: Text(
                    '正数错后开学日期 负数提前开学日期\n'
                    '目前为 ${preference.getInt(preference.Preference.swift)}',
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
            title: _buildListSubtitle('缓存登录设置'),
            remaining: const [],
            bottomRow: Column(
              children: [
                ListTile(
                  title: const Text('查看网络拦截器和日志'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => context.push(TalkerScreen(talker: log)),
                ),
                const Divider(),
                ListTile(
                  title: const Text('清除缓存后重启'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("确认对话框"),
                      content: const Text(
                        "确定清除缓存后重启程序？",
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd =
                                ProgressDialog(context: context);
                            pd.show(msg: "正在清理缓存");
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
                              showToast(context: context, msg: '缓存已被清除');
                              Restart.restartApp();
                            }
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('退出登录并重启应用'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("确认对话框"),
                      content: const Text(
                        "确定退出登录？你的所有数据将会被彻底删除！",
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            ProgressDialog pd =
                                ProgressDialog(context: context);
                            pd.show(msg: '正在退出登录');

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

void _removeAll() {
  for (var value in [
    ClassTableFile.schoolClassName,
    ClassTableFile.userDefinedClassName,
    ClassTableFile.partnerClassName,
    ClassTableFile.decorationName,
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
