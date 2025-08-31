// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/model/toolbox_addresses.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/toolbox/webview_list_tile.dart';

class ToolBoxPage extends StatefulWidget {
  const ToolBoxPage({super.key});

  @override
  State<ToolBoxPage> createState() => _ToolBoxPageState();
}

class _ToolBoxPageState extends State<ToolBoxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText("toolbox.title"),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.payment"),
            url: "https://payment.xidian.edu.cn/MNetWorkUI/showPublic",
            description: FlutterI18n.translate(
              context,
              "toolbox.payment_description",
            ),
            iconData: MingCuteIcons.mgc_exchange_cny_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.repair"),
            url:
                "https://ids.xidian.edu.cn/authserver/login?service="
                "https%3A%2F%2Fids.xidian.edu.cn%2Fauthserver%2Foauth2.0%2F"
                "callbackAuthorize%3Fclient_id%3D869608421533880320%26"
                "redirect_uri%3Dhttp%253A%252F%252Frepair.xidian.edu.cn%252F"
                "appsys%252FxidianCasLogin%252FoauthLogin%26response_type%3D"
                "code%26state%3Dhome%26client_name%3DCasOAuthClient",
            description: FlutterI18n.translate(
              context,
              "toolbox.repair_description",
            ),
            iconData: MingCuteIcons.mgc_tool_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.reserve"),
            url: "http://libspace.xidian.edu.cn",
            description: FlutterI18n.translate(
              context,
              "toolbox.reserve_description",
            ),
            iconData: MingCuteIcons.mgc_building_4_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.mobile"),
            url: "https://xxcapp.xidian.edu.cn/site/xidianPage/home",
            description: FlutterI18n.translate(
              context,
              "toolbox.mobile_description",
            ),
            iconData: MingCuteIcons.mgc_chat_2_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.network"),
            url: "https://zfw.xidian.edu.cn",
            description: FlutterI18n.translate(
              context,
              "toolbox.network_description",
            ),
            iconData: MingCuteIcons.mgc_wifi_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.physics"),
            url: "https://experiment-helper.wizzstudio.com/#/",
            description: FlutterI18n.translate(
              context,
              "toolbox.physics_description",
            ),
            iconData: MingCuteIcons.mgc_counter_2_line,
          ),
          WebViewAddresses(
            name: FlutterI18n.translate(context, "toolbox.discover"),
            url: "https://nav.xdruisi.cn/",
            description: FlutterI18n.translate(
              context,
              "toolbox.discover_description",
            ),
            iconData: MingCuteIcons.mgc_web_line,
          ),
        ].map((e) => WebViewListTile(data: e)).toList(),
      ),
    );
  }
}
