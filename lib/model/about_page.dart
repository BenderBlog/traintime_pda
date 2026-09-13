// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

const String urlOthers = "https://www.bilibili.com/video/BV1tW411n7eW";

const String urlApple = "https://www.bilibili.com/video/BV1Dt411Y7a5";

const String urlAll = "https://www.bilibili.com/video/BV1z57n6NETg?t=1094.5";

class Link {
  final String nameKey;
  final IconData icon;
  final String url;

  const Link({required this.nameKey, required this.icon, required this.url});
}

const List<Link> linkData = [
  Link(
    icon: Icons.home,
    nameKey: "setting.about_page.homepage",
    url: "https://xdyou.superbart.top",
  ),
  Link(
    icon: Icons.code,
    nameKey: "setting.about_page.code",
    url: "https://github.com/BenderBlog/traintime_pda",
  ),
];

class Developer {
  final String name;
  final String imageUrl;
  final String descriptionI18nKey;
  final String url;
  const Developer(this.name, this.imageUrl, this.descriptionI18nKey, this.url);
}

const List<Developer> getDevelopers = [
  Developer(
    "A1nair",
    "https://avatars.githubusercontent.com/u/36269472",
    "setting.about_page.alnair",
    "https://github.com/A1nair",
  ),
  Developer(
    "aqqkad (Kevin)",
    "https://avatars.githubusercontent.com/u/97880629",
    "setting.about_page.aqqkad",
    "https://github.com/aqqkad",
  ),
  Developer(
    "BellssGit",
    "https://avatars.githubusercontent.com/u/107785251",
    "setting.about_page.bellssgit",
    "https://space.bilibili.com/17772726",
  ),
  Developer(
    "BenderBlog Rodriguez",
    "https://avatars.githubusercontent.com/u/14026321",
    "setting.about_page.benderblog",
    "https://space.bilibili.com/284290692",
  ),
  Developer(
    "BrackRat",
    "https://avatars.githubusercontent.com/u/35328547",
    "setting.about_page.brackrat",
    "https://github.com/BrackRat",
  ),
  Developer(
    "Breezeline",
    "https://avatars.githubusercontent.com/u/74224286",
    "setting.about_page.breezeline",
    "mailto:ydzhang.ruc@gmail.com",
  ),
  Developer(
    "0xCAFEBABE",
    "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
    "setting.about_page.cafebabe",
    "https://blog.hxzzz.asia/",
  ),
  Developer(
    "chitao1234",
    "https://avatars.githubusercontent.com/u/25598632",
    "setting.about_page.chitao1234",
    "https://github.com/chitao1234",
  ),
  Developer(
    "CopperKoi",
    "https://avatars.githubusercontent.com/u/91732947",
    "setting.about_page.copperkoi",
    "https://copperkoi.cn/about",
  ),
  Developer(
    "Dimole",
    "https://avatars.githubusercontent.com/u/24828354",
    "setting.about_page.dimole",
    "https://github.com/Dimole",
  ),
  Developer(
    "EliteWars",
    "https://avatars.githubusercontent.com/u/44139545",
    "setting.about_page.elitewars",
    "https://space.bilibili.com/49892391/",
  ),
  Developer(
    "Mother Elliot Flores",
    "https://legacy.superbart.top/picture/Random/hirasawa.jpg",
    "setting.about_page.elliot",
    "https://mp.weixin.qq.com/s/_egmj3rjwOTAB-KHzKsYGw",
  ),
  Developer(
    "FlyingPig278",
    "https://avatars.githubusercontent.com/u/88129602",
    "setting.about_page.flyingpig",
    "https://github.com/FlyingPig278",
  ),
  Developer(
    "GodHu777777",
    "https://avatars.githubusercontent.com/u/111997394",
    "setting.about_page.godhu777777",
    "https://github.com/GodHu777777",
  ),
  Developer(
    "Hancl777",
    "https://avatars.githubusercontent.com/u/74408609",
    "setting.about_page.hancl777",
    "https://github.com/Hancl777",
  ),
  Developer(
    "Hazuki Keatsu (叶月枫)",
    "https://avatars.githubusercontent.com/u/111259147",
    "setting.about_page.hazuki-keatsu",
    "https://keatsu.top",
  ),
  Developer(
    "hawa130",
    "https://avatars.githubusercontent.com/u/26119430",
    "setting.about_page.hawa130",
    "https://hawa130.com/",
  ),
  Developer(
    "hhzm (闪电豹猫)",
    "https://avatars.githubusercontent.com/u/19224718",
    "setting.about_page.hhzm",
    "https://hhzm.win/",
  ),
  Developer(
    "imaginary_17",
    "https://avatars.githubusercontent.com/u/70046513",
    "setting.about_page.imaginary_17",
    "https://github.com/clever-max",
  ),

  Developer(
    "imoscarz",
    "https://avatars.githubusercontent.com/u/52318095",
    "setting.about_page.imoscarz",
    "https://imoscarz.me/",
  ),
  Developer(
    "Ka-mate-ka-ora",
    "https://avatars.githubusercontent.com/u/187651078",
    "setting.about_page.ka-mate-ka-ora",
    "https://github.com/Ka-mate-ka-ora/",
  ),
  Developer(
    "Lagrange-X",
    "https://avatars.githubusercontent.com/u/110022915",
    "setting.about_page.lagrange-x",
    "https://github.com/Lagrange-X/",
  ),
  Developer(
    "lhx-666-cool",
    "https://avatars.githubusercontent.com/u/63273792",
    "setting.about_page.lhx-666-cool",
    "https://github.com/lhx-666-cool/",
  ),
  Developer(
    "LichtYy",
    "https://avatars.githubusercontent.com/u/105974550",
    "setting.about_page.lichtyy",
    "https://github.com/lichtYy",
  ),
  Developer(
    "LQSY-H",
    "https://avatars.githubusercontent.com/u/142521812",
    "setting.about_page.lqsy-h",
    "https://github.com/LQSY-H",
  ),
  Developer(
    "lsy223622 (木生睡不着)",
    "https://avatars.githubusercontent.com/u/57913213",
    "setting.about_page.lsy223622",
    "https://lsy223622.com/",
  ),
  Developer(
    "MrBrilliant2046",
    "https://avatars.githubusercontent.com/u/94728421?v=4",
    "setting.about_page.mrbrilliant2046",
    "https://github.com/MrBrilliant2046",
  ),
  Developer(
    "NanCunChild",
    "https://avatars.githubusercontent.com/u/85873278?v=4",
    "setting.about_page.nancunchild",
    "https://github.com/NanCunChild",
  ),
  Developer(
    "nkAnF",
    "https://avatars.githubusercontent.com/u/172456830",
    "setting.about_page.nkanf",
    "https://github.com/nkanf-dev",
  ),
  Developer(
    "Pairman",
    "https://avatars.githubusercontent.com/u/18365163",
    "setting.about_page.pairman",
    "https://github.com/Pairman",
  ),
  Developer(
    "ReverierXu",
    "https://avatars.githubusercontent.com/u/41937333",
    "setting.about_page.reverierxu",
    "https://blog.woooo.tech/",
  ),
  Developer(
    "Rrrilac",
    "https://avatars.githubusercontent.com/u/128341096",
    "setting.about_page.rrrilac",
    "https://github.com/Rrrilac",
  ),
  Developer(
    "Ray Flores",
    "https://sns-avatar-qc.xhscdn.com/avatar/65fb96e24f8a7c5709c421f2.jpg",
    "setting.about_page.ray",
    "https://www.xiaohongshu.com/user/profile/63d293990000000026010075",
  ),
  Developer(
    "shadowyingyi",
    "https://avatars.githubusercontent.com/u/42831635",
    "setting.about_page.shadowyingyi",
    "https://github.com/shadowyingyi",
  ),
  Developer(
    "stalomeow",
    "https://avatars.githubusercontent.com/u/47203031",
    "setting.about_page.stalomeow",
    "https://stalomeow.com",
  ),
  Developer(
    "xeonds",
    "https://avatars.githubusercontent.com/u/68117734",
    "setting.about_page.xeonds",
    "https://mxts.jiujiuer.xyz",
  ),
  Developer(
    "XingShuyu",
    "https://avatars.githubusercontent.com/u/82715884",
    "setting.about_page.xingshuyu",
    "https://xingshuyu.github.io",
  ),
  Developer(
    "Xiue233",
    "https://avatars.githubusercontent.com/u/30972246",
    "setting.about_page.xiue233",
    "https://xiue233.github.io/",
  ),
  Developer(
    "xizi",
    "https://static.wikia.nocookie.net/chiikawa/images/c/c3/Hachi_main.png/revision/latest?cb=20231016011752&path-prefix=zh",
    "setting.about_page.xizi",
    "https://www.bilibili.com/video/BV1Rg4y1x7su/",
  ),
  Developer(
    "wirsbf",
    "https://avatars.githubusercontent.com/u/144008530",
    "setting.about_page.wirsbf",
    "https://xiue233.github.io/",
  ),
  Developer(
    "ZCWzy",
    "https://avatars.githubusercontent.com/u/87163986",
    "setting.about_page.zcwzy",
    "https://github.com/ZCWzy",
  ),
  Developer(
    "ZYar-er",
    "https://avatars.githubusercontent.com/u/95170599?v=4",
    "setting.about_page.zyar-er",
    "https://github.com/ZYar-er",
  ),
];
