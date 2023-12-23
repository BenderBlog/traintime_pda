// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_state.dart';

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
        if (c.controllers.isSelectMod) {
          /// Animation
          if (c.controllers.isSelected[widget.mark] == true &&
              widget.isScoreChoice) {
            setState(() => _isVisible = false);
            Future.delayed(_duration).then((value) {
              c.setScoreChoiceFromIndex(widget.mark);
              setState(() => _isVisible = true);
            });
          } else {
            c.setScoreChoiceFromIndex(widget.mark);
          }
        }
      },
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: _duration,
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          elevation: 0,
          color:
              c.controllers.isSelectMod && c.controllers.isSelected[widget.mark]
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.secondary,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      c.scoreTable[widget.mark].name,
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    Row(
                      children: [
                        TagsBoxes(
                          text: c.scoreTable[widget.mark].year,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        TagsBoxes(
                          text: c.scoreTable[widget.mark].status,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        if (c.scoreTable[widget.mark].examType.isNotEmpty)
                          TagsBoxes(
                            text: c.scoreTable[widget.mark].examType,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        if (c.scoreTable[widget.mark].examType.isNotEmpty)
                          const SizedBox(width: 5),
                        TagsBoxes(
                          text: c.scoreTable[widget.mark].examProp,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    Text(
                      "学分: ${c.scoreTable[widget.mark].credit}",
                    ),
                    Text(
                      "GPA: ${c.scoreTable[widget.mark].gpa}",
                    ),
                    Text(
                      "成绩：${c.scoreTable[widget.mark].scoreStr}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
