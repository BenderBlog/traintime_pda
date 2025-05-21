// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/schoolnet/current_login_user_net_info.dart';
import 'package:watermeter/page/schoolnet/help_guide.dart';
import 'package:watermeter/page/schoolnet/ids_account_net_info.dart';

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
          title: Text(FlutterI18n.translate(
            context,
            "school_net.title",
          )),
          actions: [
            IconButton(
              onPressed: () => context.push(const HelpGuide()),
              icon: const Icon(Icons.help),
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "school_net.ids_account_net.title",
                ),
              ),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "school_net.current_login_net.title",
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            IdsAccountNetInfo(),
            CurrentLoginUserNetInfo(),
          ],
        ),
      ),
    );
  }
}
