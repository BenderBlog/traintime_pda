// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
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
            return ExperimentListView(data: snapshot.data!);
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
