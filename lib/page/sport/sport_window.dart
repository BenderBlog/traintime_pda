// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the sport data.

import 'package:flutter/material.dart';
import 'package:watermeter/page/sport/sport_class_window.dart';
import 'package:watermeter/page/sport/sport_score_window.dart';
import 'package:watermeter/generated/translations.g.dart';

class SportWindow extends StatelessWidget {
  const SportWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.sport.title),
          bottom: TabBar(
            tabs: [
              Tab(text: context.t.sport.testScore),
              Tab(text: context.t.sport.classInfo),
            ],
          ),
        ),
        body: const TabBarView(
          children: [SportScoreWindow(), SportClassWindow()],
        ),
      ),
    );
  }
}
