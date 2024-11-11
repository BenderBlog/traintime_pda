// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/model/xidian_ids/score.dart';

class ScoreComposeCard extends StatelessWidget {
  final Score score;
  final Future<List<ComposeDetail>> detail;
  const ScoreComposeCard({
    super.key,
    required this.score,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComposeDetail>>(
      future: detail,
      builder: (context, snapshot) {
        late Widget info;
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            info = InfoDetailBox(
              child: Center(
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "score.score_compose_card.no_detail",
                  ),
                ),
              ),
            );
          } else {
            TableRow scoreDetail(ComposeDetail i) {
              return TableRow(
                children: <Widget>[
                  TableCell(
                    child: Text(i.content),
                  ),
                  TableCell(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(i.ratio),
                    ),
                  ),
                  TableCell(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(i.score),
                    ),
                  ),
                ],
              );
            }

            info = InfoDetailBox(
              child: Table(
                children: List<TableRow>.generate(
                  snapshot.data!.length,
                  (i) => scoreDetail(snapshot.data![i]),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          info = InfoDetailBox(
            child: Center(
              child: Text(
                FlutterI18n.translate(
                  context,
                  "score.score_compose_card.no_detail",
                ),
              ),
            ),
          );
        } else {
          info = InfoDetailBox(
            child: Center(
              child: Text(
                FlutterI18n.translate(
                  context,
                  "score.score_compose_card.fetching",
                ),
              ),
            ),
          );
        }
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ReXCard(
              title: Text(score.name),
              remaining: [ReXCardRemaining(score.semesterCode)],
              bottomRow: [
                [
                  Text(
                    "${FlutterI18n.translate(
                      context,
                      "score.score_compose_card.credit",
                    )}: ${score.credit}",
                  ).expanded(flex: 2),
                  Text(
                    "${FlutterI18n.translate(
                      context,
                      "score.score_compose_card.gpa",
                    )}: ${score.gpa}",
                  ).expanded(flex: 3),
                  Text(
                    "${FlutterI18n.translate(
                      context,
                      "score.score_compose_card.score",
                    )}: ${score.scoreStr}",
                  ).expanded(flex: 3),
                ].toRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                const SizedBox(height: 8),
                info,
              ].toColumn(),
            ),
          ],
        );
      },
    );
  }
}
