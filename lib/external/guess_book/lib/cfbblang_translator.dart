// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';
import 'package:yaml/yaml.dart';

const Map<String, String> _alphabet = {
  "l": "1",
  "o": "0",
  "a": "4",
  "e": "3",
  "t": "7",
  "i": "1",
  "g": "9",
  "q": "9",
  "s": "5",
};

const Map<String, List<String>> _syllables = {
  "wu": ["🈚️"],
  "fei": ["💴"],
  "da": ["🐘"],
  "kai": ["🔓"],
  "hui": ["🩶"],
  "yi": ["①", "Ⅰ", "🥻", "➖"],
  "er": ["②", "Ⅱ", "👂🏻"],
  "san": ["③", "Ⅲ", "🌂", "🥪", "☘", "📐"],
  "si": ["④", "Ⅳ", "似", "☠️"],
  "liu": ["⑥", "Ⅵ"],
  "qi": ["⑦", "Ⅶ", "🚴🏿"],
  "ba": ["⑧", "Ⅷ", "👨🏻"],
  "jiu": ["⑨", "Ⅸ", "🍷"],
  "shi": ["⑩", "Ⅹ", "🪨", "💩"],
  "zhi": ["🈯", "☞", "🧻", "📃"],
  "chou": ["🚬"],
  "xiang": ["🐘"],
  "biao": ["⌚"],
  "de": ["🉐"],
  "niu": ["🐂"],
  "hu": ["🐅"],
  "ma": ["🤱🏻"],
  "yang": ["🐏", "☀"],
  "hou": ["🐒"],
  "mo": ["👺"],
  "ji": ["🐔", "✈️"],
  "gou": ["🐕", "🐶"],
  "suan": ["🍋"],
  "ku": ["🆒", "😭", "🥲"],
  "le": ["🤣"],
  "she": ["🐍"],
  "zhu": ["🐖"],
  "long": ["🐉"],
  "zhong": ["🀄️"],
  "hua": ["🌸"],
  "fa:": ["🇫🇷"],
  "fang": ["◻️"],
  "ran": ["🔥"],
  "shu": ["📕", "🐀", "📖"],
  "ru": ["🧴"],
  "ben": ["📕", "📖"],
  "jiao": ["🦵", "🔈", "🎺", "🗣", "🗣", "🗣"],
  "chong": ["🏄‍"],
  "bi": ["🖊"],
  "gao": ["⛏"],
  "suo": ["🔒"],
  "jian": ["➖"],
  "jing": ["🚨"],
  "dao": ["🔪"],
  "guai": ["🧞"],
  "shuo": ["🗣"],
  "deng": ["🟰", "🛋️"],
  "chu": ["÷", "➗️"],
  "cheng": ["×", "❌", "✖"],
  "jia": ["＋", "➕", "⛽", "🏠"],
  "you": ["👉", "🈶"],
  "ce": ["🚻"],
  "cao": ["🌿"],
  "lang": ["🌊", "🐺"],
  "tu": ["🐇"],
  "cai": ["👎", "🥬"],
  "men": ["🚪"],
  "ju": ["🍊"],
  "nao": ["🧠"],
  "bu": ["⛔", "🚫", "🖐🏻"],
  "guo": ["🍎"],
  "he": ["⚛️"],
  "sheng": ["🔊"],
  "xian": ["🧵"],
  "mu": ["🤱🏻"],
  "shou": ["🖐🏻", "📻"],
  "zai": ["♻️"],
  "shang": ["👆"],
  "xia": ["👇"],
  "zuo": ["👈"],
  "xiao": ["🏫"],
  "hei": ["👨🏿"],
  "kong": ["🈳"],
  "guan": ["📴"],
  "qing": ["🌤"],
  "dong": ["🕳"],
  "yao": ["💊"],
  "kan": ["👀"],
};

