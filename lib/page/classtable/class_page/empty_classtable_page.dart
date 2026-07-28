import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/page/classtable/class_page/classtable_inline_banner.dart';
import 'package:watermeter/page/exam/exam_info_window.dart';
import 'package:watermeter/page/experiment/experiment_window.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/generated/translations.g.dart';

class EmptyClassTablePage extends StatelessWidget {
  const EmptyClassTablePage({super.key});

  Future<void> _showLoadErrorDialog(BuildContext context) async {
    final state = ClassTableState.of(context)!.controllers;
    final errorWithoutCacheSources = state.errorWithoutCacheSources;
    final errorWithCacheSources = state.errorWithCacheSources;

    String sourceLabel(ClassTableStatusSource source) =>
        switch (source) {
          ClassTableStatusSource.classTable =>
            context.t.classtable.statusSource.classTable,
          ClassTableStatusSource.exam =>
            context.t.classtable.statusSource.exam,
          ClassTableStatusSource.physicsExperiment =>
            context.t.classtable.statusSource.physicsExperiment,
          ClassTableStatusSource.otherExperiment =>
            context.t.classtable.statusSource.otherExperiment,
        };

    CacheHint? sourceHintKey(ClassTableStatusSource source) => switch (source) {
      ClassTableStatusSource.classTable => state.classTableCacheHintKey,
      ClassTableStatusSource.exam => state.examCacheHintKey,
      ClassTableStatusSource.physicsExperiment =>
        state.physicsExperimentCacheHintKey,
      ClassTableStatusSource.otherExperiment =>
        state.otherExperimentCacheHintKey,
    };

    final content = <String>[
      if (errorWithoutCacheSources.isNotEmpty)
        context.t.classtable.statusBanner.errorSummary(sources: errorWithoutCacheSources.map(sourceLabel).join("、")),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(context.t)
            : context.t.common.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        context.t.classtable.statusBanner.cache(sources: errorWithCacheSources.map(sourceLabel).join("、")),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(context.t)
            : context.t.common.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.common.loadError),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.confirm),
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
    final semesterCode = state.semesterCode;
    final emptyMessage = switch ((hasExamArrangement, hasExperimentArrangement)) {
      (true, true) =>
        context.t.classtable.emptyState.withExamAndExperiment(semester_code: semesterCode),
      (true, false) =>
        context.t.classtable.emptyState.withExam(semester_code: semesterCode),
      (false, true) =>
        context.t.classtable.emptyState.withExperiment(semester_code: semesterCode),
      (false, false) =>
        context.t.classtable.emptyState.noCourse(semester_code: semesterCode),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.classtable.pageTitle),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (hasError)
            IconButton(
              onPressed: () => _showLoadErrorDialog(context),
              icon: const Icon(Icons.error_outline),
              tooltip: context.t.common.loadError,
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
            text: emptyMessage,
          ),
          if (hasExamArrangement)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExamInfoWindow()),
              ),
              icon: const Icon(Icons.assignment_outlined),
              label: Text(
                context.t.classtable.emptyAction.viewExam,
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
                context.t.classtable.emptyAction.viewExperiment,
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              showToast(
                context: context,
                msg: context.t.classtable.refreshClasstable.ready,
              );
              await ClassTableState.of(
                context,
              )!.controllers.updateClasstable(context).then((data) {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: context.t.classtable.refreshClasstable.success,
                  );
                }
              });
            },
            icon: const Icon(Icons.update),
            label: Text(
              context.t.classtable.popupMenu.refreshClasstable,
            ),
          ),
        ].toColumn(mainAxisAlignment: MainAxisAlignment.center).expanded(),
      ].toColumn(),
    );
  }
}

