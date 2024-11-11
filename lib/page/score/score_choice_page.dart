// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';

class ScoreChoicePage extends StatefulWidget {
  const ScoreChoicePage({super.key});

  @override
  State<ScoreChoicePage> createState() => _ScoreChoicePageState();
}

class _ScoreChoicePageState extends State<ScoreChoicePage> {
  late ScoreState state;
  late TextEditingController text;

  @override
  void didChangeDependencies() {
    state = ScoreState.of(context)!;
    state.controllers.addListener(() => mounted ? setState(() {}) : null);
    text = TextEditingController.fromValue(
      TextEditingValue(text: state.controllers.searchInScoreChoice),
    );
    super.didChangeDependencies();
  }

  Future<void> scoreInfoDialog(context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(FlutterI18n.translate(
            context,
            "score.score_choice.sum_dialog_title",
          )),
          content: Text(
            FlutterI18n.translate(
              context,
              "score.score_choice.sum_dialog_content",
              translationParams: {
                "gpa_all": state.evalAvg(true, isGPA: true).toStringAsFixed(3),
                "avg_all": state.evalAvg(true).toStringAsFixed(2),
                "credit_all": state.evalCredit(true).toStringAsFixed(2),
                "unpassed": state.unPassed.isEmpty
                    ? FlutterI18n.translate(context, "score.all_passed")
                    : state.unPassed,
                "not_core_credit": state.notCoreClass.toString(),
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(
                context,
                "confirm",
              )),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back,
          ),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(FlutterI18n.translate(
          context,
          "score.score_choice.title",
        )),
        actions: [
          IconButton(
            onPressed: () => scoreInfoDialog(context),
            icon: const Icon(Icons.info),
          ),
        ],
      ),
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
                  isDense: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  hintText: FlutterI18n.translate(
                    context,
                    "score.score_choice.search_hint",
                  ),
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (String text) => state.searchInScoreChoice = text,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: () async {
                  await showDialog<int>(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      chooseList: ["score.all_semester", ...state.semester],
                    ),
                  ).then((value) {
                    if (value != null) {
                      state.chosenSemesterInScoreChoice =
                          ["", ...state.semester].toList()[value];
                    }
                  });
                },
                child: Text(FlutterI18n.translate(
                    context, "score.chosen_semester",
                    translationParams: {
                      "chosen":
                          state.controllers.chosenSemesterInScoreChoice == ""
                              ? FlutterI18n.translate(
                                  context,
                                  "score.all_semester",
                                )
                              : state.controllers.chosenSemesterInScoreChoice,
                    })),
              ).padding(right: 4),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: () async {
                  await showDialog<int>(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      chooseList:
                          ["score.all_type", ...state.statuses].toList(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      state.chosenStatusInScoreChoice =
                          ["", ...state.statuses].toList()[value];
                    }
                  });
                },
                child: Text(FlutterI18n.translate(context, "score.chosen_type",
                    translationParams: {
                      "type": state.controllers.chosenStatusInScoreChoice == ""
                          ? FlutterI18n.translate(
                              context,
                              "score.all_type",
                            )
                          : state.controllers.chosenStatusInScoreChoice,
                    })),
              ),
            ],
          )
              .padding(horizontal: 14, top: 8, bottom: 6)
              .constrained(maxWidth: 480),
          Expanded(
            child: state.selectedScoreList.isNotEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => AlignedGridView.count(
                          shrinkWrap: true,
                          itemCount: state.selectedScoreList.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          crossAxisCount: constraints.maxWidth ~/ cardWidth,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          itemBuilder: (context, index) => ScoreInfoCard(
                            mark: state.selectedScoreList[index].mark,
                            isScoreChoice: true,
                          ),
                        ))
                : Center(
                    child: Text(FlutterI18n.translate(
                    context,
                    "score.score_choice.empty_list",
                  ))),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.bottomInfo(context),
              textScaler: const TextScaler.linear(1.2),
            ),
          ],
        ),
      ),
    );
  }
}
