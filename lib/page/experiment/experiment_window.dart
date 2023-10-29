// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/experiment/experiment_listview.dart';
import 'package:watermeter/repository/experiment/experiment_session.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  late Future<List<ExperimentData>> data;

  @override
  void initState() {
    super.initState();
    data = ExperimentSession().getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("物理实验")),
      body: FutureBuilder<List<ExperimentData>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: ExperimentListView(data: snapshot.data!),
              floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.calendar_month),
                label: const Text("导出课表"),
                onPressed: () async {
                  String toStore = "BEGIN:VCALENDAR\n";
                  for (var i in snapshot.data!) {
                    String summary =
                        "SUMMARY:${i.name}-${i.teacher}@${i.classroom}\n";
                    String vevent = "BEGIN:VEVENT\n$summary";
                    vevent +=
                        "DTSTART:${Jiffy.parseFromDateTime(i.time[0]).format(pattern: 'yyyyMMddTHHmmss')}\n";
                    vevent +=
                        "DTEND:${Jiffy.parseFromDateTime(i.time[1]).format(pattern: 'yyyyMMddTHHmmss')}\n";
                    toStore += "${vevent}END:VEVENT\n";
                  }
                  toStore += "END:VCALENDAR";
                  try {
                    String now = Jiffy.now().format(
                      pattern: "yyyyMMddTHHmmss",
                    );
                    String tempPath = await getTemporaryDirectory()
                        .then((value) => value.path);
                    File file = File(
                      "$tempPath/experiment-$now.ics",
                    );
                    if (!(await file.exists())) {
                      await file.create();
                    }
                    await file.writeAsString(toStore);
                    await Share.shareXFiles(
                        [XFile("$tempPath/experiment-$now.ics")]);
                    await file.delete();
                    Fluttertoast.showToast(msg: "应该保存成功");
                  } on FileSystemException {
                    Fluttertoast.showToast(msg: "文件创建失败，保存取消");
                  }
                },
              ),
            );
          } else if (snapshot.hasError) {
            String errmsg = "";
            if (snapshot.error
                .toString()
                .contains("NoExperimentPasswordException")) {
              errmsg += "请去设置里设置密码";
            } else if (snapshot.error
                .toString()
                .contains("LoginFailedException")) {
              errmsg += "登录失败了";
            } else if (snapshot.error
                .toString()
                .contains("NotSchoolNetworkException")) {
              errmsg += "非校园网无法使用";
            } else {
              errmsg += snapshot.error.toString();
            }
            return Center(
              child: Text(errmsg),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
