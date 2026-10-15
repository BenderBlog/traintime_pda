// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/generated/translations.g.dart';

/// What the classtable is busy with, as two marks in the app bar's actions.
///
/// The spinner is what is being fetched right now; [Icons.sync_problem] is what
/// the table on screen is showing out of the cache. Naming the sources cost the
/// app bar a row of its own, so they are left to the tooltips and to the error
/// button beside them.
class ClassTableStatusHint extends StatelessWidget {
  final List<ClassTableStatusSource> loadingSources;
  final List<ClassTableStatusSource> cacheSources;

  const ClassTableStatusHint({
    super.key,
    required this.loadingSources,
    required this.cacheSources,
  });

  /// The size the app bar draws the buttons beside the marks at.
  static const double _iconSize = 24;

  /// Smaller than [_iconSize]: the indicator draws a little wider than its box.
  static const double _spinnerSize = 14;

  static const double _spinnerStroke = 2.5;

  /// The room between the two marks.
  static const double _gap = 6;

  String _sourceLabel(BuildContext context, ClassTableStatusSource source) =>
      switch (source) {
        ClassTableStatusSource.classTable =>
          context.t.classtable.statusSource.classTable,
        ClassTableStatusSource.exam => context.t.classtable.statusSource.exam,
        ClassTableStatusSource.physicsExperiment =>
          context.t.classtable.statusSource.physicsExperiment,
        ClassTableStatusSource.otherExperiment =>
          context.t.classtable.statusSource.otherExperiment,
      };

  String _joinSources(
    BuildContext context,
    List<ClassTableStatusSource> sources,
  ) => sources.map((source) => _sourceLabel(context, source)).join("; ");

  @override
  Widget build(BuildContext context) {
    if (loadingSources.isEmpty && cacheSources.isEmpty) {
      return const SizedBox.shrink();
    }

    /// Quieter than the buttons beside them: these are notes, not actions.
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loadingSources.isNotEmpty)
          Tooltip(
            message: context.t.classtable.statusBanner.loading(
              sources: _joinSources(context, loadingSources),
            ),
            child: SizedBox(
              width: _spinnerSize,
              height: _spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: _spinnerStroke,
                color: color,
              ),
            ),
          ),
        if (loadingSources.isNotEmpty && cacheSources.isNotEmpty)
          const SizedBox(width: _gap),
        if (cacheSources.isNotEmpty)
          Tooltip(
            message: context.t.classtable.statusBanner.cache(
              sources: _joinSources(context, cacheSources),
            ),
            child: Icon(Icons.sync_problem, size: _iconSize, color: color),
          ),
      ],
    );
  }
}
