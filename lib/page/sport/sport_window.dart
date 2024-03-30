// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the sport data.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/page/sport/sport_class_window.dart';
import 'package:watermeter/page/sport/sport_score_window.dart';

class SportWindow extends StatelessWidget {
  const SportWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () => SplitView.of(context).pop(),
          ),
          title: const Text("体育查询"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "课程信息"),
              Tab(text: "体测成绩"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SportClassWindow(),
            SportScoreWindow(),
          ],
        ),
      ),
    );
  }
}
