// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';

import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/generated/translations.g.dart';

/// What the classtable is busy with: which sources are still being fetched, and
/// which ones are served from the cache.
///
/// This used to be a bar of its own between the week row and the table, which
/// cost a row of the screen whether or not it had something to say. It sits in
/// the app bar next to the title now, so the table keeps that row and the hint
/// stays in sight while the table is scrolled.
///
/// The two states are one line each, stacked, so both of them can name their
/// sources: side by side they would not fit next to the title even on a wide
/// phone, and the second one is the one which would be cut. The app bar keeps
/// its height, so the stack is given a [MediaQuery.withClampedTextScaling] and
/// every line elides rather than wrap.
class ClassTableStatusHint extends StatelessWidget {
  final List<ClassTableStatusSource> loadingSources;
  final List<ClassTableStatusSource> cacheSources;

  const ClassTableStatusHint({
    super.key,
    required this.loadingSources,
    required this.cacheSources,
  });

  /// The tallest the text of the hint is allowed to get.
  ///
  /// Two lines have to stay inside the app bar at every font scale, and this is
  /// where they stop fitting.
  static const double _maxTextScale = 1.3;

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

  /// One line of the hint: an optional leading widget in front of the text.
  ///
  /// The line is a child of the column below, so it is measured against the
  /// room the title row has left and the text elides instead of overflowing.
  Widget _line(String text, TextStyle style, {Widget? leading}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[leading, const SizedBox(width: 4)],
      Flexible(
        child: Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    /// Smaller than the body text: this is a note about the table, not part of
    /// its title.
    final style = TextStyle(fontSize: 12, color: color);

    final lines = <Widget>[
      if (cacheSources.isNotEmpty)
        _line(
          context.t.classtable.statusBanner.cache(
            sources: _joinSources(context, cacheSources),
          ),
          style,
        ),
      if (loadingSources.isNotEmpty)
        _line(
          context.t.classtable.statusBanner.loading(
            sources: _joinSources(context, loadingSources),
          ),
          style,
          leading: SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ),
    ];

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxTextScale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      ),
    );
  }
}
