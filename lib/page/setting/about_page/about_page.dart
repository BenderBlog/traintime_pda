// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/setting/about_page/easter_egg_page.dart';
import 'package:watermeter/page/setting/about_page/developer_widget.dart';
import 'package:watermeter/page/setting/about_page/link_widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Developer> getDevelopers() => [
        Developer(
          "BenderBlog Rodriguez",
          "https://avatars.githubusercontent.com/u/14026321",
          FlutterI18n.translate(
            context,
            "setting.about_page.benderblog",
          ),
          "https://space.bilibili.com/284290692",
        ),
        Developer(
          "BellssGit",
          "https://avatars.githubusercontent.com/u/107785251",
          FlutterI18n.translate(
            context,
            "setting.about_page.bellssgit",
          ),
          "https://space.bilibili.com/17772726",
        ),
        Developer(
          "BrackRat",
          "https://avatars.githubusercontent.com/u/35328547",
          FlutterI18n.translate(
            context,
            "setting.about_page.brackrat",
          ),
          "https://github.com/BrackRat",
        ),
        Developer(
          "Breezeline",
          "https://avatars.githubusercontent.com/u/74224286",
          FlutterI18n.translate(
            context,
            "setting.about_page.breezeline",
          ),
          "mailto:ydzhang.ruc@gmail.com",
        ),
        Developer(
          "0xCAFEBABE",
          "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
          FlutterI18n.translate(
            context,
            "setting.about_page.cafebabe",
          ),
          "https://blog.hxzzz.asia/",
        ),
        Developer(
          "chitao1234",
          "https://avatars.githubusercontent.com/u/25598632",
          FlutterI18n.translate(
            context,
            "setting.about_page.chitao1234",
          ),
          "https://github.com/chitao1234",
        ),
        Developer(
          "Dimole",
          "https://avatars.githubusercontent.com/u/24828354",
          FlutterI18n.translate(
            context,
            "setting.about_page.dimole",
          ),
          "https://github.com/Dimole",
        ),
        Developer(
          "EliteWars",
          "https://avatars.githubusercontent.com/u/44139545",
          FlutterI18n.translate(
            context,
            "setting.about_page.elitewars",
          ),
          "https://space.bilibili.com/49892391/",
        ),
        Developer(
          "Elliot（西电紫鼠球）",
          "https://img.moegirl.org.cn/common/thumb/6/64/Hirasawa_yui_1.jpg/800px-Hirasawa_yui_1.jpg",
          FlutterI18n.translate(
            context,
            "setting.about_page.elliot",
          ),
          "https://mp.weixin.qq.com/s/_egmj3rjwOTAB-KHzKsYGw",
        ),
        Developer(
          "GodHu777777",
          "https://avatars.githubusercontent.com/u/111997394",
          FlutterI18n.translate(
            context,
            "setting.about_page.godhu777777",
          ),
          "https://github.com/GodHu777777",
        ),
        Developer(
          "Hancl777",
          "https://avatars.githubusercontent.com/u/74408609",
          FlutterI18n.translate(
            context,
            "setting.about_page.hancl777",
          ),
          "https://github.com/Hancl777",
        ),
        Developer(
          "hawa130",
          "https://avatars.githubusercontent.com/u/26119430",
          FlutterI18n.translate(
            context,
            "setting.about_page.hawa130",
          ),
          "https://hawa130.com/",
        ),
        Developer(
          "hhzm (闪电豹猫)",
          "https://avatars.githubusercontent.com/u/19224718",
          FlutterI18n.translate(
            context,
            "setting.about_page.hhzm",
          ),
          "https://hhzm.win/",
        ),
        Developer(
          "lhx-666-cool",
          "https://avatars.githubusercontent.com/u/63273792",
          FlutterI18n.translate(
            context,
            "setting.about_page.lhx-666-cool",
          ),
          "https://github.com/lhx-666-cool/",
        ),
        Developer(
          "LichtYy",
          "https://avatars.githubusercontent.com/u/105974550",
          FlutterI18n.translate(
            context,
            "setting.about_page.lichtyy",
          ),
          "https://github.com/lichtYy",
        ),
        Developer(
          "lsy223622 (木生睡不着)",
          "https://avatars.githubusercontent.com/u/57913213",
          FlutterI18n.translate(
            context,
            "setting.about_page.lsy223622",
          ),
          "https://lsy223622.com/",
        ),
        Developer(
            "MrBrilliant2046",
            "https://avatars.githubusercontent.com/u/94728421?v=4",
            FlutterI18n.translate(
              context,
              "setting.about_page.mrbrilliant2046",
            ),
            "https://github.com/MrBrilliant2046"),
        Developer(
          "NanCunChild",
          "https://avatars.githubusercontent.com/u/85873278?v=4",
          FlutterI18n.translate(
            context,
            "setting.about_page.nancunchild",
          ),
          "https://github.com/NanCunChild",
        ),
        Developer(
          "Pairman",
          "https://avatars.githubusercontent.com/u/18365163",
          FlutterI18n.translate(
            context,
            "setting.about_page.pairman",
          ),
          "https://github.com/Pairman",
        ),
        Developer(
          "ReverierXu",
          "https://blog.woooo.tech/img/avatar.png",
          FlutterI18n.translate(
            context,
            "setting.about_page.reverierxu",
          ),
          "https://blog.woooo.tech/",
        ),
        Developer(
          "Rrrilac",
          "https://avatars.githubusercontent.com/u/128341096",
          FlutterI18n.translate(
            context,
            "setting.about_page.rrrilac",
          ),
          "https://github.com/Rrrilac",
        ),
        Developer(
          "Ray (Elliot Edition)",
          "https://raay.xyz/wp-content/uploads/2023/07/4882705B-3C57-4B46-A3DA-F75C2E0DCE5B.jpeg",
          FlutterI18n.translate(
            context,
            "setting.about_page.ray",
          ),
          "https://raay.xyz/",
        ),
        Developer(
          "shadowyingyi",
          "https://avatars.githubusercontent.com/u/42831635",
          FlutterI18n.translate(
            context,
            "setting.about_page.shadowyingyi",
          ),
          "https://github.com/shadowyingyi",
        ),
        Developer(
          "stalomeow",
          "https://avatars.githubusercontent.com/u/47203031",
          FlutterI18n.translate(
            context,
            "setting.about_page.stalomeow",
          ),
          "https://stalomeow.com",
        ),
        Developer(
          "xeonds",
          "https://avatars.githubusercontent.com/u/68117734",
          FlutterI18n.translate(
            context,
            "setting.about_page.xeonds",
          ),
          "https://mxts.jiujiuer.xyz",
        ),
        Developer(
          "Xiue233",
          "https://avatars.githubusercontent.com/u/30972246",
          FlutterI18n.translate(
            context,
            "setting.about_page.xiue233",
          ),
          "https://xiue233.github.io/",
        ),
        Developer(
          "xizi",
          "https://static.wikia.nocookie.net/chiikawa/images/c/c3/Hachi_main.png/revision/latest?cb=20231016011752&path-prefix=zh",
          FlutterI18n.translate(
            context,
            "setting.about_page.xizi",
          ),
          "https://www.bilibili.com/video/BV1Rg4y1x7su/",
        ),
        Developer(
          "wirsbf",
          "https://avatars.githubusercontent.com/u/144008530",
          FlutterI18n.translate(
            context,
            "setting.about_page.wirsbf",
          ),
          "https://xiue233.github.io/",
        ),
        Developer(
          "ZCWzy",
          "https://avatars.githubusercontent.com/u/87163986",
          FlutterI18n.translate(
            context,
            "setting.about_page.zcwzy",
          ),
          "https://github.com/ZCWzy",
        ),
        Developer(
            "ZYar-er",
            "https://avatars.githubusercontent.com/u/95170599?v=4",
            FlutterI18n.translate(
              context,
              "setting.about_page.zyar-er",
            ),
            "https://github.com/ZYar-er")
      ];

  List<Link> linkData() => [
        Link(
          icon: const Icon(Icons.home),
          name: FlutterI18n.translate(
            context,
            "setting.about_page.homepage",
          ),
          url: "https://legacy.superbart.top/xdyou.html",
        ),
        Link(
          icon: const Icon(Icons.code),
          name: FlutterI18n.translate(
            context,
            "setting.about_page.code",
          ),
          url: "https://github.com/BenderBlog/traintime_pda",
        ),
      ];

  Widget _title(context) {
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
                text: Platform.isIOS || Platform.isMacOS
                    ? "XDYou"
                    : "Traintime PDA",
              ),
              TextSpan(
                text: " v${preference.packageInfo.version}\n",
              ),
              TextSpan(
                text:
                    "${Platform.isIOS || Platform.isMacOS ? "The Conjuring" : "Dead Romance"} - Neuromancy Edition",
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
          "Made with love from ${getDevelopers().length} people",
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

  Widget _moreList(context) => ReXCard(
        title: Text(FlutterI18n.translate(context, "setting.about_page.title"))
            .padding(
              bottom: 8,
            )
            .center(),
        remaining: const [],
        bottomRow: [
          ...linkData().map((e) => LinkWidget(
                icon: e.icon,
                name: e.name,
                url: e.url,
              )),
          ListTile(
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.balance),
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.about_page.know_more",
              ),
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName: Platform.isIOS || Platform.isMacOS
                  ? "XDYou"
                  : "Traintime PDA",
              applicationVersion: "v${preference.packageInfo.version}+"
                  "${preference.packageInfo.buildNumber}",
              applicationIcon: const AppIconWidget().padding(vertical: 16),
              applicationLegalese: FlutterI18n.translate(
                context,
                "setting.about_page.copyright_notice",
              ),
            ),
          ),
          if (Platform.isIOS || Platform.isMacOS)
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code),
              title: Text(FlutterI18n.translate(
                context,
                "setting.about_page.beian",
              )),
              subtitle: const Text("陕ICP备2024026116号-1A"),
            ),
          if (Platform.isAndroid)
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code),
              title: Text(FlutterI18n.translate(
                context,
                "setting.about_page.sign_android",
              )),
              subtitle: Text(preference.packageInfo.buildSignature),
            ),
        ].toList().toColumn(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(
            context,
            "setting.about_page.title",
          )),
        ),
        body: Builder(builder: (context) {
          if (MediaQuery.sizeOf(context).width > 600 &&
              MediaQuery.sizeOf(context).width /
                      MediaQuery.sizeOf(context).height >
                  1) {
            return [
              [
                _title(context),
              ]
                  .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                  .flexible(flex: 1),
              [
                _developerList,
                _moreList(context),
              ].toColumn().scrollable().flexible(flex: 1),
            ]
                .toRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
                .constrained(maxWidth: 800)
                .center();
          } else {
            return [_title(context), _developerList, _moreList(context)]
                .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                .padding(horizontal: 16)
                .scrollable()
                .constrained(maxWidth: 600)
                .center();
          }
        }).safeArea());
  }
}