// 此表只收录不含文字、字母的完整 emoji；读音基于原 CFBB 表。
const Map<String, List<String>> _emojiSyllables = {
  'wu': ['🚫'], 'fei': ['💴'], 'da': ['🐘'], 'kai': ['🔓'],
  'hui': ['🩶'], 'yi': ['🥻', '➖'], 'er': ['👂🏻'],
  'san': ['🌂', '🥪', '☘️', '📐'], 'si': ['☠️'],
  'liu': ['🌊'], 'qi': ['🚴🏿'], 'ba': ['👨🏻'], 'jiu': ['🍷'],
  'zhi': ['🧻', '📃'], 'chou': ['🚬'],
  'xiang': ['🐘'], 'biao': ['⌚'], 'de': ['✨'], 'niu': ['🐂'],
  'hu': ['🐅'], 'ma': ['🤱🏻'], 'yang': ['🐏', '☀️'], 'hou': ['🐒'],
  'mo': ['👺'], 'ji': ['🐔', '✈️'], 'gou': ['🐕', '🐶'],
  'suan': ['🍋'], 'ku': ['😭', '🥲'], 'le': ['🤣'], 'she': ['🐍'],
  'zhu': ['🐖'], 'long': ['🐉'], 'zhong': ['🔔'], 'hua': ['🌸'],
  'fang': ['◻️'], 'ran': ['🔥'], 'shu': ['📕', '🐀', '📖'],
  'ru': ['🧴'],
  'ben': ['📕', '📖'],
  'jiao': ['🦵', '🔈', '🎺', '🗣️', '🗣️', '🗣️'],
  'chong': ['🏄'], 'bi': ['🖊️'], 'gao': ['⛏️'], 'suo': ['🔒'],
  'jian': ['➖'], 'jing': ['🚨'], 'dao': ['🔪'], 'guai': ['🧞'],
  'shuo': ['🗣️'], 'deng': ['🟰', '🛋️'], 'chu': ['➗'],
  'cheng': ['❌', '✖️'], 'jia': ['➕', '⛽', '🏠'], 'you': ['👉'],
  'ce': ['🚻'], 'cao': ['🌿'], 'lang': ['🌊', '🐺'], 'tu': ['🐇'],
  'cai': ['👎', '🥬'], 'men': ['🚪'], 'ju': ['🍊'], 'nao': ['🧠'],
  'bu': ['⛔', '🚫', '🖐🏻'], 'guo': ['🍎'], 'he': ['⚛️'],
  'sheng': ['🔊'], 'xian': ['🧵'], 'mu': ['🤱🏻'], 'shou': ['🖐🏻', '📻'],
  'zai': ['♻️'], 'shang': ['👆'], 'xia': ['👇'], 'zuo': ['👈'],
  'xiao': ['🏫'], 'hei': ['👨🏿'], 'kong': ['🕳️'], 'guan': ['📴'],
  'qing': ['🌤️'], 'dong': ['🕳️'], 'yao': ['💊'], 'kan': ['👀'],
  // 补充书名中常见的同音线索。
  'liang': ['💡'], 'nian': ['📅'], 'bai': ['⚪'],
  'hong': ['🔴'], 'lan': ['🔵'], 'lv': ['🟢'], 'huang': ['🟡'],
  'ren': ['🧑'], 'hai': ['🌊'], 'shan': ['⛰️'], 'tian': ['🌤️'],
  'ye': ['🌃', '🍃'], 'feng': ['🌬️'],
  'xin': ['❤️'], 'lao': ['👴'], 'tou': ['🗣️'], 'nv': ['👩'],
  'zi': ['👶'], 'wang': ['👑'], 'gong': ['🏹'], 'gu': ['🍄'],
  'du': ['🦄'], 'ping': ['🍎'], 'fan': ['🍚'], 'jie': ['🌐'],
  'shi': ['🪨', '💩', '🍅'], 'ri': ['☀️'], 'yun': ['☁️'],
  'xing': ['⭐', '🚶'], 'yue': ['🌙'], 'chun': ['🌱'], 'shui': ['💧'],
  'di': ['🚇'], 'guang': ['💡'], 'ming': ['💡'], 'yu': ['🐟', '🌧️'],
  // 根据题库中缺失的读音补充同音或近义线索。
  'a': ['😮'], // 啊
  'ai': ['❤️'], // 爱
  'an': ['🛡️'], // 安
  'bang': ['💷'], // 镑
  'bao': ['👶', '💎'], // 宝
  'bian': ['💩'], // 便
  'bing': ['🧊'], // 冰
  'cha': ['🍵'], // 茶
  'chang': ['🌭'], // 肠
  'chao': ['🌅'], // 朝
  'chi': ['😋'], // 吃
  'chuan': ['🚢'], // 船
  'chui': ['🌬️'], // 吹
  'dai': ['🎗️'], // 带
  'dang': ['🔔'], // 铛
  'dian': ['🏪'], // 店
  'diao': ['🦅'], // 雕
  'dou': ['🫘'], // 豆
  'duo': ['🌼'], // 朵
  'fa': ['💇'], // 发
  'fu': ['👨‍🍼', '🧧'], // 父、福
  'gang': ['🏺'], // 缸
  'ge': ['🕊️'], // 鸽
  'gei': ['🤲'], // 给
  'gui': ['👻'], // 鬼
  'heng': ['➖'], // 横
  'huo': ['🔥'], // 火
  'jin': ['🥇'], // 金
  'kuai': ['🥢'], // 筷
  'kun': ['🐛'], // 昆虫
  'li': ['🍐'], // 梨
  'lian': ['⛓️'], // 链
  'liao': ['🦜'], // 鹩
  'lin': ['🌲'], // 林
  'ling': ['🔔'], // 铃
  'luan': ['🥚'], // 卵
  'luo': ['🐪', '🍂', '🐚'], // 骆、落、螺
  'lü': ['🟢'], // 绿
  'mai': ['🌾'], // 麦
  'man': ['🐌'], // 慢
  'mao': ['🐈', '🪶'], // 猫、毛
  'mei': ['🌹'], // 玫
  'meng': ['😴'], // 梦
  'min': ['👨‍🌾'], // 民
  'nan': ['🎃'], // 南瓜
  'ni': ['🫵'], // 你
  'niao': ['🐦'], // 鸟
  'nong': ['👨‍🌾'], // 农
  'nü': ['👩'], // 女
  'ou': ['🎎'], // 偶
  'pin': ['🏚️'], // 贫
  'qian': ['💴'], // 钱
  'qiang': ['🧱'], // 墙
  'qiu': ['🏀'], // 球
  'se': ['🎨'], // 色
  'shen': ['🗽'], // 神
  'shuang': ['👯'], // 双
  'song': ['🌲'], // 松
  'sui': ['🌾'], // 穗
  'tai': ['☀️'], // 太阳
  'tan': ['⚱️'], // 坛
  'tang': ['🍬'], // 糖
  'ti': ['🧍'], // 体
  'tie': ['🔩'], // 铁
  'tong': ['👶'], // 童
  'tuo': ['🐪'], // 驼
  'wa': ['👶'], // 娃
  'wai': ['🌍'], // 外
  'wan': ['🥣'], // 碗
  'wei': ['🧣'], // 围巾
  'wen': ['🦟'], // 蚊
  'wo': ['🐌'], // 蜗
  'xi': ['🌄'], // 夕
  'xiong': ['🐻'], // 熊
  'xu': ['🤫'], // 嘘
  'yan': ['🪨'], // 岩
  'yin': ['🥈'], // 银
  'ying': ['🦅'], // 鹰
  'yong': ['🏊'], // 泳
  'yuan': ['⭕'], // 圆
  'zan': ['👍'], // 赞
  'zen': ['🤔'], // 怎么
  'zhan': ['⚔️'], // 战
  'zhe': ['🐝'], // 蜇
  'zheng': ['🪁'], // 筝
  'zhuang': ['🏡'], // 庄
  'zhui': ['🏃'], // 追
  'zong': ['🍙'], // 粽
  'zu': ['🦶'], // 足
  'zuan': ['💎'], // 钻
  'zui': ['👄'], // 嘴
};

