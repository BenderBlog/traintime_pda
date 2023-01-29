/*
Setting window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/model/user.dart';

class SettingWindow extends StatelessWidget {
  const SettingWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F6),
      appBar: AppBar(
        title: const Text("设置页"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const SettingDetails(),
    );
  }
}

class SettingDetails extends StatefulWidget {
  const SettingDetails({Key? key}) : super(key: key);

  @override
  State<SettingDetails> createState() => _SettingDetailsState();
}

class _SettingDetailsState extends State<SettingDetails> {
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('用户相关'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                title: const Text('用户信息'),
                value: Text("${user["name"]} ${user["execution"]}\n"
                    "${user["institutes"]} ${user["subject"]}")),
            SettingsTile.navigation(
                title: const Text('退出登录'),
                value: const Text("退出登录该帐号，该帐号在本地的所有信息均将被删除！")),
          ],
        ),
        SettingsSection(
          title: const Text('体育查询设置'),
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
          ],
        ),
        SettingsSection(
          title: const Text('课表相关设置'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                title: const Text('课程偏移设置'),
                value: const Text("为应对某些紧急状况，可通过这个调整开学日期"),
                onPressed: (content) {
                  showDialog(
                    context: context,
                    builder: (context) => const SportPasswordDialog(),
                  );
                }),
            SettingsTile.navigation(
                title: const Text('强制设置学期'),
                value: const Text("强制获取该学期的课表，要没有数据可不怪我啊"),
                onPressed: (content) {
                  showDialog(
                    context: context,
                    builder: (context) => const SportPasswordDialog(),
                  );
                }),
            SettingsTile.navigation(
                title: const Text('课表背景图'),
                value: const Text("好看是好看了，但可能会导致课表卡顿"),
                onPressed: (content) {
                  showDialog(
                    context: context,
                    builder: (context) => const SportPasswordDialog(),
                  );
                }),
          ],
        ),
        SettingsSection(
          title: const Text('关于本软件'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              title: const Text('Watermeter 水表 by BenderBlog'),
              value: const Text("版本号 Pre-Alpha 0.0.2, MPL v2.0"),
              onPressed: (context) => launchUrl(
                Uri.parse("https://github.com/BenderBlog/watermeter"),
                mode: LaunchMode.externalApplication,
              ),
            ),
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
    );
  }
}

class SportPasswordDialog extends StatefulWidget {
  const SportPasswordDialog({Key? key}) : super(key: key);

  @override
  State<SportPasswordDialog> createState() => _SportPasswordDialogState();
}

class _SportPasswordDialogState extends State<SportPasswordDialog> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController =
      TextEditingController.fromValue(TextEditingValue(
    text: user["sportPassword"] == null ? "" : user["sportPassword"]!,
    selection: TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: user["sportPassword"] == null ? 0 : user["sportPassword"]!.length,
    )),
  ));

  bool _couldView = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改体适能密码'),
      content: TextField(
        controller: _sportPasswordController,
        obscureText: _couldView,
        decoration: InputDecoration(
          hintText: "请在此输入密码",
          suffixIcon: IconButton(
              icon: Icon(_couldView ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _couldView = !_couldView;
                });
              }),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消更改'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            debugPrint(_sportPasswordController.text);
            addUser("sportPassword", _sportPasswordController.text);
            Navigator.of(context).pop();
          },
          child: const Text(
            '提交',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
    );
  }
}
