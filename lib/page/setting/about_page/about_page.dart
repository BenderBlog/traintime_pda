// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/setting/about_page/easter_egg_page.dart';
import 'package:watermeter/page/setting/about_page/developer_widget.dart';
import 'package:watermeter/page/setting/about_page/link_widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/generated/translations.g.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final String urlOthers = "https://www.bilibili.com/video/BV1tW411n7eW";

  final String urlApple = "https://www.bilibili.com/video/BV1Dt411Y7a5";

  final String urlAll = "https://www.bilibili.com/video/BV1z57n6NETg?t=1094.5";

  List<Developer> getDevelopers() => [
    Developer(
      "BenderBlog Rodriguez",
      "https://avatars.githubusercontent.com/u/14026321",
      context.t.setting.aboutPage.benderblog,
      "https://space.bilibili.com/284290692",
    ),
    Developer(
      "A1nair",
      "https://avatars.githubusercontent.com/u/36269472",
      context.t.setting.aboutPage.alnair,
      "https://github.com/A1nair",
    ),
    Developer(
      "aqqkad (Kevin)",
      "https://avatars.githubusercontent.com/u/97880629",
      context.t.setting.aboutPage.aqqkad,
      "https://github.com/aqqkad",
    ),
    Developer(
      "BellssGit",
      "https://avatars.githubusercontent.com/u/107785251",
      context.t.setting.aboutPage.bellssgit,
      "https://space.bilibili.com/17772726",
    ),
    Developer(
      "BrackRat",
      "https://avatars.githubusercontent.com/u/35328547",
      context.t.setting.aboutPage.brackrat,
      "https://github.com/BrackRat",
    ),
    Developer(
      "Breezeline",
      "https://avatars.githubusercontent.com/u/74224286",
      context.t.setting.aboutPage.breezeline,
      "mailto:ydzhang.ruc@gmail.com",
    ),
    Developer(
      "0xCAFEBABE",
      "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
      context.t.setting.aboutPage.cafebabe,
      "https://blog.hxzzz.asia/",
    ),
    Developer(
      "chitao1234",
      "https://avatars.githubusercontent.com/u/25598632",
      context.t.setting.aboutPage.chitao1234,
      "https://github.com/chitao1234",
    ),
    Developer(
      "CopperKoi",
      "https://avatars.githubusercontent.com/u/91732947",
      context.t.setting.aboutPage.copperkoi,
      "https://copperkoi.cn/about",
    ),
    Developer(
      "Dimole",
      "https://avatars.githubusercontent.com/u/24828354",
      context.t.setting.aboutPage.dimole,
      "https://github.com/Dimole",
    ),
    Developer(
      "EliteWars",
      "https://avatars.githubusercontent.com/u/44139545",
      context.t.setting.aboutPage.elitewars,
      "https://space.bilibili.com/49892391/",
    ),
    Developer(
      "Mother Elliot Flores",
      "https://legacy.superbart.top/picture/Random/hirasawa.jpg",
      context.t.setting.aboutPage.elliot,
      "https://mp.weixin.qq.com/s/_egmj3rjwOTAB-KHzKsYGw",
    ),
    Developer(
      "FlyingPig278",
      "https://avatars.githubusercontent.com/u/88129602",
      context.t.setting.aboutPage.flyingpig,
      "https://github.com/FlyingPig278",
    ),
    Developer(
      "GodHu777777",
      "https://avatars.githubusercontent.com/u/111997394",
      context.t.setting.aboutPage.godhu777777,
      "https://github.com/GodHu777777",
    ),
    Developer(
      "Hancl777",
      "https://avatars.githubusercontent.com/u/74408609",
      context.t.setting.aboutPage.hancl777,
      "https://github.com/Hancl777",
    ),
    Developer(
      "Hazuki Keatsu (叶月枫)",
      "https://avatars.githubusercontent.com/u/111259147",
      context.t.setting.aboutPage.hazukiKeatsu,
      "https://keatsu.top",
    ),
    Developer(
      "hawa130",
      "https://avatars.githubusercontent.com/u/26119430",
      context.t.setting.aboutPage.hawa130,
      "https://hawa130.com/",
    ),
    Developer(
      "hhzm (闪电豹猫)",
      "https://avatars.githubusercontent.com/u/19224718",
      context.t.setting.aboutPage.hhzm,
      "https://hhzm.win/",
    ),
    Developer(
      "imaginary_17",
      "https://avatars.githubusercontent.com/u/70046513",
      context.t.setting.aboutPage.imaginary17,
      "https://github.com/clever-max",
    ),

    Developer(
      "imoscarz",
      "https://avatars.githubusercontent.com/u/52318095",
      context.t.setting.aboutPage.imoscarz,
      "https://imoscarz.me/",
    ),
    Developer(
      "Ka-mate-ka-ora",
      "https://avatars.githubusercontent.com/u/187651078",
      context.t.setting.aboutPage.kaMateKaOra,
      "https://github.com/Ka-mate-ka-ora/",
    ),
    Developer(
      "Lagrange-X",
      "https://avatars.githubusercontent.com/u/110022915",
      context.t.setting.aboutPage.lagrangeX,
      "https://github.com/Lagrange-X/",
    ),
    Developer(
      "lhx-666-cool",
      "https://avatars.githubusercontent.com/u/63273792",
      context.t.setting.aboutPage.lhx666Cool,
      "https://github.com/lhx-666-cool/",
    ),
    Developer(
      "LichtYy",
      "https://avatars.githubusercontent.com/u/105974550",
      context.t.setting.aboutPage.lichtyy,
      "https://github.com/lichtYy",
    ),
    Developer(
      "LQSY-H",
      "https://avatars.githubusercontent.com/u/142521812",
      context.t.setting.aboutPage.lqsyH,
      "https://github.com/LQSY-H",
    ),
    Developer(
      "lsy223622 (木生睡不着)",
      "https://avatars.githubusercontent.com/u/57913213",
      context.t.setting.aboutPage.lsy223622,
      "https://lsy223622.com/",
    ),
    Developer(
      "MrBrilliant2046",
      "https://avatars.githubusercontent.com/u/94728421?v=4",
      context.t.setting.aboutPage.mrbrilliant2046,
      "https://github.com/MrBrilliant2046",
    ),
    Developer(
      "NanCunChild",
      "https://avatars.githubusercontent.com/u/85873278?v=4",
      context.t.setting.aboutPage.nancunchild,
      "https://github.com/NanCunChild",
    ),
    Developer(
      "nkAnF",
      "https://avatars.githubusercontent.com/u/172456830",
      context.t.setting.aboutPage.nkanf,
      "https://github.com/nkanf-dev",
    ),
    Developer(
      "Pairman",
      "https://avatars.githubusercontent.com/u/18365163",
      context.t.setting.aboutPage.pairman,
      "https://github.com/Pairman",
    ),
    Developer(
      "ReverierXu",
      "https://avatars.githubusercontent.com/u/41937333",
      context.t.setting.aboutPage.reverierxu,
      "https://blog.woooo.tech/",
    ),
    Developer(
      "Rrrilac",
      "https://avatars.githubusercontent.com/u/128341096",
      context.t.setting.aboutPage.rrrilac,
      "https://github.com/Rrrilac",
    ),
    Developer(
      "Ray Flores",
      "https://sns-avatar-qc.xhscdn.com/avatar/65fb96e24f8a7c5709c421f2.jpg",
      context.t.setting.aboutPage.ray,
      "https://www.xiaohongshu.com/user/profile/63d293990000000026010075",
    ),
    Developer(
      "shadowyingyi",
      "https://avatars.githubusercontent.com/u/42831635",
      context.t.setting.aboutPage.shadowyingyi,
      "https://github.com/shadowyingyi",
    ),
    Developer(
      "stalomeow",
      "https://avatars.githubusercontent.com/u/47203031",
      context.t.setting.aboutPage.stalomeow,
      "https://stalomeow.com",
    ),
    Developer(
      "xeonds",
      "https://avatars.githubusercontent.com/u/68117734",
      context.t.setting.aboutPage.xeonds,
      "https://mxts.jiujiuer.xyz",
    ),
    Developer(
      "XingShuyu",
      "https://avatars.githubusercontent.com/u/82715884",
      context.t.setting.aboutPage.xingshuyu,
      "https://xingshuyu.github.io",
    ),
    Developer(
      "Xiue233",
      "https://avatars.githubusercontent.com/u/30972246",
      context.t.setting.aboutPage.xiue233,
      "https://xiue233.github.io/",
    ),
    Developer(
      "xizi",
      "https://static.wikia.nocookie.net/chiikawa/images/c/c3/Hachi_main.png/revision/latest?cb=20231016011752&path-prefix=zh",
      context.t.setting.aboutPage.xizi,
      "https://www.bilibili.com/video/BV1Rg4y1x7su/",
    ),
    Developer(
      "wirsbf",
      "https://avatars.githubusercontent.com/u/144008530",
      context.t.setting.aboutPage.wirsbf,
      "https://xiue233.github.io/",
    ),
    Developer(
      "ZCWzy",
      "https://avatars.githubusercontent.com/u/87163986",
      context.t.setting.aboutPage.zcwzy,
      "https://github.com/ZCWzy",
    ),
    Developer(
      "ZYar-er",
      "https://avatars.githubusercontent.com/u/95170599?v=4",
      context.t.setting.aboutPage.zyarEr,
      "https://github.com/ZYar-er",
    ),
  ];

  List<Link> linkData() => [
    Link(
      icon: const Icon(Icons.home),
      name: context.t.setting.aboutPage.homepage,
      url: "https://xdyou.superbart.top",
    ),
    Link(
      icon: const Icon(Icons.code),
      name: context.t.setting.aboutPage.code,
      url: "https://github.com/BenderBlog/traintime_pda",
    ),
  ];

  Widget _title(BuildContext context) {
    return [
          const AppIconWidget(),
          const Divider(color: Colors.transparent),
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                        ? "XDYou"
                        : "Traintime PDA",
                  ),
                  TextSpan(text: " v${preference.packageInfo.version}\n"),
                  TextSpan(
                    text:
                        "${Platform.isIOS || Platform.isMacOS ? "Fly Me to The Moon" : "Pursuing Dreams"}"
                        " And\nLiving Inside Your Love Above Stars Edition",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
        .padding(all: 32)
        .gestures(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EasterEggPage()),
          ),
        );
  }

  Widget get _developerList => ReXCard(
    title: Text(
      context.t.setting.acknowledgement(developers: getDevelopers().length.toString()),
    ).padding(bottom: 8).center(),
    remaining: const [],
    bottomRow: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.0,
      runSpacing: 12.0,
      children: getDevelopers()
          .map((e) => DeveloperWidget(developer: e))
          .toList(),
    ).center(),
  );

  Widget _moreList(BuildContext context) => ReXCard(
    title: Text(
      context.t.setting.aboutPage.title,
    ).padding(bottom: 8).center(),
    remaining: const [],
    bottomRow: [
      ...linkData().map(
        (e) => LinkWidget(icon: e.icon, name: e.name, url: e.url),
      ),
      ListTile(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.balance),
        title: Text(
          context.t.setting.aboutPage.knowMore,
        ),
        onTap: () => showLicensePage(
          context: context,
          applicationName:
              Platform.isIOS || Platform.isMacOS || Platform.isAndroid
              ? "XDYou"
              : "Traintime PDA",
          applicationVersion:
              "v${preference.packageInfo.version}+"
              "${preference.packageInfo.buildNumber}",
          applicationIcon: const AppIconWidget().padding(vertical: 16),
          applicationLegalese: context.t.setting.aboutPage.copyrightNotice,
        ),
      ),
      if (Platform.isIOS || Platform.isMacOS)
        ListTile(
          minLeadingWidth: 0,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code),
          title: Text(
            context.t.setting.aboutPage.beian,
          ),
          subtitle: const Text("陕ICP备2024026116号-1A"),
        ),
      if (Platform.isAndroid)
        ListTile(
          minLeadingWidth: 0,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code),
          title: Text(
            context.t.setting.aboutPage.signAndroid,
          ),
          subtitle: Text(preference.packageInfo.buildSignature),
        ),
    ].toList().toColumn(),
  );

  Widget _versionHint(BuildContext context) => ReXCard(
    title: Text(
      context.t.setting.easterEggPage,
    ).padding(bottom: 8).center(),
    remaining: const [],
    bottomRow: [
      [
        IconButton.filledTonal(
          onPressed: () => launchUrl(
            Uri.parse(
              Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
            ),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.headphones),
        ),
        const SizedBox(width: 24),
        IconButton.filledTonal(
          onPressed: () => launchUrl(
            Uri.parse(urlAll),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.headphones),
        ),
        const SizedBox(width: 24),
        IconButton.filledTonal(
          onPressed: () => launchUrl(
            Uri.parse(
              Platform.isIOS || Platform.isMacOS ? urlOthers : urlApple,
            ),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.headphones),
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(bottom: 8),
      Text(
        Platform.isIOS || Platform.isMacOS
            ? context.t.common.easterEggApple
            : context.t.common.easterEggOthers,
        textAlign: TextAlign.center,
      ),
    ].toColumn(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.setting.aboutPage.title),
      ),
      body: Builder(
        builder: (context) {
          if (MediaQuery.sizeOf(context).width > 600 &&
              MediaQuery.sizeOf(context).width /
                      MediaQuery.sizeOf(context).height >
                  1) {
            return [
                  [_title(context), _developerList]
                      .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                      .padding(vertical: 8)
                      .scrollable()
                      .flexible(flex: 1),
                  [_moreList(context), _versionHint(context)]
                      .toColumn()
                      .padding(vertical: 8)
                      .scrollable()
                      .flexible(flex: 1),
                ]
                .toRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
                .constrained(maxWidth: 800)
                .center();
          } else {
            return [
                  _title(context),
                  _developerList,
                  _moreList(context),
                  _versionHint(context).padding(bottom: 14),
                ]
                .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                .padding(horizontal: 16)
                .scrollable()
                .constrained(maxWidth: 600)
                .center();
          }
        },
      ),
    );
  }
}
