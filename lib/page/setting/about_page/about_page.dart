// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/setting/about_page/easter_egg_page.dart';
import 'package:watermeter/page/setting/about_page/developer_widget.dart';
import 'package:watermeter/page/setting/about_page/link_widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatelessWidget {
  final List<Developer> getDevelopers = const [
    Developer(
      "BenderBlog Rodriguez",
      "https://avatars.githubusercontent.com/u/14026321",
      "主要开发者，iOS 小部件编写和拼接",
      "https://space.bilibili.com/284290692",
    ),
    Developer(
      "BellssGit",
      "https://avatars.githubusercontent.com/u/107785251",
      "支持：最佳&最久故障反馈者",
      "https://space.bilibili.com/17772726",
    ),
    Developer(
      "BrackRat",
      "https://avatars.githubusercontent.com/u/35328547",
      "设计：主页，登录页，配色，iOS 小部件等",
      "https://github.com/BrackRat",
    ),
    Developer(
      "Breezeline",
      "https://avatars.githubusercontent.com/u/74224286",
      "支持：无价值无意义的产品经理(他自己的描述)",
      "mailto:ydzhang.ruc@gmail.com",
    ),
    Developer(
      "0xCAFEBABE",
      "https://blog.hxzzz.asia/usr/uploads/2024/05/1717631110.jpg",
      "支持：提供彩蛋代码",
      "https://blog.hxzzz.asia/",
    ),
    Developer(
      "chitao1234",
      "https://avatars.githubusercontent.com/u/25598632",
      "开发：修复滑块不对齐问题",
      "https://github.com/chitao1234",
    ),
    Developer(
      "Dimole",
      "https://avatars.githubusercontent.com/u/24828354",
      "支持：辅助修复滑块问题",
      "https://github.com/Dimole",
    ),
    Developer(
      "EliteWars",
      "https://avatars.githubusercontent.com/u/44139545",
      "设计：体育成绩页面",
      "https://space.bilibili.com/49892391/",
    ),
    Developer(
      "hhzm (闪电豹猫)",
      "https://avatars.githubusercontent.com/u/19224718",
      "支持：提供彩蛋代码",
      "https://hhzm.win/",
    ),
    Developer(
      "lsy223622 (木生睡不着)",
      "https://avatars.githubusercontent.com/u/57913213",
      "设计：iOS 图标",
      "https://lsy223622.com/",
    ),
    Developer(
      "NanCunChild",
      "https://avatars.githubusercontent.com/u/85873278?v=4",
      "开发：图书馆搜索功能",
      "https://github.com/NanCunChild",
    ),
    Developer(
      "Pairman",
      "https://avatars.githubusercontent.com/u/18365163",
      "开发：成绩缓存功能和优化滑块算法",
      "https://github.com/Pairman",
    ),
    Developer(
      "ReverierXu",
      "https://blog.woooo.tech/img/avatar.png",
      "设计：用于信息展示的 ReX 卡片",
      "https://blog.woooo.tech/",
    ),
    Developer(
      "Ray (Railgun Edition)",
      "https://raay.xyz/wp-content/uploads/2023/07/4882705B-3C57-4B46-A3DA-F75C2E0DCE5B.jpeg",
      "设计：开屏画面 / 支持：iOS 开发",
      "https://raay.xyz/",
    ),
    Developer(
      "stalomeow",
      "https://avatars.githubusercontent.com/u/47203031",
      "设计：首页时间轴 / 开发：异步登录",
      "https://stalomeow.com",
    ),
    Developer(
      "xeonds",
      "https://avatars.githubusercontent.com/u/68117734",
      "设计：设置页面 / 开发：XDU Planet",
      "https://mxts.jiujiuer.xyz",
    ),
    Developer(
      "Xiue233",
      "https://xiue233.github.io/images/avatar.png",
      "开发：Android 小部件和拼接",
      "https://xiue233.github.io/",
    ),
    Developer(
      "ZCWzy",
      "https://avatars.githubusercontent.com/u/87163986",
      "开发：修复丁香电费 / 支持：研究生版本开发",
      "https://github.com/ZCWzy",
    ),
  ];

  final List<Link> linkData = const [
    Link(
      icon: Icon(Icons.home),
      name: "主页",
      url: "https://legacy.superbart.top/xdyou.html",
    ),
    Link(
      icon: Icon(Icons.code),
      name: "开源代码",
      url: "https://github.com/BenderBlog/traintime_pda",
    ),
    Link(
      icon: Icon(Icons.redeem),
      name: "给我捐款",
      url: "https://afdian.com/a/benderblog",
    ),
  ];

  const AboutPage({super.key});

  Widget _title(context) => [
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
                  text: Platform.isIOS || Platform.isMacOS
                      ? "Te o toriatte Edition"
                      : "Let Us Cling Together Edition",
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

  Widget get _developerList => ReXCard(
        title: Text("Made with love from ${getDevelopers.length} people")
            .padding(
              bottom: 8,
            )
            .center(),
        remaining: const [],
        bottomRow: getDevelopers
            .map((e) => DeveloperWidget(developer: e))
            .toList()
            .toColumn(),
      );

  Widget _moreList(context) => ReXCard(
        title: const Text("知道更多")
            .padding(
              bottom: 8,
            )
            .center(),
        remaining: const [],
        bottomRow: [
          ...linkData.map((e) => LinkWidget(
                icon: e.icon,
                name: e.name,
                url: e.url,
              )),
          ListTile(
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.balance),
            title: const Text("开源协议和授权信息"),
            onTap: () => showLicensePage(
              context: context,
              applicationName: Platform.isIOS || Platform.isMacOS
                  ? "XDYou"
                  : "Traintime PDA",
              applicationVersion: "v${preference.packageInfo.version}+"
                  "${preference.packageInfo.buildNumber}",
              applicationLegalese:
                  "本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译，"
                  "代码按照 Mozilla Public License, v. 2.0 授权。\n\n"
                  "本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。\n\n"
                  "Copyright 2023-Present BenderBlog Rodriguez and contributors. "
                  "The Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. "
                  "If a copy of the MPL was not distributed with this file, "
                  "You can obtain one at https://mozilla.org/MPL/2.0/.",
            ),
          ),
          if (Platform.isIOS || Platform.isMacOS)
            const ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.code),
              title: Text("备案号"),
              subtitle: Text("陕ICP备2024026116号-1A"),
            ),
          if (Platform.isAndroid)
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code),
              title: const Text("安卓签名"),
              subtitle: Text(preference.packageInfo.buildSignature),
            ),
        ].toList().toColumn(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("关于本软件")),
        body: Builder(builder: (context) {
          if (MediaQuery.sizeOf(context).width > 600 &&
              MediaQuery.sizeOf(context).width /
                      MediaQuery.sizeOf(context).height >
                  1) {
            return [
              [
                const Spacer(),
                _title(context),
                const Spacer(),
                _moreList(context),
              ]
                  .toColumn(mainAxisAlignment: MainAxisAlignment.end)
                  .flexible(flex: 1),
              [
                _developerList,
              ].toColumn().scrollable().flexible(flex: 1),
            ]
                .toRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
                .constrained(maxWidth: 800)
                .center()
                .safeArea();
          } else {
            return [_title(context), _developerList, _moreList(context)]
                .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                .scrollable()
                .constrained(maxWidth: 600)
                .center()
                .safeArea();
          }
        }));
  }
}
