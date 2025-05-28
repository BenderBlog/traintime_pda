// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_page.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';

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
                FlutterI18n.translate(
                  context,
                  "score.score_page.title",
                ),
              ),
              actions: [
                if (state.state == ScoreFetchState.ok)
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () =>
                        state.refreshingState(context, isForce: true),
                  ),
              ],
            ),
            body: Builder(builder: (context) {
              switch (state.state) {
                case ScoreFetchState.ok:
                  return const ScorePage();
                case ScoreFetchState.error:
                  return ReloadWidget(
                    errorStatus: state.error,
                    function: () => state.refreshingState(context),
                  );
                case ScoreFetchState.fetching:
                  return const Center(child: CircularProgressIndicator());
              }
            }),
          );
        },
      ),
    );
  }
}
