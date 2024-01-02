// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the sport data.

import 'package:flutter/material.dart';
import 'package:watermeter/page/sport/punch_record_window.dart';
import 'package:watermeter/page/sport/sport_score_window.dart';

class SportWindow extends StatelessWidget {
  const SportWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabForSport();
  }
}

class TabForSport extends StatelessWidget {
  const TabForSport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("体育查询"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "打卡记录"),
              Tab(text: "体测记录"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PunchRecordWindow(),
            SportScoreWindow(),
          ],
        ),
      ),
    );
  }
}
