// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/generated/translations.g.dart';

class ScoreWindow extends StatelessWidget {
  const ScoreWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScoreState(context),
      child: Consumer<ScoreState>(
        builder: (context, state, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                context.t.score.scorePage.title,
              ),
              actions: [
                if (state.state == ScoreFetchState.readyCache ||
                    state.state == ScoreFetchState.readyFresh)
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () =>
                        state.refreshingState(context, isForce: true),
                  ),
              ],
            ),
            body: Builder(
              builder: (context) {
                switch (state.state) {
                  case ScoreFetchState.readyFresh:
                  case ScoreFetchState.readyCache:
                  case ScoreFetchState.fetchingWithData:
                    return const ScorePage();
                  case ScoreFetchState.error:
                    return ReloadWidget(
                      errorStatus: state.error,
                      stackTrace: state.stackTrace,
                      function: () => state.refreshingState(context),
                    );
                  case ScoreFetchState.fetching:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
