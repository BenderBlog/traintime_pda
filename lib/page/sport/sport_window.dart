// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the sport data.
// TODO: Fix reloadwidget cannot get the idea...

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
          title: Text(FlutterI18n.translate(
            context,
            "sport.title",
          )),
          bottom: TabBar(
            tabs: [
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "sport.test_score",
                ),
              ),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "sport.class_info",
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SportScoreWindow(),
            SportClassWindow(),
          ],
        ),
      ),
    );
  }
}
