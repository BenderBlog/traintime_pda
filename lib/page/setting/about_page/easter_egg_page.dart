// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  final String urlApple = "https://www.bilibili.com/video/BV1T34y1n7MF/";

  final String urlOthers = "https://www.bilibili.com/video/BV1rK4y187Z2/";

  final String articleUrlApple = "https://www.bilibili.com/read/cv28967035/";

  final String articleUrlOthers =
      "https://www.bilibili.com/video/BV1tN411v7wD/";

  final String songApple = '''
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

  final String songOthers = '''
Many too Many / Genesis

Credit: Tony Banks, 1978
With: Mike Rutherford on Guitar and Phil Collins on Vocal
From: ...and then there were three...

[第一部分]

Many, too many have stood where I stand
这里之前有很多人体会孤独
Many more will stand here too
之后还会有更多的人
I think what I find strange is the way you built me up
我奇怪的你，怎能之前如此亲密
Then knocked me down again
然后把我又抛弃了

The part was fun but now it's over
之前的甜蜜现在已经没了
Why can't I just leave the stage?
为啥我死活无法忘怀
Maybe that's because you securely locked me up
也许，是你把我安全地锁了起来
Then threw away the key
然后扔掉了钥匙

Oh, mama
Please, would you find the key
天哪，你不要扔掉钥匙啊

Oh, pretty mama
Please, won't you let me go free
求求了，你不想让我自由吗

[过渡段]

I thought I was lucky
I thought that I'd got it made
How could I be so blind?
本以为我多么幸运
本以为是我导致的
我怎么迷乱了内心

[第二部分]

You said goodbye on a corner
你在那个拐角跟我道别
That I thought led to the straight
我本以为可以直接离开
You set me on a firmly laid and simple course
你让我走上了那条告别的直道
Then removed the road
然后你把路拆了

Oh, mama
Please help me find my way
天哪，你给我指条明路吧

Oh, pretty mama
Please lead me through the next day
求求了，请让我看到明日的朝阳吧

[过渡段]

I thought I was lucky
Oh, I thought that I'd got it made
How could I be so blind?
Oh, no
本以为我多么幸运
本以为是我导致的
我怎么迷乱了内心
不要再这样了……

你们不要走啊……
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
