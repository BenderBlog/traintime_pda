// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/generated/l10n.dart';

class BookPlaceCard extends StatelessWidget {
  final BookLocation toUse;
  const BookPlaceCard({super.key, required this.toUse});

  @override
  Widget build(BuildContext context) {
    final icon = toUse.processType == "在架"
        ? MingCuteIcons.mgc_book_5_line
        : MingCuteIcons.mgc_exit_line;

    return [
          [
            Icon(
              icon,
              color: toUse.processType == "在架"
                  ? Colors.green.shade900
                  : Colors.red.shade900,
            ),
            const SizedBox(width: 8),
            Text(
              toUse.locationName ?? I18n.of(context)!.libraryNotProvided,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: toUse.processType == "在架"
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ).expanded(),
          ].toRow(),
          const SizedBox(height: 8),
          Text(
            I18n.of(context)!.libraryBookCode(
              toUse.barCode ?? I18n.of(context)!.libraryNotProvided,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: toUse.processType == "在架"
                  ? Colors.green.shade900
                  : Colors.red.shade900,
            ),
            softWrap: true,
          ),
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 12)
        .backgroundColor(
          toUse.processType == "在架"
              ? Colors.green.shade200
              : Colors.red.shade200,
        )
        .clipRRect(all: 12)
        .padding(vertical: 4);
  }
}
