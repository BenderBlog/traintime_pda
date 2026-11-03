// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/repository/translation_key.dart';

/// The app bar button which opens the load errors together with the sources
/// that ended up on screen from the cache. Nothing is drawn when nothing
/// failed, and nothing is cached behind an error.
class ClassTableErrorButton extends StatelessWidget {
  const ClassTableErrorButton({super.key});

  Future<void> _showDialog(BuildContext context) async {
    final state = ClassTableState.of(context)!.controllers;
    final errorWithoutCacheSources = state.errorWithoutCacheSources;
    final errorWithCacheSources = state.errorWithCacheSources;

    String sourceLabel(ClassTableStatusSource source) =>
        context.t.resolveKey(switch (source) {
          ClassTableStatusSource.classTable =>
            "classtable.status_source.class_table",
          ClassTableStatusSource.exam => "classtable.status_source.exam",
          ClassTableStatusSource.physicsExperiment =>
            "classtable.status_source.physics_experiment",
          ClassTableStatusSource.otherExperiment =>
            "classtable.status_source.other_experiment",
        });

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
        context.t.classtable.statusBanner.errorSummary(
          sources: errorWithoutCacheSources.map(sourceLabel).join("、"),
        ),
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
        context.t.classtable.statusBanner.cache(
          sources: errorWithCacheSources.map(sourceLabel).join("、"),
        ),
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
        title: Text(context.t.classtable.errorDialogTitle),
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
    if (!hasError) {
      return const SizedBox.shrink();
    }
    return IconButton(
      onPressed: () => _showDialog(context),
      icon: const Icon(Icons.error_outline),
      tooltip: context.t.classtable.errorDialogTitle,
    );
  }
}
