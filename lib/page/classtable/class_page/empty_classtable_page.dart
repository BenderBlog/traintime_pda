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
import 'package:watermeter/generated/l10n.dart';

class EmptyClassTablePage extends StatelessWidget {
  const EmptyClassTablePage({super.key});

  Future<void> _showLoadErrorDialog(BuildContext context) async {
    final state = ClassTableState.of(context)!.controllers;
    final errorWithoutCacheSources = state.errorWithoutCacheSources;
    final errorWithCacheSources = state.errorWithCacheSources;

    String sourceLabel(ClassTableStatusSource source) =>
        switch (source) {
          ClassTableStatusSource.classTable =>
            I18n.of(context)!.classtableStatusSourceClassTable,
          ClassTableStatusSource.exam =>
            I18n.of(context)!.classtableStatusSourceExam,
          ClassTableStatusSource.physicsExperiment =>
            I18n.of(context)!.classtableStatusSourcePhysicsExperiment,
          ClassTableStatusSource.otherExperiment =>
            I18n.of(context)!.classtableStatusSourceOtherExperiment,
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
        I18n.of(context)!.classtableStatusBannerErrorSummary(errorWithoutCacheSources.map(sourceLabel).join("、")),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(I18n.of(context)!)
            : I18n.of(context)!.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        I18n.of(context)!.classtableStatusBannerCache(errorWithCacheSources.map(sourceLabel).join("、")),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(I18n.of(context)!)
            : I18n.of(context)!.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(I18n.of(context)!.loadError),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18n.of(context)!.confirm),
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
        I18n.of(context)!.classtableEmptyStateWithExamAndExperiment(semesterCode),
      (true, false) =>
        I18n.of(context)!.classtableEmptyStateWithExam(semesterCode),
      (false, true) =>
        I18n.of(context)!.classtableEmptyStateWithExperiment(semesterCode),
      (false, false) =>
        I18n.of(context)!.classtableEmptyStateNoCourse(semesterCode),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context)!.classtablePageTitle),
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
              tooltip: I18n.of(context)!.loadError,
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
                I18n.of(context)!.classtableEmptyActionViewExam,
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
                I18n.of(context)!.classtableEmptyActionViewExperiment,
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              showToast(
                context: context,
                msg: I18n.of(context)!.classtableRefreshClasstableReady,
              );
              await ClassTableState.of(
                context,
              )!.controllers.updateClasstable(context).then((data) {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: I18n.of(context)!.classtableRefreshClasstableSuccess,
                  );
                }
              });
            },
            icon: const Icon(Icons.update),
            label: Text(
              I18n.of(context)!.classtablePopupMenuRefreshClasstable,
            ),
          ),
        ].toColumn(mainAxisAlignment: MainAxisAlignment.center).expanded(),
      ].toColumn(),
    );
  }
}

