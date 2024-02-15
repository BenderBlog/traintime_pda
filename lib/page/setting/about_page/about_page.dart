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
      "支持：最佳/最久故障反馈者",
      "https://space.bilibili.com/17772726",
    ),
    Developer(
      "BrackRat",
      "https://avatars.githubusercontent.com/u/35328547",
      "设计：主页，登录页，配色，iOS 小部件等",
      "https://github.com/BrackRat",
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
      "ReverierXu",
      "https://blog.woooo.tech/img/avatar.png",
      "设计：用于信息展示的 ReX 卡片",
      "https://blog.woooo.tech/",
    ),
    Developer(
      "Ray (Railgun Edition)",
      "https://ray.al/wp-content/uploads/2023/07/4882705B-3C57-4B46-A3DA-F75C2E0DCE5B.jpeg",
      "设计：开屏画面 / 支持：iOS 开发",
      "https://ray.al/",
    ),
    Developer(
      "stalomeow",
      "https://avatars.githubusercontent.com/u/47203031",
      "设计：首页时间轴 / 开发：异步登录",
      "https://note.stalomeow.com/",
    ),
    Developer(
      "xeonds",
      "https://avatars.githubusercontent.com/u/68117734",
      "设计：设置页面",
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
      "开发：修复丁香电费/支持：研究生版本开发",
      "https://github.com/ZCWzy",
    ),
  ];

  final List<Link> linkData = [
    Link(
      icon: Icons.home,
      name: "主页",
      url: "https://legacy.superbart.xyz/xdyou.html",
    ),
    Link(
      icon: Icons.code,
      name: "代码",
      url: "https://github.com/BenderBlog/watermeter",
    ),
    Link(
      icon: Icons.copyright,
      name: "授权协议",
      url: "https://legacy.superbart.xyz/xdyou_eula.html",
    ),
    Link(
      icon: Icons.redeem,
      name: "给我捐款",
      url: "https://afdian.net/a/benderblog",
    ),
  ];

  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于本软件")),
      body: [
        [
          const AppIconWidget(size: 56),
          const VerticalDivider(),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 18),
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
                  const TextSpan(
                    text: "\"Ripples...\" Edition",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.center)
            .padding(all: 32)
            .gestures(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EasterEggPage()),
              ),
            ),
        ReXCard(
          title: const Text("Made with love from")
              .padding(
                bottom: 8,
              )
              .center(),
          remaining: const [],
          bottomRow: getDevelopers
              .map((e) => DeveloperWidget(developer: e))
              .toList()
              .toColumn(),
        ),
        ReXCard(
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
            if (Platform.isIOS || Platform.isMacOS)
              const ListTile(
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.code),
                title: Text("备案号"),
                subtitle: Text("陕ICP备2024026116号"),
              )
          ].toList().toColumn(),
        ),
      ]
          .toColumn(mainAxisAlignment: MainAxisAlignment.center)
          .scrollable()
          .constrained(maxWidth: 600)
          .safeArea(),
    );
  }
}