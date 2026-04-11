// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Interface of the sport score window of the sport data.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/model/xidian_sport/sport_score.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

// 常量定义
const double _textBackgroundAlpha = 0.3;
// const double _textTitleBackgroundAlpha = 0.6;
const int _primaryColorShade = 900;
const int _secondaryColorShade = 900;
const double _scoreFontSize = 13.0;
const double _rankFontSize = 13.0;
const double _labelFontSize = 11.0;

class ScoreColorScheme {
  final Color scoreBackgroundColor;
  final Color scoreTextColor;
  final Color rankBackgroundColor;
  final Color rankTextColor;

  ScoreColorScheme({
    required this.scoreBackgroundColor,
    required this.scoreTextColor,
    required this.rankBackgroundColor,
    required this.rankTextColor,
  });
}

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({super.key});

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<FetchResult<SportScore>> _future;

  Object? _translateError(BuildContext context, Object? error) {
    if (error is SportCredentialMissingException ||
        error is SportCredentialInvalidException) {
      return FlutterI18n.translate(context, error.toString());
    }
    if (error is String) {
      return FlutterI18n.translate(context, error);
    }
    return error;
  }

  /// 根据合格/不合格状态获取颜色方案
  ScoreColorScheme _getColorScheme(bool isQualified, bool isFourYearsComplete) {
    if (isFourYearsComplete) {
      return ScoreColorScheme(
        scoreBackgroundColor: Colors.grey.withValues(
          alpha: _textBackgroundAlpha,
        ),
        scoreTextColor: Colors.grey[_primaryColorShade]!,
        rankBackgroundColor: Colors.grey.withValues(
          alpha: _textBackgroundAlpha,
        ),
        rankTextColor: Colors.grey[_secondaryColorShade]!,
      );
    }

    final baseColor = isQualified ? Colors.green : Colors.red;
    return ScoreColorScheme(
      scoreBackgroundColor: baseColor.withValues(alpha: _textBackgroundAlpha),
      scoreTextColor: baseColor[_primaryColorShade]!,
      rankBackgroundColor: baseColor.withValues(alpha: _textBackgroundAlpha),
      rankTextColor: baseColor[_secondaryColorShade]!,
    );
  }

  @override
  void initState() {
    super.initState();
    _future = SportSession().getScore();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _future = SportSession().getScore();
        });
      },
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final result = snapshot.data!;
            final data = result.data;
            final scoreColorScheme = _getColorScheme(
              data.isQualified,
              data.isFourYearsComplete,
            );
            List<Widget> things = [
              ReXCard(
                title: Text(
                  FlutterI18n.translate(context, "sport.total_score"),
                ),
                remaining: [],
                bottomRow: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    [
                          [
                                Text(
                                  FlutterI18n.translate(
                                    context,
                                    "sport.total_score_label",
                                  ),
                                  style: const TextStyle(
                                    fontSize: _labelFontSize,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        scoreColorScheme.scoreBackgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    data.total,
                                    style: TextStyle(
                                      color: scoreColorScheme.scoreTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _scoreFontSize,
                                    ),
                                  ),
                                ),
                              ]
                              .toRow(
                                crossAxisAlignment: CrossAxisAlignment.center,
                              )
                              .expanded(),
                          const SizedBox(width: 12),
                          [
                                Text(
                                  FlutterI18n.translate(
                                    context,
                                    "sport.rank_label",
                                  ),
                                  style: const TextStyle(
                                    fontSize: _labelFontSize,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scoreColorScheme.rankBackgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    FlutterI18n.translate(
                                      context,
                                      data.scoreRankI18nStr,
                                    ),
                                    style: TextStyle(
                                      color: scoreColorScheme.rankTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _rankFontSize,
                                    ),
                                  ),
                                ),
                              ]
                              .toRow(
                                crossAxisAlignment: CrossAxisAlignment.center,
                              )
                              .expanded(),
                        ]
                        .toRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        )
                        .padding(vertical: 8.0),
                    const Divider(height: 16, thickness: 0.5),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Center(
                        child: Text(
                          data.detail.substring(0, data.detail.indexOf("\\")),
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
                data.list.length,
                (index) => ScoreCard(toUse: data.list[index]),
              ).reversed,
            );
            return Column(
              children: [
                if (result.isCache)
                  CacheAlerter(
                    dataType: FlutterI18n.translate(context, "sport.title"),
                    hint: FlutterI18n.translate(
                      context,
                      result.hintKey ?? "cache_reason_default",
                    ),
                    placeOfCache: PlaceOfCache.inapp,
                    fetchTime: result.fetchTime,
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: things.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: sheetMaxWidth),
                          child: things[index],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.5,
                      vertical: 9.0,
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return ReloadWidget(
              function: () => setState(() {
                _future = SportSession().getScore();
              }),
              errorStatus: _translateError(context, snapshot.error),
              stackTrace: snapshot.stackTrace,
            ).center();
          } else {
            return const CircularProgressIndicator().center();
          }
        },
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;

  const ScoreCard({super.key, required this.toUse});

  String unitToShow(String eval) =>
      eval.contains(".") ? eval.substring(0, eval.indexOf(".")) : eval;

  Map<String, dynamic> _getTitleBadgeColorScheme() {
    final isQualified = !toUse.rank.contains("不");
    final baseColor = isQualified ? Colors.green : Colors.red;
    return {
      'scoreBackgroundColor': baseColor[_primaryColorShade],
      'scoreTextColor': Colors.white,
      'rankBackgroundColor': baseColor[_primaryColorShade],
      'rankTextColor': Colors.white,
    };
  }

  @override
  Widget build(BuildContext context) {
    //final displayInfo = _getScoreDisplayInfo();
    final titleBadgeInfo = _getTitleBadgeColorScheme();

    return ReXCard(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              FlutterI18n.translate(
                context,
                "sport.semester",
                translationParams: {
                  "year": toUse.year,
                  "gradeType": toUse.gradeType,
                },
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  "${FlutterI18n.translate(context, "sport.total_score_label")}：",
                  style: const TextStyle(fontSize: _labelFontSize),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: titleBadgeInfo['scoreBackgroundColor'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    toUse.totalScore,
                    style: TextStyle(
                      color: titleBadgeInfo['scoreTextColor'],
                      fontWeight: FontWeight.bold,
                      fontSize: _scoreFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      remaining: [],
      bottomRow: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
