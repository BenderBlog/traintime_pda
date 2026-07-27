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
import 'package:watermeter/generated/l10n.dart';

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
      title: Text(I18n.of(context)!.scoreScoreChoiceSumDialogTitle),
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
                  hint: I18n.of(context)!.scoreFetchingHint,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<ScoreState>(
            builder: (context, state, _) {
              if (state.state == ScoreFetchState.readyCache) {
                return CacheAlerter(
                  hint: state.cacheHint?.resolve(I18n.of(context)!) ?? I18n.of(context)!.cacheReasonDefault,
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
                      hintText: I18n.of(context)!.scoreScorePageSearchHint,
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
                              I18n.of(context)!.scoreAllSemester,
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
                        I18n.of(context)!.scoreChosenSemester(
                          state.chosenSemester == ""
                              ? I18n.of(context)!.scoreAllSemester
                              : state.chosenSemester,
                        ),
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
                              I18n.of(context)!.scoreAllType,
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
                        I18n.of(context)!.scoreChosenType(
                          state.chosenStatus == ""
                              ? I18n.of(context)!.scoreAllType
                              : state.chosenStatus,
                        ),
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
                  text: I18n.of(context)!.scoreScorePageNoRecord,
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
                      child: Text(I18n.of(context)!.scoreScorePageSelectAll),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.none),
                      child: Text(
                        I18n.of(context)!.scoreScorePageSelectNothing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.original),
                      child: Text(I18n.of(context)!.scoreScorePageResetSelect),
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
                        I18n.of(context)!.scoreScoreChoiceSumDialogContent(
                          state.evalAvg(true, isGPA: true).toStringAsFixed(2),
                          state.evalAvg(true).toStringAsFixed(2),
                          state.evalCredit(true).toStringAsFixed(2),
                          state.unPassed,
                          state.notCoreClassTypeList == null
                              ? I18n.of(context)!.scoreNone
                              : state.notCoreClassTypeList!,
                        ),
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

