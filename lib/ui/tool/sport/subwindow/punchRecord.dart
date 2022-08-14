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
import 'package:watermeter/ui/weight.dart';
import 'package:watermeter/dataStruct/sport/punch.dart';
import 'package:watermeter/communicate/sport/sportSession.dart';

class PunchRecordWindow extends StatefulWidget {
  const PunchRecordWindow({Key? key}) : super(key: key);

  @override
  State<PunchRecordWindow> createState() => _PunchRecordWindowState();
}

class _PunchRecordWindowState extends State<PunchRecordWindow> {
  bool isValid = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _get(),
            child: FutureBuilder<PunchDataList>(
              future: _get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text("坏事: ${snapshot.error} / ${toUse.userId}"));
                  } else {
                    return Scaffold(
                      body: Column(
                        children: [
                          TitleLine(
                              child:Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children:[
                                    Text(
                                      "总次数：${snapshot.data.allTime}      成功次数：${snapshot.data.valid}",
                                      textScaleFactor: 1.2,
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (int i = snapshot.data.all.length - 1; i >=0 ; --i)
                                  RecordCard(mark: i + 1, toUse: snapshot.data.all[i]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      floatingActionButton: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            isValid = !isValid;
                          });
                        },
                        label: Text(
                          isValid ? "查看所有记录" : "查看成功记录",
                          textScaleFactor: 1.1,
                        ),
                        backgroundColor: Colors.deepPurple,
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Future<PunchDataList> _get() async =>
      getPunchData(isValid);
}

class RecordCard extends StatelessWidget {

  final PunchData toUse;
  final int mark;
  const RecordCard({Key? key, required this.mark, required this.toUse}) : super(key: key);

  TagsBoxes situation () {
    String toShow;
    Color background;
    if (toUse.state.contains("成功")){
      toShow = "成功：${toUse.state.substring(18)}";
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
    return ShadowBox(
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
                    Expanded(child: Text(
                      toUse.state.contains("锻炼间隔需30分钟以上") ?
                      toUse.state.replaceAll("锻炼间隔需30分钟以上","") :
                      toUse.state,
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

