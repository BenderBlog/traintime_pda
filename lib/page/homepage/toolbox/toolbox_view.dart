// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/homepage/toolbox/toolbox_addresses.dart';
import 'package:watermeter/page/homepage/toolbox/webview.dart';
import 'package:watermeter/page/creative_job/creative_job.dart';
import 'package:watermeter/page/telebook/telebook_view.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';
import 'dart:io';

class ToolBoxView extends StatelessWidget {
  final BoxConstraints constraints;
  const ToolBoxView({
    super.key,
    required this.constraints,
  });

  TextStyle textStyle(context) => TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      );

  @override
  Widget build(BuildContext context) {
    final List<Widget> authorService = [
      GestureDetector(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreativeJobView(),
            ),
          );
        },
        child: const SmallFunctionCard(
          icon: Icons.star,
          name: "双创竞赛",
          description: "拉队友来看看",
        ),
      ),
      GestureDetector(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const XDUPlanetPage(),
            ),
          );
        },
        child: const SmallFunctionCard(
          icon: Icons.rss_feed,
          name: "博客星球",
          description: "学习先辈经验",
        ),
      ),
      GestureDetector(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TeleBookWindow(),
            ),
          );
        },
        child: const SmallFunctionCard(
          icon: Icons.contacts_rounded,
          name: "电话本",
          description: "校园服务电话",
        ),
      ),
    ];

    int crossItems = constraints.minWidth ~/ 180;

    int rowItem(int length) {
      int rowItem = length ~/ crossItems;
      if (crossItems * rowItem < length) {
        rowItem += 1;
      }
      return rowItem;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("小工具"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.025,
        ),
        children: [
          Text(
            "学校服务快捷方式",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          LayoutGrid(
            columnSizes: repeat(crossItems, [1.fr]),
            rowSizes: repeat(rowItem(SchoolAddresses.values.length), [84.px]),
            children: List.generate(
              SchoolAddresses.values.length,
              (index) {
                return GestureDetector(
                  onTap: () async {
                    if (!Platform.isAndroid) {
                      launchUrlString(SchoolAddresses.values[index].url);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WebView(
                            name: SchoolAddresses.values[index].name,
                            cookieDomainList: const [
                              "http://ids.xidian.edu.cn/authserver/"
                            ],
                            domain: SchoolAddresses.values[index].url,
                          ),
                        ),
                      );
                    }
                  },
                  child: SmallFunctionCard(
                    icon: SchoolAddresses.values[index].iconData,
                    name: SchoolAddresses.values[index].name,
                    description: SchoolAddresses.values[index].description,
                  ),
                );
              },
            ),
          ),
          Text(
            "其他服务",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          LayoutGrid(
            columnSizes: repeat(crossItems, [1.fr]),
            rowSizes: repeat(
                rowItem(OtherAddress.values.length + authorService.length),
                [84.px]),
            children: authorService
              ..addAll(
                List.generate(
                  OtherAddress.values.length,
                  (index) {
                    return GestureDetector(
                      onTap: () async {
                        if (!Platform.isAndroid) {
                          launchUrlString(OtherAddress.values[index].url);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WebView(
                                name: OtherAddress.values[index].name,
                                cookieDomainList: const [
                                  "http://ids.xidian.edu.cn/authserver/"
                                ],
                                domain: OtherAddress.values[index].url,
                              ),
                            ),
                          );
                        }
                      },
                      child: SmallFunctionCard(
                        icon: OtherAddress.values[index].iconData,
                        name: OtherAddress.values[index].name,
                        description: OtherAddress.values[index].description,
                      ),
                    );
                  },
                ),
              ),
          ),
        ],
      ),
    );
  }
}
