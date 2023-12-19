// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  final String androidSong = '''
Catch the Rainbow / Ritchie Blackmore's Rainbow

Credit: Ronnie James Dio & Ritchie Blackmore, 1975

When evening falls, she'll run to me
当夜晚来临，她会跑向我
Like whispered dreams
Your eyes can't see
像是双眼看不见的低语的梦
Soft and warm, she'll touch my face
轻柔而温暖，她抚摸我的脸庞
A bed of straw
Against the lace
像是衬着花边的稻草床

We believed we'd catch the rainbow
我们相信我们会抓住彩虹
Ride the wind to the sun
御风追赶太阳
Sail away on ships of wonder
乘着奇迹之船远航
But life's not a wheel
但是人生不是
With chains made of steel
按部就班的齿轮
So bless me
所以，为我祈祷吧
Come the dawn
黎明来临
Come the dawn
黎明来临
Come the dawn
黎明快来吧
Come the dawn
快降临吧

We believed we'd catch the rainbow
我们相信我们会抓住彩虹
Ride the wind to the sun
御风追赶太阳
And sail away on ships of wonder
乘着奇迹之船远航
But life's not a wheel
但是生活不是
With chains made of steel
按部就班的齿轮
So bless me, oh bless me, bless me
所以，为我祈祷吧，祝福我，祝福我吧
Come the dawn
黎明来临
''';

  final String appleSong = '''
The Temple of the King / Ritchie Blackmore's Rainbow

Credit: Ronnie James Dio & Ritchie Blackmore, 1975

One day, in the Year of the Fox
在懵懂之年的某一天
Came a time remembered well,
一段令人难忘的时光
When the strong young man of the rising sun
当健壮而年轻的朝阳之子
Heard the tolling of the great black bell.
听见那口黑色大鐘的鐘声响起
One day in the Year of the Fox,
在懵懂之年的某一天
When the bell began to ring,
当鐘声开始响起
It meant the time had come for one to go
意味著某人进入
To the temple of the king.
帝王宫殿的时刻已经来临

There in the middle of the circle he stands,
他站立在圆圈中央
Searching, seeking.
搜索，寻找
With just one touch of his trembling hand,
只要被那颤动的手一经触摸
The answer will be found.
谜底就会揭晓
Daylight waits while the old man sings,
阳光在等候年迈者唱著:
"Heaven help me!"
"上天啊，帮帮我!"
And then like the rush of a thousand wings,
然后像千百双羽翼的扑击般
It shines upon the One.
阳光照在他身上
And the day has just begun.
这一天才刚开始

One day in the Year of the Fox
在懵懂之年的某一天
Came a time remembered well,
一段令人难忘的时光
When the strong young man of the rising sun
当健壮而年轻的朝阳之子
Heard the tolling of the great black bell.
听见那口黑色大鐘的鐘声响起
One day in the Year of the Fox,
在懵懂之年的某一天
When the bell began to sing
当钟声开始响起
It meant the time had come for the One to go
意味著某人进入
To the temple of the king.
帝王宫殿的时刻已经来临

There in the middle of the people he stands,
他站立在圆圈中央
Seeing, feeling.
凝视，感受
With just a wave of the strong right hand, he's gone
那强壮的右手挥一挥动
To the temple of the king.
他进入了帝王的宫殿

Far from the circle, at the edge of the world,
远离圆圈，在世界的边缘
He's hoping, wondering.
他企盼著，犹疑著
Thinking back on the stories he's heard of
回想著他听说过
What he's going to see.
且即将面对的故事
There, in the middle of a circle it lies.
他站立在圆圈中央
"Heaven help me!"
"上天啊，帮帮我!"
Then all could see by the shine in his eyes
从他眼中的光芒里他们都可以看出
The answer had been found.
谜底已然揭晓
Back with the people in the circle he stands,
回到人群中，他在圆圈裡站立著
Giving, feeling.
给予，感受
With just one touch of a strong right hand, they know
只一触碰那强壮的右手，他们知道
Of the temple and the king.
这是帝王和他的宫殿

DO NOT USE DEBIAN GNU/LINUX!
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("圣诞节快乐")),
      body: ListView(children: [
        Image.asset(
          Platform.isIOS || Platform.isMacOS
              ? "assets/uuz_Christmas.jpg"
              : "assets/Bocchi_Christmas.jpg",
          width: 250,
          height: 250,
        ),
        Text(
          Platform.isIOS || Platform.isMacOS ? appleSong : androidSong,
          textAlign: TextAlign.center,
        ).padding(vertical: 10),
      ]),
    );
  }
}
