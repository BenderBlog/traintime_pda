// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

enum WebViewAddresses {
  payment(
    name: "缴费系统",
    url: "https://payment.xidian.edu.cn/MNetWorkUI/showPublic",
    description: "电费该交了吧",
    iconData: MingCuteIcons.mgc_exchange_cny_line,
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
    iconData: MingCuteIcons.mgc_tool_line,
  ),
  reserve(
    name: "空间预约",
    url: "http://libspace.xidian.edu.cn",
    description: "找个地方打牌",
    iconData: MingCuteIcons.mgc_building_4_line,
  ),
  mobileEntry(
    name: "移动门户",
    url: "https://xxcapp.xidian.edu.cn/site/xidianPage/home",
    description: "请假专用门户",
    iconData: MingCuteIcons.mgc_chat_2_line,
  ),
  network(
    name: "网络查询",
    url: "https://zfw.xidian.edu.cn",
    description: "希望永不收费",
    iconData: MingCuteIcons.mgc_wifi_line,
  ),
  calculator(
    name: "物理计算",
    url: "https://experiment-helper.wizzstudio.com/#/",
    description: "希望操作顺利",
    iconData: MingCuteIcons.mgc_counter_2_line,
  ),
  ruisiEntry(
    name: "睿思导航",
    url: "https://nav.xdruisi.com/",
    description: "补充其他功能",
    iconData: MingCuteIcons.mgc_web_line,
  );

  final String name;
  final String url;
  final String description;
  final IconData iconData;

  const WebViewAddresses({
    required this.name,
    required this.url,
    required this.description,
    required this.iconData,
  });
}