// const Map<String, String> _phrases = {
//   "啥b": "😅",
//   "可可": "🍥🥹可可",
//   "0xcafebabe": "☕👶🏻",
//   "cafebabe": "☕👶🏻",
//   "我": "👴",
//   "luo": "🐕",
//   "信号": "📶",
//   "xkm": "🐱",
//   "电脑": "💻",
//   "企鹅": "🐧",
//   "厕所": "🚻",
//   "wc": "🚾",
//   "?": "❓",
//   "？": "❓",
//   "豆腐": "🧈",
// };

/// 将文字转换为 CFBB 语言。
///
/// 每次调用会随机选择同音替换和字母变形。大括号内的占位符保持不变。
/// 可注入 [random]，以便复现或测试随机结果。
class CfbbLangTranslator {
  CfbbLangTranslator({Random? random}) : _random = random ?? Random();

  final Random _random;
  static final RegExp _placeholder = RegExp(r'\{.*?\}');
  static const _pinyinOptions = PinyinOptions(
    toneType: ToneType.none,
    toneSandhi: false,
  );

  /// 将汉字按读音转换成不含汉字或字母图标的 emoji。
  /// 没有对应表情的字用 ❓ 表示；非汉字不会出现在结果中。
  String translateToEmoji(String text) {
    final result = StringBuffer();
    for (final rune in text.runes) {
      final isHan =
          (rune >= 0x3400 && rune <= 0x9fff) ||
          (rune >= 0x20000 && rune <= 0x323af);
      if (!isHan) continue;
      final reading =
          pinyin(String.fromCharCode(rune), options: _pinyinOptions) as String;
      final choices = _emojiSyllables[reading];
      result.write(
        choices == null ? '❓' : choices[_random.nextInt(choices.length)],
      );
    }
    return result.isEmpty ? '❓' : result.toString();
  }

