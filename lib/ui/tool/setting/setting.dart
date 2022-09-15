import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/ui/weight.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              debugPrint("保存设置后退出");
              Navigator.pop(context);
            },
          ),
        ],
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

  final player = AudioPlayer();

  /// Play easter egg sound effect.
  void _playEffect(String soundRoute) async {
    await player.play(AssetSource(soundRoute));
  }

  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('体育查询设置'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.run_circle_outlined),
              title: Text('体适能密码'),
              value: TextField(
                controller: _sportPasswordController,
                obscureText: true,
              ),
            ),
          ],
        ),
        SettingsSection(
          title: const Text('关于本软件'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              title: Text('Main Developer'),
              value: Text("BenderBlog"),
              onPressed: (context) => _playEffect("Megahealth.wav"),
            ),
            SettingsTile.navigation(
              title: Text('Inspired by'),
              value: Text("Robotxm's Myxdu"),
              onPressed: (context) => _playEffect("QuadDamage.wav"),
            ),
            SettingsTile.navigation(
              title: Text('Backend'),
              value: Text("Xidian-script by Xidian Open Source Community"),
              onPressed: (context) => _playEffect("HellProtecting.wav"),
            ),
            SettingsTile.navigation(
              title: Text('Xidian Directory Backend'),
              value: Text("hawa130"),
              onPressed: (context) => _playEffect("HellProtection.wav"),
            ),

          ],
        ),
      ],
    );
  }
}
