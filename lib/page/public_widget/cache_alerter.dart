// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/generated/l10n.dart';

// inapp: cache in the memory, will be cleared once program restart
// device: cache in device, read from a file
enum PlaceOfCache { inapp, device }

class CacheAlerter extends StatelessWidget {
  final String hint;
  final String? dataType;
  final PlaceOfCache placeOfCache;
  final DateTime fetchTime;

  const CacheAlerter({
    super.key,
    required this.hint,
    this.dataType,
    required this.placeOfCache,
    required this.fetchTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cachePlaceHint = placeOfCache == PlaceOfCache.inapp
        ? I18n.of(context)!.inappCacheHint(fetchTime.toString())
        : I18n.of(context)!.localCacheHint(fetchTime.toString());

    return Container(
      decoration: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      ).decoration,
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataType == null ? hint : "$dataType: $hint",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cachePlaceHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
