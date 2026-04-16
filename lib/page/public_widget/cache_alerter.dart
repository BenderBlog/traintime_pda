// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
    final cachePlaceHint = FlutterI18n.translate(
      context,
      placeOfCache == PlaceOfCache.inapp
          ? "inapp_cache_hint"
          : "local_cache_hint",
      translationParams: {"datetime": fetchTime.toString()},
    );

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
