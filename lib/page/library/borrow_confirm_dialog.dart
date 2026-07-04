// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

class BorrowConfirmDialog extends StatefulWidget {
  final String? coverUrl;
  final String bookName;
  final String? locationName;

  const BorrowConfirmDialog({
    super.key,
    this.coverUrl,
    required this.bookName,
    this.locationName,
  });

  @override
  State<BorrowConfirmDialog> createState() => _BorrowConfirmDialogState();
}

class _BorrowConfirmDialogState extends State<BorrowConfirmDialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown <= 1) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).pop(false);
        return;
      }
      setState(() {
        _countdown--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
                imageUrl: widget.coverUrl ?? "",
                placeholder: (_, _) => Image.asset(
                  "assets/art/pda_empty_cover.jpg",
                  width: 100,
                  height: 125,
                  fit: BoxFit.fill,
                ),
                errorWidget: (_, _, _) => Image.asset(
                  "assets/art/pda_empty_cover.jpg",
                  width: 100,
                  height: 125,
                  fit: BoxFit.fill,
                ),
                width: 100,
                height: 125,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              )
              .clipRRect(all: 12)
              .padding(all: 2)
              .decorated(
                border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(14)),
              ),
          const SizedBox(height: 16),
          Text(
            widget.bookName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.locationName != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.locationName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                FlutterI18n.translate(context, "library.confirm_borrow"),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "${FlutterI18n.translate(context, "cancel")} ($_countdown)",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
