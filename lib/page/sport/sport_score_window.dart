// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Interface of the sport score window of the sport data.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({super.key});

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (sportScore.value.situation == null && sportScore.value.detail.isEmpty) {
      SportSession().getScore();
    }
  }

  /// 判断四年成绩是否完整
  bool _isFourYearsComplete() {
    // 标准的四年应该有4年的成绩记录
    return sportScore.value.list.length >= 4;
  }

  /// 获取总分显示值和颜色
  Map<String, dynamic> _getTotalScoreInfo() {
    final score = sportScore.value.total;

    if (!_isFourYearsComplete()) {
      return {
        'score': score,
        'rank': FlutterI18n.translate(
          context,
          "class_attendance.course_state.unknown",
        ),
        'scoreBackgroundColor': Colors.grey.withValues(alpha: 0.15),
        'scoreTextColor': Colors.grey[900],
        'rankBackgroundColor': Colors.grey.withValues(alpha: 0.1),
        'rankTextColor': Colors.grey[800],
        'isBold': false,
      };
    }

    bool isQualified = !sportScore.value.rank.contains("不");
    return {
      'score': score,
      'rank': sportScore.value.rank,
      'scoreBackgroundColor': isQualified
          ? Colors.green.withValues(alpha: 0.15)
          : Colors.red.withValues(alpha: 0.15),
      'scoreTextColor': isQualified ? Colors.green[900] : Colors.red[900],
      'rankBackgroundColor': isQualified
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
      'rankTextColor': isQualified ? Colors.green[800] : Colors.red[800],
      'isBold': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        await SportSession().getClass();
      },
      child: Obx(() {
        if (sportScore.value.situation == null &&
            sportScore.value.detail.isNotEmpty) {
          final scoreInfo = _getTotalScoreInfo();
          List<Widget> things = [
            ReXCard(
              title: Text(FlutterI18n.translate(context, "sport.total_score")),
              remaining: [],
              bottomRow: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FlutterI18n.translate(
                                  context,
                                  "sport.total_score_label",
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: scoreInfo['scoreBackgroundColor'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  scoreInfo['score'],
                                  style: TextStyle(
                                    color: scoreInfo['scoreTextColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FlutterI18n.translate(
                                  context,
                                  "sport.rank_label",
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: scoreInfo['rankBackgroundColor'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  scoreInfo['rank'],
                                  style: TextStyle(
                                    color: scoreInfo['rankTextColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Center(
                      child: Text(
                        sportScore.value.detail.substring(
                          0,
                          sportScore.value.detail.indexOf("\\"),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
          things.addAll(
            List<Widget>.generate(
              sportScore.value.list.length,
              (index) => ScoreCard(toUse: sportScore.value.list[index]),
            ).reversed,
          );
          return DataList<Widget>(list: things, initFormula: (toUse) => toUse);
        } else if (sportScore.value.situation == "sport.situation_fetching") {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: ReloadWidget(
              function: () => SportSession().getClass(),
              errorStatus: sportClass.value.situation != null
                  ? FlutterI18n.translate(
                      context,
                      "sport.situation_error",
                      translationParams: {
                        "situation": FlutterI18n.translate(
                          context,
                          sportClass.value.situation ?? "",
                        ),
                      },
                    )
                  : null,
            ),
          );
        }
      }),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;

  const ScoreCard({super.key, required this.toUse});

  String unitToShow(String eval) =>
      eval.contains(".") ? eval.substring(0, eval.indexOf(".")) : eval;

  /// 获取单年成绩的显示颜色和背景
  Map<String, dynamic> _getScoreDisplayInfo() {
    bool isQualified = !toUse.rank.contains("不");
    return {
      'scoreBackgroundColor': isQualified
          ? Colors.green.withValues(alpha: 0.15)
          : Colors.red.withValues(alpha: 0.15),
      'scoreTextColor': isQualified ? Colors.green[900] : Colors.red[900],
      'rankBackgroundColor': isQualified
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
      'rankTextColor': isQualified ? Colors.green[800] : Colors.red[800],
      'isBold': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayInfo = _getScoreDisplayInfo();

    return ReXCard(
      title: Text(
        FlutterI18n.translate(
          context,
          "sport.semester",
          translationParams: {"year": toUse.year, "gradeType": toUse.gradeType},
        ),
      ),
      remaining: [],
      bottomRow: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlutterI18n.translate(
                          context,
                          "sport.total_score_label",
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: displayInfo['scoreBackgroundColor'],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          toUse.totalScore,
                          style: TextStyle(
                            color: displayInfo['scoreTextColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlutterI18n.translate(context, "sport.rank_label"),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: displayInfo['rankBackgroundColor'],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          toUse.rank,
                          style: TextStyle(
                            color: displayInfo['rankTextColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (toUse.details.isNotEmpty)
            const Divider(height: 16, thickness: 0.5),
          if (toUse.details.isNotEmpty)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(0.4),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      FlutterI18n.translate(context, "sport.subject"),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      FlutterI18n.translate(context, "sport.data"),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      FlutterI18n.translate(context, "sport.score"),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      FlutterI18n.translate(context, "sport.passed"),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
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
                      Text(i.examName, textAlign: TextAlign.start),
                      Text(
                        i.actualScore.contains('/')
                            ? "${i.actualScore.split('/')[0]}cm/${i.actualScore.split('/')[1]}kg"
                            : "${i.actualScore}${unitToShow(i.examunit)}",
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "sport.score_string",
                          translationParams: {"score": i.score.toString()},
                        ),
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
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
            Text(toUse.moreinfo),
        ],
      ),
    );
  }
}
