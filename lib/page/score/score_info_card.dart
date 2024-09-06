// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/score/score_compose_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/xidian_ids/ehall_score_session.dart';

class ScoreInfoCard extends StatefulWidget {
  // Mark is a variable in ScoreInfo class
  final int mark;
  // Is in score choice window
  final bool isScoreChoice;
  const ScoreInfoCard({
    super.key,
    required this.mark,
    this.isScoreChoice = false,
  });

  @override
  State<ScoreInfoCard> createState() => _ScoreInfoCardState();
}

class _ScoreInfoCardState extends State<ScoreInfoCard> {
  late ScoreState c;

  double get cardOpacity {
    if ((c.controllers.isSelectMod || widget.isScoreChoice) &&
        !c.controllers.isSelected[widget.mark]) {
      return 0.38;
    } else {
      return 1;
    }
  }

  @override
  void didChangeDependencies() {
    c = ScoreState.of(context)!;
    c.controllers.addListener(() => mounted ? setState(() {}) : null);
    super.didChangeDependencies();
  }

  bool _isVisible = true;
  Duration get _duration => Duration(milliseconds: _isVisible ? 0 : 150);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// Score choice window
        if (c.controllers.isSelectMod) {
          if (widget.isScoreChoice) {
            setState(() => _isVisible = false);
            Future.delayed(_duration).then((value) {
              c.setScoreChoiceFromIndex(widget.mark);
              setState(() => _isVisible = true);
            });
          } else {
            c.setScoreChoiceFromIndex(widget.mark);
          }
        } else {
          BothSideSheet.show(
            context: context,
            title: "成绩详情",
            child: ScoreComposeCard(
              score: c.scoreTable[widget.mark],
              detail: ScoreSession().getDetail(
                c.scoreTable[widget.mark].classID,
                c.scoreTable[widget.mark].semesterCode,
              ),
            ),
          );
        }
      },
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: _duration,
        child: ReXCard(
          opacity: cardOpacity,
          title: Text.rich(TextSpan(children: [
            if (c.scoreTable[widget.mark].scoreStatus != "初修")
              TextSpan(text: "${c.scoreTable[widget.mark].scoreStatus} "),
            if (c.scoreTable[widget.mark].isPassed == false)
              const TextSpan(text: "[挂] "),
            TextSpan(text: c.scoreTable[widget.mark].name)
          ])),
          remaining: [
            ReXCardRemaining(c.scoreTable[widget.mark].classStatus),
          ],
          bottomRow: Row(
            children: [
              Text(
                "学分 ${c.scoreTable[widget.mark].credit}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).expanded(flex: 2),
              Text(
                "GPA ${c.scoreTable[widget.mark].gpa}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).expanded(flex: 3),
              Text(
                "成绩 ${c.scoreTable[widget.mark].scoreStr}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).expanded(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
