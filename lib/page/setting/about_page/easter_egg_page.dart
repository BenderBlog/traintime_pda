// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Python script by arttnba3

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pinyin/pinyin.dart';

Map<String, int> tableChangeAlphabet = {
  "l": 1,
  "o": 0,
  "a": 4,
  "e": 3,
  "t": 7,
  "i": 1,
  "g": 9,
  "q": 9,
  "s": 5,
};

Map<String, List<String>> abstractTable = {
  'fei': ['💴'],
  'da': ['🐘'],
  'kai': ['🔓'],
  'hui': ['🩶'],
  'yi': ['①', 'Ⅰ', '🥻', '➖'],
  'er': ['②', 'Ⅱ', '👂🏻'],
  'san': ['③', 'Ⅲ', '🌂', '🥪', '☘', '📐'],
  'si': ['④', 'Ⅳ', '似', '☠️'],
  'wu': ['⑤', 'Ⅴ', '🕺🏻', '🈚️'],
  'liu': ['⑥', 'Ⅵ'],
  'qi': ['⑦', 'Ⅶ', '🚴🏿'],
  'ba': ['⑧', 'Ⅷ', '👨🏻'],
  'jiu': ['⑨', 'Ⅸ', '🍷'],
  'shi': ['⑩', 'Ⅹ', '🪨', '💩'],
  'zhi': ['🈯', '☞', '🧻', '📃'],
  'chou': ['🚬'],
  'xiang': ['🐘'],
  'biao': ['⌚'],
  'de': ['🉐'],
  'niu': ['🐂'],
  'hu': ['🐅'],
  'ma': ['🐎', '🤱🏻'],
  'yang': ['🐏', '☀'],
  'hou': ['🐒'],
  'mo': ['👺'],
  'ji': ['🐔', '✈️'],
  'gou': ['🐕', '🐶'],
  'suan': ['🍋'],
  'ku': ['🆒', '😭', '🥲'],
  'le': ['🤣'],
  'she': ['🐍'],
  'zhu': ['🐖', '㊗️'],
  'long': ['🐉', '🐲'],
  'zhong': ['🀄️'],
  'hua': ['🌸'],
  'fa:': ['🇫🇷'],
  'fang': ['◻️'],
  'ran': ['🔥'],
  'shu': ['📕', '🐀', '📖', '🌲'],
  'ru': ['🧴'],
  'ben': ['📕', '📖'],
  'jiao': ['🦵', '🔈', '🎺', '🗣🗣🗣'],
  'chong': ['🏄‍'],
  'bi': ['🖊'],
  'gao': ['⛏'],
  'suo': ['🔒'],
  'jian': ['➖'],
  'jing': ['🚨', '🐋', '🐳'],
  'cuo': ['×'],
  'dao': ['🔪'],
  'guai': ['🧞'],
  'shuo': ['🗣'],
  'deng': ['🟰', '🛋️'],
  'chu': ['÷', '➗️'],
  'cheng': ['×', '❌', '✖'],
  'jia': ['＋', '➕', '⛽', '🏠'],
  'you': ['👉', '🈶'],
  'ce': ['🚻'],
  'cao': ['🌿'],
  'lang': ['🌊', '🐺'],
  'tu': ['🐇'],
  'cai': ['👎', '🥬'],
  'men': ['🚪'],
  'ju': ['🍊'],
  'nao': ['🧠'],
  'bu': ['⛔', '🚫', '🖐🏻'],
  'guo': ['🍎'],
  'he': ['⚛️'],
  'sheng': ['🔊'],
  'xian': ['🧵'],
  'mu': ['🤱🏻'],
  'shou': ['🖐🏻', '📻'],
  'zai': ['♻️'],
  'shang': ['👆'],
  'xia': ['👇'],
  'zuo': ['👈'],
  'xiao': ['🏫'],
  'hei': ['👨🏿'],
  'kong': ['🈳'],
  'guan': ['📴', '🧪'],
  'qing': ['🌤'],
  'dong': ['🕳'],
  'yao': ['💊'],
  'kan': ['👀'],
  'qian': ['💴'],
  'dai': ['🛍️'],
  'lou': ['🏢'],
  'zao': ['🛀'],
  'mao': ['🐱'],
  'ye': ['👴'],
  'ban': ['©️'],
  'neng': ['🉑'],
  'ke': ['🉑'],
  'hao': ['👌'],
  'ken': ['🥺'],
  'ding': ['📌'],
  'bie': ['⑧'],
  'ni': ['🫵'],
  'ri': ['☀', '🌞'],
  'lei': ['💦'],
  'han': ['💦'],
  'shui': ['💦'],
  'xin': ['♥'],
  'yan': ['👀', '🧂'],
  'yin': ['🔈'],
  'dui': ['√'],
  'liang': ['②'],
  'ren': ['🧑'],
  'dan': ['🥚'],
  'lu': ['🦌'],
  'dian': ['⚡'],
  'zhuan': ['🧱'],
  'bing': ['🧊'],
  'gui': ['👻', '🐢'],
  'xiong': ['🐻'],
  'kun': ['😪'],
  'tang': ['🍬'],
  'yue': ['🈷️', '🌙'],
  'jin': ['🈲'],
  'ge': ['🈹'],
  'shao': ['🥄'],
  'gua': ['🍉'],
  'zha': ['💥'],
  'wa': ['🐸'],
  'tian': ['👅'],
  'leng': ['🥶'],
};

