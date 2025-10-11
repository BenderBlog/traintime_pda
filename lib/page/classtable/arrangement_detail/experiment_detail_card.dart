// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_list_tile.dart';

/// A dialog/card shows the exam detail.
class ExperimentDetailCard extends StatelessWidget {
  final ExperimentData experiment;
  final MaterialColor infoColor;
  const ExperimentDetailCard({
    super.key,
    required this.experiment,
    required this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
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
                experiment.name,
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              [
                CustomListTile(
                  icon: Icons.person,
                  str: experiment.teacher,
                  infoColor: infoColor,
                ).flexible(),
                CustomListTile(
                  icon: Icons.room,
                  str: experiment.classroom,
                  infoColor: infoColor,
                ).flexible(),
              ].toRow(),
              //  if (experiment.reference != null)
              //    CustomListTile(
              //      icon: Icons.book,
              //      str: experiment.reference!,
              //      infoColor: infoColor,
              //    ),
              Builder(
                builder: (context) {
                  final dateFormatter = DateFormat(
                    'y/M/d EEEE',
                    Localizations.localeOf(context).toLanguageTag(),
                  );
                  final timeFormatter = DateFormat("HH:mm");

                  return CustomListTile(
                    icon: Icons.access_time_filled_outlined,
                    infoColor: infoColor,
                    str: experiment.timeRanges
                        .map<String>((timeRange) {
                          final firstDate = timeRange.$1;
                          final secondDate = timeRange.$2;
                          final dateStr = dateFormatter.format(firstDate);
                          final startTimeStr = timeFormatter.format(firstDate);
                          final endTimeStr = timeFormatter.format(secondDate);
                          return "$dateStr $startTimeStr-$endTimeStr";
                        })
                        .join("\n"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
