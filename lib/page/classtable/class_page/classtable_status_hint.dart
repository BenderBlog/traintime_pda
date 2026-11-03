// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/generated/translations.g.dart';

/// A loop beside the error button while a source is being fetched, and nothing
/// otherwise. Which sources came from the cache is the error dialog's business.
class ClassTableStatusHint extends StatelessWidget {
  final List<ClassTableStatusSource> loadingSources;

  const ClassTableStatusHint({super.key, required this.loadingSources});

  /// The size the app bar draws the buttons beside the mark at.
  static const double _iconSize = 24;

  /// Smaller than [_iconSize]: the indicator draws a little wider than its box.
  static const double _spinnerSize = 14;

  static const double _spinnerStroke = 2.5;

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
    if (loadingSources.isEmpty) {
      return const SizedBox.shrink();
    }

    /// Quieter than the buttons beside it: this is a note, not an action.
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    /// The box keeps one size, so the buttons beside it do not shift.
    return Tooltip(
      message: context.t.classtable.statusBanner.loading(
        sources: _joinSources(context, loadingSources),
      ),
      child: SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: Center(
          child: SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: _spinnerStroke,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
