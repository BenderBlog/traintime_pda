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

  /// Play easter egg sound effect.
  final player = AudioPlayer();
  void _playEffect(String soundRoute) async {
    await player.play(AssetSource(soundRoute));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('体育查询设置'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.run_circle_outlined),
              title: const Text('体适能密码'),
              onPressed: (content) {
                showDialog(
                    context: context,
                    builder: (context) => const SportPasswordDialog(),
                );
              }
            ),
          ],
        ),
        SettingsSection(
          title: const Text('关于本软件'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              title: const Text('Main Developer'),
              value: const Text("BenderBlog"),
              onPressed: (context) => _playEffect("Megahealth.wav"),
            ),
            SettingsTile.navigation(
              title: const Text('Inspired by'),
              value: const Text("Robotxm's Myxdu"),
              onPressed: (context) => _playEffect("QuadDamage.wav"),
            ),
            SettingsTile.navigation(
              title: const Text('Backend'),
              value: const Text("Xidian-script by Xidian Open Source Community"),
              onPressed: (context) => _playEffect("HellProtecting.wav"),
            ),
            SettingsTile.navigation(
              title: const Text('Xidian Directory Backend'),
              value: const Text("hawa130"),
              onPressed: (context) => _playEffect("HellProtection.wav"),
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
  final TextEditingController _sportPasswordController = TextEditingController.fromValue(
      TextEditingValue(
        text: user["sportPassword"] == null ? "" : user["sportPassword"]!,
        selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: user["sportPassword"] == null ? 0 : user["sportPassword"]!.length,
            )
        ),
      )
  );

  /// If other things happens, it should be a array.
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
                setState(() { _couldView = !_couldView; print(_couldView); });
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
      actionsPadding: const EdgeInsets.fromLTRB(24,0,12,24),
    );
  }
}
