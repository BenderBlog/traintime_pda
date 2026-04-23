import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_page/classtable_inline_banner.dart';
import 'package:watermeter/page/exam/exam_info_window.dart';
import 'package:watermeter/page/experiment/experiment_window.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class EmptyClassTablePage extends StatelessWidget {
  const EmptyClassTablePage({super.key});

  Future<void> _showLoadErrorDialog(BuildContext context) async {
    final state = ClassTableState.of(context)!.controllers;
    final errorWithoutCacheSources = state.errorWithoutCacheSources;
    final errorWithCacheSources = state.errorWithCacheSources;

    String sourceLabel(ClassTableStatusSource source) =>
        FlutterI18n.translate(context, switch (source) {
          ClassTableStatusSource.classTable =>
            "classtable.status_source.class_table",
          ClassTableStatusSource.exam => "classtable.status_source.exam",
          ClassTableStatusSource.physicsExperiment =>
            "classtable.status_source.physics_experiment",
          ClassTableStatusSource.otherExperiment =>
            "classtable.status_source.other_experiment",
        });

    String? sourceHintKey(ClassTableStatusSource source) => switch (source) {
      ClassTableStatusSource.classTable => state.classTableCacheHintKey,
      ClassTableStatusSource.exam => state.examCacheHintKey,
      ClassTableStatusSource.physicsExperiment =>
        state.physicsExperimentCacheHintKey,
      ClassTableStatusSource.otherExperiment =>
        state.otherExperimentCacheHintKey,
    };

    final content = <String>[
      if (errorWithoutCacheSources.isNotEmpty)
        FlutterI18n.translate(
          context,
          "classtable.status_banner.error_summary",
          translationParams: {
            "sources": errorWithoutCacheSources.map(sourceLabel).join("、"),
          },
        ),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? FlutterI18n.translate(context, hintKey)
            : FlutterI18n.translate(context, "network_error");
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        FlutterI18n.translate(
          context,
          "classtable.status_banner.cache",
          translationParams: {
            "sources": errorWithCacheSources.map(sourceLabel).join("、"),
          },
        ),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? FlutterI18n.translate(context, hintKey)
            : FlutterI18n.translate(context, "network_error");
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, "load_error")),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ClassTableState.of(context)!.controllers;
    final hasError =
        state.errorWithoutCacheSources.isNotEmpty ||
        state.errorWithCacheSources.isNotEmpty;
    final hasExamArrangement = state.hasExamArrangement;
    final hasExperimentArrangement = state.hasExperimentArrangement;
    final emptyMessageKey = hasExamArrangement && hasExperimentArrangement
        ? "classtable.empty_state.with_exam_and_experiment"
        : hasExamArrangement
        ? "classtable.empty_state.with_exam"
        : hasExperimentArrangement
        ? "classtable.empty_state.with_experiment"
        : "classtable.empty_state.no_course";

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "classtable.page_title")),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () =>
              Navigator.of(ClassTableState.of(context)!.parentContext).pop(),
        ),
        actions: [
          if (hasError)
            IconButton(
              onPressed: () => _showLoadErrorDialog(context),
              icon: const Icon(Icons.error_outline),
              tooltip: FlutterI18n.translate(context, "load_error"),
            ),
        ],
      ),
      body: [
        ClassTableInlineBanner(
          loadingSources: state.loadingSources,
          cacheSources: state.cacheSources,
        ),
        [
          EmptyListView(
            type: EmptyListViewType.rolling,
            text: FlutterI18n.translate(
              context,
              emptyMessageKey,
              translationParams: {
                "semester_code": ClassTableState.of(
                  context,
                )!.controllers.semesterCode,
              },
            ),
          ),
          if (hasExamArrangement)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExamInfoWindow()),
              ),
              icon: const Icon(Icons.assignment_outlined),
              label: Text(
                FlutterI18n.translate(
                  context,
                  "classtable.empty_action.view_exam",
                ),
              ),
            ),
          if (hasExperimentArrangement)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExperimentWindow(),
                ),
              ),
              icon: const Icon(Icons.science_outlined),
              label: Text(
                FlutterI18n.translate(
                  context,
                  "classtable.empty_action.view_experiment",
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "classtable.refresh_classtable.ready",
                ),
              );
              await ClassTableState.of(
                context,
              )!.controllers.updateClasstable(context).then((data) {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "classtable.refresh_classtable.success",
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.update),
            label: Text(
              FlutterI18n.translate(
                context,
                "classtable.popup_menu.refresh_classtable",
              ),
            ),
          ),
        ].toColumn(mainAxisAlignment: MainAxisAlignment.center).expanded(),
      ].toColumn(),
    );
  }
}
