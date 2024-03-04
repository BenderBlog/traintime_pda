// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SportClassWindow extends StatefulWidget {
  const SportClassWindow({super.key});

  @override
  State<SportClassWindow> createState() => _SportClassWindowState();
}

class _SportClassWindowState extends State<SportClassWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sportClass.value.items.isEmpty) {
      SportSession().getClass();
    }

    super.build(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
        child: EasyRefresh.builder(
          controller: _controller,
          clipBehavior: Clip.none,
          header: const MaterialHeader(
            clamping: true,
            showBezierBackground: false,
            bezierBackgroundAnimation: false,
            bezierBackgroundBounce: false,
            springRebound: false,
          ),
          onRefresh: () async {
            await SportSession().getClass();
            _controller.finishRefresh();
          },
          refreshOnStart: true,
          childBuilder: (context, physics) => Obx(
            () {
              if (sportClass.value.situation == null &&
                  sportClass.value.items.isNotEmpty) {
                return DataList<Widget>(
                  list: sportClass.value.items
                      .map(
                        (element) => SportClassCard(data: element),
                      )
                      .toList(),
                  initFormula: (toUse) => toUse,
                );
              } else if (sportClass.value.situation == "正在获取") {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: Text("坏事: ${sportClass.value.situation}"),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class SportClassCard extends StatelessWidget {
  final SportClassItem data;
  const SportClassCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    String time = "星期";
    switch (data.week) {
      case 1:
        time += "一";
        break;
      case 2:
        time += "二";
        break;
      case 3:
        time += "三";
        break;
      case 4:
        time += "四";
        break;
      case 5:
        time += "五";
        break;
      case 6:
        time += "六";
        break;
      case 7:
        time += "七";
        break;
    }
    time += "第${data.start}节到第${data.stop}节";

    return ReXCard(
      title: Text(data.termToShow),
      remaining: [
        if (data.score.contains(RegExp(r'[0-9]'))) ReXCardRemaining(data.score)
      ],
      bottomRow: [
        informationWithIcon(
          Icons.access_time_filled_outlined,
          time,
          context,
        ),
        [
          informationWithIcon(
            Icons.person,
            data.teacher,
            context,
          ).flexible(),
          informationWithIcon(
            Icons.stadium,
            data.place,
            context,
          ).flexible(),
        ].toRow(),
      ].toColumn(),
    );
  }
}
