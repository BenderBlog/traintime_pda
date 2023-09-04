// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Interface of the punch record window of the sport data.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class PunchRecordWindow extends StatefulWidget {
  const PunchRecordWindow({Key? key}) : super(key: key);

  @override
  State<PunchRecordWindow> createState() => _PunchRecordWindowState();
}

class _PunchRecordWindowState extends State<PunchRecordWindow>
    with AutomaticKeepAliveClientMixin {
  bool isValid = false;
  late EasyRefreshController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
            child: EasyRefresh.builder(
              controller: _controller,
              clipBehavior: Clip.none,
              header: const MaterialHeader(
                clamping: true,
                showBezierBackground: false,
                bezierBackgroundAnimation: false,
                bezierBackgroundBounce: false,
                springRebound: false,
              ),
              onRefresh: () async {
                await SportSession().getPunch();
                _controller.finishRefresh();
              },
              childBuilder: (context, physics) {
                if (punchData.value.situation.isEmpty) {
                  if (punchData.value.all.isNotEmpty) {
                    int count = 0;
                    List<RecordCard> toUse = [];
                    for (var i in punchData.value.all) {
                      if ((isValid && i.state.contains("恭喜你本次打卡成功")) ||
                          !isValid) {
                        toUse.insertAll(
                            0, [RecordCard(mark: count + 1, toUse: i)]);
                        count++;
                      }
                    }
                    return dataList<RecordCard, RecordCard>(
                      toUse,
                      (toUse) => toUse,
                      physics: physics,
                    );
                  } else {
                    return ListView(
                      physics: physics,
                      children: [
                        SizedBox(
                          height: context.height * 0.7,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  size: 64,
                                ),
                                Text(
                                  "列表为空，快去打卡吧()",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                } else if (punchData.value.situation.contains("正在加载")) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Center(
                    child: Text("坏事: ${punchData.value.situation}"),
                  );
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "总次数: ${punchData.value.allTime}\n成功次数: ${punchData.value.validTime}",
                textScaleFactor: 1.2,
              ),
              FloatingActionButton.extended(
                elevation: 0.0,
                highlightElevation: 0.0,
                focusElevation: 0.0,
                disabledElevation: 0.0,
                onPressed: () {
                  setState(() {
                    isValid = !isValid;
                  });
                  _controller.callRefresh();
                },
                label: Text(
                  isValid ? "查看所有记录" : "查看成功记录",
                  textScaleFactor: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final PunchData toUse;
  final int mark;

  const RecordCard({Key? key, required this.mark, required this.toUse})
      : super(key: key);

  TagsBoxes situation() {
    String toShow;
    Color background;
    if (toUse.state.contains("成功")) {
      toShow = toUse.state.length == 4
          ? toUse.state
          : "成功：${toUse.state.substring(18)}";
      background = Colors.green;
    } else if (toUse.state.contains("失败")) {
      toShow = "失败";
      background = Colors.red;
    } else {
      toShow = "信息";
      background = Colors.blueAccent;
    }
    return TagsBoxes(
      text: toShow,
      backgroundColor: background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondary,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            TagsBoxes(
              text: "第 $mark 条",
            ),
            situation(),
            const Divider(
              color: Colors.transparent,
              height: 5,
            ),
            informationWithIcon(Icons.punch_clock,
                toUse.time.format(pattern: "yyyy-MM-dd HH:mm:ss"), context),
            informationWithIcon(Icons.place, toUse.machineName, context),
            if (!toUse.state.contains("成功"))
              informationWithIcon(
                  Icons.error_outline,
                  toUse.state.contains("锻炼间隔需30分钟以上")
                      ? toUse.state.replaceAll("锻炼间隔需30分钟以上", "")
                      : toUse.state,
                  context),
          ],
        ),
      ),
    );
  }
}
