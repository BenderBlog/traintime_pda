// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_list_tile.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_data.dart';
import 'package:intl/intl.dart';

/// A dialog/card shows the exam detail.
class ExamDetailCard extends StatelessWidget {
  final ArrangementDetailItem item;
  const ExamDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final infoColor = item.color;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        elevation: 0,
        color: infoColor.shade100,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              [
                CustomListTile(
                  icon: Icons.room,
                  str: item.classroom ?? '',
                  infoColor: infoColor,
                ).flexible(),
                if (item.seat != null)
                  CustomListTile(
                    icon: Icons.chair,
                    str: item.seat!,
                    infoColor: infoColor,
                  ).flexible(),
              ].toRow(),
              CustomListTile(
                icon: Icons.access_time_filled_outlined,
                str: item.dateRanges
                    .map((range) {
                      final dateFormatter = DateFormat(
                        'y/M/d EEEE',
                        Localizations.localeOf(context).toLanguageTag(),
                      );
                      return '${dateFormatter.format(range.start)} ${DateFormat('HH:mm').format(range.start)}-${DateFormat('HH:mm').format(range.end)}';
                    })
                    .join('\n'),
                infoColor: infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
