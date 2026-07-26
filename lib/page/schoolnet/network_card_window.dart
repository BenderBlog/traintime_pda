// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/schoolnet/current_net_info_page.dart';
import 'package:watermeter/page/schoolnet/general_network_usage_page.dart';
import 'package:watermeter/generated/l10n.dart';

class NetworkCardWindow extends StatefulWidget {
  const NetworkCardWindow({super.key});

  @override
  State<NetworkCardWindow> createState() => _NetworkCardWindowState();
}

class _NetworkCardWindowState extends State<NetworkCardWindow> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context)!.schoolNetTitle),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: I18n.of(context)!.schoolNetIdsAccountNetTitle,
              ),
              Tab(
                text: I18n.of(context)!.schoolNetCurrentLoginNetTitle,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[GeneralNetworkUsagePage(), CurrentNetInfoPage()],
        ),
      ),
    );
  }
}
