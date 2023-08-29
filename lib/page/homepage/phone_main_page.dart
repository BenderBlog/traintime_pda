// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';

import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_card.dart';
import 'package:watermeter/page/homepage/dynamic_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/dynamic_widget/library_card.dart';
import 'package:watermeter/page/homepage/dynamic_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/dynamic_widget/sport_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PhoneMainPage extends StatelessWidget {
  const PhoneMainPage({super.key});

  final classCardHeight = 140.0;

  final List<Widget> children = const [
    SportCard(),
    ElectricityCard(),
    LibraryCard(),
    SchoolCardInfoCard(),
  ];

  String get _now {
    DateTime now = DateTime.now();
    if (now.hour >= 5 && now.hour < 11) {
      return "早安 祝你好运";
    } else if (now.hour >= 11 && now.hour < 17) {
      return "午安 目前如何";
    } else {
      return "晚安 祝你好梦";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05,
                vertical: 16,
              ),
              title: GetBuilder<ClassTableController>(
                builder: (c) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _now,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      c.isGet
                          ? c.isNotVacation
                              ? "第 ${c.currentWeek + 1} 周"
                              : "假期中"
                          : c.error != null
                              ? "加载错误"
                              : "正在加载",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: EasyRefresh(
          onRefresh: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("请稍候，正在刷新信息"),
            ));
            update();
          },
          header: PhoenixHeader(
            skyColor: Theme.of(context).colorScheme.primaryContainer,
            position: IndicatorPosition.locator,
            safeArea: true,
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              children: [
                const HeaderLocator(),
                Text(
                  "日程安排",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ).padding(
                  left: 20,
                  top: 10,
                  right: 0,
                  bottom: 4,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: LayoutGrid(
                    columnSizes: [1.fr],
                    rowSizes: const [auto],
                    children: const [
                      ClassTableCard(),
                    ],
                  ),
                ),
                Text(
                  "收藏组件",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ).padding(
                  left: 20,
                  top: 20,
                  right: 0,
                  bottom: 4,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: LayoutGrid(
                    columnSizes: [1.fr, 1.fr],
                    rowSizes: [160.px, 160.px, auto, auto],
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
