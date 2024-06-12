// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_score_session.dart';

class ScoreWindow extends StatefulWidget {
  const ScoreWindow({super.key});

  @override
  State<ScoreWindow> createState() => _ScoreWindowState();
}

class _ScoreWindowState extends State<ScoreWindow> {
  static const scoreListCacheName = "scores.json";
  late Future<List<Score>> scoreList;

  Navigator _getNavigator(BuildContext context, Widget child) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }

  Future<List<Score>> loadScoreListCache() async {
    log.i(
      "[ScoreWindow][loadScoreListCache] "
      "Path at ${supportPath.path}/$scoreListCacheName.",
    );
    file = File("${supportPath.path}/$scoreListCacheName");
    if (file.existsSync()) {
      final timeDiff = DateTime.now().difference(
        file.lastModifiedSync()
      ).inDays;
      if (timeDiff < 1) {
        log.i(
          "[ScoreWindow][loadScoreListCache] "
          "Load effective cache file.",
        );
      return jsonDecode(file.readAsStringSync()).map(
        (s) => Score.fromJson(s)
      ).toList();
      }
    }
    log.i(
      "[ScoreWindow][loadScoreListCache] "
      "Cache file non-existent or ineffective.",
    );
    return [];
  }

  void dumpScoreListCache(List<Score> scores) {
    file.writeAsStringSync(
      jsonEncode(scores.map((s) => s.toJson()).toList())
    );
  }

  Future<void> dataInit async () {
    final cache = await loadScoreListCache();
    if (scoreList.isEmpty) {
      log.i(
        "[ScoreWindow][loadScoreListCache] "
        "Get scores via ScoreSession.",
      );
      scoreList = ScoreSession().getScore();
    } else {
      scoreList = Future.value(cache);
    }
  }

  @override
  void initState() {
    dataInit().then(() => super.initState())
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
                dataInit();
              }),
            );
          } else {
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
