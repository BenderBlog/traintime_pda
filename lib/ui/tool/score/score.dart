import 'package:flutter/material.dart';

/*
Intro of the score data from ids.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/
import 'package:flutter/material.dart';
import 'package:watermeter/dataStruct/ids/score.dart';
import 'package:watermeter/ui/tool/sport/subwindow/punchRecord.dart';
import 'package:watermeter/ui/tool/sport/subwindow/sportScore.dart';

import '../../weight.dart';

class ScoreWindow extends StatelessWidget {
  const ScoreWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabForScore();
  }
}

class TabForScore extends StatelessWidget {
  const TabForScore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("成绩查询"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('关于成绩查询'),
                          content: const Text(
                            "Copyright 2022 SuperBart. \nMPL 2.0 License.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("确定"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
        body: const ScoreTable(),
      ),
    );
  }
}

class ScoreTable extends StatefulWidget {
  const ScoreTable({Key? key}) : super(key: key);

  @override
  State<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<ScoreTable> {
  List<bool> selected =
      List<bool>.generate(scoreTable.length, (int index) => false);

  @override
  Widget build(BuildContext context) {
    print(scoreTable.length);
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: DataTable(
            dataRowHeight: 70,
            columns: const [
              DataColumn(label: Text('')),
            ],
            rows: List<DataRow>.generate(
              scoreTable.length,
              (int index) => DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  // All rows will have the same selected color.
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.08);
                  }
                  // Even rows will have a grey color.
                  if (index.isEven) {
                    return Colors.grey.withOpacity(0.3);
                  }
                  return null; // Use default value for other states and odd rows.
                }),
                cells: <DataCell>[
                  DataCell(ScoreCard(toUse: scoreTable[index])),
                ],
                selected: selected[index],
                onSelectChanged: (bool? value) {
                  setState(() {
                    selected[index] = value!;
                  });
                },
              ),
            ),
          ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final Score toUse;

  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toUse.name,
                  textAlign: TextAlign.left,
                  textScaleFactor: 0.9,
                ),
                Row(
                  children: [
                    TagsBoxes(
                      text: toUse.status,
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("学期：${toUse.year}",textScaleFactor: 0.9,),
                Text("学分: ${toUse.credit}",textScaleFactor: 0.9,),
                Text("成绩：${toUse.score}",textScaleFactor: 0.9,)
              ],
            ),
          ],
        ),
      )
    );
  }
}
