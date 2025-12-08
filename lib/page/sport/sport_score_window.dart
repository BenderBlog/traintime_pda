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
          List<Widget> things = [
            ReXCard(
              title: Text(FlutterI18n.translate(context, "sport.total_score")),
              remaining: [
                ReXCardRemaining(
                  sportScore.value.total,
                  color: sportScore.value.rank.contains("不")
                      ? Colors.red
                      : null,
                  isBold: true,
                ),
                ReXCardRemaining(
                  sportScore.value.rank,
                  color: sportScore.value.rank.contains("不")
                      ? Colors.red
                      : null,
                  isBold: sportScore.value.rank.contains("不"),
                ),
              ],
              bottomRow: Text(
                sportScore.value.detail.substring(
                  0,
                  sportScore.value.detail.indexOf("\\"),
                ),
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

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text(
        FlutterI18n.translate(
          context,
          "sport.semester",
          translationParams: {"year": toUse.year, "gradeType": toUse.gradeType},
        ),
      ),
      remaining: [
        ReXCardRemaining(
          toUse.totalScore,
          color: toUse.rank.contains("不") ? Colors.red : null,
          isBold: true,
        ),
        ReXCardRemaining(
          toUse.rank,
          color: toUse.rank.contains("不") ? Colors.red : null,
          isBold: toUse.rank.contains("不"),
        ),
      ],
      bottomRow: toUse.details.isNotEmpty
          ? Table(
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
          : Text(toUse.moreinfo),
    );
  }
}
