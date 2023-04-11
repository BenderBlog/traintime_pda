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
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/main.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/login/login.dart';
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
              SettingsTile.navigation(
                title: const Text('Traintime PDA by BenderBlog'),
                value: const Text(
                    "版本号 Pre-Alpha 0.0.4, MPL v2.0\n(codename watermeter)"),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://github.com/BenderBlog/watermeter"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              SettingsTile.navigation(
                  title: const Text('用户信息'),
                  value: Text("${user["name"]} ${user["execution"]}\n"
                      "${user["institutes"]} ${user["subject"]}")),
            ],
          ),
          SettingsSection(
            title: const Text('颜色设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: const Text('设置程序主题色'),
                  value: const Text("改变程序的色调，符合你的品味"),
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
                  title: const Text('体适能密码'),
                  value: const Text("你体育帐号密码，要是忘了找体育部"),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => const SportPasswordDialog(),
                    );
                  }),
              SettingsTile.navigation(
                  title: const Text('电费帐号密码'),
                  value: const Text("如果你的密码不是123456，请修改这里"),
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
                  value: const Text("为应对某些紧急状况，可通过这个调整开学日期\n"
                      "输入负数提前开学日期，输入正数延后开学日期\n"
                      "(希望以后没有因为疫情导致提前上下学期课程的情况，tmd 这大学真白上了)"),
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
                  value: const Text("把你的对象搁课程表上面，上课没事就看(这不神经病)"),
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
                title: const Text('清除 Cookie'),
                value: const Text("清除所有 Cookie，适用于重新登录"),
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
                title: const Text('退出登录'),
                value: const Text("返回登录界面"),
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

                  /// Return homepage
                  if (mounted) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginWindow()));
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('Alice 拦截器查看'),
                value: const Text("查询本软件网络通讯状况"),
                onPressed: (context) => alice.showInspector(),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('关于本软件'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('受到这个软件的启发'),
                value: const Text("Robotxm's Myxdu (电表)"),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://myxdu.moefactory.com/"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: Make your attack 4 times stronger, ALSO AN ANGRILY FACE.
                // onPressed: (context) => _playEffect("QuadDamage.wav"),
              ),
              SettingsTile.navigation(
                title: const Text('网络逻辑'),
                value: const Text("西电开源社区的 Xidian-Script"),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://github.com/xdlinux/xidian-scripts"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: You don't need to fear about anything, even Shub-Niggurath...
                // onPressed: (context) => _playEffect("HellProtecting.wav"),
              ),
              SettingsTile.navigation(
                title: const Text('西电目录数据提供商'),
                value: const Text("hawa130, SuperBart, and others."),
                onPressed: (context) => launchUrl(
                  Uri.parse("https://ncov.hawa130.com/about"),
                  mode: LaunchMode.externalApplication,
                ),
                // Quake: ...with the power of HELL, the updown Pentagram.
                // onPressed: (context) => _playEffect("HellProtection.wav"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
