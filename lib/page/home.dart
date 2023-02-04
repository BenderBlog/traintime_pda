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
import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/modified_library/sprt_sn_progress_dialog/sprt_sn_progress_dialog.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'package:watermeter/page/setting/subwindow/sport_password_dialog.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  ClassTable classTable = ClassTable();

  @override
  void onReady() async {
    await ClassTableFile().get().onError((error, stackTrace) {
      throw error.toString();
    }).then((value) {
      isGet = true;
      classTable.update(value);
    });
    update();
  }
}

/*
class PunchController extends GetxController {
  bool isGet = false;
  String error = "";
  ClassTable classTable = ClassTable();

  @override
  void onReady() async {
    await ClassTableFile().get().then((value) {
      isGet = true;
      classTable.update(value);
    });
    update();
  }
}
*/

class HomePage extends StatelessWidget {
  final _classTableController = Get.put(ClassTableController());

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Traintime PDA"),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GetBuilder<ClassTableController>(
              builder: (c) => GestureDetector(
                onTap: () => Get.to(
                  () => LayoutBuilder(
                    builder: (p0, p1) => ClassTableWindow(
                      constraints: p1,
                      classData: _classTableController.classTable,
                    ),
                  ),
                ),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_sharp,
                        size: 96.0,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "课程表 ${_classTableController.classTable.semesterCode}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            /*
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
            ),*/
          ],
        ),
      ),
    );
  }
  /*
  void _getClassTable(bool isFocus) async {
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
      await ses.getClasstable(
        focus: isFocus,
        onResponse: (int number, String status) =>
            pd.update(msg: status, value: number),
      );
    } on Exception catch (e) {
      isGood = false;
      pd.update(value: -1, msg: e.toString());
    }
    if (!mounted) return;
    if (isGood == true) {
      if (pd.isOpen()) {
        pd.close();
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) => ClassTableWindow(
              classData: classData,
              constraints: constraints,
            ),
          );
        }),
      );
    }
  }
  */
}
