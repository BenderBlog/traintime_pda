// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  final String url = "https://www.bilibili.com/video/BV1T34y1n7MF/";

  final String articleUrl = "https://www.bilibili.com/read/cv28967035/";

  final String song = '''
Ceremony / New Order & Joy Division

Credit: Ian Curtis, Peter Hook, Stephen Morris & Bernard Sumner, 1981
With: Gillian Gilbert on Guitar in New Order Version
From: Factory FAC 33 & Still

New Order 是在 Joy Division 的主唱 Ian Curtis 自杀后，剩下组员改的名字。
视频提供的是 New Order 版本，Bernard Sumner 主唱。

Oh, I'll break them down, no mercy shown
哦 我会把他们撕碎 毫不怜悯
Heaven knows, it's got to be this time
天知道 我做的没错
Watching her, these things she said,
注视着她 那些她说过的话
The times she cried
那些她流过泪的时光
Too frail to wake this time
我太脆弱 不能从梦中醒来


Oh I'll break them down, no mercy shown
哦 我会把他们撕碎 毫不怜悯
Heaven knows, it's got to be this time
天知道 我做的没错
Avenues all lined with trees
在路上 林荫映衬
Picture me and then you start watching
想象我的身影 你开始注视
Watching forever
永远的注视
Watching forever
永远的注视
Letting me know, forever
永远让我知晓

我不在乎钱，我在乎把反动和腐旧全部砸毁！
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("你找到了彩蛋")),
      body: [
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text("听歌时间"),
        ).padding(vertical: 20),
        Text(song, textAlign: TextAlign.center),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(articleUrl),
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
