import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/model/xidian_ids/score.dart';

class ScoreComposeCard extends StatelessWidget {
  final Score score;
  const ScoreComposeCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        elevation: 0,
        color: Colors.transparent,
        child: ListView(
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: GetBuilder<ScoreController>(
                builder: (c) => FutureBuilder<Compose>(
                  future: c.getDetail(score.classID, score.year),
                  builder: (context, snapshot) {
                    late Widget info;
                    if (snapshot.hasData) {
                      if (snapshot.data == null ||
                          snapshot.data!.score.isEmpty) {
                        info = const InfoDetailBox(
                            child: Center(child: Text("未提供详情信息")));
                      } else {
                        info = InfoDetailBox(
                          child: Table(
                            children: [
                              for (var i in snapshot.data!.score)
                                TableRow(
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
                                ),
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      info = const InfoDetailBox(
                          child: Center(child: Text("未获取详情信息")));
                    } else {
                      info = const InfoDetailBox(
                          child: Center(child: Text("正在获取")));
                    }
                    return Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              Text(
                                score.name,
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
                                    text: score.year,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  TagsBoxes(
                                    text: score.status,
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
                                "学分: ${score.credit}",
                              ),
                              Text(
                                "GPA: ${score.gpa}",
                              ),
                              Text(
                                "成绩：${score.how == 1 || score.how == 2 ? "${score.level}(${score.score})" : score.score}",
                              ),
                              Card(
                                elevation: 0,
                                child: info,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: GetBuilder<ScoreController>(
                builder: (c) => FutureBuilder<ScorePlace>(
                  future: c.getPlaceInClass(score.classID, score.year),
                  builder: (context, snapshot) {
                    List<Widget> info = [];
                    if (snapshot.hasData) {
                      if (snapshot.data!.highest != null) {
                        info.add(InfoDetailBox(
                          child: Table(
                            children: [
                              if (snapshot.data!.place != null)
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("排名"),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${snapshot.data!.place} / ${snapshot.data!.total}"),
                                      ),
                                    ),
                                  ],
                                ),
                              TableRow(
                                children: <Widget>[
                                  const TableCell(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("最高分"),
                                    ),
                                  ),
                                  TableCell(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          snapshot.data!.highest.toString()),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  const TableCell(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("最低分"),
                                    ),
                                  ),
                                  TableCell(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          snapshot.data!.lowest.toString()),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  const TableCell(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("平均分"),
                                    ),
                                  ),
                                  TableCell(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          snapshot.data!.average.toString()),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                      }
                      if (snapshot.data!.statistics.isNotEmpty) {
                        info.add(const SizedBox(height: 10));
                        info.add(SizedBox(
                            height: 150,
                            child: InfoDetailBox(
                                child: Chart(
                              data: [
                                for (var i in snapshot.data!.statistics)
                                  {'level': i.level, 'people': i.people},
                              ],
                              variables: {
                                'level': Variable(
                                  accessor: (Map map) => map['level'] as String,
                                ),
                                'people': Variable(
                                  accessor: (Map map) => map['people'] as int,
                                ),
                              },
                              marks: [
                                IntervalMark(
                                  label: LabelEncode(
                                      encoder: (tuple) =>
                                          Label(tuple['people'].toString())),
                                  color: ColorEncode(
                                    value: Defaults.primaryColor,
                                    updaters: {
                                      'tap': {
                                        false: (color) => color.withAlpha(100)
                                      }
                                    },
                                  ),
                                ),
                              ],
                              axes: [
                                Defaults.horizontalAxis,
                                Defaults.verticalAxis,
                              ],
                            ))));
                      }

                      if (info.isEmpty) {
                        info.add(const InfoDetailBox(
                            child: Center(child: Text("目前没有班级成绩详情信息"))));
                      }
                    } else if (snapshot.hasError) {
                      info.add(const InfoDetailBox(
                          child: Center(child: Text("未获取班级成绩详情信息"))));
                    } else {
                      info.add(const InfoDetailBox(
                          child: Center(child: Text("正在获取"))));
                    }
                    return Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "班级信息",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...info
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoDetailBox extends StatelessWidget {
  final Widget child;
  const InfoDetailBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
