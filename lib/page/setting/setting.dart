/*
Setting window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restart_app/restart_app.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/setting/subwindow/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/subwindow/sport_password_dialog.dart';
import 'package:watermeter/page/setting/subwindow/change_swift_dialog.dart';
import 'package:watermeter/page/setting/subwindow/change_color_dialog.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/general.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({Key? key}) : super(key: key);

  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SettingsList(
        lightTheme: SettingsThemeData(
            settingsListBackground: Theme.of(context).colorScheme.background),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text('XDYou 0.0.5'),
                value: const Text('Codebase Traintime PDA 0.0.5'),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://github.com/BenderBlog/watermeter"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              SettingsTile(
                title: const Text('用户信息'),
                value: Text("${user["name"]} ${user["execution"]}\n"
                    "${user["institutes"]} ${user["subject"]}"),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('颜色设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: const Text('设置程序主题色'),
                  value: Text(
                      ColorSeed.values[int.parse(user["color"] ?? "0")].label),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const ChangeColorDialog(),
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
                  title: const Text('电费帐号密码设置'),
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
              SettingsTile.navigation(
                  title: const Text('课程偏移设置'),
                  value: Text("目前为 ${user["swift"] ?? '0'}"),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => ChangeSwiftDialog(),
                    );
                  }),
              SettingsTile.switchTile(
                title: const Text("开启课表背景图"),
                initialValue:
                    user["decorated"] != null && user["decorated"]! == "true"
                        ? true
                        : false,
                onToggle: (bool value) {
                  if (value == true &&
                      (user["decoration"] == null ||
                          user["decoration"]!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('你先选个图片罢，就在下面'),
                    ));
                  } else {
                    setState(() {
                      addUser("decorated", value.toString());
                    });
                  }
                },
              ),
              SettingsTile.navigation(
                  title: const Text('课表背景图选择'),
                  onPressed: (content) async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (mounted) {
                      if (result != null) {
                        Directory appDocDir =
                            await getApplicationDocumentsDirectory();
                        Directory destination = Directory(
                            "${appDocDir.path}/org.superbart.watermeter");
                        if (!destination.existsSync()) {
                          await destination.create();
                        }
                        var decorated = File(result.files.single.path!)
                            .copySync("${destination.path}/decoration.jpg");
                        addUser("decoration", decorated.path);
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('设定成功'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('你没有选捏，目前设置${user["decoration"]}'),
                        ));
                      }
                    }
                  }),
            ],
          ),
          SettingsSection(
            title: const Text('缓存登录设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text("Alice 网络拦截器"),
                onPressed: (context) => alice.showInspector(),
              ),
              SettingsTile.navigation(
                title: const Text('清除 Cookie'),
                onPressed: (context) async {
                  try {
                    await IDSCookieJar.deleteAll();
                    await SportCookieJar.deleteAll();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Cookie 已被清除'),
                      ));
                    }
                  } on PathNotFoundException {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('目前没有缓存 Cookie'),
                    ));
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('退出登录并重启应用'),
                onPressed: (context) async {
                  /// Clean Cookie
                  try {
                    await IDSCookieJar.deleteAll();
                    await SportCookieJar.deleteAll();
                    // I don't care.
                    // ignore: empty_catches
                  } on Exception {}

                  /// Clean Classtable cache.
                  Directory appDocDir =
                      await getApplicationDocumentsDirectory();
                  Directory destination =
                      Directory("${appDocDir.path}/org.superbart.watermeter");
                  if (!destination.existsSync()) {
                    await destination.create();
                  }
                  var file = File("${destination.path}/ClassTable.json");
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  /// Clean user information
                  prefrenceClear();

                  /// Theme back to default
                  ThemeController toChange = Get.put(ThemeController());
                  toChange.onUpdate();

                  /// Restart app
                  if (mounted) {
                    Restart.restartApp();
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('关于本软件'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('Developed by BenderBlog Rodriguez'),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://legacy.superbart.xyz/"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: Make your attack 4 times stronger, ALSO AN ANGRILY FACE.
                // onPressed: (context) => _playEffect("QuadDamage.wav"),
              ),
              SettingsTile(
                title: const Text('受到 Myxdu (电表)启发'),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://myxdu.moefactory.com/"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: Make your attack 4 times stronger, ALSO AN ANGRILY FACE.
                // onPressed: (context) => _playEffect("QuadDamage.wav"),
              ),
              SettingsTile(
                title: const Text('网络逻辑 xidian-script'),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://github.com/xdlinux/xidian-scripts"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: You don't need to fear about anything, even Shub-Niggurath...
                // onPressed: (context) => _playEffect("HellProtecting.wav"),
              ),
              SettingsTile(
                title: const Text('西电目录原版'),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://ncov.hawa130.com/about"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: ...with the power of HELL, the updown Pentagram.
                // onPressed: (context) => _playEffect("HellProtection.wav"),
              ),
              SettingsTile(
                title: const Text('Apple 硬件支援者自画像'),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Self-Portrait of this person"),
                      content: Image.asset("assets/Ray.jpg"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("文章"),
                          onPressed: () => launchUrl(
                            Uri.parse("https://www.coolapk.com/feed/45104934"),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        TextButton(
                          child: const Text("确定"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
