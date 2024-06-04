// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  final String urlApple = "https://www.bilibili.com/video/BV1LV4y1R7sY/";

  final String urlOthers = "https://www.bilibili.com/video/BV1yk4y127tn/";

  final String articleUrlApple = "https://www.bilibili.com/video/BV1EN411K7Ac/";

  final String articleUrlOthers =
      "https://www.bilibili.com/video/BV1ux411Q7Ev/";

  final String songApple = '''
不要偷吃西瓜。
''';

  final String songOthers = '''
这个人影响了我们80年代的音乐审美。
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("你找到了彩蛋")),
      body: [
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(
              Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
            ),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text("听歌时间"),
        ).padding(vertical: 20),
        Text(Platform.isIOS || Platform.isMacOS ? songApple : songOthers,
            textAlign: TextAlign.center),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(
              Platform.isIOS || Platform.isMacOS
                  ? articleUrlApple
                  : articleUrlOthers,
            ),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text("了解这个乐队吧"),
        ),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .center()
          .padding(horizontal: 20)
          .scrollable()
          .safeArea(),
    );
  }
}
