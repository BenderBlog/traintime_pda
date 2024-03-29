// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/model/xidian_ids/score.dart';

class ScoreComposeCard extends StatefulWidget {
  final Score score;
  final Future<List<ComposeDetail>> detail;
  const ScoreComposeCard({
    super.key,
    required this.score,
    required this.detail,
  });

  @override
  State<ScoreComposeCard> createState() => _ScoreComposeCardState();
}

class _ScoreComposeCardState extends State<ScoreComposeCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComposeDetail>>(
      future: widget.detail,
      builder: (context, snapshot) {
        late Widget info;
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            info = const InfoDetailBox(child: Center(child: Text("未提供详情信息")));
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
          info = const InfoDetailBox(child: Center(child: Text("未获取详情信息")));
        } else {
          info = const InfoDetailBox(child: Center(child: Text("正在获取")));
        }
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ReXCard(
              title: Text(widget.score.name),
              remaining: [ReXCardRemaining(widget.score.semesterCode)],
              bottomRow: [
                [
                  Text(
                    "学分: ${widget.score.credit}",
                  ).expanded(flex: 3),
                  Text(
                    "GPA: ${widget.score.gpa}",
                  ).expanded(flex: 3),
                  Text(
                    "成绩: ${widget.score.scoreStr}",
                  ).expanded(flex: 2),
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
