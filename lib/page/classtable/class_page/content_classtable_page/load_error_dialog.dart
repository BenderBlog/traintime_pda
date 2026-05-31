// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

Future<void> showClassTableLoadErrorDialog(BuildContext context) async {
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
    ClassTableStatusSource.otherExperiment => state.otherExperimentCacheHintKey,
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
    if (errorWithoutCacheSources.isNotEmpty && errorWithCacheSources.isNotEmpty)
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
      title: Text(
        FlutterI18n.translate(context, "classtable.error_dialog_title"),
      ),
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
