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
  // Babe I am leaving you, for myself...
  // God damn, where's my babe
  final String urlApple = "https://www.bilibili.com/video/BV1Td8ceJEFb/";

  final String urlOthers = "https://www.bilibili.com/video/BV1HN411Y7Ct?p=7";

  TextEditingController inputController = TextEditingController(
    text: Platform.isIOS
        ? '''
for myself...

[Verse 1]
Babe, baby, baby, I'm gonna leave you
I said baby, you know I'm gonna leave you
I'll leave you when the summertime
Leave you when the summer comes a-rollin'
Leave you when the summer comes along

我的宝贝，我将在夏季结束之时离开你

[Verse 2]
Babe, babe, babe, babe, babe, babe, baby
Baby, I wanna leave you
I ain't joking' woman, I've got to ramble
Oh, yeah, baby, baby, I believin'
We really got to ramble (I can hear it callin' me)
I can hear it callin' me the way it used to do
I can hear it callin' me back home

我要去探求未知，他跟往常一样让我回到之前

[Bridge]
Oh, babe, I'm gonna leave you
Oh, baby, you know
I've really got to leave you
Oh, I can hear it callin' me
I said don't you hear it callin' me the way it used to do?
Ooohh

我听到他让我回到之前了，你听不到吗

[Verse 3]
I know, I know, I know I never, never, never, never, never
Gonna leave you, babe
But I got to go away from this place
I've got to quit you, yeah
Oh, baby, baby, baby, baby, baby, baby, baby
Oh, don't you hear it callin' me?

我真的一点 一点 一点都不想离开你啊
但我真的要走了，那催促声你听不到吗

Woman, woman, I know, I know
It feels good to have you back again
And I know that one day, baby
It's gonna really grow, yes it is
We gonna go walkin' through the park
Every day

我明白，我们俩还会再见，在春天万物复苏的时候
到那时，我们再不分开的样子多好啊

Come what may, every day, oh
My, my, my, my, my, my babe
I'm gonna leave you, go away

每天不分开，但我现在不得不离开你了啊

[Bridge]
Oh, I miss you, baby
It was really, really good
You made me happy every single day
But now, I've got to go away
Ooh, oh, oh

我已经怀念你，每天你是我的光
但我必须得走了

[Outro]
Baby, baby, baby
That's when it's callin' me
I said that's when it's callin' me
Back home

宝贝啊 宝贝啊 这就是催促我回到之前的 声音啊

Babe I’m Gonna Leave You
by Anne Bredon
arranged by Jimmy Page and Robert Plant
from Led Zeppelin, 1969

Ray and Elliot are thinking privately about pulling Partner Classtable request for my program since July, 2024.
'''
        : '''
And may you never lay your head down
Without a hand to hold
May you never make your bed out in the cold

You’re just like a great strong brother of mine
You know that I love you true
And you never talk dirty behind my back
And I know that there’s those that do

Oh please won’t you, please won’t you
Bear it in mind
Love is a lesson to learn in our time
Now please won’t you, please won’t you
Bear it in mind for me

请你不要在无人支持时低下头颅
愿你不要孤身一人
你就像我坚强的哥哥
我真的爱你
有人在背后说我的坏话
而你从不


请你不要忘记
爱是你我生命中的必修课
不
请你不要 请你不要 请你不要忘记
请你
牢记在心

John Martyn, covered by Eric Clapton
Slowhand, 1977

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
