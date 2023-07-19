/*
Intro UI of the Xidian Directory. With the bar.
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:watermeter/page/xidian_directory/comprehensive.dart';
import 'package:watermeter/page/xidian_directory/dininghall.dart';
import 'package:watermeter/page/xidian_directory/telephone.dart';

class XidianDirWindow extends StatefulWidget {
  const XidianDirWindow({super.key});

  @override
  State<XidianDirWindow> createState() => _XidianDirWindowState();
}

class _XidianDirWindowState extends State<XidianDirWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store_mall_directory)),
              Tab(icon: Icon(Icons.restaurant)),
              Tab(icon: Icon(Icons.phone)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ComprehensiveWindow(),
            DiningHallWindow(),
            TeleBookWindow(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
