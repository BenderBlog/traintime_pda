/*
Score info card.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/both_side_sheet.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/page/score/score_info.dart';
import 'package:watermeter/controller/score_controller.dart';

class ScoreInfoCard extends StatelessWidget {
  // Mark is a variable in ScoreInfo class
  final int mark;
  final bool functionActivated;
  const ScoreInfoCard({
    super.key,
    required this.mark,
    required this.functionActivated,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScoreController>(
      builder: (c) => GestureDetector(
        onTap: () {
          if (functionActivated) {
            if (c.isSelectMod) {
              c.setScoreChoiceState(mark);
            } else {
              /*showBottomSheet(
                context: context,
                builder: (context) => ScoreComposeCard(
                  score: c.scoreTable[mark],
                ),
              );*/

              BothSideSheet.show(
                context: context,
                title: "成绩详情",
                child: ScoreComposeCard(
                  score: c.scoreTable[mark],
                ),
              );
            }
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          elevation: 0,
          color: functionActivated && c.isSelectMod && c.isSelected[mark]
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      c.scoreTable[mark].name,
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
                          text: c.scoreTable[mark].year,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        TagsBoxes(
                          text: c.scoreTable[mark].status,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        TagsBoxes(
                          text: c.scoreTable[mark].type,
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
                      "学分: ${c.scoreTable[mark].credit}",
                    ),
                    Text(
                      "GPA: ${c.scoreTable[mark].gpa}",
                    ),
                    Text(
                      "成绩：${c.scoreTable[mark].how == 1 || c.scoreTable[mark].how == 2 ? c.scoreTable[mark].level : c.scoreTable[mark].score}",
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
