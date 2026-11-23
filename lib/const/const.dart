// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/features/settings/presentation/models/developer.dart';
import 'package:watermeter/features/settings/presentation/models/link.dart';

const double sheetMaxWidth = 600;

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

const String versionDescription = 'NOEL - PDA Third Year Anniversary Edition';

final List<Developer> developers = [
  Developer(
    "A1nair",
    "https://avatars.githubusercontent.com/u/36269472",
    (t) => t.settings.aboutPage.alnair,
    "https://github.com/A1nair",
  ),
  Developer(
    "aqqkad (Kevin)",
    "https://avatars.githubusercontent.com/u/97880629",
    (t) => t.settings.aboutPage.aqqkad,
    "https://github.com/aqqkad",
  ),
  Developer(
    "BellssGit",
    "https://avatars.githubusercontent.com/u/107785251",
    (t) => t.settings.aboutPage.bellssgit,
    "https://space.bilibili.com/17772726",
  ),
  Developer(
    "BenderBlog Rodriguez",
    "https://avatars.githubusercontent.com/u/14026321",
    (t) => t.settings.aboutPage.benderblog,
    "https://space.bilibili.com/284290692",
  ),
  Developer(
    "BrackRat",
    "https://avatars.githubusercontent.com/u/35328547",
    (t) => t.settings.aboutPage.brackrat,
    "https://github.com/BrackRat",
  ),
  Developer(
    "Breezeline",
    "https://avatars.githubusercontent.com/u/74224286",
    (t) => t.settings.aboutPage.breezeline,
    "mailto:ydzhang.ruc@gmail.com",
  ),
  Developer(
    "0xCAFEBABE",
    "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
    (t) => t.settings.aboutPage.cafebabe,
    "https://blog.hxzzz.asia/",
  ),
  Developer(
    "chitao1234",
    "https://avatars.githubusercontent.com/u/25598632",
    (t) => t.settings.aboutPage.chitao1234,
    "https://github.com/chitao1234",
  ),
  Developer(
    "CopperKoi",
    "https://avatars.githubusercontent.com/u/91732947",
    (t) => t.settings.aboutPage.copperkoi,
    "https://copperkoi.cn/about",
  ),
  Developer(
    "DaMi (Kangwenqiao)",
    "https://avatars.githubusercontent.com/u/118408678",
    (t) => t.settings.aboutPage.dami,
    "https://github.com/Kangwenqiao",
  ),
  Developer(
    "Dimole",
    "https://avatars.githubusercontent.com/u/24828354",
    (t) => t.settings.aboutPage.dimole,
    "https://github.com/Dimole",
  ),
  Developer(
    "EliteWars",
    "https://avatars.githubusercontent.com/u/44139545",
    (t) => t.settings.aboutPage.elitewars,
    "https://space.bilibili.com/49892391/",
  ),
  Developer(
    "Mother Elliot Flores",
    "https://legacy.superbart.top/picture/Random/hirasawa.jpg",
    (t) => t.settings.aboutPage.elliot,
    "https://mp.weixin.qq.com/s/_egmj3rjwOTAB-KHzKsYGw",
  ),
  Developer(
    "FlyingPig278",
    "https://avatars.githubusercontent.com/u/88129602",
    (t) => t.settings.aboutPage.flyingpig,
    "https://github.com/FlyingPig278",
  ),
  Developer(
    "GodHu777777",
    "https://avatars.githubusercontent.com/u/111997394",
    (t) => t.settings.aboutPage.godhu777777,
    "https://github.com/GodHu777777",
  ),
  Developer(
    "Hancl777",
    "https://avatars.githubusercontent.com/u/74408609",
    (t) => t.settings.aboutPage.hancl777,
    "https://github.com/Hancl777",
  ),
  Developer(
    "Hazuki Keatsu (叶月枫)",
    "https://avatars.githubusercontent.com/u/111259147",
    (t) => t.settings.aboutPage.hazukiKeatsu,
    "https://keatsu.top",
  ),
  Developer(
    "hawa130",
    "https://avatars.githubusercontent.com/u/26119430",
    (t) => t.settings.aboutPage.hawa130,
    "https://hawa130.com/",
  ),
  Developer(
    "hhzm (闪电豹猫)",
    "https://avatars.githubusercontent.com/u/19224718",
    (t) => t.settings.aboutPage.hhzm,
    "https://hhzm.win/",
  ),
  Developer(
    "imaginary_17",
    "https://avatars.githubusercontent.com/u/70046513",
    (t) => t.settings.aboutPage.imaginary17,
    "https://github.com/clever-max",
  ),

  Developer(
    "imoscarz",
    "https://avatars.githubusercontent.com/u/52318095",
    (t) => t.settings.aboutPage.imoscarz,
    "https://imoscarz.me/",
  ),
  Developer(
    "Ka-mate-ka-ora",
    "https://avatars.githubusercontent.com/u/187651078",
    (t) => t.settings.aboutPage.kaMateKaOra,
    "https://github.com/Ka-mate-ka-ora/",
  ),
  Developer(
    "L1angYun",
    "https://avatars.githubusercontent.com/u/76769653",
    (t) => t.settings.aboutPage.l1angyun,
    "https://github.com/L1angYun",
  ),
  Developer(
    "Lagrange-X",
    "https://avatars.githubusercontent.com/u/110022915",
    (t) => t.settings.aboutPage.lagrangeX,
    "https://github.com/Lagrange-X/",
  ),
  Developer(
    "lhx-666-cool",
    "https://avatars.githubusercontent.com/u/63273792",
    (t) => t.settings.aboutPage.lhx666Cool,
    "https://github.com/lhx-666-cool/",
  ),
  Developer(
    "LichtYy",
    "https://avatars.githubusercontent.com/u/105974550",
    (t) => t.settings.aboutPage.lichtyy,
    "https://github.com/lichtYy",
  ),
  Developer(
    "littlestejan",
    "https://avatars.githubusercontent.com/u/40530340",
    (t) => t.settings.aboutPage.littlestejan,
    "https://github.com/littlestejan",
  ),
  Developer(
    "LQSY-H",
    "https://avatars.githubusercontent.com/u/142521812",
    (t) => t.settings.aboutPage.lqsyH,
    "https://github.com/LQSY-H",
  ),
  Developer(
    "lsy223622 (木生睡不着)",
    "https://avatars.githubusercontent.com/u/57913213",
    (t) => t.settings.aboutPage.lsy223622,
    "https://lsy223622.com/",
  ),
  Developer(
    "MrBrilliant2046",
    "https://avatars.githubusercontent.com/u/94728421?v=4",
    (t) => t.settings.aboutPage.mrbrilliant2046,
    "https://github.com/MrBrilliant2046",
  ),
  Developer(
    "NanCunChild",
    "https://avatars.githubusercontent.com/u/85873278?v=4",
    (t) => t.settings.aboutPage.nancunchild,
    "https://github.com/NanCunChild",
  ),
  Developer(
    "nkAnF",
    "https://avatars.githubusercontent.com/u/172456830",
    (t) => t.settings.aboutPage.nkanf,
    "https://github.com/nkanf-dev",
  ),
  Developer(
    "Pairman",
    "https://avatars.githubusercontent.com/u/18365163",
    (t) => t.settings.aboutPage.pairman,
    "https://github.com/Pairman",
  ),
  Developer(
    "ReverierXu",
    "https://avatars.githubusercontent.com/u/41937333",
    (t) => t.settings.aboutPage.reverierxu,
    "https://blog.woooo.tech/",
  ),
  Developer(
    "Rrrilac",
    "https://avatars.githubusercontent.com/u/128341096",
    (t) => t.settings.aboutPage.rrrilac,
    "https://github.com/Rrrilac",
  ),
  Developer(
    "Ray Flores",
    "https://sns-avatar-qc.xhscdn.com/avatar/65fb96e24f8a7c5709c421f2.jpg",
    (t) => t.settings.aboutPage.ray,
    "https://www.xiaohongshu.com/user/profile/63d293990000000026010075",
  ),
  Developer(
    "shadowyingyi",
    "https://avatars.githubusercontent.com/u/42831635",
    (t) => t.settings.aboutPage.shadowyingyi,
    "https://github.com/shadowyingyi",
  ),
  Developer(
    "SixTeenForever",
    "https://avatars.githubusercontent.com/u/184718848",
    (t) => t.settings.aboutPage.sixteenforever,
    "https://github.com/16forever233",
  ),
  Developer(
    "stalomeow",
    "https://avatars.githubusercontent.com/u/47203031",
    (t) => t.settings.aboutPage.stalomeow,
    "https://stalomeow.com",
  ),
  Developer(
    "xeonds",
    "https://avatars.githubusercontent.com/u/68117734",
    (t) => t.settings.aboutPage.xeonds,
    "https://mxts.jiujiuer.xyz",
  ),
  Developer(
    "XingShuyu",
    "https://avatars.githubusercontent.com/u/82715884",
    (t) => t.settings.aboutPage.xingshuyu,
    "https://xingshuyu.github.io",
  ),
  Developer(
    "Xiue233",
    "https://avatars.githubusercontent.com/u/30972246",
    (t) => t.settings.aboutPage.xiue233,
    "https://xiue233.github.io/",
  ),
  Developer(
    "xizi",
    "https://static.wikia.nocookie.net/chiikawa/images/c/c3/Hachi_main.png/revision/latest?cb=20231016011752&path-prefix=zh",
    (t) => t.settings.aboutPage.xizi,
    "https://www.bilibili.com/video/BV1Rg4y1x7su/",
  ),
  Developer(
    "wirsbf",
    "https://avatars.githubusercontent.com/u/144008530",
    (t) => t.settings.aboutPage.wirsbf,
    "https://xiue233.github.io/",
  ),
  Developer(
    "ZCWzy",
    "https://avatars.githubusercontent.com/u/87163986",
    (t) => t.settings.aboutPage.zcwzy,
    "https://github.com/ZCWzy",
  ),
  Developer(
    "ZYar-er",
    "https://avatars.githubusercontent.com/u/95170599?v=4",
    (t) => t.settings.aboutPage.zyarEr,
    "https://github.com/ZYar-er",
  ),
];
