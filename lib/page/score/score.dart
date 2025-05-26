// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreWindow extends StatelessWidget {
  const ScoreWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScoreState(),
      child: Consumer<ScoreState>(
        builder: (context, state, _) {
          Widget body;
          if (state.state == ScoreFetchState.ok) {
            if (ScoreSession.isScoreListCacheUsed) {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "score.cache_message",
                ),
              );
            }
            body = const ScorePage();
          } else if (state.state == ScoreFetchState.error) {
            body = ReloadWidget(
              errorStatus: context.read<ScoreState>().error,
              function: () => context.read<ScoreState>().refreshingState(),
            );
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
                if (state.state == ScoreFetchState.ok)
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () => context
                        .read<ScoreState>()
                        .refreshingState(isForce: true),
                  ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}


//class ScoreWindow extends StatefulWidget {
//  const ScoreWindow({super.key});
//
//  @override
//  State<ScoreWindow> createState() => _ScoreWindowState();
//}
//
//class _ScoreWindowState extends State<ScoreWindow> {
//  late ScoreSession scoreSession;
//  late Future<List<Score>> scoreList;
//
//  Navigator _getNavigator(BuildContext context, Widget child) {
//    return Navigator(
//      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
//        builder: (context) => child,
//      ),
//    );
//  }
//
//  void dataInit() {
//    scoreSession = ScoreSession();
//    scoreList = scoreSession.getScore();
//  }
//
//  @override
//  void initState() {
//    dataInit();
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return 
//  }
//}
//
