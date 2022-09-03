import 'package:flutter/material.dart';

/*
Calculate the average score.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/
import 'package:flutter/material.dart';
import 'package:watermeter/dataStruct/ids/score.dart';
import 'package:watermeter/ui/weight.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


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
                            "Copyright 2022 SuperBart. \n"
                            "MPL 2.0 License.\n"
                            "Please, Fry. I don't know how to teach. I'm a professor! ",
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
      List<bool>.generate(scores.scoreTable.length, (int index) => false);

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  double _evalAvgScore (){
    double totalScore = 0.0;
    double totalCredit = 0.0;
    for (var i = 0; i < selected.length; ++i){
      if (selected[i] == true){
        totalScore += scores.scoreTable[i].score * scores.scoreTable[i].credit;
        totalCredit += scores.scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore/totalCredit : 0.0;
  }

  List<Score> toShow () {
    /// If I write "whatever = scores.scoreTable", every change I make to "whatever"
    /// applies to scores.scoreTable. Since the reference whatsoever.
    List<Score> whatever = List.from(scores.scoreTable);
    print(scores.scoreTable.length);
    if (chosenSemester != "") {
      whatever.removeWhere((element)=>element.year!=chosenSemester);
    }
    if (chosenStatus != ""){
      whatever.removeWhere((element)=>element.status!=chosenStatus);
    }
    return whatever;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0.1,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
          child:Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25,10,10,10),
                child: DropdownButton(
                  value: chosenSemester,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  underline: Container(
                    height: 2,
                  ),
                  items: [
                    const DropdownMenuItem(value: "", child: Text("所有学期")),
                    for (var i in scores.semester)
                      DropdownMenuItem(value: i, child: Text(i))
                  ],
                  onChanged: (String? value) {
                    setState(() {chosenSemester = value!; },);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: DropdownButton(
                  value: chosenStatus,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  underline: Container(
                    height: 2,
                  ),
                  items: [
                    const DropdownMenuItem(value: "", child: Text("所有类型")),
                    for (var i in scores.statuses)
                      DropdownMenuItem(value: i, child: Text(i))
                  ],
                  onChanged: (String? value) {
                    setState(() { chosenStatus = value!; },);
                  },
                ),
              ),
              TextButton(
                  onPressed: () { print("Pending..."); },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "计算均分",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (builder, index){
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ScoreCard(toUse: toShow()[index]),
                  ),
                  const Divider(height: 10, thickness:5.0),
                ],
              );
            },
            itemCount: toShow().length,
          ),
        ),
      ],
    );






    /*return SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: DataTable(
            dataRowHeight: 70,
            columns: [
              DataColumn(label: Text('目前选中科目计算的均分：${evalAvgScore().toStringAsFixed(2)}')),
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
                    evalAvgScore();
                  });
                },
              ),
            ),
          ),
    );*/
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
                  //textScaleFactor: 0.9,
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
