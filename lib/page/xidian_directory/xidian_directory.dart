/*
Intro UI of the Xidian Directory. With the bar.
Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/page/xidian_directory/subwindow/comprehensive.dart';
import 'package:watermeter/page/xidian_directory/subwindow/dininghall.dart';
import 'package:watermeter/page/xidian_directory/subwindow/telephone.dart';

class XidianDirWindow extends StatelessWidget {
  const XidianDirWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabForXDDir();
  }
}

class TabForXDDir extends StatelessWidget {
  const TabForXDDir({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
