// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/generated/translations.g.dart';

const String urlOthers = "https://www.bilibili.com/video/BV1tW411n7eW";

const String urlApple = "https://www.bilibili.com/video/BV1Dt411Y7a5";

const String urlAll = "https://www.bilibili.com/video/BV1z57n6NETg?t=1094.5";

enum LinkName { homepage, code }

class Link {
  final LinkName name;
  final IconData icon;
  final String url;

  const Link({required this.name, required this.icon, required this.url});

  String resolve(Translations t) {
    switch (name) {
      case LinkName.homepage: return t.setting.aboutPage.homepage;
      case LinkName.code: return t.setting.aboutPage.code;
    }
  }
}

const List<Link> linkData = [
  Link(
    icon: Icons.home,
    name: LinkName.homepage,
    url: "https://xdyou.superbart.top",
  ),
  Link(
    icon: Icons.code,
    name: LinkName.code,
    url: "https://github.com/BenderBlog/traintime_pda",
  ),
];

class Developer {
  final String name;
  final String imageUrl;
  final String Function(Translations t) description;
  final String url;
  const Developer(this.name, this.imageUrl, this.description, this.url);
}

final List<Developer> getDevelopers = [
  Developer(
    "A1nair",
    "https://avatars.githubusercontent.com/u/36269472",
    (t) => t.setting.aboutPage.alnair,
    "https://github.com/A1nair",
  ),
  Developer(
    "aqqkad (Kevin)",
    "https://avatars.githubusercontent.com/u/97880629",
    (t) => t.setting.aboutPage.aqqkad,
    "https://github.com/aqqkad",
  ),
  Developer(
    "BellssGit",
    "https://avatars.githubusercontent.com/u/107785251",
    (t) => t.setting.aboutPage.bellssgit,
    "https://space.bilibili.com/17772726",
  ),
  Developer(
    "BenderBlog Rodriguez",
    "https://avatars.githubusercontent.com/u/14026321",
    (t) => t.setting.aboutPage.benderblog,
    "https://space.bilibili.com/284290692",
  ),
  Developer(
    "BrackRat",
    "https://avatars.githubusercontent.com/u/35328547",
    (t) => t.setting.aboutPage.brackrat,
    "https://github.com/BrackRat",
  ),
  Developer(
    "Breezeline",
    "https://avatars.githubusercontent.com/u/74224286",
    (t) => t.setting.aboutPage.breezeline,
    "mailto:ydzhang.ruc@gmail.com",
  ),
  Developer(
    "0xCAFEBABE",
    "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
    (t) => t.setting.aboutPage.cafebabe,
    "https://blog.hxzzz.asia/",
  ),
  Developer(
    "chitao1234",
    "https://avatars.githubusercontent.com/u/25598632",
    (t) => t.setting.aboutPage.chitao1234,
    "https://github.com/chitao1234",
  ),
  Developer(
    "CopperKoi",
    "https://avatars.githubusercontent.com/u/91732947",
    (t) => t.setting.aboutPage.copperkoi,
    "https://copperkoi.cn/about",
  ),
  Developer(
    "Dimole",
    "https://avatars.githubusercontent.com/u/24828354",
    (t) => t.setting.aboutPage.dimole,
    "https://github.com/Dimole",
  ),
  Developer(
    "EliteWars",
    "https://avatars.githubusercontent.com/u/44139545",
    (t) => t.setting.aboutPage.elitewars,
    "https://space.bilibili.com/49892391/",
  ),
  Developer(
    "Mother Elliot Flores",
    "https://legacy.superbart.top/picture/Random/hirasawa.jpg",
    (t) => t.setting.aboutPage.elliot,
    "https://mp.weixin.qq.com/s/_egmj3rjwOTAB-KHzKsYGw",
  ),
  Developer(
    "FlyingPig278",
    "https://avatars.githubusercontent.com/u/88129602",
    (t) => t.setting.aboutPage.flyingpig,
    "https://github.com/FlyingPig278",
  ),
  Developer(
    "GodHu777777",
    "https://avatars.githubusercontent.com/u/111997394",
    (t) => t.setting.aboutPage.godhu777777,
    "https://github.com/GodHu777777",
  ),
  Developer(
    "Hancl777",
    "https://avatars.githubusercontent.com/u/74408609",
    (t) => t.setting.aboutPage.hancl777,
    "https://github.com/Hancl777",
  ),
  Developer(
    "Hazuki Keatsu (叶月枫)",
    "https://avatars.githubusercontent.com/u/111259147",
    (t) => t.setting.aboutPage.hazukiKeatsu,
    "https://keatsu.top",
  ),
  Developer(
    "hawa130",
    "https://avatars.githubusercontent.com/u/26119430",
    (t) => t.setting.aboutPage.hawa130,
    "https://hawa130.com/",
  ),
  Developer(
    "hhzm (闪电豹猫)",
    "https://avatars.githubusercontent.com/u/19224718",
    (t) => t.setting.aboutPage.hhzm,
    "https://hhzm.win/",
  ),
  Developer(
    "imaginary_17",
    "https://avatars.githubusercontent.com/u/70046513",
    (t) => t.setting.aboutPage.imaginary17,
    "https://github.com/clever-max",
  ),

  Developer(
    "imoscarz",
    "https://avatars.githubusercontent.com/u/52318095",
    (t) => t.setting.aboutPage.imoscarz,
    "https://imoscarz.me/",
  ),
  Developer(
    "Ka-mate-ka-ora",
    "https://avatars.githubusercontent.com/u/187651078",
    (t) => t.setting.aboutPage.kaMateKaOra,
    "https://github.com/Ka-mate-ka-ora/",
  ),
  Developer(
    "Lagrange-X",
    "https://avatars.githubusercontent.com/u/110022915",
    (t) => t.setting.aboutPage.lagrangeX,
    "https://github.com/Lagrange-X/",
  ),
  Developer(
    "lhx-666-cool",
    "https://avatars.githubusercontent.com/u/63273792",
    (t) => t.setting.aboutPage.lhx666Cool,
    "https://github.com/lhx-666-cool/",
  ),
  Developer(
    "LichtYy",
    "https://avatars.githubusercontent.com/u/105974550",
    (t) => t.setting.aboutPage.lichtyy,
    "https://github.com/lichtYy",
  ),
  Developer(
    "LQSY-H",
    "https://avatars.githubusercontent.com/u/142521812",
    (t) => t.setting.aboutPage.lqsyH,
    "https://github.com/LQSY-H",
  ),
  Developer(
    "lsy223622 (木生睡不着)",
    "https://avatars.githubusercontent.com/u/57913213",
    (t) => t.setting.aboutPage.lsy223622,
    "https://lsy223622.com/",
  ),
  Developer(
    "MrBrilliant2046",
    "https://avatars.githubusercontent.com/u/94728421?v=4",
    (t) => t.setting.aboutPage.mrbrilliant2046,
    "https://github.com/MrBrilliant2046",
  ),
  Developer(
    "NanCunChild",
    "https://avatars.githubusercontent.com/u/85873278?v=4",
    (t) => t.setting.aboutPage.nancunchild,
    "https://github.com/NanCunChild",
  ),
  Developer(
    "nkAnF",
    "https://avatars.githubusercontent.com/u/172456830",
    (t) => t.setting.aboutPage.nkanf,
    "https://github.com/nkanf-dev",
  ),
  Developer(
    "Pairman",
    "https://avatars.githubusercontent.com/u/18365163",
    (t) => t.setting.aboutPage.pairman,
    "https://github.com/Pairman",
  ),
  Developer(
    "ReverierXu",
    "https://avatars.githubusercontent.com/u/41937333",
    (t) => t.setting.aboutPage.reverierxu,
    "https://blog.woooo.tech/",
  ),
  Developer(
    "Rrrilac",
    "https://avatars.githubusercontent.com/u/128341096",
    (t) => t.setting.aboutPage.rrrilac,
    "https://github.com/Rrrilac",
  ),
  Developer(
    "Ray Flores",
    "https://sns-avatar-qc.xhscdn.com/avatar/65fb96e24f8a7c5709c421f2.jpg",
    (t) => t.setting.aboutPage.ray,
    "https://www.xiaohongshu.com/user/profile/63d293990000000026010075",
  ),
  Developer(
    "shadowyingyi",
    "https://avatars.githubusercontent.com/u/42831635",
    (t) => t.setting.aboutPage.shadowyingyi,
    "https://github.com/shadowyingyi",
  ),
  Developer(
    "stalomeow",
    "https://avatars.githubusercontent.com/u/47203031",
    (t) => t.setting.aboutPage.stalomeow,
    "https://stalomeow.com",
  ),
  Developer(
    "xeonds",
    "https://avatars.githubusercontent.com/u/68117734",
    (t) => t.setting.aboutPage.xeonds,
    "https://mxts.jiujiuer.xyz",
  ),
  Developer(
    "XingShuyu",
    "https://avatars.githubusercontent.com/u/82715884",
    (t) => t.setting.aboutPage.xingshuyu,
    "https://xingshuyu.github.io",
  ),
  Developer(
    "Xiue233",
    "https://avatars.githubusercontent.com/u/30972246",
    (t) => t.setting.aboutPage.xiue233,
    "https://xiue233.github.io/",
  ),
  Developer(
    "xizi",
    "https://static.wikia.nocookie.net/chiikawa/images/c/c3/Hachi_main.png/revision/latest?cb=20231016011752&path-prefix=zh",
    (t) => t.setting.aboutPage.xizi,
    "https://www.bilibili.com/video/BV1Rg4y1x7su/",
  ),
  Developer(
    "wirsbf",
    "https://avatars.githubusercontent.com/u/144008530",
    (t) => t.setting.aboutPage.wirsbf,
    "https://xiue233.github.io/",
  ),
  Developer(
    "ZCWzy",
    "https://avatars.githubusercontent.com/u/87163986",
    (t) => t.setting.aboutPage.zcwzy,
    "https://github.com/ZCWzy",
  ),
  Developer(
    "ZYar-er",
    "https://avatars.githubusercontent.com/u/95170599?v=4",
    (t) => t.setting.aboutPage.zyarEr,
    "https://github.com/ZYar-er",
  ),
];