  String translate(String text) {
    final result = StringBuffer();
    var start = 0;
    for (final match in _placeholder.allMatches(text)) {
      result.write(_translateText(text.substring(start, match.start)));
      result.write(match.group(0));
      start = match.end;
    }
    result.write(_translateText(text.substring(start)));
    return result.toString();
  }

  String _translateText(String text) {
    // for (final entry in _phrases.entries) {
    //   text = text.replaceAll(entry.key, entry.value);
    // }

    final result = StringBuffer();
    for (final rune in text.runes) {
      final original = String.fromCharCode(rune);
      final reading = pinyin(original, options: _pinyinOptions) as String;
      final choices = _syllables[reading];
      final replacement = choices == null
          ? original
          : choices[_random.nextInt(choices.length)];
      for (final character in replacement.runes) {
        final value = String.fromCharCode(character);
        final change = _random.nextInt(112596) + 1919 <= 88100;
        final circle = _random.nextInt(21) <= 10;
        if (change && circle && value.toLowerCase() == 'o') {
          result.write('⭕️');
        } else if (change && _alphabet.containsKey(value.toLowerCase())) {
          result.write(_alphabet[value.toLowerCase()]);
        } else {
          result.write(value);
        }
      }
    }
    return result.toString();
  }

  /// 递归转换映射和列表中的字符串值；映射的键保持不变。
  Object? translateData(Object? value) {
    if (value is String) return translate(value);
    if (value is Map) {
      return value.map((key, item) => MapEntry(key, translateData(item)));
    }
    if (value is List) return value.map(translateData).toList();
    return value;
  }

  /// 对 YAML 中的字符串值进行转换，并返回 JSON，与原脚本的输出格式一致。
  String translateYamlToJson(String yaml) =>
      jsonEncode(translateData(loadYaml(yaml)));
}
