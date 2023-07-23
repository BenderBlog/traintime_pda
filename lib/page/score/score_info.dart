import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/score/watermark.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/model/xidian_ids/score.dart';

class ScoreComposeCard extends StatefulWidget {
  final Score score;
  const ScoreComposeCard({
    super.key,
    required this.score,
  });

  @override
  State<ScoreComposeCard> createState() => _ScoreComposeCardState();
}

class _ScoreComposeCardState extends State<ScoreComposeCard> {
  final ScoreController c = Get.put(ScoreController());
  late Future<ScorePlace> inClassPlace;
  late Future<ScorePlace> inGradePlace;
  late Future<Compose> compose;

  @override
  void initState() {
    super.initState();
    compose = c.getDetail(widget.score.classID, widget.score.year);
    inClassPlace = c.getPlaceInClass(widget.score.classID, widget.score.year);
    inGradePlace = c.getPlaceInGrade(widget.score.courseID, widget.score.year);
  }

  Widget scoreInfo(bool isInClass, BuildContext context) => Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: GetBuilder<ScoreController>(
          builder: (c) {
            Widget table(ScorePlace c) => Table(
                  children: [
                    if (c.place != null)
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
                              child: Text("${c.place} / ${c.total}"),
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
                            child: Text(c.highest.toString()),
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
                            child: Text(c.lowest.toString()),
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
                            child: Text(c.average.toString()),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
            return FutureBuilder<ScorePlace>(
              future: isInClass ? inClassPlace : inGradePlace,
              builder: (context, snapshot) {
                List<Widget> info = [];
                if (snapshot.hasData) {
                  if (snapshot.data!.highest != null) {
                    info.add(InfoDetailBox(child: table(snapshot.data!)));
                  }
                  if (snapshot.data!.statistics.isNotEmpty) {
                    info.add(const SizedBox(height: 10));
                    info.add(
                      SizedBox(
                        height: 176,
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
                                  encoder: (tuple) => Label(
                                    tuple['people'].toString(),
                                  ),
                                ),
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
                          ),
                        ),
                      ),
                    );
                  }
                  if (info.isEmpty) {
                    info.add(
                      InfoDetailBox(
                        child: Center(
                          child: Text("目前没有${isInClass ? "班级" : "年级"}成绩详情信息"),
                        ),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  info.add(
                    InfoDetailBox(
                      child: Center(
                        child: Text("未获取${isInClass ? "班级" : "年级"}成绩详情信息"),
                      ),
                    ),
                  );
                } else {
                  info.add(
                    const InfoDetailBox(
                      child: Center(
                        child: Text("正在获取"),
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${isInClass ? "班级" : "年级"}信息",
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
            );
          },
        ),
      );

  var watermark = Watermark(
    rowCount: 3,
    columnCount: 8,
    text: "${preference.getString(preference.Preference.idsAccount)} "
        "${preference.getString(preference.Preference.name)} \n"
        "仅个人参考 他用无效 ",
    textStyle: const TextStyle(
      color: Color(0x48000000),
      fontSize: 12,
      height: 4,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: GetBuilder<ScoreController>(
                builder: (c) => FutureBuilder<Compose>(
                  future: compose,
                  builder: (context, snapshot) {
                    late Widget info;

                    if (snapshot.hasData) {
                      if (snapshot.data == null ||
                          snapshot.data!.score.isEmpty) {
                        info = const InfoDetailBox(
                            child: Center(child: Text("未提供详情信息")));
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
                              snapshot.data!.score.length,
                              (i) => scoreDetail(snapshot.data!.score[i]),
                            ),
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
                                widget.score.name,
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
                                    text: widget.score.year,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  TagsBoxes(
                                    text: widget.score.status,
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
                                "学分: ${widget.score.credit}",
                              ),
                              Text(
                                "GPA: ${widget.score.gpa}",
                              ),
                              Text(
                                "成绩：${widget.score.how == 1 || widget.score.how == 2 ? "${widget.score.level}(${widget.score.score})" : widget.score.score}",
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
            if (Get.put(ScoreController()).allowDetail)
              scoreInfo(true, context),
            if (Get.put(ScoreController()).allowDetail)
              scoreInfo(false, context),
          ],
        ),
        watermark,
      ],
    );
  }
}
