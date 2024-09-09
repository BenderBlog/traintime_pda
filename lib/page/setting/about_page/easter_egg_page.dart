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
  'zhu': ['🐖'],
  'long': ['🐉'],
  'zhong': ['🀄️'],
  'hua': ['🌸'],
  'fa:': ['🇫🇷'],
  'fang': ['◻️'],
  'ran': ['🔥'],
  'shu': ['📕', '🐀', '📖'],
  'ru': ['🧴'],
  'ben': ['📕', '📖'],
  'jiao': ['🦵', '🔈', '🎺', '🗣🗣🗣'],
  'chong': ['🏄‍'],
  'bi': ['🖊'],
  'gao': ['⛏'],
  'suo': ['🔒'],
  'jian': ['➖'],
  'jing': ['🚨'],
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
  'ri': ['☀'],
  'lei': ['💦'],
  'han': ['💦'],
  'shui': ['💦'],
  'xin': ['♥'],
  'yan': ['👀'],
  'yin': ['🔈'],
  'dui': ['√'],
  'liang': ['②'],
  'ren': ['🧑'],
  'dan': ['🥚'],
  'lu': ['🦌'],
  'dian': ['⚡'],
  'zhuan': ['🧱'],
  'bing': ['🧊'],
  'gui': ['👻'],
  'xiong': ['🐻'],
  'kun': ['😪'],
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
  final String urlApple = "https://www.bilibili.com/video/BV1mN411C7QV/";

  final String urlOthers = "https://www.bilibili.com/video/BV1mN411C7QV/";

  TextEditingController inputController = TextEditingController(
    text: '''
Let us cling together as the years go by,
Oh my love, my love,
In the quiet of the night
Let our candle always burn,
Let us never lose the lessons we have learned.

手を取り合って このまま行こう
愛する人よ
静かな宵に
光を灯し
愛しき教えを抱き

让我们随着时间一起手牵手
我的爱人
在夜深之时
我们的光芒永现
不要忘记来时的荆棘丛生

Brain May and The Queens
A Day at the Races, 1976
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
