// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/model/toolbox_addresses.dart';
import 'package:watermeter/page/toolbox/webview_list_tile.dart';
import 'package:watermeter/generated/l10n.dart';

class ToolBoxPage extends StatefulWidget {
  const ToolBoxPage({super.key});

  @override
  State<ToolBoxPage> createState() => _ToolBoxPageState();
}

class _ToolBoxPageState extends State<ToolBoxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context)!.toolboxTitle)),
      body: ListView(
        children: [
          WebViewAddresses(
            name: I18n.of(context)!.toolboxPayment,
            url:
                "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY&appid=200260318155520600&state=1231231231",
            description: I18n.of(context)!.toolboxPaymentDescription,
            iconData: MingCuteIcons.mgc_exchange_cny_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxDrinkingwater,
            url: "https://order.xidian.edu.cn/mobile/thirdoauth/oauth2Xidian/1",
            description: I18n.of(context)!.toolboxDrinkingwaterDescription,
            iconData: MingCuteIcons.mgc_drop_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxRepair,
            url:
                "https://ids.xidian.edu.cn/authserver/login?service="
                "https%3A%2F%2Fids.xidian.edu.cn%2Fauthserver%2Foauth2.0%2F"
                "callbackAuthorize%3Fclient_id%3D869608421533880320%26"
                "redirect_uri%3Dhttp%253A%252F%252Frepair.xidian.edu.cn%252F"
                "appsys%252FxidianCasLogin%252FoauthLogin%26response_type%3D"
                "code%26state%3Dhome%26client_name%3DCasOAuthClient",
            description: I18n.of(context)!.toolboxRepairDescription,
            iconData: MingCuteIcons.mgc_tool_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxReserve,
            url: "http://libspace.xidian.edu.cn",
            description: I18n.of(context)!.toolboxReserveDescription,
            iconData: MingCuteIcons.mgc_building_4_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxNetwork,
            url: "https://zfw.xidian.edu.cn",
            description: I18n.of(context)!.toolboxNetworkDescription,
            iconData: MingCuteIcons.mgc_wifi_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxPhysics,
            url: "https://experiment-helper.wizzstudio.com/#/",
            description: I18n.of(context)!.toolboxPhysicsDescription,
            iconData: MingCuteIcons.mgc_counter_2_line,
          ),
          WebViewAddresses(
            name: I18n.of(context)!.toolboxDiscover,
            url: "https://nav.xdruisi.cn/",
            description: I18n.of(context)!.toolboxDiscoverDescription,
            iconData: MingCuteIcons.mgc_web_line,
          ),
        ].map((e) => WebViewListTile(data: e)).toList(),
      ),
    );
  }
}
