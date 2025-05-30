// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
// Main window for score.

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late TextEditingController text;

  Widget scoreInfoDialog(BuildContext context) => Consumer<ScoreState>(
        builder: (context, state, _) => FloatingActionButton(
          child: const Icon(Icons.calculate),
          onPressed: () => state.isSelectMode = !state.isSelectMode,
        ),
      );

  void pushSumDialog(BuildContext context, String text) => context.pushDialog(
        AlertDialog(
          title: Text(FlutterI18n.translate(
            context,
            "score.score_choice.sum_dialog_title",
          )),
          content: Text(text),
        ),
      );

  @override
  void didChangeDependencies() {
    text = TextEditingController.fromValue(
      TextEditingValue(text: context.watch<ScoreState>().search),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              TextField(
                style: const TextStyle(fontSize: 14),
                controller: text,
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: FlutterI18n.translate(
                    context,
                    "score.score_page.search_hint",
                  ),
                ),
                onSubmitted: (String text) =>
                    context.read<ScoreState>().search = text,
              ).padding(bottom: 8),
              Consumer<ScoreState>(
                builder: (context, state, _) => FilledButton(
                  onPressed: () async {
                    await showDialog<int>(
                      context: context,
                      builder: (context) => ColumnChooseDialog(
                        chooseList:
                            ["score.all_semester", ...state.semester].toList(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        state.chosenSemester =
                            ["", ...state.semester].toList()[value];
                      }
                    });
                  },
                  child: Text(FlutterI18n.translate(
                      context, "score.chosen_semester",
                      translationParams: {
                        "chosen": state.chosenSemester == ""
                            ? FlutterI18n.translate(
                                context,
                                "score.all_semester",
                              )
                            : state.chosenSemester,
                      })),
                ),
              ).padding(right: 8),
              Consumer<ScoreState>(
                builder: (context, state, _) => FilledButton(
                  onPressed: () async {
                    await showDialog<int>(
                      context: context,
                      builder: (context) => ColumnChooseDialog(
                        chooseList:
                            ["score.all_type", ...state.statuses].toList(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        state.chosenStatus =
                            ["", ...state.statuses].toList()[value];
                      }
                    });
                  },
                  child: Text(FlutterI18n.translate(
                      context, "score.chosen_type",
                      translationParams: {
                        "type": state.chosenStatus == ""
                            ? FlutterI18n.translate(
                                context,
                                "score.all_type",
                              )
                            : state.chosenStatus,
                      })),
                ),
              ),
            ],
          )
              .padding(horizontal: 14, top: 8, bottom: 6)
              .constrained(maxWidth: 480),
          Consumer<ScoreState>(builder: (context, state, _) {
            if (state.toShow.isNotEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => AlignedGridView.count(
                  shrinkWrap: true,
                  itemCount: state.toShow.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  crossAxisCount: constraints.maxWidth ~/ cardWidth,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) => ScoreInfoCard(
                    mark: state.toShow[index].mark,
                  ),
                ),
              );
            } else {
              return EmptyListView(
                type: EmptyListViewType.reading,
                text: FlutterI18n.translate(
                  context,
                  "score.score_page.no_record",
                ),
              );
            }
          }).safeArea().expanded(),
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
                      child: Text(FlutterI18n.translate(
                        context,
                        "score.score_page.select_all",
                      )),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.none),
                      child: Text(FlutterI18n.translate(
                        context,
                        "score.score_page.select_nothing",
                      )),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () =>
                          state.setScoreChoiceState(ChoiceState.original),
                      child: Text(FlutterI18n.translate(
                        context,
                        "score.score_page.reset_select",
                      )),
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
                        FlutterI18n.translate(
                          context,
                          "score.score_choice.sum_dialog_content",
                          translationParams: {
                            "gpa_all": state
                                .evalAvg(true, isGPA: true)
                                .toStringAsFixed(3),
                            "avg_all": state.evalAvg(true).toStringAsFixed(2),
                            "credit_all":
                                state.evalCredit(true).toStringAsFixed(2),
                            "unpassed": state.unPassed.isEmpty
                                ? FlutterI18n.translate(
                                    context, "score.all_passed")
                                : state.unPassed,
                            "not_core_credit": state.notCoreClass.toString(),
                          },
                        ),
                      ),
                      icon: const Icon(Icons.info),
                    )
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
