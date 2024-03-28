// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:watermeter/controller/classtable_controller.dart';

import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_card.dart';

import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/info_widget/notice_card/notice_card.dart';

import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/login/jc_captcha.dart';

class PadMainPage extends StatelessWidget {
  const PadMainPage({super.key});

  final inBetweenCardHeight = 136.0;

  double width(context) => MediaQuery.sizeOf(context).width;
  double height(context) => MediaQuery.sizeOf(context).height;

  TextStyle textStyle(context) => TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: GetBuilder<ClassTableController>(builder: (c) {
          /// TODO: check it
          String text = c.state == ClassTableState.fetched
              ? c.getCurrentWeek(updateTime) >= 0 &&
                      c.getCurrentWeek(updateTime) <
                          c.classTableData.semesterLength
                  ? "第 ${c.getCurrentWeek(updateTime) + 1} 周"
                  : "假期中"
              : c.state == ClassTableState.error
                  ? "加载错误"
                  : "正在加载";
          return Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: "请稍候，正在刷新信息",
                timeInSecForIosWeb: 1,
              );
              update(sliderCaptcha: (String cookieStr) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CaptchaWidget(cookie: cookieStr),
                  ),
                );
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.025,
        ),
        children: [
          Text(
            "日程安排和通知",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          LayoutGrid(
            columnSizes: [1.fr],
            rowSizes: const [auto, auto],
            children: const [
              NoticeCard(),
              ClassTableCard(),
            ],
          ),
          Text(
            "动态信息",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: LayoutGrid(
              columnSizes: repeat(4, [180.px]),
              rowSizes: [
                180.px,
              ],
              children: const [
                //SportCard(),
                ElectricityCard(),
                LibraryCard(),
                SchoolCardInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
