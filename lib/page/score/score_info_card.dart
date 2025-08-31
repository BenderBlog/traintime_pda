// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/score/score_compose_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

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
    if ((c.isSelectMode || widget.isScoreChoice) &&
        !c.isSelected[widget.mark]) {
      return 0.38;
    } else {
      return 1;
    }
  }

  @override
  void didChangeDependencies() {
    c = Provider.of<ScoreState>(context);
    super.didChangeDependencies();
  }

  bool _isVisible = true;
  Duration get _duration => Duration(milliseconds: _isVisible ? 0 : 150);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// Score choice window
        if (c.isSelectMode) {
          if (widget.isScoreChoice) {
            setState(() => _isVisible = false);
            Future.delayed(_duration).then((value) {
              c.setScoreChoiceFromIndex(widget.mark);
              setState(() => _isVisible = true);
            });
          } else {
            c.setScoreChoiceFromIndex(widget.mark);
          }
        } else if (!getBool(Preference.role)) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: ScoreComposeCard(
                  score: c.scoreData[widget.mark],
                  detail: ScoreSession().getDetail(
                    c.scoreData[widget.mark].classID,
                    c.scoreData[widget.mark].semesterCode,
                  ),
                ),
              );
            },
          );
        }
      },
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: _duration,
        child: ReXCard(
          opacity: cardOpacity,
          title: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                // TODO: Backend-return Data, unable to change at the moment...
                if (c.scoreData[widget.mark].scoreStatus != "初修")
                  TextSpan(text: "${c.scoreData[widget.mark].scoreStatus} "),
                if (c.scoreData[widget.mark].isPassed == false)
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "score.score_info_card.failed",
                    ),
                  ),
                TextSpan(text: c.scoreData[widget.mark].name),
              ],
            ),
          ),
          remaining: [ReXCardRemaining(c.scoreData[widget.mark].classStatus)],
          bottomRow: DefaultTextStyle(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: [
              Text(
                "${FlutterI18n.translate(context, "score.score_compose_card.credit")}: ${c.scoreData[widget.mark].credit}",
              ).expanded(flex: 2),
              Text(
                "${FlutterI18n.translate(context, "score.score_compose_card.gpa")}: ${c.scoreData[widget.mark].gpa}",
              ).expanded(flex: 3),
              Text(
                "${FlutterI18n.translate(context, "score.score_compose_card.score")}: ${c.scoreData[widget.mark].scoreStr}",
              ).expanded(flex: 3),
            ].toRow(),
          ),
        ),
      ),
    );
  }
}
