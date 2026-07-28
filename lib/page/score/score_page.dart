// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
// Main window for score.

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/generated/translations.g.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late final TextEditingController text;

  Widget scoreInfoDialog(BuildContext context) => Consumer<ScoreState>(
    builder: (context, state, _) => FloatingActionButton(
      child: const Icon(Icons.calculate),
      onPressed: () => state.isSelectMode = !state.isSelectMode,
    ),
  );

  void pushSumDialog(BuildContext context, String text) => context.pushDialog(
    AlertDialog(
      title: Text(context.t.score.scoreChoice.sumDialogTitle),
      content: Text(text),
    ),
  );

  @override
  void initState() {
    super.initState();
    text = TextEditingController();
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Consumer<ScoreState>(
            builder: (context, state, _) {
              if (state.state == ScoreFetchState.fetchingWithData) {
                return LoadingAlerter(
                  isLoading: true,
                  showOverlay: false,
                  showAnimation: false,
                  hint: context.t.score.fetchingHint,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<ScoreState>(
            builder: (context, state, _) {
              if (state.state == ScoreFetchState.readyCache) {
                return CacheAlerter(
                  hint: state.cacheHint?.resolve(context.t) ?? context.t.common.cacheReasonDefault,
                  placeOfCache: PlaceOfCache.device,
                  fetchTime: state.fetchDate,
                );
              }
              return SizedBox.shrink();
            },
          ),
          Wrap(
                alignment: WrapAlignment.start,
                children: [
                  TextField(
                    style: const TextStyle(fontSize: 14),
                    controller: text,
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: context.t.score.scorePage.searchHint,
                    ),
                    onChanged: (value) =>
                        context.read<ScoreState>().search = value,
                    onSubmitted: (String text) =>
                        context.read<ScoreState>().search = text,
                  ).padding(bottom: 8),
                  Consumer<ScoreState>(
                    builder: (context, state, _) => FilledButton(
                      onPressed: () async {
                        await showDialog<int>(
                          context: context,
                          builder: (context) => ColumnChooseDialog(
                            chooseList: [
                              context.t.score.allSemester,
                              ...state.semester,
                            ].toList(),
                          ),
                        ).then((value) {
                          if (value != null) {
                            state.chosenSemester = [
                              "",
                              ...state.semester,
                            ].toList()[value];
                          }
                        });
                      },
                      child: Text(
                        context.t.score.chosenSemester(chosen: state.chosenSemester == ""
                              ? context.t.score.allSemester
                              : state.chosenSemester),
                      ),
                    ),
                  ).padding(right: 8),
                  Consumer<ScoreState>(
                    builder: (context, state, _) => FilledButton(
                      onPressed: () async {
                        await showDialog<int>(
                          context: context,
                          builder: (context) => ColumnChooseDialog(
                            chooseList: [
                              context.t.score.allType,
                              ...state.statuses,
                            ].toList(),
                          ),
                        ).then((value) {
                          if (value != null) {
                            state.chosenStatus = [
                              "",
                              ...state.statuses,
                            ].toList()[value];
                          }
                        });
                      },
                      child: Text(
                        context.t.score.chosenType(type: state.chosenStatus == ""
                              ? context.t.score.allType
                              : state.chosenStatus),
                      ),
                    ),
                  ),
                ],
              )
              .padding(horizontal: 14, top: 8, bottom: 6)
              .constrained(maxWidth: 480),
          Consumer<ScoreState>(
            builder: (context, state, _) {
              if (state.toShow.isNotEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) => AlignedGridView.count(
                    shrinkWrap: true,
                    itemCount: state.toShow.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    crossAxisCount: (constraints.maxWidth ~/ cardWidth).clamp(
                      1,
                      1000,
                    ),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemBuilder: (context, index) =>
                        ScoreInfoCard(mark: state.toShow[index].mark),
                  ),
                );
              } else {
                return EmptyListView(
                  type: EmptyListViewType.reading,
                  text: context.t.score.scorePage.noRecord,
                );
              }
            },
          ).safeArea().expanded(),
        ],
      ),
      floatingActionButton: scoreInfoDialog(context),
      bottomNavigationBar: Consumer<ScoreState>(
        builder: (context, state, _) => Visibility(
          visible: state.isSelectMode,
          child: BottomAppBar(
            height: 136,
            elevation: 5.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.all),
                      child: Text(context.t.score.scorePage.selectAll),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.none),
                      child: Text(
                        context.t.score.scorePage.selectNothing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.original),
                      child: Text(context.t.score.scorePage.resetSelect),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(state.bottomInfo(context)),
                    IconButton(
                      onPressed: () => pushSumDialog(
                        context,
                        context.t.score.scoreChoice.sumDialogContent(gpa_all: state.evalAvg(true, isGPA: true).toStringAsFixed(2), avg_all: state.evalAvg(true).toStringAsFixed(2), credit_all: state.evalCredit(true).toStringAsFixed(2), unpassed: state.unPassed, not_core_type: state.notCoreClassTypeList == null
                              ? context.t.score.none
                              : state.notCoreClassTypeList!),
                      ),
                      icon: const Icon(Icons.info),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