Map<String, String> abstractTableMulti = {
  '0xcafebabe': '☕👶🏻',
  '咖啡': '☕',
  '宝贝': '👶',
  'cafebabe': '☕👶🏻',
  '我': '👴',
  '信号': '📶',
  '电脑': '💻',
  '可可': '🍫',
  '企鹅': '🐧',
  '厕所': '🚻',
  'wc': '🚾',
  '?': '❓',
  '？': '❓',
  '豆腐': '🧈',
  '网安大楼': '🌃',
  '小丑': '🤡',
  '击剑': '🤺',
  'sos': '🆘',
  'atm': '🏧',
  'rx': '↱χ',
  'RX': '↱χ',
  'Rx': '↱χ',
};

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  final String urlApple = "https://www.bilibili.com/video/BV1wN4y1L7Ut";

  final String urlOthers = "https://www.bilibili.com/video/BV1HN411Y7Ct?p=7";

  TextEditingController inputController = TextEditingController(
    text: Platform.isIOS
        ? '''
[Verse 1]
Let it roll across the floor
Through the hall and out the door
To the fountain of perpetual mirth
Let it roll for all it's worth

我们穿过大堂而去
穿过大厅，出门而去
向着永远充满欢乐的源头前进
为了欢乐，我们一起前进

[Verse 2]
Find me where ye echo lays
Lose ye bodies in the maze
See the Lord and all the mouths he feeds
Let it roll among the weeds

在回声中找到我
你在迷宫中迷失
看到上天和芸芸众生
我们穿过草丛而去

[Chorus]
Let it roll

我们继续前进吧

(Sir Frankie Crisp
Oh, Sir Frankie Crisp
Oh, Sir Frankie Crisp
Oh, Sir Frankie Crisp)

[Verse 3]
Let it roll down through the caves
Ye long walks of Coole and Shades
Through ye woode, here may ye rest awhile
Handkerchiefs to match your tie

我们继续穿过洞穴
从阴凉中走过
在树丛下，他休息了一下
拿出手帕擦擦汗

[Chorus]
Let it roll...

我们继续前进吧

[Verse 4]
Fools illusions everywhere
Joan and Molly sweeps the stairs
Eyes are shining full of inner light
Let it roll into the night

街上都是麻木的人
小明和小红在擦楼梯
在夜晚他们的眼睛很明亮
我们在这夜晚中前进吧

Ballad of Sir Frankie Crisp (Let It Roll)
by George Harrison
from All Things Must Pass, 1970

Ray and Elliot are thinking privately about pulling Partner Classtable request for my program since July, 2024.
'''
        : '''
And may you never lay your head down
Without a hand to hold
May you never make your bed out in the cold

请你不要在无人支持时低下头颅
愿你不要孤身一人

You’re just like a great strong brother of mine
You know that I love you true
And you never talk dirty behind my back
And I know that there’s those that do

你就像我坚强的哥哥
我真的爱你
有人在背后说我的坏话
而你从不

Oh please won’t you, please won’t you
Bear it in mind
Love is a lesson to learn in our time
Now please won’t you, please won’t you
Bear it in mind for me

请你不要忘记
爱是你我生命中的必修课
请你不要 请你不要 请你不要忘记
请你牢记在心

John Martyn, covered by Eric Clapton
from Slowhand, 1977

Translated by Ray (Elliot Edition)
Ray and Elliot are thinking privately about pulling Partner Classtable request for my program since July, 2024.
''',
  );

  TextEditingController resultController = TextEditingController();

  void onSubmitted() {
    String value = inputController.text;
    for (var i in abstractTableMulti.entries) {
      value = value.replaceAll(i.key, i.value);
    }

    List<String> toReturn = value.split('');
    for (int i = 0; i < toReturn.length; ++i) {
      String pinyin = PinyinHelper.getPinyinE(toReturn[i]);
      if (abstractTable.containsKey(pinyin)) {
        toReturn[i] = abstractTable[pinyin]
                ?[Random().nextInt(abstractTable[pinyin]?.length ?? 0 - 1)] ??
            toReturn[i];
      }
      bool change1 = Random().nextBool();
      bool change2 = Random().nextBool();
      if (toReturn[i].toLowerCase() == 'o' && change1 && change2) {
        toReturn[i] = '⭕️';
      }
      if (change1 &&
          tableChangeAlphabet.containsKey(toReturn[i].toLowerCase())) {
        toReturn[i] =
            tableChangeAlphabet[toReturn[i].toLowerCase()]?.toString() ??
                toReturn[i];
      }
    }
    resultController.text = toReturn.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("你找到了彩蛋")),
      body: [
        const SizedBox(height: 16.0),
        TextFormField(
          maxLines: null,
          minLines: 1,
          controller: inputController,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        )
            .padding(horizontal: 12)
            .decorated(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            )
            .expanded(),
        const SizedBox(height: 8),
        [
          TextButton(
            onPressed: onSubmitted,
            child: const Text("加密上面的文本"),
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text("听歌时间"),
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlOthers : urlApple,
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text("听另一首歌"),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        const SizedBox(height: 8),
        TextField(
          controller: resultController,
          readOnly: true,
          maxLines: null,
          minLines: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        )
            .padding(horizontal: 12)
            .decorated(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            )
            .expanded(),
        const SizedBox(height: 16.0),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .center()
          .padding(horizontal: 16)
          .safeArea(),
    );
  }
}
