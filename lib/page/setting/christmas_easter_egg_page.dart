// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  final String url = "https://www.bilibili.com/video/BV1P54y1B7F8/";

  final String articleUrl = "https://www.bilibili.com/read/cv28967035/";

  final String song = '''
Where is my perfect kiss...

The Perfect Kiss / New Order

Credit: Gillian Gilbert, Peter Hook, Stephen Morris & Bernard Sumner, 1985

I stood there beside myself
Thinking hard about the weather
They came by a friend of mine
Suggested we go out together
Then I knew it from the start
This friend of mine would fall apart
Pretending not to see his guilt
I said "Let's go out and have some fun"

I know you know
We believe in a land of love

I have always thought about
Staying in and going out
Tonight I should have stayed at home
Playing with my pleasure zone
He has always been so strange
I'd often thought he was deranged
Pretending not to see his gu
I said "Let's go out and have some fun"

I know, you know
We believe in a land of love

写歌的都不知道他们在写啥，要啥翻译啊
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("你找到了彩蛋")),
      body: ListView(children: [
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text("听歌时间"),
        ),
        Text(song, textAlign: TextAlign.center).padding(vertical: 10),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(articleUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text("了解这个乐队吧"),
        ),
      ]),
    );
  }
}
