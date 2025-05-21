// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreWindow extends StatefulWidget {
  const ScoreWindow({super.key});

  @override
  State<ScoreWindow> createState() => _ScoreWindowState();
}

class _ScoreWindowState extends State<ScoreWindow> {
  late ScoreSession scoreSession;
  late Future<List<Score>> scoreList;

  Navigator _getNavigator(BuildContext context, Widget child) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }

  void dataInit() {
    scoreSession = ScoreSession();
    scoreList = scoreSession.getScore();
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
              errorStatus: snapshot.error,
              function: () => setState(() {
                dataInit();
              }),
            );
          } else {
            if (ScoreSession.isScoreListCacheUsed) {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "score.cache_message",
                ),
              );
            }
            body = ScoreState.init(
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
          appBar: AppBar(
            title: Text(
              FlutterI18n.translate(
                context,
                "score.score_page.title",
              ),
            ),
            actions: [
              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError)
                IconButton(
                  icon: const Icon(Icons.replay_outlined),
                  onPressed: () => setState(() {
                    scoreList = scoreSession.getScore(force: true);
                  }),
                ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}
