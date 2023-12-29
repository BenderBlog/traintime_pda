// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Interface of the sport score window of the sport data.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

const _cardHorizontalPadding = 12.0;
const _cardVerticalPadding = 16.0;

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({Key? key}) : super(key: key);

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow>
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
    if (sportScore.value.situation == null && sportScore.value.detail.isEmpty) {
      SportSession().getScore();
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
            await SportSession().getScore();
            _controller.finishRefresh();
          },
          refreshOnStart: true,
          childBuilder: (context, physics) => Obx(() {
            if (sportScore.value.situation == null &&
                sportScore.value.detail.isNotEmpty) {
              List things = [
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Column(
                    children: [
                      ScoreCardTitleRow(
                        title: "四年总分",
                        score: double.parse(sportScore.value.total),
                        rank: sportScore.value.rank,
                      ).padding(bottom: 8),
                      Text(
                        sportScore.value.detail.substring(
                          0,
                          sportScore.value.detail.indexOf("\\"),
                        ),
                      ),
                    ],
                  ).paddingDirectional(
                    horizontal: _cardHorizontalPadding,
                    vertical: _cardVerticalPadding,
                  ),
                ),
              ];
              things.addAll(List.generate(sportScore.value.list.length,
                      (index) => ScoreCard(toUse: sportScore.value.list[index]))
                  .reversed);
              return dataList<dynamic, Widget>(
                things,
                (toUse) => toUse,
                physics: physics,
              );
            } else if (sportScore.value.situation == "正在获取") {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text("坏事: ${sportScore.value.situation}"));
            }
          }),
        ),
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;

  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  String unitToShow(String eval) =>
      eval.contains(".") ? eval.substring(0, eval.indexOf(".")) : eval;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          ScoreCardTitleRow(
            title: "${toUse.year} 第${toUse.gradeType}",
            score: double.parse(toUse.totalScore),
            rank: toUse.rank,
          ).padding(bottom: 8),
          if (toUse.details.isNotEmpty)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(0.4),
              },
              children: [
                const TableRow(
                  children: [
                    Text(
                      "项目",
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "数据",
                      style: TextStyle(fontFeatures: [
                        FontFeature.tabularFigures(),
                      ]),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "分数",
                      style: TextStyle(fontFeatures: [
                        FontFeature.tabularFigures(),
                      ]),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "及格",
                      style: TextStyle(fontFeatures: [
                        FontFeature.tabularFigures(),
                      ]),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                TableRow(
                  children: List<Widget>.generate(
                    4,
                    (index) => const Divider(height: 8),
                  ),
                ),
                for (var i in toUse.details)
                  TableRow(
                    children: [
                      Text(
                        i.examName,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        i.actualScore.contains('/')
                            ? "${i.actualScore.split('/')[0]}cm/${i.actualScore.split('/')[1]}kg"
                            : "${i.actualScore}${unitToShow(i.examunit)}",
                        style: const TextStyle(fontFeatures: [
                          FontFeature.tabularFigures(),
                        ]),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "${i.score}分",
                        style: const TextStyle(fontFeatures: [
                          FontFeature.tabularFigures(),
                        ]),
                        textAlign: TextAlign.start,
                      ),
                      Icon(
                        i.score >= 60
                            ? MingCuteIcons.mgc_check_circle_line
                            : MingCuteIcons.mgc_close_circle_line,
                        color: i.score >= 60 ? Colors.green : Colors.red,
                      ).alignment(Alignment.centerRight),
                    ],
                  ),
              ],
            )
          else
            Text(toUse.moreinfo).center(),
        ],
      ).paddingDirectional(
        horizontal: _cardHorizontalPadding,
        vertical: _cardVerticalPadding,
      ),
    );
  }
}

class ScoreCardTitleRow extends StatelessWidget {
  final String title;
  final double score;
  final String rank;

  const ScoreCardTitleRow({
    super.key,
    required this.title,
    required this.score,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              "$score分",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: score >= 50 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            TagsBoxes(
              text: rank,
              backgroundColor: rank.contains("不") ? Colors.red : Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}
