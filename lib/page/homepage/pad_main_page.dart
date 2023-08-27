// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/toolbox/cards/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/cards/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/toolbox/cards/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/sport_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PadMainPage extends StatelessWidget {
  const PadMainPage({super.key});

  final inBetweenCardHeight = 136.0;

  double width(context) => MediaQuery.sizeOf(context).width;
  double height(context) => MediaQuery.sizeOf(context).height;

  TextStyle textStyle(context) => TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ClassTableController>(
          builder: (c) {
            String text = c.isGet
                ? c.isNotVacation
                    ? "第 ${c.currentWeek + 1} 周"
                    : "假期中"
                : c.error != null
                    ? "加载错误"
                    : "正在加载";
            return Text(text);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("请稍候，正在刷新信息"),
              ));
              update();
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
            "日程安排",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: const ClassTableCard(),
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
          LayoutGrid(
            columnSizes: [1.fr, 1.fr, 1.fr, 1.fr],
            rowSizes: const [auto],
            children: const [
              SportCard(),
              ElectricityCard(),
              LibraryCard(),
              SchoolCardInfoCard(),
            ],
          ),
          Text(
            "常用工具",
            style: textStyle(context),
          ).padding(
            left: 16,
            top: 8,
            right: 0,
            bottom: 0,
          ),
          LayoutGrid(
            columnSizes: [1.fr, 1.fr, 1.fr, 1.fr],
            rowSizes: const [auto],
            children: const [
              ScoreCard(),
              ExamCard(),
              EmptyClassroomCard(),
            ],
          ),
        ],
      ),
    );
  }
}
