// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/xidian_ids/ehall_score_session.dart';

class ScoreWindow extends StatefulWidget {
  const ScoreWindow({super.key});

  @override
  State<ScoreWindow> createState() => _ScoreWindowState();
}

class _ScoreWindowState extends State<ScoreWindow> {
  bool _isScoreListLoaded = false;
  late Future<List<Score>> scoreList;

  Navigator _getNavigator(BuildContext context, Widget child) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }

  void dataInit() {
    if (!_isScoreListLoaded) {
      scoreList = ScoreSession().getScore();
    }
  }

  @override
  void initState() {
    dataInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: scoreList,
      builder: (context, snapshot) {
        Widget body;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            body = ReloadWidget(
              function: () => setState(() {
                _isScoreListLoaded = false;
                dataInit();
              }),
            );
          } else {
            _isScoreListLoaded = true;
            return ScoreState.init(
              scoreTable: snapshot.data!,
              context: context,
              child: _getNavigator(
                context,
                const ScorePage(),
              ),
            );
          }
        } else {
          body = const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text("成绩查询")),
          body: body,
        );
      },
    );
  }
}
