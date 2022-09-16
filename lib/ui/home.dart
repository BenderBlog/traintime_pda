/*
Home window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/modified_lib/sprt_sn_progress_dialog/sprt_sn_progress_dialog.dart';
import 'package:watermeter/ui/tool/score/score.dart';
import 'package:watermeter/ui/tool/sport/sportWindow.dart';
import 'package:watermeter/ui/tool/setting/setting.dart';
import 'package:watermeter/ui/xidianDir/xidianDir.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/communicate/IDS/ehall.dart';
import 'package:watermeter/communicate/sport/sportSession.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WaterMeter"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const SettingWindow();
                }),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const ToolWindow(),
    );
  }
}

class ToolWindow extends StatefulWidget {
  const ToolWindow({Key? key}) : super(key: key);

  @override
  State<ToolWindow> createState() => _ToolWindowState();
}


class _ToolWindowState extends State<ToolWindow> {

  void _sportLogin() async {
    bool isGood = true;
    if (user["sportPassword"] == "" || user["sportPassword"] == null){
      await showDialog(
        context: context,
        builder: (context) => const SportPasswordDialog(),
      );
    }
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: '正在登录体育后台',
      max: 100,
      hideValue: true,
      completed: Completed(
        completedMsg: "登录成功",
        closedDelay: 2500,
      ),
      error: ErrorSignal(
        closedDelay: 2500,
      ),
    );
    try {
      await sportLogin(
        (int number, String status) => pd.update(msg: status, value: number),
      );
    } catch (e) {
      isGood = false;
      pd.update(value: -1, msg: e.toString());
    }
    if (!mounted) return;
    if (isGood == true) {
      if (pd.isOpen()) {
        pd.close();
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {return const SportWindow();}
        ),
      );
    }
  }

  void _getScore() async {
    bool isGood = true;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: '正在获取成绩',
      max: 100,
      hideValue: true,
      completed: Completed(
        completedMsg: "成绩已经获得",
        closedDelay: 2500,
      ),
      error: ErrorSignal(
        closedDelay: 2500,
      ),
    );
    try {
      await ses.getScore(
        onResponse: (int number, String status) => pd.update(msg: status, value: number),
      );
    } catch (e) {
      isGood = false;
      pd.update(value: -1, msg: e.toString());
    }
    if (!mounted) return;
    if (isGood == true) {
      if (pd.isOpen()) {
        pd.close();
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return const ScoreWindow();
          }
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          MaterialButton(
            color: Colors.cyan,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.run_circle_outlined,
                  size: 96.0,
                ),
                SizedBox(height: 10),
                Text(
                  "体育查询",
                  textScaleFactor: 1.5,
                ),
              ],
            ),
            onPressed: () => _sportLogin(),
          ),
          MaterialButton(
            color: Colors.orange,
            onPressed: _getScore,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.score,
                  size: 96.0,
                ),
                SizedBox(height: 10),
                Text(
                  "成绩查询",
                  textScaleFactor: 1.5,
                ),
              ],
            ),
          ),
          MaterialButton(
            color: Colors.yellowAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.nightlife,
                  size: 96.0,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "生活信息",
                  textScaleFactor: 1.5,
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const XidianDirWindow();
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

