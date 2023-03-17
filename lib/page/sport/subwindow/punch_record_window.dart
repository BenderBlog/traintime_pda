/*
Interface of the punch record window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/punch_controller.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/page/widget.dart';

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
    return GetBuilder<PunchController>(
      builder: (c) => Scaffold(
        body: EasyRefresh.builder(
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
            c.updatePunch();
            _controller.finishRefresh();
          },
          childBuilder: (context, physics) {
            if (c.isGet == false && c.error != null) {
              return ListView(
                physics: physics,
                children: [
                  SizedBox(
                    height: context.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error),
                          Text(
                            "坏事 ${c.error}",
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            if (c.punch.all.isNotEmpty) {
              int count = 0;
              List<RecordCard> toUse = [];
              for (var i in c.punch.all) {
                if ((isValid && i.state.contains("恭喜你本次打卡成功")) || !isValid) {
                  toUse.insertAll(0, [RecordCard(mark: count + 1, toUse: i)]);
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.warning),
                          Text(
                            "列表为空",
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "总次数: ${c.punch.allTime}\n成功次数: ${c.punch.valid}",
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
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            TagsBoxes(
              text: "第 $mark 条",
              backgroundColor: Colors.deepPurple,
            ),
            situation(),
            const Divider(
              color: Colors.transparent,
              height: 5,
            ),
            informationWithIcon(Icons.punch_clock,
                "${toUse.punchDay}-${toUse.punchTime}", context),
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
