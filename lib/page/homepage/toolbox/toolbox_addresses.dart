// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

enum SchoolAddresses {
  payment(
    name: "缴费系统",
    url: "https://payment.xidian.edu.cn/MNetWorkUI/showPublic",
    description: "电费该交了吧",
    iconData: Icons.payments,
  ),
  repair(
    name: "后勤报修",
    url: "https://ids.xidian.edu.cn/authserver/login?service="
        "https%3A%2F%2Fids.xidian.edu.cn%2Fauthserver%2Foauth2.0%2F"
        "callbackAuthorize%3Fclient_id%3D869608421533880320%26"
        "redirect_uri%3Dhttp%253A%252F%252Frepair.xidian.edu.cn%252F"
        "appsys%252FxidianCasLogin%252FoauthLogin%26response_type%3D"
        "code%26state%3Dhome%26client_name%3DCasOAuthClient",
    description: "不要漏水断网",
    iconData: Icons.home_repair_service,
  ),
  reserve(
    name: "空间预约",
    url: "http://libspace.xidian.edu.cn",
    description: "找个地方打牌",
    iconData: Icons.book_online,
  ),
  mobileEntry(
    name: "手机门户",
    url: "https://xxcapp.xidian.edu.cn/site/xidianPage/home",
    description: "请假专用门户",
    iconData: Icons.apartment,
  ),
  network(
    name: "校园网查询",
    url: "https://zfw.xidian.edu.cn",
    description: "希望永不收费",
    iconData: Icons.signal_wifi_statusbar_4_bar,
  );

  final String name;
  final String url;
  final String description;
  final IconData iconData;

  const SchoolAddresses({
    required this.name,
    required this.url,
    required this.description,
    required this.iconData,
  });
}

enum OtherAddress {
  calculator(
    name: "物理计算",
    url: "https://experiment-helper.wizzstudio.com/#/",
    description: "希望操作顺利",
    iconData: Icons.calculate,
  ),
  ruisiEntry(
    name: "睿思导航",
    url: "https://nav.xdruisi.com/",
    description: "补充其他功能",
    iconData: Icons.language,
  );

  final String name;
  final String url;
  final String description;
  final IconData iconData;

  const OtherAddress({
    required this.name,
    required this.url,
    required this.description,
    required this.iconData,
  });
}
