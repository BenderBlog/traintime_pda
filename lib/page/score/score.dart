// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_score_session.dart';

class ScoreWindow extends StatefulWidget {
  const ScoreWindow({super.key});

  @override
  State<ScoreWindow> createState() => _ScoreWindowState();
}

class _ScoreWindowState extends State<ScoreWindow> {
  static const scoreListCacheName = "scores.json";
  bool scoreListCacheLoadEnabled = true;
  late Future<List<Score>> scoreList;
  late File file;

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
      "Path at ${supportPath.path}/${scoreListCacheName}.",
    );
    if (file.existsSync()) {
      final timeDiff = DateTime.now().difference(
        file.lastModifiedSync()
      ).inDays;
      if (timeDiff < 1) {
        log.i(
          "[ScoreWindow][loadScoreListCache] "
          "Cache file effective.",
        );
        return (jsonDecode(file.readAsStringSync()) as List).map(
          (s) => Score.fromJson(s as Map<String, dynamic>)
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
    log.i(
      "[ScoreWindow][dumpScoreListCache] "
      "Dumped scoreList to ${supportPath.path}/${scoreListCacheName}.",
    );
  }

  Future<void> dataInit() async {
    file = File("${supportPath.path}/${scoreListCacheName}");
    final list = scoreListCacheLoadEnabled ? (await loadScoreListCache()) : [];
    scoreListCacheLoadEnabled = true;
    if (list.isEmpty) {
      log.i(
        "[ScoreWindow][dataInit] "
        "Loaded scoreList from ScoreSession.",
      );
      scoreList = ScoreSession().getScore();
      final list = await scoreList;
      dumpScoreListCache(list);
    } else {
      log.i(
        "[ScoreWindow][dataInit] "
        "Loaded scoreList from cache.",
      );
      scoreList = Future.value(list);
    }
  }

  @override
  void initState() {
    file = File("${supportPath.path}/${scoreListCacheName}");
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
                scoreListCacheLoadEnabled = false;
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
