// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/generated/translations.g.dart';

class ClassTableInlineBanner extends StatelessWidget {
  final List<ClassTableStatusSource> loadingSources;
  final List<ClassTableStatusSource> cacheSources;

  const ClassTableInlineBanner({
    super.key,
    required this.loadingSources,
    required this.cacheSources,
  });

  String _sourceLabel(BuildContext context, ClassTableStatusSource source) =>
      switch (source) {
        ClassTableStatusSource.classTable => context.t.classtable.statusSource.classTable,
        ClassTableStatusSource.exam => context.t.classtable.statusSource.exam,
        ClassTableStatusSource.physicsExperiment => context.t.classtable.statusSource.physicsExperiment,
        ClassTableStatusSource.otherExperiment => context.t.classtable.statusSource.otherExperiment,
      };

  @override
  Widget build(BuildContext context) {
    final isVisible = loadingSources.isNotEmpty || cacheSources.isNotEmpty;
    final loadingText = loadingSources.isEmpty
        ? null
        : context.t.classtable.statusBanner.loading(sources: loadingSources
                .map((source) => _sourceLabel(context, source))
                .join("; "));
    final cacheText = cacheSources.isEmpty
        ? null
        : context.t.classtable.statusBanner.cache(sources: cacheSources
                .map((source) => _sourceLabel(context, source))
                .join("; "));

    return !isVisible
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loadingText != null) ...[
                        Text(
                          loadingText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                        if (cacheText != null) const SizedBox(height: 2),
                      ],
                      if (cacheText != null) ...[
                        Text(
                          cacheText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (loadingText != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
