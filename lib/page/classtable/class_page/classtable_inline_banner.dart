// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/generated/l10n.dart';

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
        ClassTableStatusSource.classTable => I18n.of(
          context,
        )!.classtableStatusSourceClassTable,
        ClassTableStatusSource.exam => I18n.of(
          context,
        )!.classtableStatusSourceExam,
        ClassTableStatusSource.physicsExperiment => I18n.of(
          context,
        )!.classtableStatusSourcePhysicsExperiment,
        ClassTableStatusSource.otherExperiment => I18n.of(
          context,
        )!.classtableStatusSourceOtherExperiment,
      };

  @override
  Widget build(BuildContext context) {
    final isVisible = loadingSources.isNotEmpty || cacheSources.isNotEmpty;
    final loadingText = loadingSources.isEmpty
        ? null
        : I18n.of(context)!.classtableStatusBannerLoading(
            loadingSources
                .map((source) => _sourceLabel(context, source))
                .join("; "),
          );
    final cacheText = cacheSources.isEmpty
        ? null
        : I18n.of(context)!.classtableStatusBannerCache(
            cacheSources
                .map((source) => _sourceLabel(context, source))
                .join("; "),
          );

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
