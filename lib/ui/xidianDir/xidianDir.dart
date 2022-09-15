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
import 'package:watermeter/ui/xidianDir/subwindow/comprehensive.dart';
import 'package:watermeter/ui/xidianDir/subwindow/dininghall.dart';

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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("生活信息"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('关于生活信息'),
                      content: const Text(
                        "This Flutter frontend, \nCopyright 2022 SuperBart. MPL License.\n"
                        "\nOriginal React/Chakra-UI frontend, \nCopyright 2022 hawa130. All right reserved.\n"
                        "\nData used with permission from \nXidian Directory Development Group.\n"
                        "\nBender have shiny metal ass which should not be bitten.\n",
                        textScaleFactor: 0.89,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("确定"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store_mall_directory), ),
              Tab(icon: Icon(Icons.restaurant)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ComprehensiveWindow(),
            DiningHallWindow(),
          ],
        ),
      ),
    );
  }
}
