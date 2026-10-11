// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/generated/translations.g.dart';

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
        ? context.t.common.inappCacheHint(datetime: fetchTime.toString())
        : context.t.common.localCacheHint(datetime: fetchTime.toString());

    return DecoratedBox(
      decoration: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      ).decoration,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: sheetMaxWidth),
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info, color: theme.colorScheme.primary),
              SizedBox(width: 8),
              Expanded(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
