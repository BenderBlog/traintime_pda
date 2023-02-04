/*
Interface of the punch record window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

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

  @override
  bool get wantKeepAlive => true;

  int total = 0;
  int valid = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<PunchController>(
      builder: (c) => Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => c.updatePunch(),
          child: FutureBuilder<PunchDataList>(
            future: Future(() => c.punch),
            builder:
                (BuildContext context, AsyncSnapshot<PunchDataList> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return Center(child: Text("坏事: ${snapshot.error}"));
                } else {
                  total = snapshot.data!.valid;
                  valid = snapshot.data!.valid;
                  if (snapshot.data!.all.isEmpty) {
                    return const Center(
                      child: Text(
                        "没有记录",
                        textScaleFactor: 1.2,
                      ),
                    );
                  }
                  return dataList<RecordCard, RecordCard>(
                    List.generate(
                      snapshot.data!.all.length,
                      (i) =>
                          RecordCard(mark: i + 1, toUse: snapshot.data!.all[i]),
                    ),
                    (toUse) => toUse,
                  );
                }
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      Divider(color: Colors.transparent),
                      Text(
                        "正在获取信息...",
                        textScaleFactor: 1.2,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "总次数：$total\n成功次数：$valid",
                //"总次数：${snapshot.data.allTime}\n成功次数：${snapshot.data.valid}",
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
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagsBoxes(
                  text: mark.toString(),
                  backgroundColor: Colors.deepPurple,
                ),
                situation(),
              ],
            ),
            const Divider(height: 15),
            Row(
              children: [
                const SizedBox(width: 5),
                Text(
                  "于 ${toUse.punchDay} ${toUse.punchTime} 在 ${toUse.machineName}",
                  textScaleFactor: 1.1,
                ),
              ],
            ),
            if (!toUse.state.contains("成功"))
              Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text(
                    toUse.state.contains("锻炼间隔需30分钟以上")
                        ? toUse.state.replaceAll("锻炼间隔需30分钟以上", "")
                        : toUse.state,
                    textScaleFactor: 1.1,
                  )),
                ],
              )
          ],
        ),
      ),
    );
  }
}
