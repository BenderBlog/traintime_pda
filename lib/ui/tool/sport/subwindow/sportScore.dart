/*
Interface of the sport score window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/communicate/sport/sportSession.dart';
import 'package:watermeter/ui/weight.dart';
import 'package:watermeter/dataStruct/sport/score.dart';

TagsBoxes situation (String rank) => TagsBoxes(
  text: rank,
  backgroundColor: rank.contains("不") ? Colors.red : Colors.green,
);

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({Key? key}) : super(key: key);

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _get(),
      child: FutureBuilder<SportScore>(
        future: _get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("坏事: ${snapshot.error} / ${toUse.userId}"));
            } else {
              return ListView(
                  children: [
                    ShadowBox(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("目前四年总分 ${snapshot.data.total}"),
                            Text("${snapshot.data.detail.substring(0,snapshot.data.detail.indexOf("\\"))}"),
                          ],
                        ),
                      )
                    ),
                    for (int i = snapshot.data.list.length - 1; i >= 0 ; --i)
                      ScoreCard(toUse: snapshot.data.list[i]),
                  ],
                );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<SportScore> _get() async => getSportScore();
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;
  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  String unitToShow (String eval){
    if (eval.contains(".")){
      return eval.substring(0,eval.indexOf("."));
    } else {
      return eval;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text("${toUse.year} ${toUse.gradeType}"),
                    situation(toUse.rank),
                  ],
                ),
                Text(toUse.totalScore),
              ],
            ),
            const Divider(height: 15),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 242, 247),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Table(
                  children: [
                    for (var i in toUse.details)
                      TableRow(
                        children: [
                          Text(i.examName, textAlign:TextAlign.center,),
                          Text("${i.actualScore} ${unitToShow(i.examunit)}", textAlign:TextAlign.end,),
                          Text("${i.score} 分", textAlign:TextAlign.end,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [const SizedBox(width: 12), situation(i.rank),],
                          )
                        ],
                      ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
